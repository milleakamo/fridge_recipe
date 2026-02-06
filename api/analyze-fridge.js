// Vercel Serverless Function for Gemini Vision API integration
// Path: fridge_recipe/api/analyze-fridge.js

const { GoogleGenerativeAI } = require("@google/generative-ai");

// Master Data for Shelf Life (from BACKEND_A_DATA_LOG.md)
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
  
  // Check for specific item match in variants
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

  const { image } = req.body; // Expecting base64 string
  
  if (!image) {
    return res.status(400).json({ error: 'No image data provided' });
  }

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    return res.status(500).json({ error: 'Gemini API key not configured' });
  }

  const genAI = new GoogleGenerativeAI(apiKey);
  const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

  try {
    // Convert base64 to parts for Gemini API
    const imageParts = [
      {
        inlineData: {
          data: image.split(',')[1] || image,
          mimeType: "image/jpeg",
        },
      },
    ];

    const { type } = req.body; // 'fridge' or 'receipt'
    
    let prompt = "";
    if (type === 'receipt') {
      prompt = `You are an expert OCR and grocery audit assistant. Analyze the receipt image.
      1. Extract the Store Name and Purchase Date (YYYY-MM-DD). If no date is found, use '2026-02-06'.
      2. List all purchased food and grocery items. IGNORE non-food items (e.g., plastic bags, batteries, kitchenware).
      3. For each item:
         - Clean the name: Remove internal codes, price markers, or abbreviations. Use the full product name.
         - Price: Numeric value only.
         - Quantity: Integer count.
         - Category: Choose from [Meat, Dairy, Vegetable, Fruit, Snack, Beverage, Condiment, Grain, Frozen, Processed, Other].
         - Expiry Days: Estimated shelf life for this specific item (integer).
      Return ONLY a JSON object in this format: 
      {
        "store": "Store Name",
        "date": "YYYY-MM-DD",
        "items": [
          {"name": "Product Name", "price": 0, "quantity": 1, "category": "Category", "expiry_days": 7}
        ]
      }`;
    } else {
      prompt = `You are an expert culinary assistant specialized in refrigerator inventory management. 
      Analyze the provided image of a refrigerator's interior and identify all food items and ingredients.
      1. Identify individual items with high precision (e.g., 'Greek Yogurt' instead of 'Yogurt').
      2. Identify brand names if clearly visible.
      3. Estimate the current quantity or fullness (e.g., '1 Bottle', 'Half-full', 'Large Pack').
      4. Assign a category: [Meat, Dairy, Vegetable, Fruit, Snack, Beverage, Condiment, Grain, Frozen, Processed, Other].
      5. Confidence: 0.0 to 1.0 based on how clearly the item is identified.
      6. Expiry Days: Estimated remaining shelf life based on visual freshness and item type (integer).
      
      Return ONLY a JSON object in this format:
      {
        "items": [
          {
            "name": "Item Name", 
            "brand": "Brand Name or null", 
            "quantity": "Quantity info", 
            "category": "Category", 
            "confidence": 0.95, 
            "expiry_days": 5
          }
        ]
      }`;
    }

    const result = await model.generateContent([prompt, ...imageParts]);
    const response = await result.response;
    let text = response.text();

    // Enhanced JSON Extraction Logic
    const jsonRegex = /\{[\s\S]*\}/;
    const match = text.match(jsonRegex);
    
    if (match) {
      text = match[0];
    }

    try {
      const jsonData = JSON.parse(text);
      
      // Data Refinement Logic (Server Slave 1 Task)
      if (jsonData.items && Array.isArray(jsonData.items)) {
        jsonData.items = jsonData.items.map(item => {
          // If Gemini provided an expiry_days, use it as a hint, 
          // but we can normalize it using our master data if needed.
          // For now, let's prioritize Gemini's visual judgment but fallback to master data if it's missing or suspicious.
          if (!item.expiry_days || item.expiry_days <= 0) {
            item.expiry_days = refineExpiryDays(item.category, item.name);
          }
          return item;
        });
      }

      // Ensure date is present for receipt
      if (type === 'receipt' && !jsonData.date) {
        jsonData.date = '2026-02-06';
      }
      return res.status(200).json(jsonData);
    } catch (e) {
      console.error("JSON Parse Error. Raw Text:", text);
      return res.status(200).json({ 
        error: 'JSON parse failed',
        raw_text: text,
        message: 'The AI response was not in a valid JSON format. Please try again with a clearer photo.'
      });
    }
  } catch (error) {
    console.error("Gemini API Error:", error);
    return res.status(500).json({ error: 'Failed to analyze image' });
  }
}
