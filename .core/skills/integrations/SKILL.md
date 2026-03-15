<skill id="integrations" version="2.0">
<!-- Jira ve Confluence MCP işlemleri: okuma, yazma, etiket yönetimi -->
<!-- Kullananlar: interview-agent, codebase-analyst, jira-creator -->

<purpose>
Atlassian MCP üzerinden Jira ve Confluence işlemlerini tanımlar.
Platform-neutral direktifler — her platform kendi MCP client'ını kullanır.
</purpose>

<jira-read>
  Ticket okuma:
  - Ne zaman: Her analiz başında
  - Çıktı: summary, description, priority, labels, components, linkedIssues, reporter, assignee, status
  - Tier seçimi için bkz. skills/jira-smart-read/SKILL.md

  Yorum okuma:
  - Ne zaman: PO notlarını ve teknik kararları okumak için (Tier 3)

  Arama (JQL):
  - benzer_component: "project = [PROJE] AND component = [KOMPONENT] AND status = Done ORDER BY updated DESC"
  - benzer_konu:      "project = [PROJE] AND text ~ '[anahtar_kelime]' AND status = Done ORDER BY updated DESC"
  - ayni_label:       "project = [PROJE] AND labels = [ETİKET] ORDER BY updated DESC"
  - bu_sprint:        "project = [PROJE] AND sprint in openSprints() ORDER BY priority ASC"
  - tbd_takip:        "project = [PROJE] AND labels = TBD AND status != Done"
</jira-read>

<jira-write>
  Yorum ekleme:
  - Ne zaman: Analiz tamamlandığında — Jira Creator sonunda otomatik
  - İçerik: skills/output-formats/SKILL.md → Format 4
  - ÖNEMLI: Yorum metninde gerçek satır sonu karakterleri kullan; \n escape sequence değil

  Etiket yönetimi:
  - Analiz başlarken: "core-analysis-in-progress" etiketi ekle
  - Analiz bitince: "core-analysis-done" ekle; "core-analysis-in-progress" kaldır
  - TBD varsa: "has-open-tbd" etiketi ekle

  Issue oluşturma (toplu, 5'erli gruplar — rate limit güvencesi):
  - Epic: ANA_BOARD'a; Story: target_board'a göre

  İssue bağlama:
  - Bağımlılık ilişkileri için "blocks" tipi kullan
</jira-write>

<confluence-read>
  Arama:
  - Ne zaman: Her analiz başında, bağlam toplarken
  - Önerilen sorgular:
    - "[banka adı] entegrasyon"
    - "[servis adı] BRD"
    - "ADR [konu]"
    - "mimari OR architecture decision"
  - Space: aktif domain'in confluence_space değeri (domain-context.yaml'dan)

  Sayfa okuma:
  - Ne zaman: Arama sonucunda bulunan sayfalarda detay gerektiğinde
</confluence-read>

<confluence-write>
  Sayfa oluşturma:
  - Ne zaman: Analiz tamamlandığında — Jira Creator adım 5'te otomatik
  - Space: domain-context.yaml → confluence_space
  - Üst sayfa: "BRD Arşivi"
  - Başlık: "[TICKET-ID] — [BRD başlığı]"
  - İçerik: brd.md içeriği (output_language dilinde)

  Sayfa güncelleme:
  - Ne zaman: Sayfa zaten varsa (yeniden analiz veya revizyon)
</confluence-write>

<lifecycle>
  Analiz başlarken:
  - Jira ticket'a "core-analysis-in-progress" etiketi ekle

  Analiz bitince:
  - Jira'ya özet yorum ekle (Format 4)
  - Confluence'da BRD sayfası oluştur
  - Etiket güncelle: "core-analysis-done" ekle, "in-progress" kaldır
  - TBD varsa "has-open-tbd" etiketi ekle

  TBD çözülünce:
  - memory/tbd-tracker/tbd-tracker.md güncelle
  - Tüm TBD'ler kapandıysa "has-open-tbd" etiketini kaldır
</lifecycle>

<rules>
  <r>dry_run: true ise tüm yazma işlemlerini atla; [DRY-RUN] önekiyle simüle et</r>
  <r>jira.enabled: false ise Jira yazmalarını atla; confluence.enabled: false ise Confluence yazmalarını atla</r>
  <r>Atlassian işlemleri için aktif MCP server'ı kullan — araç adını sabit kodlama</r>
  <r>Cloud ID gerektiğinde Atlassian MCP'den erişilebilir kaynakları çek ve oturumda cache'le</r>
</rules>

</skill>
