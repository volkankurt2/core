<skill id="output-formats" version="2.0">
<!-- Hangi durumda hangi format üretileceği -->
<!-- Kullananlar: jira-creator, feedback-collector, core-pptx, core-excel -->

<purpose>
CORE çıktılarının hedef kitleye ve amaca göre doğru formatta üretilmesini
sağlar. Format kararı matris ile verilir; her format için yapı ve içerik
şablonu tanımlanır.
</purpose>

<decision-matrix>
  | Hedef Kitle       | Amaç                         | Format             |
  |-------------------|------------------------------|--------------------|
  | PO / Yönetim      | Özet sunum, karar toplantısı | PPTX               |
  | Geliştirici ekibi | Gereksinim referansı         | Word BRD           |
  | Mühendis / Mimar  | Etki değerlendirmesi         | Excel Matrisi      |
  | Jira              | Ticket özeti                 | Jira yorumu        |
  | Confluence        | Kalıcı arşiv                 | Confluence sayfası |
</decision-matrix>

<formats>
  <format id="pptx" trigger="/core-pptx [TICKET-ID]">
    Çıktı: core-output/[ID]/sunum.pptx
    8 slide yapısı:
    - Slide 1: Kapak — [Ticket ID] | [Başlık] | Tarih | TASLAK
    - Slide 2: Problem ve Fırsat — Mevcut Durum → Hedef Durum
    - Slide 3: Kapsam — İçinde / Dışında
    - Slide 4: Temel Gereksinimler — Must Have listesi (maks 5 madde)
    - Slide 5: Teknik Etki Özeti — Etkilenen servisler + Tahmini efor
    - Slide 6: Riskler — İlk 3 risk + azaltma | Yüksek/Orta/Düşük
    - Slide 7: Zaman Çizelgesi — Milestone'lar ve tarihler
    - Slide 8: Açık Kararlar — TBD listesi + sorumlu kişi
  </format>

  <format id="word-brd" trigger="Analiz sonunda otomatik">
    Çıktı: core-output/[ID]/brd.docx
    İçerik: brd.md → Word formatına dönüştür
    Logo + header | Sayfa numaraları | Otomatik içindekiler | Tablo formatları
  </format>

  <format id="excel" trigger="/core-excel [TICKET-ID]">
    Çıktı: core-output/[ID]/teknik-etki-matrisi.xlsx
    5 sheet:
    - Sheet 1 — Etkilenen Servisler: Servis | Etki | Detay | Risk | Efor | Ekip
    - Sheet 2 — Yasal Matris: Düzenleme | Madde | Risk | Azaltma | Sorumlu
    - Sheet 3 — Story Özeti: Story ID | Başlık | Öncelik | SP | Bağımlılık
    - Sheet 4 — Test Kapsamı: TC ID | Tür | Story | Öncelik | Ortam
    - Sheet 5 — TBD Takip: TBD ID | Konu | Sorumlu | Son Tarih | Durum
  </format>

  <format id="jira-comment" trigger="Jira Creator — Adım 4">
    Dil: config/system.yaml → output_language
    ÖNEMLI: Gerçek satır sonu karakterleri kullan — \n escape sequence Jira'da hatalı görünür

    Şablon:
    🤖 CORE Analiz Zinciri Tamamlandı

    📋 BRD → [Confluence linki]
    📖 [N] User Story oluşturuldu → [Epic linki]
    ⚙️ Teknik Etki → core-output/[ID]/04-impact-analysis.md
    🧪 [N] Test Senaryosu
    ⏱️ Tahmini efor: ~[N] gün
    Risk: Yüksek/Orta/Düşük 🔴/🟡/🟢

    Açık TBD'ler: [N] adet → /core-tbd ile takip et
    cc: @ProductOwner @TechLead
  </format>

  <format id="confluence-page" trigger="Jira Creator — Adım 5">
    Dil: config/system.yaml → output_language
    Sayfa hiyerarşisi:
    [SPACE]
    └── BRD Arşivi
        └── [Yıl]
            └── [TICKET-ID] — [Başlık]   ← ana sayfa
                ├── Teknik Etki Analizi
                ├── User Stories
                └── Test Senaryoları
  </format>
</formats>

<rules>
  <r>Format seçimi decision-matrix'e göre; hedef kitleyi önce belirle</r>
  <r>Jira yorumu her zaman output_language dilinde — config/system.yaml'dan oku</r>
  <r>dry_run: true ise hiçbir format Atlassian'a yazılmaz; lokale yaz ve [DRY-RUN] belirt</r>
  <r>Confluence sayfası BRD Arşivi'nin altına açılır — root space'e değil</r>
  <r>Atlassian işlemleri için aktif MCP server'ı kullan — araç adını sabit kodlama</r>
</rules>

</skill>
