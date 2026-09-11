import yfinance as yf
import pandas as pd
import time
import os

# Ensure directory exists
os.makedirs('data/raw', exist_ok=True)

# ─── KSE-100 Companies by Sector ────────────────────
tickers = {
    'Banking': ['HBL.KA', 'UBL.KA', 'MCB.KA', 'ABL.KA', 'BAFL.KA'],
    'Energy': ['PSO.KA', 'OGDC.KA', 'PPL.KA', 'SNGP.KA', 'SSGC.KA'],
    'Fertilizer': ['ENGRO.KA', 'FFBL.KA', 'FFC.KA', 'FATIMA.KA'],
    'Cement': ['LUCK.KA', 'DGKC.KA', 'MLCF.KA', 'CHCC.KA'],
    'Technology': ['TRG.KA', 'SYS.KA', 'NETSOL.KA', 'TELE.KA']
}

# ─── Download Price Data ─────────────────────────────
all_data = []

for sector, symbols in tickers.items():
    print(f"\nDownloading {sector} sector...")
    for symbol in symbols:
        try:
            df = yf.download(
                symbol,
                start='2023-01-01',
                end='2024-12-31',
                progress=False
            )
            if df.empty:
                print(f"  ⚠️ No data for {symbol}")
                continue
            
            df = df.reset_index()
            
            # Flatten multi-index columns if returned by yfinance
            if isinstance(df.columns, pd.MultiIndex):
                df.columns = [col[0] for col in df.columns]
                
            df['ticker'] = symbol
            df['sector'] = sector
            df['company'] = symbol.replace('.KA', '')
            
            # Rename columns to lowercase standard format
            df.columns = [str(c).lower().replace(' ', '_') for c in df.columns]
            all_data.append(df)
            print(f"  ✅ {symbol}: {len(df)} rows")
            time.sleep(0.5)
        except Exception as e:
            print(f"  ❌ Error for {symbol}: {e}")

# Combine and save raw data
if all_data:
    psx_raw = pd.concat(all_data, ignore_index=True)
    print(f"\nTotal rows collected: {len(psx_raw)}")
    print(psx_raw.head())

    psx_raw.to_csv('data/raw/psx_raw.csv', index=False)
    print("\n✅ Raw data successfully saved to 'data/raw/psx_raw.csv'")
else:
    print("\n❌ No data collected. Please check internet connection or ticker formats.")
