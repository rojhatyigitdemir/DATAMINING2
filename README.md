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

## 🎯 2. Araştırma Amacı ve Hipotezler
Projenin temel amacı, piyasa beklentilerinin zaman içinde rasyonelleşme hızını ve öngörücü (predictive) gücünü ölçmektir.

* **$H_1$:** Vade sonuna kalan süre ($t \rightarrow 0$) azaldıkça, tahmin piyasalarındaki Beklenen Değer (EV) ile Gerçek Spot Fiyat arasındaki makas daralır (Yakınsama Hipotezi).
* **$H_2$:** Gecikmeli tahminlerin (t-1, t-3, t-7) bugünkü spot fiyatı açıklama gücü düşüktür; piyasa anlık bilgiyi hızla fiyatlar.

---

## ⚙️ 3. Metodoloji ve Veri Madenciliği (Data Mining)

### 3.1. Veri Kaynakları
* **Spot Fiyat:** Yahoo Finance API (`quantmod` kütüphanesi) üzerinden çekilen günlük BTC kapanış fiyatları.
* **Tahmin Verisi:** Polymarket'in çift katmanlı API mimarisi kullanılarak çekilmiştir:
  * *Gamma API:* Hedef sözleşmelerin (Market IDs) benzersiz `clobTokenIds` değerlerini ayrıştırmak için.
  * *CLOB API (Central Limit Order Book):* Token ID'ler üzerinden `prices-history` endpoint'i ile tarihsel günlük kapanış olasılıklarını çekmek için.

### 3.2. Tam Olasılık Dağılımı ve EV Modellemesi
Piyasanın genel beklentisini tek bir sayıya indirgemek için tüm sözleşme kademeleri (Tiers) analiz edilmiştir. Sağ ve sol kuyruk (left/right tail) risklerini hesaplamak amacıyla formülizasyon şu şekilde kurulmuştur:

$EV = \sum_{i=1}^{n} (P_{dip\_i} \times V_i) + (P_{mid} \times V_{mid}) + \sum_{j=1}^{m} (P_{reach\_j} \times V_j)$

*Burada $P$, hesaplanan marjinal olasılığı; $V$ ise hedef fiyat kademesini temsil etmektedir.*

---

## 📊 4. Keşifsel Veri Analizi (Exploratory Data Analysis)

![BTC vs Polymarket Tahmini](05-plots/01_btc_vs_ev_timeseries.png)
*(Not: Repo klonlandıktan sonra ilgili grafik `05-plots` klasöründe incelenebilir.)*

**Görsel Yorumu:** Zaman serisi analizinde, vade başlangıcında (düşük likidite ve yüksek spekülasyon dönemi) EV çizgisinin oldukça volatil olduğu, ancak vade sonuna yaklaştıkça Polymarket katılımcılarının tahminlerinin hızla gerçek BTC spot fiyatına yakınsadığı ($H_1$ kabul) gözlemlenmiştir.

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
