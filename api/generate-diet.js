// Vercel Serverless Function for Gemini Diet Plan Generation
// Path: fridge_recipe/api/generate-diet.js

const axios = require("axios");

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

  try {
    const ingredientList = ingredients.map(i => `${i.name}(유통기한:${i.expiryDate})`).join(', ');

    const prompt = `당신은 전문 영양사이자 셰프입니다. 냉장고에 남은 재료: ${ingredientList}를 사용하여 3일간의 맞춤형 식단을 작성하세요.
    - 제공된 재료의 유통기한이 임박한 것부터 우선적으로 사용하세요.
    - 절대 추가 식재료를 구매하지 않는(Zero-Purchase) 레시피를 제안하세요.
    - JSON 외에 어떤 텍스트도 포함하지 마세요.
    - 반드시 다음 JSON 형식을 엄격히 지켜 응답하세요:
    {
      "diet_plan": [
        {
          "day": "1일차",
          "meals": {
            "breakfast": {"menu": "메뉴명", "reason": "추천 이유"},
            "lunch": {"menu": "메뉴명", "reason": "추천 이유"},
            "dinner": {"menu": "메뉴명", "reason": "추천 이유"}
          }
        },
        {
          "day": "2일차",
          "meals": {
            "breakfast": {"menu": "메뉴명", "reason": "추천 이유"},
            "lunch": {"menu": "메뉴명", "reason": "추천 이유"},
            "dinner": {"menu": "메뉴명", "reason": "추천 이유"}
          }
        },
        {
          "day": "3일차",
          "meals": {
            "breakfast": {"menu": "메뉴명", "reason": "추천 이유"},
            "lunch": {"menu": "메뉴명", "reason": "추천 이유"},
            "dinner": {"menu": "메뉴명", "reason": "추천 이유"}
          }
        }
      ]
    }`;

    // Directly call the Google AI API using axios (Stable v1 endpoint)
    const response = await axios.post(
      `https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=${apiKey}`,
      {
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: {
          responseMimeType: "application/json"
        }
      }
    );

    let text = response.data.candidates[0].content.parts[0].text.trim();

    // Remove markdown code blocks if present
    if (text.startsWith('```json')) {
      text = text.replace(/^```json/, '').replace(/```$/, '').trim();
    } else if (text.startsWith('```')) {
      text = text.replace(/^```/, '').replace(/```$/, '').trim();
    }

    const jsonData = JSON.parse(text);
    return res.status(200).json(jsonData);

  } catch (error) {
    console.error("Gemini API Error:", error.response ? error.response.data : error.message);
    return res.status(500).json({ 
      error: 'Failed to generate diet plan',
      details: error.response ? error.response.data : error.message
    });
  }
}
