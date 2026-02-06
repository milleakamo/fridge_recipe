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
  const model = genAI.getGenerativeModel({ 
    model: "gemini-pro"
  });

  try {
    const ingredientList = ingredients.map(i => `${i.name}(유통기한:${i.expiryDate})`).join(', ');

    const prompt = `당신은 전문 영양사이자 셰프입니다. 냉장고에 남은 재료: ${ingredientList}를 사용하여 3일간의 맞춤형 식단을 작성하세요.
    - 제공된 재료의 유통기한이 임박한 것부터 우선적으로 사용하세요.
    - 각 끼니마다 추천 메뉴와 그 메뉴를 추천하는 구체적인 이유(예: "유통기한이 2일 남은 닭가슴살 소진 필요", "가벼운 시작을 위한 채소 위주 식단")를 한국어로 작성하세요.
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

    const result = await model.generateContent(prompt);
    const response = await result.response;
    let text = response.text().trim();

    // Remove markdown code blocks if present
    if (text.startsWith('```json')) {
      text = text.replace(/^```json/, '').replace(/```$/, '').trim();
    } else if (text.startsWith('```')) {
      text = text.replace(/^```/, '').replace(/```$/, '').trim();
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
    return res.status(500).json({ 
      error: 'Failed to generate diet plan',
      details: error.message,
      stack: error.stack
    });
  }
}
