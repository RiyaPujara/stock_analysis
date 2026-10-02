import dotenv from 'dotenv';
dotenv.config();

import { IndianStockService } from '../services/indianStock.service';
import { GeminiService } from '../services/gemini.service';

async function test() {
  console.log('--- 1. Testing IndianStockService ---');
  try {
    const stock = await IndianStockService.getRealtimeStock('RELIANCE');
    console.log('Stock Quote:', {
      symbol: stock.symbol,
      company: stock.companyName,
      price: stock.currentPrice,
      changePercent: stock.changePercent,
      source: stock.source,
    });
  } catch (e) {
    console.error('IndianStockService error:', e);
  }

  console.log('\n--- 2. Testing Realtime Indices ---');
  try {
    const indices = await IndianStockService.getRealtimeIndices();
    console.log('Indices count:', indices.length, indices.map((i: any) => `${i.name}: ${i.currentValue}`));
  } catch (e) {
    console.error('Indices error:', e);
  }

  console.log('\n--- 3. Testing Gemini What-If Analysis ---');
  try {
    const whatIf = await GeminiService.analyzeWhatIfScenario({
      symbol: 'RELIANCE',
      companyName: 'Reliance Industries Ltd',
      currentPrice: 2945.5,
      scenario: 'Q3 net profit increases by 25% with telecom ARPU growth to 200 INR',
    });
    console.log('What-If Result:', {
      sentiment: whatIf.sentiment,
      probability: whatIf.probability,
      baseTarget: whatIf.projectedPrice.base,
      confidence: whatIf.confidenceScore,
      action: whatIf.actionPlan.substring(0, 80) + '...',
    });
  } catch (e) {
    console.error('GeminiService error:', e);
  }
}

test();
