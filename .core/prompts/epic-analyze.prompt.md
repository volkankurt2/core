<orchestrator id="epic-analyze" version="2.0" trigger="/core-epic-analyze">

<!-- Kullanım: /core-epic-analyze PAY-1234 -->
<!-- Büyük, çok ekipli veya çok sprintlik talepler için epic zinciri -->
<!-- analyze.prompt.md ile aynı zincir; epic moduna özgü farklar aşağıda -->

<activation>
  <step n="1">config/system.yaml oku → output_language, active_domain, integrations.dry_run</step>
  <step n="2">domains/[active_domain]/domain-context.yaml oku → domain bağlamını yükle</step>
  <step n="3">Ticket ID'yi $ARGUMENTS'tan çıkar</step>
</activation>

<workflow>

  <step n="0" name="Metrikleri Başlat">
    core-output/[TICKET-ID]/metrics.json oluştur:
    - analysis_type: "epic"  ← standart analizden tek fark burada
    - ticket_id, started_at, tüm agent alanları boş
  </step>

  <step n="1" name="Interview — Epic Ekstraları">
    .core/agents/interview.agent.md → çalıştır
    Standart sorulara EK olarak şunları da sor:
    - Kaç sprint öngörülüyor?
    - Hangi ekipler dahil?
    - Phased rollout planlanıyor mu?
    - Pilot grup veya bölge var mı?
    Çıktı: core-output/[ID]/00-requirements-brief.md
  </step>

  <step n="2" name="PRD — Epic Yapısı">
    .core/agents/prd.agent.md → çalıştır
    Standart PRD'ye EK olarak:
    - Epic'i sub-story'lere böl; her biri için ayrı kapsam bölümü
    - Phased release planı ekle (aşamalar, bağımlılıklar)
    Çıktı: core-output/[ID]/01-prd.md + 02-brd.md
  </step>

  <step n="3" name="PRD Reviewer">
    .core/agents/prd-reviewer.agent.md → çalıştır (standart ile aynı)
    - RED → Adım 2'ye geri | ONAY → Adım 4'e geç
    Çıktı: core-output/[ID]/03-review-report.md
  </step>

  <step n="4" name="Codebase Analyst — Cross-Service">
    .core/agents/codebase-analyst.agent.md → çalıştır
    Standart analize EK olarak:
    - Her etkilenen ekip için ayrı etki tablosu
    - Cross-service bağımlılıkları açıkça listele
    Çıktı: core-output/[ID]/04-impact-analysis.md
  </step>

  <step n="5" name="Implementation Planner — Sprint Roadmap">
    .core/agents/implementation-plan.agent.md → çalıştır
    Standart plana EK olarak:
    - Sprint bazlı roadmap (hangi sprint, hangi ekip, hangi story)
    - Milestone'lar ve Go/No-Go kriterleri
    Çıktı: core-output/[ID]/05-user-stories.md + 06-test-scenarios.md + 07-implementation-plan.md
  </step>

  <step n="6" name="Jira Creator — Epic Hiyerarşisi">
    .core/agents/jira-creator.agent.md → çalıştır
    Standart işlemlere EK olarak:
    - 1 Epic → N Sub-Epic → M Story hiyerarşisi kur
    - Her ekip için ayrı component etiketi ekle
  </step>

  <step n="7" name="Feedback Collector">
    .core/agents/feedback-collector.agent.md → çalıştır (standart ile aynı)
  </step>

  <step n="8" name="Metrikleri Tamamla">
    core-output/[ID]/metrics.json → summary hesapla (analyze.prompt.md Adım 8 ile aynı)
    analysis_type "epic" olarak kalır.
    Ekrana Türkçe zincir özetini yaz.
  </step>

</workflow>

<rules>
  <r>Hiçbir adımda onay bekleme — PRD RED ve Kategori A çelişki hariç</r>
  <r>Çıktı dili config/system.yaml → output_language (varsayılan: tr)</r>
  <r>dry_run: true ise Atlassian'a yazma — [DRY-RUN] önekiyle simüle et</r>
  <r>Her agent dosyasını sırayla oku ve içindeki direktifleri uygula</r>
  <r>Epic modunda Jira hiyerarşisi: 1 Epic → N Sub-Epic → M Story; düz Story listesi üretme</r>
</rules>

</orchestrator>
