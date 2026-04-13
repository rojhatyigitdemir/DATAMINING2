# 📈 A Time Series Analysis of Bitcoin’s Spot Price Using Polymarket Predictions
![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white)
![Data Science](https://img.shields.io/badge/Data_Science-150458?style=for-the-badge&logo=databricks&logoColor=white)
![Finance](https://img.shields.io/badge/Quantitative_Finance-005571?style=for-the-badge)

## 📌 Executive Summary
This research project examines the dynamic relationship between participant expectations in decentralized prediction markets and the actual spot price of an asset, such as Bitcoin. The study constructed a mathematical **Expected Value (EV)** time series using daily probability distributions (Dip, Reach, and Middle Zone) extracted from the “March 2026 Price Targets” contracts on Polymarket, and subsequently analyzed this series against actual spot prices using a Multiple Linear Regression model with a time.
---

## 🏛️ 1. Theoritical Framework and Literature Review
Price formation in markets revolves around information asymmetry and market efficiency. This project is built upon two fundamental theory 
1. **Wisdom of Crowds:** Surowiecki (2004), argues that the collective predictions of market participants are often more accurate than those of experts. Prediction markets (such as Polymarket) are a financial manifestation of this theory.
2. **Efficient Market Hypothesis - EMH:** ccording to the hypothesis formulated by Fama (1970), market prices instantly reflect all available information. Therefore, past price (or expectation) movements cannot be used to predict future prices.

---

## 🎯 2. Research Goals and Hypothesis 
The primary objective of the project is to measure the rate at which market expectations rationalize over time and their predictive power.

* **$H_1$:** As the time to maturity ($t \rightarrow 0$) decreases, the spread between the Expected Value (EV) in prediction markets and the actual spot price narrows (Convergence Hypothesis).
* **$H_2$:** The explanatory power of lagged forecasts (t-1, t-3, t-7) for today’s spot price is low; the market quickly prices in real-time information.

---

## ⚙️ 3. Methodological Data Mining

### 3.1. Data Science
* **Spot Price:** Yahoo Finance API (`quantmod` Library) daily BTC closing prices source.
* **Forecasting** Extracted using Polymarket’s API architecture:
  * *Gamma API:*To extract the unique `clobTokenIds` values of Market IDs.
  * *CLOB API (Central Limit Order Book):* To retrieve historical daily closing probabilities using the `prices-history` endpoint via token IDs.

### 3.2. Full Probability Distribution and EV Modeling

All contract tiers were analyzed to distill market expectations into a single figure. The formula was constructed:

$EV = \sum_{i=1}^{n} (P_{dip\_i} \times V_i) + (P_{mid} \times V_{mid}) + \sum_{j=1}^{m} (P_{reach\_j} \times V_j)$

* $P$ represents the calculated marginal probability, and $V$ represents the target price level.*

---

## 📊 4. Exploratory Data Analysis

![BTC Real Price vs Polymarket Prediction](05-plots/01_btc_vs_ev_timeseries.png)

**Graph Comment:** Looking at the time series, we see that the EV line is quite volatile at the beginning of the contract period (a period of low liquidity and high speculation). However, as the contract period nears its end, we observe that Polymarket participants’ predictions rapidly converge toward the actual BTC spot price (assuming $H_1$).


---

## 📈 5. İstatistiksel Bulgular ve Regresyon Analizi

Gecikme (Lag) değişkenlerinin fiyat üzerindeki etkisini test etmek için OLS (Ordinary Least Squares) yöntemiyle Çoklu Doğrusal Regresyon uygulanmıştır.

| Değişken | Tahmin Edilen Katsayı (Estimate) | Standart Hata | t-değeri | p-değeri (Pr>\|t\|) |
| :--- | :--- | :--- | :--- | :--- |
| **(Intercept)** | 8.331e+04 | 1.067e+04 | 7.810 | 4.8e-06 *** |
| **EV_Lag_1** | 8.131e-02 | 8.757e-02 | 0.928 | 0.371 |
| **EV_Lag_3** | -1.511e-01 | 8.740e-02 | -1.729 | 0.109 |
| **EV_Lag_7** | -1.135e-01 | 6.880e-02 | -1.649 | 0.125 |
| **Days_to_Exp** | 1.748e+02 | 1.581e+02 | 1.105 | 0.291 |

* **Model Performansı:** `Multiple R-squared: 0.3421`. Model, fiyat varyansının yaklaşık %34'ünü açıklamaktadır.
* **Korelasyon:** Spot fiyat ile eşzamanlı EV arasında orta-güçlü düzeyde (**r = 0.547**) pozitif korelasyon bulunmuştur.
* **EMH Doğrulaması:** $H_2$ hipotezimiz doğrulanmıştır. `EV_Lag_1`, `EV_Lag_3` ve `EV_Lag_7` değişkenlerinin p-değerleri > 0.05'tir. Bu durum, geçmiş beklentilerin bugünkü anlık fiyatı açıklamakta yetersiz kaldığını ve Etkin Piyasalar Hipotezi'nin kripto tahmin piyasalarında da geçerliliğini koruduğunu göstermektedir.

---

## ⚠️ 6. Araştırma Kısıtları (Limitations)
Regresyon modelinde serbestlik derecesinin (Degrees of Freedom = 12) düşük olmasının ana sebebi örneklem kısıtıdır (Sample Size). 7 günlük gecikme (Lag 7) analizi, zaman serisinin ilk 7 günlük verisinin silinmesine (NA) yol açmıştır. Gelecekteki araştırmaların, 6 aylık veya 1 yıllık daha geniş veri setleri ile ARIMA veya VAR (Vector Autoregression) modelleri kullanılarak yapılması literatüre katkı sağlayacaktır.

---

## 📁 7. Proje Dizin Yapısı (Repository Structure)

Bu proje, veri biliminin en iyi uygulamaları (best practices) gözetilerek modüler bir yapıda tasarlanmıştır:

```text
📂 project-root/
├── 📁 01-data_raw/             # API'lerden çekilen ham, işlenmemiş JSON/CSV verileri
├── 📁 02-data_preprocessed/    # Temizlenmiş, birleştirilmiş ve analize hazır EV tabloları
├── 📁 03-scripts/              # Tüm R veri madenciliği, ön işleme ve analiz kodları
├── 📁 04-results/              # İstatistiksel modellerin çıktıları (Regresyon tablosu)
├── 📁 05-plots/                # Keşifsel veri analizi (EDA) grafikleri
└── 📄 README.md                # Proje dokümantasyonu
