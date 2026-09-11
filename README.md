📈 PSX KSE-100 Sector Pulse Dashboard
— Risk-Adjusted Investment Intelligence

Can a sector with the highest return
actually be the worst investment?

On Pakistan's KSE-100 in 2023-2024
the answer is yes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

𝗧𝗛𝗘 𝗣𝗥𝗢𝗕𝗟𝗘𝗠

PSX market data exists as raw price
and trading tables scattered across
multiple sources.

No clean publicly available dashboard
compares KSE-100 sectors on a consistent
risk vs return basis.

Retail investors see Energy returning 70%.
They buy Energy.
They miss the 38.24% annual volatility
that comes with it.

The business question was simple:

"Which KSE-100 sectors delivered
the strongest returns RELATIVE
to the risk taken to earn them?"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

𝗧𝗛𝗘 𝗦𝗢𝗟𝗨𝗧𝗜𝗢𝗡

I built a full end-to-end analytics
pipeline from raw data collection
to interactive dashboard:

𝗗𝗮𝘁𝗮 𝗖𝗼𝗹𝗹𝗲𝗰𝘁𝗶𝗼𝗻
Scraped 2 years of daily PSX price
data for 22 companies across 5 sectors
using Python yfinance library.
PSX tickers use the .KA suffix format
(HBL.KA, OGDC.KA, LUCK.KA etc.)
This dataset did not exist anywhere —
I built it from scratch.

𝗗𝗮𝘁𝗮 𝗘𝗻𝗴𝗶𝗻𝗲𝗲𝗿𝗶𝗻𝗴
Cleaned non-trading days, zero-volume
rows, and weekend data in Python.
Calculated daily returns, 30-day
rolling volatility, and 52-week
high/low for every stock.
Aggregated to sector-level daily metrics.

𝗗𝗮𝘁𝗮 𝗠𝗼𝗱𝗲𝗹𝗶𝗻𝗴
Built a Galaxy Schema in MySQL with
two fact tables at different granularity:
one at company level and one at
sector level — sharing conformed
dimension tables for date and sector.

𝗔𝗻𝗮𝗹𝘆𝘀𝗶𝘀
Calculated Sharpe Ratio for each sector
using Pakistan's 21% T-Bill rate as
the risk-free benchmark — not the
US Federal rate that most tutorials use.
Classified every sector into an
investment quadrant: Ideal, Aggressive,
Defensive, or Avoid.

𝗩𝗶𝘀𝘂𝗮𝗹𝗶𝘇𝗮𝘁𝗶𝗼𝗡
3-page Power BI dashboard with
50 DAX measures — all filtered
to exclude non-trading days.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

𝗣𝗔𝗚𝗘 𝟭 — 𝗠𝗔𝗥𝗞𝗘𝗧 𝗢𝗩𝗘𝗥𝗩𝗜𝗘𝗪
"How is the market performing?"

→ Monthly return line chart for all
  5 sectors over 24 months
→ Sector × Month heatmap showing
  every sector's return pattern
  at a single glance
→ Annual return and volatility
  comparison bars

𝗞𝗲𝘆 𝗮𝗰𝘁𝗶𝗼𝗻 𝗳𝗿𝗼𝗺 𝗣𝗮𝗴𝗲 𝟭:

Banking July 2023 returned +24.72%
in a single month.

But volume spiked +125% in May —
two months BEFORE the price moved.

Then volume spiked +175% in July
alongside the price.

Retail investors saw the return.
Institutional investors saw the
volume signal two months earlier.

<img width="837" height="783" alt="Screenshot 2026-09-11 190913" src="https://github.com/user-attachments/assets/d8e95a70-6127-43dd-bb01-1f80a00e2997" />


𝗣𝗔𝗚𝗘 𝟮 — 𝗥𝗜𝗦𝗞-𝗥𝗘𝗧𝗨𝗥𝗡 𝗔𝗡𝗔𝗟𝗬𝗦𝗜𝗦
"Which sectors compensate for risk?"

The scatter plot puts every sector
in a volatility vs return quadrant.
Each bubble is a sector.
Bubble size shows trading volume.

𝗙𝗲𝗿𝘁𝗶𝗹𝗶𝘇𝗲𝗿 — Sharpe 2.52 ⭐
70.75% return | 28.06% volatility
Best risk-adjusted sector on PSX.
Almost identical return to Energy
but 27% less volatility.
Sits in the top-left ideal zone.

𝗕𝗮𝗻𝗸𝗶𝗻𝗴 — Sharpe 2.49 ✅
66.35% return | 26.66% volatility
Lowest volatility of all top performers.
Explosive months mixed with stable base.

𝗘𝗻𝗲𝗿𝗴𝘆 — Sharpe 1.85 ⚠️
70.86% return | 38.24% volatility
Highest raw return on PSX.
But Sharpe of 1.85 versus
Fertilizer's 2.52 shows the
extra return does not justify
the extra risk taken.

