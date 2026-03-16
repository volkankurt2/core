<orchestrator id="epic-analyze" version="2.1" trigger="/core-epic-analyze">

<!-- Kullanım: /core-epic-analyze PAY-1234 -->
<!-- Büyük, çok ekipli veya çok sprintlik talepler için epic zinciri -->

<activation>
  <step n="1">config/system.yaml oku → output_language, active_domain, integrations.dry_run</step>
  <step n="2">domains/[active_domain]/domain-context.yaml oku → domain bağlamını yükle</step>
  <step n="3">Ticket ID'yi $ARGUMENTS'tan çıkar</step>
  <step n="4">Argümanlar "--dry-run" içeriyorsa DRY_RUN=true olarak override et; kullanıcıya bildir</step>
</activation>

<workflow>
  .core/agents/orchestrator.agent.md dosyasını oku.
  Dosyadaki tüm &lt;activation&gt;, &lt;workflow&gt;, &lt;epic-mode&gt;, &lt;rules&gt; bloklarını adım adım uygula.
  analysis_type: "epic"

  Epic modu ek direktifleri (&lt;epic-mode&gt; bloğunda tanımlı):
  - Interview: kaç sprint, hangi ekipler, phased rollout soruları
  - PRD: sub-story ayrıştırma, phased release planı
  - Codebase Analyst: cross-service bağımlılık tablosu
  - Implementation Planner: sprint roadmap, milestone'lar, Go/No-Go kriterleri
  - Jira Creator: Epic → Sub-Epic → Story hiyerarşisi
</workflow>

<rules>
  <r>Onay mekanizması orchestrator.agent.md içindeki → HANDOFF ONAYI direktiflerinden okunur</r>
  <r>Çıktı dili config/system.yaml → output_language (varsayılan: tr)</r>
  <r>dry_run: true ise Atlassian'a yazma — [DRY-RUN] önekiyle simüle et</r>
</rules>

</orchestrator>
