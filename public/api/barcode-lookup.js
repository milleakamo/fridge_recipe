// Vercel Serverless Function for Barcode Lookup
// Path: fridge_recipe/api/barcode-lookup.js

const axios = require('axios');

export default async function handler(req, res) {
  const { code } = req.query;

  if (!code) {
    return res.status(400).json({ error: 'Barcode is required' });
  }

  try {
    let productData = null;

    // 1. Try Korean Food Safety Info API (식품안전나라 - C005 Service)
    // C005 is optimized for Barcode lookups
    const govApiKey = process.env.KR_GOV_FOOD_API_KEY;
    if (govApiKey) {
      try {
        const govUrl = `http://openapi.foodsafetykorea.go.kr/api/${govApiKey}/C005/json/1/1/BAR_CD=${code}`;
        const govResponse = await axios.get(govUrl, { timeout: 3000 });
        const data = govResponse.data.C005;
        
        if (data && parseInt(data.total_count) > 0 && data.row) {
          const item = data.row[0];
          productData = {
            name: item.PRDLST_NM,
            manufacturer: item.BSSH_NM,
            category: item.PRDLST_DCLS_NM,
            raw_category: item.PRDLST_DCLS_NM,
            image_url: null,
            source: 'gov_kr'
          };
        }
      } catch (e) {
        console.error("Gov API Error:", e.message);
      }
    }

    // 2. Fallback to Open Food Facts (Global Database)
    if (!productData) {
      try {
        const offUrl = `https://world.openfoodfacts.org/api/v2/product/${code}.json`;
        const offResponse = await axios.get(offUrl, { timeout: 3000 });
        if (offResponse.data.status === 1) {
          const p = offResponse.data.product;
          productData = {
            name: p.product_name || p.product_name_ko || p.product_name_en || 'Unknown Product',
            manufacturer: p.brands || 'Unknown Brand',
            category: p.categories ? p.categories.split(',')[0].trim() : 'Other',
            image_url: p.image_url || p.image_front_url,
            source: 'open_food_facts'
          };
        }
      } catch (e) {
        console.error("OFF API Error:", e.message);
      }
    }

    if (productData) {
      // Normalize category and estimate expiry
      const { expiry_days, category_tag } = analyzeProductCategory(productData.category);
      productData.suggested_expiry_days = expiry_days;
      productData.normalized_category = category_tag;
      
      return res.status(200).json(productData);
    } else {
      return res.status(404).json({ 
        error: 'Product not found', 
        code,
        message: 'Could not find product in Korean Gov database or Open Food Facts.'
      });
    }

  } catch (error) {
    console.error("Barcode API Error:", error);
    return res.status(500).json({ error: 'Internal Server Error' });
  }
}

/**
 * Maps raw category strings to normalized categories and suggests expiry days.
 */
function analyzeProductCategory(category) {
  const cat = String(category).toLowerCase();
  
  const rules = [
    { keywords: ['우유', 'milk', '유제품', 'dairy', '요거트', 'yogurt', '치즈', 'cheese'], expiry: 10, tag: 'Dairy' },
    { keywords: ['채소', 'vegetable', '야채', '샐러드', 'salad', '나물'], expiry: 7, tag: 'Vegetable' },
    { keywords: ['고기', 'meat', '육류', '소고기', '돼지고기', '닭고기', '정육'], expiry: 5, tag: 'Meat' },
    { keywords: ['과일', 'fruit', '사과', '바나나', '포도'], expiry: 7, tag: 'Fruit' },
    { keywords: ['과자', 'snack', '쿠키', 'cookie', '비스킷', '캔디', '초콜릿'], expiry: 180, tag: 'Snack' },
    { keywords: ['음료', 'beverage', 'juice', 'soda', '콜라', '주스', '탄산'], expiry: 30, tag: 'Beverage' },
    { keywords: ['냉동', 'frozen', '아이스크림', '만두'], expiry: 90, tag: 'Frozen' },
    { keywords: ['가공식품', 'processed', '통조림', 'can', '즉석', '레토르트'], expiry: 365, tag: 'Processed' },
    { keywords: ['양념', 'condiment', '소스', 'sauce', '장류', '고추장', '된장', '간장'], expiry: 180, tag: 'Condiment' },
    { keywords: ['곡류', 'grain', '쌀', '밀가루', '잡곡'], expiry: 365, tag: 'Grain' },
  ];

  for (const rule of rules) {
    if (rule.keywords.some(k => cat.includes(k))) {
      return { expiry_days: rule.expiry, category_tag: rule.tag };
    }
  }

  return { expiry_days: 14, category_tag: 'Other' }; // Default 2 weeks
}
