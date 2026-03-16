<orchestrator id="analyze" version="2.1" trigger="/core-analyze">

<!-- Kullanım: /core-analyze PAY-1234  veya  Copilot: "PAY-1234'ü analiz et" -->
<!-- Tek özellik veya küçük-orta ölçekli talepler için standart zincir -->

<activation>
  <step n="1">config/system.yaml oku → output_language, active_domain, integrations.dry_run</step>
  <step n="2">domains/[active_domain]/domain-context.yaml oku → domain bağlamını yükle</step>
  <step n="3">Ticket ID'yi $ARGUMENTS'tan çıkar; Jira formatı (PROJE-NNN) veya serbest metin olabilir</step>
  <step n="4">Argümanlar "--dry-run" içeriyorsa DRY_RUN=true olarak override et; kullanıcıya bildir</step>
</activation>

<workflow>
  .core/agents/orchestrator.agent.md dosyasını oku.
  Dosyadaki tüm &lt;activation&gt;, &lt;workflow&gt;, &lt;rules&gt; bloklarını adım adım uygula.
  analysis_type: "standard"
</workflow>

<rules>
  <r>Onay mekanizması orchestrator.agent.md içindeki → HANDOFF ONAYI direktiflerinden okunur</r>
  <r>Çıktı dili config/system.yaml → output_language (varsayılan: tr)</r>
  <r>dry_run: true ise Atlassian'a yazma — [DRY-RUN] önekiyle simüle et</r>
</rules>

</orchestrator>
