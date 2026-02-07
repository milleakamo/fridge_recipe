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
    
    const prompt = `당신은 가재컴퍼니의 냉장고 관리 앱 데이터 추출 엔진입니다.
    제공된 영수증 이미지에서 다음 규칙에 따라 JSON 데이터를 추출하세요:

    1. ROI 필터링 규칙 (Toss Style):
       - Whitelist (포함): 농산물, 수산물, 축산물, 가공식품, 음료, 소스류, 유제품.
       - Blacklist (제외): 주류, 담배, 종량제 봉투, 주방용품(수세미 등), 욕실용품, 문구류, 잡화.
    2. 품목명 정제: 표준 식재료 명칭으로 정제하세요 (예: '무농약 콩나물 300g' -> '콩나물').
    3. ROI 계산: 'total_estimated_savings'는 전체 식품 구매액의 약 15%를 식재료 관리 효율화로 아낄 수 있는 금액으로 추정하여 계산하세요.

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
          "expiry_days": 7,
          "saving_tip": "이 재료를 활용한 절약 팁 (예: '냉동 보관 시 2주 더 신선해요!')"
        }
      ]
    }
    - 'non_food_items_count'에는 제외된 비식품 항목의 총 개수를 기록하세요.
    - 'expiry_days'는 식약처 데이터를 기반으로 추정된 보관 가능 일수(숫자)를 입력하세요.`;

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
