# CORE — Company Ops Role Engine
# Her oturum başında otomatik yüklenir.

## Agent Zinciri (Handoff)
```
/core-analyze veya /core-epic-analyze
        ↓
  Interview Agent        → 00-requirements-brief.md
        ↓ handoff
  PRD Agent              → 01-prd.md + 02-brd.md
        ↓ handoff
  PRD Reviewer           → 03-review-report.md
   ONAY ↓   ↑ RED (PRD Agent'a geri)
  Codebase Analyst       → 04-impact-analysis.md
        ↓ handoff
  Implementation Planner → 05-user-stories.md + 06-test-scenarios.md + 07-implementation-plan.md
        ↓ handoff
  Jira Creator           → Jira backlog + Confluence BRD
        ↓
  Feedback Collector     → analist kalite değerlendirmesi + memory güncelle
```

## Agent ve Skill Dosya Formatı
Agent ve skill dosyaları **XML-in-Markdown** formatında yazılmıştır:
- `<agent id="..." name="..." version="..." icon="...">` → `<activation>`, `<workflow>`, `<output>`, `<rules>`
- `<skill id="..." version="...">` → `<purpose>`, içerik blokları, `<rules>`

Python pseudocode yoktur. Direktifler doğal dil + XML yapısıyla anlatılır.
Her platform (Claude, Copilot) kendi MCP client'ını kullanır — araç adları sabit kodlanmamıştır.

## Dosya Konumları
```
.core/agents/         ← 13 agent (XML-in-Markdown) — tek kaynak
.core/skills/         ← 10 skill (XML-in-Markdown) — tek kaynak
.core/prompts/        ← orchestrator prompt'lar
.claude/commands/     ← Claude Code slash komutları (git'te, doğrudan edit)
.github/prompts/      ← Copilot prompt dosyaları (git'te, doğrudan edit)
.github/copilot-instructions.md ← Copilot sistem talimatları
domains/[domain-id]/  ← aktif domain pack (/core-setup ile oluşturulur)
config/system.yaml    ← sistem konfigürasyonu
memory/               ← kurumsal hafıza
knowledge-base/       ← servis knowledge base (JSON, repo-scanner ile üretilir)
```

## Her Agent Başlamadan Önce Okuyacaklar
Her agent kendi `<activation>` bloğunda spesifik okuma sırasını tanımlar. Genel sıra:
1. `config/system.yaml` → dil, kalite eşikleri, entegrasyon ayarları, dry_run
2. `domains/[active_domain]/domain-context.yaml` → servisler, regülasyonlar, board'lar
3. `memory/decisions/institutional-memory.md` → kurumsal kararlar
4. `memory/tbd-tracker/tbd-tracker.md` → açık TBD'ler
5. Kendi `.core/agents/[agent-id].agent.md` dosyası
6. İlgili `.core/skills/*/SKILL.md` dosyaları

## Oturum Yönetimi (Fresh Chat Protocol)

BMAD'den uyarlanan bu protokol büyük workflow adımları arasında context kirlenmesini önler:

- **Her büyük zincir adımını yeni oturumda başlatın.** Interview → PRD aşaması geçişinde yeni chat.
- **Devam amaçlı değil, handoff dosyaları amaçlı.** Agent çıktısı (`core-output/[ID]/*.md`) bir sonraki agent'ın girdisidir; tek bağ bu.
- **Neden?** Uzun context → halüsinasyon artar, maliyet yükselir, agent kendi önceki kararlarına takılır.
- **İstisna:** Elicitation diyaloğu (Interview Agent Step 2) doğası gereği aynı oturumda devam eder.

Pratik kural: `/core-analyze` çalıştırdınız → PRD Reviewer ONAY verdi → yeni oturum açın → Codebase Analyst'ı çalıştırın.

## Slash Komutları
- `/core-analyze [ticket/talep]`       → Standart zincir
- `/core-epic-analyze [ticket/talep]`  → Epic zincir
- `/core-tbd`                          → Açık TBD'leri listele
- `/core-memory [konu]`                → Kurumsal hafızayı sorgula
- `/core-pptx [ticket]`               → Yönetim sunumu (PPTX)
- `/core-excel [ticket]`              → Etki matrisi (Excel)
- `/core-optimize [agent?]`           → Agent prompt'larını otomatik optimize et
- `/core-setup`                        → CORE kurulum sihirbazı (ilk kurulum veya güncelleme)
- `/core-analytics`                    → core-output/ metrik özetini göster
- `/core-setup-boards`                 → Jira board'larını keşfet ve domain-context.yaml'a yaz
- `/core-update`                       → CORE framework'ünü git pull ile güvenli güncelle
- `/core-help`                         → Mevcut durumu analiz et, sonraki adımı öner

## Çıktı Klasörü
`core-output/[TICKET-ID]/`
```
00-requirements-brief.md
01-prd.md
02-brd.md
03-review-report.md
04-impact-analysis.md
05-user-stories.md
06-test-scenarios.md
07-implementation-plan.md
metrics.json
```

## Temel Kural
Dil, format ve kalite eşikleri `config/system.yaml` dosyasından okunur.
Varsayılan: `output_language: tr` — tüm dokümanlar, Jira yorumları ve Confluence sayfaları Türkçe.
