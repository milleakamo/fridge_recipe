// Vercel Serverless Function for Gemini Diet Plan Generation (7-Day)
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

    const prompt = `당신은 전문 영양사이자 셰프입니다. 냉장고에 남은 재료: ${ingredientList}를 사용하여 7일간의 완벽한 맞춤형 식단을 작성하세요.
    - 재료의 유통기한이 임박한 것부터 우선적으로 사용하세요.
    - 절대 추가 식재료를 구매하지 않는(Zero-Purchase) 레시피를 제안하세요.
    - 요일별로 메뉴를 다양하게 구성하여 재미를 더하세요.
    - 식사 시간은 아침 08:00, 점심 12:45, 저녁 18:30으로 지정하세요.
    - 식사당 3~5개의 '추천 쇼핑 목록'을 제안하여 식재료 소전률을 100%로 극대화하세요.
    - 전체 7일 치 합을 기준으로 Bronze(0~3개완료), Silver(4~5개완료), Gold(6~7개완료) 등급을 결정하여 응답에 포함하세요.
    - JSON 외에 어떤 텍스트도 포함하지 마세요.
    - 반드시 다음 JSON 형식을 엄격히 지켜 응답하세요:
    {
      "diet_plan": [
        {
          "day": "1일차",
          "meal_time": "아침 08:00, 점심 12:45, 저녁 18:30",
          "meals": {
            "breakfast": {"menu": "메뉴명", "reason": "추천 이유"},
            "lunch": {"menu": "메뉴명", "reason": "추천 이유"},
            "dinner": {"menu": "메뉴명", "reason": "추천 이유"}
          },
          "recommended_shopping": [
            {"item": "쇼핑 항목명", "market": "쿠팡/이마트/컬리", "approx_price": "알패스"}
          ]
        },
        {
          "day": "2일차",
          "meal_time": "아침 08:00, 점심 12:45, 저녁 18:30",
          "meals": {
            "breakfast": {"menu": "메뉴명", "reason": "추천 이유"},
            "lunch": {"menu": "메뉴명", "reason": "추천 이유"},
            "dinner": {"menu": "메뉴명", "reason": "추천 이유"}
          },
          "recommended_shopping": [
            {"item": "쇼핑 항목명", "market": "쿠팡/이마트/컬리", "approx_price": "알패스"}
          ]
        },
        {
          "day": "3일차",
          "meal_time": "아침 08:00, 점심 12:45, 저녁 18:30",
          "meals": {
            "breakfast": {"menu": "메뉴명", "reason": "추천 이유"},
            "lunch": {"menu": "메뉴명", "reason": "추천 이유"},
            "dinner": {"menu": "메뉴명", "reason": "추천 이유"}
          },
          "recommended_shopping": [
            {"item": "쇼핑 항목명", "market": "쿠팡/이마트/컬리", "approx_price": "알패스"}
          ]
        },
        {
          "day": "4일차",
          "meal_time": "아침 08:00, 점심 12:45, 저녁 18:30",
          "meals": {
            "breakfast": {"menu": "메뉴명", "reason": "추천 이유"},
            "lunch": {"menu": "메뉴명", "reason": "추천 이유"},
            "dinner": {"menu": "메뉴명", "reason": "추천 이유"}
          },
          "recommended_shopping": [
            {"item": "쇼핑 항목명", "market": "쿠팡/이마트/컬리", "approx_price": "알패스"}
          ]
        },
        {
          "day": "5일차",
          "meal_time": "아침 08:00, 점심 12:45, 저녁 18:30",
          "meals": {
            "breakfast": {"menu": "메뉴명", "reason": "추천 이유"},
            "lunch": {"menu": "메뉴명", "reason": "추천 이유"},
            "dinner": {"menu": "메뉴명", "reason": "추천 이유"}
          },
          "recommended_shopping": [
            {"item": "쇼핑 항목명", "market": "쿠팡/이마트/컬리", "approx_price": "알패스"}
          ]
        },
        {
          "day": "6일차",
          "meal_time": "아침 08:00, 점심 12:45, 저녁 18:30",
          "meals": {
            "breakfast": {"menu": "메뉴명", "reason": "추천 이유"},
            "lunch": {"menu": "메뉴명", "reason": "추천 이유"},
            "dinner": {"menu": "메뉴명", "reason": "추천 이유"}
          },
          "recommended_shopping": [
            {"item": "쇼핑 항목명", "market": "쿠팡/이마트/컬리", "approx_price": "알패스"}
          ]
        },
        {
          "day": "7일차",
          "meal_time": "아침 08:00, 점심 12:45, 저녁 18:30",
          "meals": {
            "breakfast": {"menu": "메뉴명", "reason": "추천 이유"},
            "lunch": {"menu": "메뉴명", "reason": "추천 이유"},
            "dinner": {"menu": "메뉴명", "reason": "추천 이유"}
          },
          "recommended_shopping": [
            {"item": "쇼핑 항목명", "market": "쿠팡/이마트/컬리", "approx_price": "알패스"}
          ]
        }
      ],
      "weekly_stats": {
        "total_savings": "₩62,100",
        "success_rate": "92%",
        "tier": "Bronze"
      }
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