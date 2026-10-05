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

  console.log('\n--- 3. Testing Gemini What-If Analysis (Day & Week Horizon) ---');
  try {
    const whatIfDay = await GeminiService.analyzeWhatIfScenario({
      symbol: 'RELIANCE',
      companyName: 'Reliance Industries Ltd',
      currentPrice: 2945.5,
      scenario: 'Blockbuster order win of ₹5,000 Cr announced in morning trade',
      timeHorizon: '1 Day',
    });
    console.log('1-Day What-If Result:', {
      sentiment: whatIfDay.sentiment,
      probability: whatIfDay.probability,
      baseTarget: whatIfDay.projectedPrice.base,
      changePercent: whatIfDay.projectedChangePercent + '%',
      summary: whatIfDay.executiveSummary,
    });

    const whatIfWeek = await GeminiService.analyzeWhatIfScenario({
      symbol: 'RELIANCE',
      companyName: 'Reliance Industries Ltd',
      currentPrice: 2945.5,
      scenario: 'Weekly earnings surge with margin expansion guidance',
      timeHorizon: '1 Week',
    });
    console.log('1-Week What-If Result:', {
      sentiment: whatIfWeek.sentiment,
      probability: whatIfWeek.probability,
      baseTarget: whatIfWeek.projectedPrice.base,
      changePercent: whatIfWeek.projectedChangePercent + '%',
      summary: whatIfWeek.executiveSummary,
    });
  } catch (e) {
    console.error('GeminiService error:', e);
  }

  console.log('\n--- 4. Testing MarketService 1D & 1W Chart Data ---');
  try {
    const { MarketService } = await import('../services/market.service');
    const hist1D = await MarketService.getHistoricalPrices('RELIANCE', '1D');
    console.log('1D History points:', hist1D.length, 'First:', hist1D[0]?.close, 'Last:', hist1D[hist1D.length - 1]?.close);

    const hist1W = await MarketService.getHistoricalPrices('RELIANCE', '1W');
    console.log('1W History points:', hist1W.length, 'First:', hist1W[0]?.close, 'Last:', hist1W[hist1W.length - 1]?.close);
  } catch (e) {
    console.error('MarketService error:', e);
  }
}

test();
