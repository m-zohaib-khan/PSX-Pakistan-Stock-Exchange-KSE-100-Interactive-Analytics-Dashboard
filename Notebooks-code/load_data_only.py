from pathlib import Path
from urllib.parse import quote_plus

import pandas as pd
from sqlalchemy import create_engine

# ─── 1. DATABASE CONFIGURATION ──────────────────────────────────────────────
DB_USER = "root"
DB_PASS = "zohaib123@#$"  # Password URL-encoded
DB_HOST = "localhost"
DB_PORT = "3306"
DB_NAME = "psx_dashboard"

db_url = f"mysql+pymysql://{DB_USER}:{quote_plus(DB_PASS)}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
engine = create_engine(db_url)

print("🚀 Starting ETL process across all 3 source datasets...")

# ─── 2. READ SOURCE CSV FILES ───────────────────────────────────────────────
print("⏳ Reading CSV files...")
data_dir = Path(__file__).resolve().parent

# Reads 'psx_stock_clean.csv' (or falls back to 'psx_raw.csv')
stock_file = data_dir / 'psx_stock_clean.csv'
if not stock_file.exists():
    stock_file = data_dir / 'psx_raw.csv'

raw_df = pd.read_csv(stock_file)
sector_daily_df = pd.read_csv(data_dir / 'psx_sector_daily.csv')
sector_summary_df = pd.read_csv(data_dir / 'psx_sector_summary.csv')

raw_df['date'] = pd.to_datetime(raw_df['date'])
sector_daily_df['date'] = pd.to_datetime(sector_daily_df['date'])

# ─── 3. POPULATE DIMENSION 1: dim_sector ────────────────────────────────────
print("⏳ Loading dim_sector...")
all_sectors = pd.concat([
    raw_df['sector'],
    sector_daily_df['sector'],
    sector_summary_df['sector']
]).dropna().unique()

dim_sector = pd.DataFrame({'sector_name': sorted(all_sectors)})
dim_sector.to_sql('dim_sector', con=engine, if_exists='append', index=False)
print(f"  ✅ Loaded {len(dim_sector)} rows into 'dim_sector'")

# Retrieve assigned auto-increment sector_id keys
sector_lookup = pd.read_sql("SELECT sector_id, sector_name FROM dim_sector", engine)

# ─── 4. POPULATE DIMENSION 2: dim_company ───────────────────────────────────
print("⏳ Loading dim_company...")
dim_company = raw_df[['ticker', 'company', 'sector']].drop_duplicates().copy()
dim_company.rename(columns={'company': 'company_name', 'sector': 'sector_name'}, inplace=True)

# Map foreign key sector_id
dim_company = dim_company.merge(sector_lookup, on='sector_name')
dim_company = dim_company[['sector_id', 'ticker', 'company_name']]

dim_company.to_sql('dim_company', con=engine, if_exists='append', index=False)
print(f"  ✅ Loaded {len(dim_company)} rows into 'dim_company'")

# Retrieve assigned auto-increment company_id keys
company_lookup = pd.read_sql("SELECT company_id, ticker FROM dim_company", engine)

# ─── 5. POPULATE DIMENSION 3: dim_date ──────────────────────────────────────
print("⏳ Loading dim_date...")
all_dates = pd.concat([raw_df['date'], sector_daily_df['date']]).drop_duplicates().sort_values()

dim_date = pd.DataFrame({'date': all_dates})
dim_date['year'] = dim_date['date'].dt.year
dim_date['month'] = dim_date['date'].dt.month
dim_date['quarter'] = dim_date['date'].dt.quarter
dim_date['month_name'] = dim_date['date'].dt.strftime('%b')
dim_date['year_month_str'] = dim_date['date'].dt.strftime('%Y-%m')  # Renamed to match MySQL schema

dim_date.to_sql('dim_date', con=engine, if_exists='append', index=False)
print(f"  ✅ Loaded {len(dim_date)} rows into 'dim_date'")

# Retrieve assigned auto-increment date_id keys
date_lookup = pd.read_sql("SELECT date_id, date FROM dim_date", engine)
date_lookup['date'] = pd.to_datetime(date_lookup['date'])

# ─── 6. POPULATE FACT 1: fact_stock_prices ─────────────────────────────────
print("⏳ Loading fact_stock_prices...")
fact_stock = raw_df.sort_values(by=['ticker', 'date']).copy()

# Calculate daily percentage return
fact_stock['daily_return'] = fact_stock.groupby('ticker')['close'].pct_change()

# Map foreign keys
fact_stock = fact_stock.merge(company_lookup, on='ticker')
fact_stock = fact_stock.merge(date_lookup, on='date')

fact_stock.rename(columns={
    'open': 'open_price',
    'high': 'high_price',
    'low': 'low_price',
    'close': 'close_price'
}, inplace=True)

fact_stock_final = fact_stock[[
    'company_id', 'date_id', 'open_price', 'high_price', 
    'low_price', 'close_price', 'volume', 'daily_return'
]].copy()

# Round numbers to match DECIMAL definitions
price_cols = ['open_price', 'high_price', 'low_price', 'close_price']
fact_stock_final[price_cols] = fact_stock_final[price_cols].round(2)
fact_stock_final['daily_return'] = fact_stock_final['daily_return'].round(4)

# Convert NaNs to None for MySQL NULL compatibility
fact_stock_final = fact_stock_final.where(pd.notnull(fact_stock_final), None)

fact_stock_final.to_sql('fact_stock_prices', con=engine, if_exists='append', index=False)
print(f"  ✅ Loaded {len(fact_stock_final)} rows into 'fact_stock_prices'")

# ─── 7. POPULATE FACT 2: fact_sector_daily ─────────────────────────────────
print("⏳ Loading fact_sector_daily...")
fact_sec = sector_daily_df.copy()
fact_sec.rename(columns={'sector': 'sector_name'}, inplace=True)

# Map foreign keys
fact_sec = fact_sec.merge(sector_lookup, on='sector_name')
fact_sec = fact_sec.merge(date_lookup, on='date')

fact_sec_final = fact_sec[[
    'sector_id', 'date_id', 'avg_close', 'avg_daily_return', 
    'total_volume', 'avg_volatility', 'stock_count'
]].copy()

# Round numbers to match DECIMAL definitions
fact_sec_final['avg_close'] = fact_sec_final['avg_close'].round(2)
fact_sec_final[['avg_daily_return', 'avg_volatility']] = fact_sec_final[['avg_daily_return', 'avg_volatility']].round(4)

# Convert NaNs to None for MySQL NULL compatibility
fact_sec_final = fact_sec_final.where(pd.notnull(fact_sec_final), None)

fact_sec_final.to_sql('fact_sector_daily', con=engine, if_exists='append', index=False)
print(f"  ✅ Loaded {len(fact_sec_final)} rows into 'fact_sector_daily'")

print("\n🎉 ETL process completed successfully! Check MySQL Workbench to see populated data.")