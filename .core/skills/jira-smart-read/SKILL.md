<skill id="jira-smart-read" version="3.0">
<!-- Context-aware, optimize edilmiş Atlassian okuma stratejisi -->

<purpose>
Atlassian MCP çağrılarını içerik ihtiyacına göre üç katmana böler. Her agent
yalnızca ihtiyacı kadar veri çeker; gereksiz token tüketimini önler.
</purpose>

<tiers>
  <tier n="1" name="Summary" tokens="2-3k" use="İlk bakış, quick-check, liste tarama">
    Alanlar: summary, status, issuetype, priority
    Ne zaman: Interview Agent başlangıcı, birden fazla ticket listelenirken
  </tier>

  <tier n="2" name="Content" tokens="4-6k" use="Analiz için içerik gerekli">
    Alanlar: summary, description, status, issuetype, priority,
             assignee, reporter, created, updated, labels, components
    Yorumlar ve history dahil değil.
    Ne zaman: Interview Agent, PRD Agent, Codebase Analyst
  </tier>

  <tier n="3" name="Full" tokens="15-25k" use="Yorumlar ve history kesinlikle gerekli">
    Tüm alanlar (fields belirtme), yorumlar ve history dahil.
    Ne zaman: Sadece Jira Creator — epic/story oluştururken
  </tier>
</tiers>

<agent-guidelines>
  <agent id="interview">Tier 2 — summary, description, priority, labels, components</agent>
  <agent id="prd">Tier 2 — ilişkili linkler için Tier 1 kullan</agent>
  <agent id="codebase-analyst">Tier 2 — description yeterli, cache'den al</agent>
  <agent id="jira-creator">Tier 3 — sadece ana ticket için; story'ler Tier 1</agent>
</agent-guidelines>

<cache-strategy>
  Cache key: {cloudId}:{issueKey}:{tier}
  Kapsam: Oturum boyunca (her /core-analyze başında sıfırla)

  Kurallar:
  - Aynı tier, aynı issue → cache'den dön
  - Daha yüksek tier istendi → yeniden çek
  - Daha düşük tier istendi → mevcut yüksek tier cache'i kullan
  - Çapraz agent okuma → cache paylaşılır (Interview → PRD handoff)

  Beklenen tasarruf (tipik flow):
  - Interview: Tier 2 çeker (5k token)
  - PRD Agent: cache hit → 0 token
  - Codebase Analyst: cache hit → 0 token
  - Jira Creator: Tier 3 çeker (20k token, farklı tier = cache miss)
</cache-strategy>

<search-strategy>
  Birden fazla ticket listelerken: Tier 1 + JQL
  Tier 1 sonuçlardan ilgili olanı seç → Tier 2 detay çek
  Context > 150k token ise uzun ticket'ları subagent'a taşı

  JQL örnekleri:
  - benzer_konu:  "project = [PROJECT] AND text ~ '[konu]' AND status = Done ORDER BY updated DESC"
  - ayni_label:   "project = [PROJECT] AND labels = '[etiket]' ORDER BY updated DESC"
  - bu_sprint:    "project = [PROJECT] AND sprint in openSprints() ORDER BY priority ASC"
</search-strategy>

<error-handling>
  Rate limit (429): Retry; 60 saniye bekle
  Timeout (504):    Tier 3 ise Tier 2'ye düş; sonra retry
  Not found (404):  Retry yapma; kullanıcıdan giriş iste
  Server error (5xx): Exponential backoff ile 3 deneme; stale cache varsa kullan
  Auth error (401): Cache'e düş; yoksa başarısız say

  Graceful degradation sırası:
  Tier 3 timeout → Tier 2 → Tier 1 → stale cache → kullanıcıya sor
</error-handling>

<batch-operations>
  Story oluştururken 5'erli gruplar halinde işle (rate limit güvencesi).
  Başarısız olanları kaydet; son raporda listele.
  Paralel okuma: Birden fazla issue için eş zamanlı çağrı yap — max 5 paralel.
</batch-operations>

<rules>
  <r>Default tier: Tier 2 (analiz başlangıcı, context &lt; 150k token)</r>
  <r>Context &gt; 150k token ise büyük issue'ları subagent'a offload et</r>
  <r>Tier 3 yalnızca Jira Creator için; diğer agentlar Tier 3 kullanmaz</r>
  <r>Atlassian işlemleri için aktif MCP server'ı kullan — araç adını sabit kodlama</r>
  <r>Cloud ID gerektiğinde Atlassian MCP'den erişilebilir kaynakları çek ve cache'le</r>
</rules>

</skill>
