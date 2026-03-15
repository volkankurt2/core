<skill id="brd-quality" version="2.0">
<!-- BRD yazılmadan önce okunur: şablonlar, kontrol listeleri, kalite kriterleri -->
<!-- Kullananlar: prd-agent (Adım 3-4), prd-reviewer (Adım 1) -->

<purpose>
Üretilen BRD dokümanının kalitesini garanti altına alır. Kontrol listesi ile
self-check imkânı sağlar, FG ve NFR şablonları ile yapıyı standardize eder.
</purpose>

<checklist>
  Temel Yapı:
  - [ ] Meta tablo eksiksiz (ticket, tarih, versiyon, durum, yazar)
  - [ ] Mevcut Durum / Hedef Durum net ayrımı yapıldı
  - [ ] En az 1 ölçülebilir KPI tanımlandı
  - [ ] Kapsam İçi ve Kapsam Dışı ayrı yazıldı
  - [ ] Paydaş tablosu dolu

  Gereksinimler:
  - [ ] Her FG için MoSCoW önceliği atandı
  - [ ] Her FG için en az 1 kabul kriteri var
  - [ ] Ölçülebilir ifade kullanıldı (❌ "hızlı" → ✅ "p95 &lt; 3 saniye")
  - [ ] Olumsuz gereksinimler (yapılmayacaklar) belirtildi

  Domain-Spesifik Kontroller:
  - [ ] domain-context.yaml → prd_review_extra_criteria.mandatory listesi tamamlandı
  - [ ] domain-context.yaml → prd_review_extra_criteria.warning listesi gözden geçirildi

  Yasal Uyumluluk:
  - [ ] domain-context.yaml → regulations listesindeki her regülasyon için tarama yapıldı
  - [ ] Her düzenleme için risk seviyesi yazıldı
  - [ ] Yüksek riskli her madde için azaltma stratejisi var

  Geçmiş Bağlantılar:
  - [ ] Benzer geçmiş ticket'lar referans verildi (varsa)
  - [ ] Çelişen eski karar belirtildi (varsa)
  - [ ] Geçerli mimari kararlar bağlantılı
</checklist>

<templates>
  FG şablonu:
    **FG-[N]: [Kısa Başlık]**
    - Açıklama: [Sistem ne yapmalı — özne + eylem + koşul]
    - Öncelik: Must / Should / Could / Won't
    - Kabul Kriteri: [Ölçülebilir, test edilebilir]
    - Bağımlılık: [Başka FG veya dış sistem]
    - Geçmiş Ref: [TICKET-XXX — varsa]

  NFR Performans tablosu:
    | Ölçüt       | Hedef    | Ölçüm Yöntemi |
    |-------------|----------|---------------|
    | p50 latency | &lt; 500ms  | Prometheus    |
    | p95 latency | &lt; 2000ms | Prometheus    |
    | Hata oranı  | &lt; %0,1   | Grafana       |

  NFR Güvenlik tablosu:
    | Gereksinim              | Standart              | Kontrol Yöntemi |
    |-------------------------|-----------------------|-----------------|
    | TLS versiyonu           | 1.2+                  | SSL taraması    |
    | Hassas veri maskeleme   | [domain regülasyonu]  | Log denetimi    |

  Yasal Risk Matrisi:
    | Düzenleme          | Madde                    | Risk   | Azaltma Stratejisi         |
    |--------------------|--------------------------|--------|----------------------------|
    | [domain-context reg] | [İlgili madde]         | Yüksek | [Azaltma yöntemi]          |
    | [domain-context reg] | [İlgili madde]         | Orta   | [Mevcut kontrol mekanizması] |
</templates>

<anti-patterns>
  ❌ Çözüm önce gereksinim sonra: "Redis cache eklenecek" → ✅ "Sorgu sonucu 5 dk cache'lenecek"
  ❌ Ölçüsüz performans: "Hızlı çalışmalı" → ✅ "p95 &lt; 2 saniye"
  ❌ Kapsam karışıklığı: Aynı madde hem İçinde hem Dışında olamaz
  ❌ Sahipsiz FG: Her FG'nin en az 1 user story karşılığı olmalı
</anti-patterns>

<rules>
  <r>Domain-spesifik kontroller domain-context.yaml → prd_review_extra_criteria ve regulations listelerinden dinamik okunur; SKILL.md'ye sabit kodlanmaz</r>
  <r>Self-check: PRD Agent adım 4'te bu listeyi uygular; PRD Reviewer adım 1'de bağımsız olarak uygular</r>
  <r>Tüm zaman ve performans değerleri somut sayı içermeli — belirsiz niteleyici kabul edilmez</r>
</rules>

</skill>
