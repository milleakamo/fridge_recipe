const axios = require("axios");

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

  const { image, type } = req.body;
  if (!image) {
    return res.status(400).json({ error: 'No image data provided' });
  }

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    return res.status(500).json({ error: 'Gemini API key not configured' });
  }

  try {
    const base64Data = image.split(',')[1] || image;
    
    let prompt = "";
    if (type === 'receipt') {
      prompt = `Analyze receipt JSON: {store, date, items: [{name, price, quantity, category, expiry_days}]}`;
    } else {
      prompt = `Analyze fridge JSON: {items: [{name, brand, quantity, category, confidence, expiry_days}]}`;
    }

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
        if (!item.expiry_days) item.expiry_days = refineExpiryDays(item.category, item.name);
        return item;
      });
    }

    return res.status(200).json(jsonData);
  } catch (error) {
    console.error("Gemini API Error:", error.response ? error.response.data : error.message);
    return res.status(500).json({ error: 'Failed to analyze image' });
  }
}
