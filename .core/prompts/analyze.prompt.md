<orchestrator id="analyze" version="2.0" trigger="/core-analyze">

<!-- Kullanım: /core-analyze PAY-1234  veya  Copilot: "PAY-1234'ü analiz et" -->
<!-- Tek özellik veya küçük-orta ölçekli talepler için standart zincir -->

<activation>
  <step n="1">config/system.yaml oku → output_language, active_domain, integrations.dry_run</step>
  <step n="2">domains/[active_domain]/domain-context.yaml oku → domain bağlamını yükle</step>
  <step n="3">Ticket ID'yi $ARGUMENTS'tan çıkar; Jira formatı (PROJE-NNN) veya serbest metin olabilir</step>
</activation>

<workflow>

  <step n="0" name="Metrikleri Başlat">
    Ticket ID'yi belirle. core-output/[TICKET-ID]/ dizinini oluştur.
    .core/skills/performance-tracker/SKILL.md şemasına göre metrics.json yarat:
    - ticket_id, analysis_type: "standard", started_at, tüm agent alanları boş
  </step>

  <step n="1" name="Interview">
    .core/agents/interview.agent.md → çalıştır
    Çıktı: core-output/[ID]/00-requirements-brief.md
  </step>

  <step n="2" name="PRD">
    .core/agents/prd.agent.md → çalıştır (self-check + halüsinasyon kontrolü dahil)
    Çıktı: core-output/[ID]/01-prd.md + 02-brd.md
  </step>

  <step n="3" name="PRD Reviewer">
    .core/agents/prd-reviewer.agent.md → çalıştır
    Çıktı: core-output/[ID]/03-review-report.md
    - RED   → Adım 2'ye geri dön (maksimum 2 iterasyon)
    - ONAY  → Adım 4'e geç
  </step>

  <step n="4" name="Codebase Analyst">
    .core/agents/codebase-analyst.agent.md → çalıştır
    Çıktı: core-output/[ID]/04-impact-analysis.md
  </step>

  <step n="5" name="Implementation Planner">
    .core/agents/implementation-plan.agent.md → çalıştır
    Çıktı: core-output/[ID]/05-user-stories.md + 06-test-scenarios.md + 07-implementation-plan.md
  </step>

  <step n="6" name="Jira Creator">
    .core/agents/jira-creator.agent.md → çalıştır
    Jira backlog + Confluence BRD + hafıza güncelle
  </step>

  <step n="7" name="Feedback Collector">
    .core/agents/feedback-collector.agent.md → çalıştır
    Analistten kalite değerlendirmesi al; personal memory + feedback-log + improvement-list güncelle
  </step>

  <step n="8" name="Metrikleri Tamamla">
    core-output/[ID]/metrics.json → summary bölümünü hesapla:
    - completed_at, total_duration_seconds, total_estimated_tokens
    - prd_pass_on_first_review, reviewer_iterations, overall_quality_score
    - hallucination_rates (prd + codebase-analyst), cost_estimate (performance-tracker formülü)

    Ekrana Türkçe zincir özetini yaz.
  </step>

</workflow>

<rules>
  <r>Hiçbir adımda onay bekleme — PRD RED ve Kategori A çelişki hariç</r>
  <r>Çıktı dili config/system.yaml → output_language (varsayılan: tr)</r>
  <r>dry_run: true ise Atlassian'a yazma — [DRY-RUN] önekiyle simüle et</r>
  <r>Her agent dosyasını sırayla oku ve içindeki direktifleri uygula</r>
</rules>

</orchestrator>