𝗖𝗲𝗺𝗲𝗻𝘁 — Sharpe 1.53 🛡️
49.57% return | 32.40% volatility
Positive risk-adjusted performance.
No standout characteristic.

𝗧𝗲𝗰𝗵𝗻𝗼𝗹𝗼𝗴𝘆 — Sharpe 0.40 ❌
15.37% return | 38.24% volatility
Pakistan T-Bill rate: 21%
Technology falls BELOW the risk-free rate.
Same volatility as Energy.
4.6x lower return than Energy.
An investor was better off in
government bonds during this period.

𝗞𝗲𝘆 𝗮𝗰𝘁𝗶𝗼𝗻 𝗳𝗿𝗼𝗺 𝗣𝗮𝗴𝗲 𝟮:
Overweight Fertilizer and Banking.
Reduce Energy to selective positions.
Zero allocation to Technology.

<img width="1116" height="841" alt="Screenshot 2026-09-11 190947" src="https://github.com/user-attachments/assets/afae8ffe-9f0b-40af-b445-492dc73f37fb" />
<img width="912" height="813" alt="Screenshot 2026-09-11 191013" src="https://github.com/user-attachments/assets/aa540c53-72bb-45ba-8f93-852002200bbe" />

𝗣𝗔𝗚𝗘 𝟯 — 𝗖𝗢𝗠𝗣𝗔𝗡𝗬 𝗗𝗘𝗘𝗣 𝗗𝗜𝗩𝗘
"Which specific stocks within a sector?"

The sector tells you which pond to fish in.
The company page tells you which fish.

Within Energy sector — same sector,
very different risk profiles:

SSGC: 52-week price range of 512%
Moved from PKR 8.19 to PKR 50.13.
Extreme single-stock risk.

OGDC: 52-week range of 163%
Same sector. Far more stable.

UBL in Banking: 52-week range 139%
Widest in Banking — strongest momentum.

LUCK in Cement: 52-week range 85%
Most stable large-cap in analysis.

𝗞𝗲𝘆 𝗮𝗰𝘁𝗶𝗼𝗻 𝗳𝗿𝗼𝗺 𝗣𝗮𝗴𝗲 𝟯:
Energy exposure → concentrate in OGDC
and PPL not SSGC.
Banking exposure → UBL for momentum
or HBL for stability.

<img width="818" height="777" alt="Screenshot 2026-09-11 191030" src="https://github.com/user-attachments/assets/0212176a-4ea0-4ffc-b13f-ab4a104949e0" />
<img width="862" height="752" alt="Screenshot 2026-09-11 191042" src="https://github.com/user-attachments/assets/884228c2-a995-4872-adcf-4dbeb784cfd0" />


𝗧𝗛𝗘 𝗠𝗔𝗜𝗡 𝗜𝗡𝗦𝗜𝗚𝗛𝗧

Highest return ≠ best investment.

Energy produced the highest raw return
at 70.86%.

Fertilizer produced a better investment
at 70.75% return — because it delivered
nearly the same reward with
significantly less risk.

This is what the Sharpe Ratio measures:
how much return you earn per unit
of risk you accept.

On PSX in 2023-2024 no sector offered
a safe low-volatility option.
Every sector was AGGRESSIVE or AVOID.

In that environment the only question
that matters is:
which aggressive sector compensates
you best for the risk you must take?

The data answered: Fertilizer.
Then Banking.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

𝗧𝗘𝗖𝗛𝗡𝗢𝗟𝗢𝗚𝗬 𝗦𝗧𝗔𝗖𝗞

Data Collection →
  Python + yfinance
  (scraped PSX .KA tickers directly)

Data Cleaning & Engineering →
  Python + Pandas + Numpy

Data Modeling →
  MySQL Galaxy Schema
  (2 fact tables + 3 dimension tables)

Financial Analysis →
  Sharpe Ratio | Volatility | 52W Range
  Investment Quadrant Classification

Visualization →
  Power BI | 3 pages | 50 DAX measures

Stakeholder Report →
  Excel Sector Scorecard

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🗄️ 𝗗𝗔𝗧𝗔 𝗠𝗢𝗗𝗘𝗟

The project uses a Galaxy Schema to manage data at different levels of granularity.

<img width="1516" height="791" alt="Screenshot 2026-09-11 191057" src="https://github.com/user-attachments/assets/87cee30f-91bd-45f3-ac3a-71f245a3eef8" />



⚠️ 𝗗𝗜𝗦𝗖𝗟𝗔𝗜𝗠𝗘𝗥

This project is created for educational and analytical purposes only.

It does not provide financial advice, individual stock recommendations, portfolio allocation advice, or buy/sell signals.

The analysis is based on selected companies and historical data from 2023–2024.

Historical performance does not guarantee future results.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👨‍💻 𝗔𝗨𝗧𝗛𝗢𝗥

Muhammad Zohaib Khan

BS Software Engineering — COMSATS University Islamabad

Focus Areas

Data Analytics · Data Science · AI/ML · Business Intelligence
