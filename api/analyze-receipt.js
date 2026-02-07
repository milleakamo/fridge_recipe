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
    
    const prompt = `당신은 토스(Toss) 스타일의 직관적이고 효율적인 UX를 지향하는 가재컴퍼니의 영수증 분석 엔진입니다. 
    영수증 이미지에서 식재료 정보를 정밀하게 추출하고, 사용자의 ROI를 극대화하는 JSON 데이터를 생성하세요.

    GAJAE ROI FILTER RULE:
    1. 식재료(식품)만 추출: 과일, 채소, 육류, 유제품, 가공식품, 음료, 조미료 등 먹을 수 있는 것만 포함하세요.
    2. 비식품 엄격 제외: 종량제 봉투, 세제, 키친타월, 건전지, 비누, 샴푸, 의류, 배달비, 서비스 요금, 담배 등은 절대 'items'에 넣지 마세요.
    3. 비식품 카운트: 제외된 비식품 항목의 총 개수를 'non_food_items_count'에 기록하세요.
    4. 명칭 정제: '무농약 콩나물 300g' -> '콩나물'과 같이 표준 명칭으로 정제하세요.

    The output must strictly follow this JSON schema: 
    {
      "store": "상점 이름",
      "date": "YYYY-MM-DD",
      "total_estimated_savings": 2400,
      "non_food_items_count": 0,
      "items": [
        {
          "name": "정제된 품목명",
          "price": 12000,
          "quantity": 1,
          "category": "Meat|Dairy|Vegetable|Fruit|Seafood|Frozen|Processed|Beverage|Condiment|Grain",
          "is_food": true,
          "is_edible": true,
          "saving_tip": "이 재료를 활용한 절약 팁 (예: '냉동 보관 시 2주 더 신선해요!')"
        }
      ]
    }
    - 'total_estimated_savings'는 전체 식품 구매액의 약 15%를 식재료 관리 효율화로 아낄 수 있는 금액으로 추정하여 계산하세요.
    - 'saving_tip'은 사용자가 즉각적인 이득을 느낄 수 있도록 친절하고 구체적으로 작성하세요.`;

    const response = await axios.post(
      `https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=${apiKey}`,
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
