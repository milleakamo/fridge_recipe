import axios from "axios";

// Master Data for Shelf Life
const SHELF_LIFE_MASTER = {
  "Meat": { default: 3, variants: { "Beef": 5, "Pork": 3, "Chicken": 2 } },
  "Dairy": { default: 10, variants: { "Milk": 10, "Cheese": 30, "Egg": 30, "Tofu": 5 } },
  "Vegetable": { default: 7, variants: { "Onion": 30, "Potato": 30, "Green Onion": 7, "Carrot": 14 } },
  "Fruit": { default: 7 },
  "Seafood": { default: 2 },
  "Frozen": { default: 90 },
  "Processed": { default: 14 },
  "Beverage": { default: 30 },
  "Condiment": { default: 180 },
  "Grain": { default: 365 }
};

function refineExpiryDays(category, itemName) {
  const master = SHELF_LIFE_MASTER[category] || { default: 7 };
  if (master.variants) {
    for (const [key, value] of Object.entries(master.variants)) {
      if (itemName.toLowerCase().includes(key.toLowerCase())) {
        return value;
      }
    }
  }
  return master.default;
}

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  const { image } = req.body;
  if (!image) {
    return res.status(400).json({ error: 'No image data provided' });
  }

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    return res.status(500).json({ error: 'Gemini API key not configured' });
  }

  try {
    const base64Data = image.split(',')[1] || image;
    
    const prompt = `Analyze the receipt image and extract items in a structured JSON format. 
    
    GAJAE FILTER RULE: 
    - You MUST identify and separate food/edible items from non-food items.
    - Food items: Fruits, vegetables, meats, dairy, snacks, drinks, seasonings, etc.
    - Non-food items (TO BE FILTERED): Trash bags, detergents, paper towels, batteries, soap, shampoo, clothing, delivery fees, service charges, tobacco, etc.
    
    The output must strictly follow this JSON schema: 
    {
      "store": "Store Name",
      "date": "YYYY-MM-DD",
      "total_estimated_savings": 2400,
      "non_food_items_count": 0,
      "items": [
        {
          "name": "Standardized Item Name",
          "price": 12000,
          "quantity": 1,
          "category": "Meat|Dairy|Vegetable|Fruit|Seafood|Frozen|Processed|Beverage|Condiment|Grain",
          "is_food": true,
          "is_edible": true,
          "saving_tip": "e.g., '아삭할 때 샐러드로 드세요'"
        }
      ]
    }
    1. Only include items with is_food: true in the "items" list.
    2. Increment "non_food_items_count" for each non-food item found.
    3. Calculate "total_estimated_savings" based on market trends (estimate 5-10% of total if not clear).
    4. Ignore non-item entries (points, changes, taxes).`;

    const response = await axios.post(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`,
      {
        contents: [{
          parts: [
            { text: prompt },
            { inlineData: { mimeType: "image/jpeg", data: base64Data } }
          ]
        }],
        generationConfig: { responseMimeType: "application/json" }
      }
    );

    let text = response.data.candidates[0].content.parts[0].text;
    const jsonData = JSON.parse(text);

    if (jsonData.items) {
      jsonData.items = jsonData.items.map(item => {
        if (!item.expiry_days || item.expiry_days === 0) {
          item.expiry_days = refineExpiryDays(item.category, item.name);
        }
        return item;
      });
    }

    return res.status(200).json(jsonData);
  } catch (error) {
    console.error("Gemini Receipt API Error:", error.response ? error.response.data : error.message);
    return res.status(500).json({ error: 'Failed to analyze receipt' });
  }
}
