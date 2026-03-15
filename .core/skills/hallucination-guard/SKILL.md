<skill id="hallucination-guard" version="2.0">
<!-- Domain-aware fact checking: üretilen içerikteki teknik iddiaları doğrular -->
<!-- Kullananlar: prd-agent, prd-reviewer, codebase-analyst -->

<purpose>
AI halüsinasyon riskini minimize etmek için domain bilgi tabanına karşı aktif
doğrulama yapar. Referans verilen her teknik varlığın gerçekten var olduğunu
teyit eder. Doğrulanamayan ifadeleri '[DOĞRULANMADI]' etiketi ile işaretler.
</purpose>

<verification-sources>
  | Kategori                         | Kaynak |
  |----------------------------------|--------|
  | Servis adları ve ID'leri         | domains/[domain]/domain-context.yaml → services[*] |
  | Servis API / RabbitMQ bilgileri  | knowledge-base/[servis-id].json |
  | Regülasyon kodları               | domains/[domain]/domain-context.yaml → regulations[*].id |
  | Domain terimleri ve kısaltmalar  | domains/[domain]/domain-context.yaml → glossary[*] |
  | Servis envanteri                 | knowledge-base/_progress.json |
</verification-sources>

<categories>
  <cat id="KAT-1" name="Servis Adı">
    İçerikte geçen her servis adını domain-context.yaml services listesi ve
    data/INDEX.md ile karşılaştır. Eşleşme yoksa:
    [DOĞRULANMADI - Bilinmeyen Servis]
  </cat>

  <cat id="KAT-2" name="API / Endpoint">
    API endpoint, method adı, RabbitMQ exchange/queue adlarını ilgili
    knowledge-base/[servis-id].json ile karşılaştır.
    KB yoksa: [DOĞRULANMADI - KB Bulunamadı: servis-id]
    endpoint bulunamazsa: [DOĞRULANMADI - Endpoint Bulunamadı: servis-adı]
  </cat>

  <cat id="KAT-3" name="Regülasyon Maddesi">
    Regülasyon ID'sini domain-context.yaml → regulations[*].id ile kontrol et.
    Madde numarası belirsiz/uydurma görünüyorsa: [DOĞRULANMADI - Regülasyon Maddesi Teyit Edilmeli]
    Bilinmeyen kod ise: [DOĞRULANMADI - Regülasyon Bilinmiyor]
  </cat>

  <cat id="KAT-4" name="Teknik Terim">
    domain-context.yaml → glossary[*].term ile karşılaştır.
    Domain dışı veya belirsiz: [DOĞRULANMADI - Terim Doğrulanamadı]
  </cat>
</categories>

<procedure>
  <step n="1">config/system.yaml → active_domain oku; domains/[domain]/domain-context.yaml oku; knowledge-base/_progress.json oku</step>
  <step n="2">Üretilen dokümanı baştan sona tara: her paragrafta KAT-1..4 var mı kontrol et</step>
  <step n="3">Eşleşme gereken her varlık için kaynak dosyaya bak; gerçekten tanımlı mı kontrol et</step>
  <step n="4">Doğrulanamayan ifadeleri yerinde etiketle (içeriği silme, sadece etiket ekle)</step>
  <step n="5">Dokümanın sonuna Halüsinasyon Doğrulama Özeti tablosu ekle</step>
</procedure>

<summary-table-format>
  ## Halüsinasyon Doğrulama Özeti

  | Kategori             | Kontrol Edilen | Doğrulanan | Doğrulanamayan |
  |----------------------|---------------|------------|----------------|
  | Servis Adları        | N             | N          | N              |
  | API Endpoint'ler     | N             | N          | N              |
  | Regülasyon Maddeleri | N             | N          | N              |
  | Teknik Terimler      | N             | N          | N              |
  | **TOPLAM**           | **N**         | **N**      | **N**          |

  Doğrulanma Oranı: XX%
  Doğrulanamayan Maddeler: [varsa listele]
</summary-table-format>

<rules>
  <r>Doğrulanma oranı hedefi ≥ %85 — altında kalırsa PRD Reviewer RED verir</r>
  <r>Kullanıcının sağladığı kaynak metinleri (brief, Jira yorumu) doğrulama kapsamı dışında</r>
  <r>Emin olmadığında işaretlemek daha güvenli — false negative'den kaç</r>
  <r>Servis adı domain-context.yaml'da var ama KB yoksa → servis adı OK, endpoint [DOĞRULANMADI - KB Bulunamadı]</r>
  <r>"Payment Service" gibi genel ifadeler domain servisiyle eşleşebilir — bağlamı değerlendir</r>
</rules>

</skill>
