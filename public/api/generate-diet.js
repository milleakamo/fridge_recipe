// Vercel Serverless Function for Gemini Diet Plan Generation
// Path: fridge_recipe/api/generate-diet.js

const { GoogleGenerativeAI } = require("@google/generative-ai");

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }

  const { ingredients } = req.body;

  if (!ingredients || !Array.isArray(ingredients) || ingredients.length === 0) {
    return res.status(400).json({ error: 'No ingredients provided' });
  }

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    return res.status(500).json({ error: 'Gemini API key not configured' });
  }

  const genAI = new GoogleGenerativeAI(apiKey);
  const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

  try {
    const ingredientList = ingredients.map(i => i.name).join(', ');

    const prompt = `You are an expert nutritionist and chef. Based on the following ingredients available in a fridge: ${ingredientList}, create a balanced and healthy 3-day diet plan.
    
    For each day, provide suggestions for breakfast, lunch, and dinner.
    - Prioritize using the provided ingredients.
    - Suggest simple and easy-to-cook meals.
    - For each meal, provide a short "reason" why it's a good choice (e.g., "Uses up the chicken before it expires", "A light and healthy start to the day").
    - The response should be in Korean.
    
    Return ONLY a JSON object in this format:
    {
      "diet_plan": [
        {
          "day": "Day 1",
          "meals": {
            "breakfast": {"menu": "Menu Name", "reason": "Reason"},
            "lunch": {"menu": "Menu Name", "reason": "Reason"},
            "dinner": {"menu": "Menu Name", "reason": "Reason"}
          }
        },
        {
          "day": "Day 2",
          "meals": {
            "breakfast": {"menu": "Menu Name", "reason": "Reason"},
            "lunch": {"menu": "Menu Name", "reason": "Reason"},
            "dinner": {"menu": "Menu Name", "reason": "Reason"}
          }
        },
        {
          "day": "Day 3",
          "meals": {
            "breakfast": {"menu": "Menu Name", "reason": "Reason"},
            "lunch": {"menu": "Menu Name", "reason": "Reason"},
            "dinner": {"menu": "Menu Name", "reason": "Reason"}
          }
        }
      ]
    }`;

    const result = await model.generateContent(prompt);
    const response = await result.response;
    let text = response.text();

    const jsonRegex = /\{[\s\S]*\}/;
    const match = text.match(jsonRegex);
    
    if (match) {
      text = match[0];
    }

    try {
      const jsonData = JSON.parse(text);
      return res.status(200).json(jsonData);
    } catch (e) {
      console.error("JSON Parse Error. Raw Text:", text);
      return res.status(200).json({ 
        error: 'JSON parse failed',
        raw_text: text,
        message: 'The AI response was not in a valid JSON format. Please try again.'
      });
    }
  } catch (error) {
    console.error("Gemini API Error:", error);
    return res.status(500).json({ error: 'Failed to generate diet plan' });
  }
}
