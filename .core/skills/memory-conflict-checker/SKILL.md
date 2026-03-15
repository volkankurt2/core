<skill id="memory-conflict-checker" version="2.0">
<!-- Yeni gereksinimleri kurumsal kararlarla karşılaştırarak çelişki tespit eder -->
<!-- Kullananlar: interview-agent (Adım 1.5), prd-agent (Adım 1.5) -->

<purpose>
memory/decisions/institutional-memory.md dosyasındaki KUR kararlarını okur,
yeni talebin anahtar kavramlarını semantik haritalama ile karşılaştırır.
Çelişkiyi üç kategoride sınıflandırır ve CONFLICT_CHECK_RESULT üretir.
</purpose>

<procedure>
  <step n="1" name="Kurumsal Hafızayı Oku">
    memory/decisions/institutional-memory.md dosyasını oku.
    Her KUR kararını parse et: KUR-ID, Başlık, Karar, Kapsam, İstisna
  </step>

  <step n="2" name="Etiket Çıkar">
    Her KUR kararı için anahtar kavramları listele:
    Kısaltmalar, alternatif yazımlar, ilgili teknik terimler, Türkçe karşılıklar.
    Örnek: KUR-001 → "3DS, 3ds, 3D Secure, üç D, banka entegrasyonu, v1, v2, fallback"
  </step>

  <step n="3" name="Talep Metnini Tara">
    Şu kaynakları tara:
    - Ticket başlığı + açıklama
    - requirements-brief.md (varsa)
    - PRD taslağı (varsa)

    Her KUR'un etiket kümesiyle metin içinde eşleşme ara.
    Eşleşme bulunursa → o KUR ilgili karar olarak işaretle.
  </step>

  <step n="4" name="Çelişki Kategorileri">
    Kategori A — Doğrudan Çelişki (Kırmızı):
    Yeni talep, mevcut KUR kararıyla açıkça zıt.
    Aksiyon: Agent çalışmasını durdur, kullanıcı onayı iste.

    Kategori B — Potansiyel Çelişki (Sarı):
    Talep KUR kapsamına giriyor ama doğrudan zıt değil.
    Aksiyon: PRD/BRD'de "Dikkat" bölümüne ekle.

    Kategori C — İlgili Bilgi (Mavi):
    Doğrudan çelişki yok ama bağlamsal olarak ilgili.
    Aksiyon: requirements-brief.md → "Geçmiş Referanslar" bölümüne listele.
  </step>

  <step n="5" name="Çelişki Raporu Üret">
    ## ⚡ Kurumsal Karar Taraması

    🔴 Doğrudan Çelişkiler tablosu (KUR-ID | Başlık | Mevcut Karar | Çelişen Talep | Öneri)
    🟡 Potansiyel Çelişkiler tablosu (KUR-ID | Başlık | Dikkat Konusu | Eylem)
    🔵 İlgili Kararlar tablosu (KUR-ID | Başlık | Neden İlgili)
    ✅ Çelişki Yok satırı (eşleşme bulunamazsa)
  </step>

  <step n="6" name="Kritik Çelişki Protokolü (sadece Kategori A)">
    Kullanıcıya şu seçenekleri sun ve yanıt bekle:

    🚨 KRİTİK: Kurumsal Karar Çelişkisi
    [KUR-NNN] [Başlık]
    Mevcut karar: [kısa özet]
    Yeni talep: [kısa özet]

    A) Talebi KUR-NNN'e uyacak şekilde revize et (önerilen)
    B) KUR-NNN'i güncelle (gerekçe ve onay gerekir)
    C) Bu ticket için istisna tanımla (gerekçe ekle)

    Kullanıcı yanıt verene kadar PRD üretimine devam etme.
  </step>

  <step n="7" name="İstisna Yönetimi (Seçenek C seçilirse)">
    - requirements-brief.md'ye istisna gerekçesi yaz
    - PRD/BRD'de açıkça belirt: "Bu geliştirme KUR-NNN'den MUAFTIR — Gerekçe: [...]"
    - memory/tbd-tracker/tbd-tracker.md'ye TBD ekle:
      "KUR-NNN güncellenmeli mi? [Ticket] için istisna tanımlandı."
  </step>
</procedure>

<output-format>
  CONFLICT_CHECK_RESULT:
    critical: [true/false]
    conflicts_A: [KUR listesi veya boş]
    conflicts_B: [KUR listesi veya boş]
    references_C: [KUR listesi veya boş]
    report: [Adım 5 çıktısı]
</output-format>

<rules>
  <r>Kategori A tespit edilirse analizi durdur ve kullanıcı kararı al — otomatik geçme</r>
  <r>Etiket listesi yeni KUR eklendiğinde güncellenir; dinamik tarama yapar</r>
  <r>Semantik eşleşme kullan — sadece birebir aynı kelime değil, anlam yakınlığını da değerlendir</r>
  <r>İstisna tanımlandığında TBD tracker'a mutlaka kaydet</r>
</rules>

</skill>
