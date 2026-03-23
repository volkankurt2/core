# WISE — Workflow Intelligence & Strategy Engine
### AI-Destekli Otonom İş Analiz Sistemi
> Jira ticket'tan tam belgelenmiş geliştirme planına — tek komutla.

---

## Nedir?

WISE, iş taleplerini (Jira ticket veya serbest metin) alarak uçtan uca analiz eden,
19 AI agent'tan oluşan otonom bir sistemdir. Her agent bir öncekinin çıktısını girdi olarak alır.

**İki katmandan oluşur:**

**1. Analiz Zinciri** — iş taleplerini işler, belge üretir, Jira/Confluence'a yazar:
- Gereksinim Özeti (requirements-brief)
- Gereksinim ve Geliştirme Dokümanı — GGD (PRD)
- İş Gereksinimi Dokümanı — BRD
- Teknik Etki Analizi
- User Stories + Test Senaryoları
- Sprint Planı (implementation-plan)
- Jira backlog + Confluence BRD sayfası
- Yönetim sunumu (PPTX) ve etki matrisi (Excel)

**2. Repo Knowledge (RK)** — codebase'i tarayarak servis KB'si oluşturur:
- Her servis için `~/.wise/knowledge-base/[servis].json` — API'ler, bağımlılıklar, güvenlik riskleri
- Cross-repo bağımlılık ve etki haritası (`_ecosystem_map.json`)
- Geliştirici soruları için anlık yönlendirme

---

## Agent Zinciri (Analiz)

```
/wise-analyze PAY-1234
        ↓
  Interview Agent        → 00-requirements-brief.md
  [Çelişki kontrolü ✓]
        ↓ ✋ Handoff Onayı — özet gösterilir, kullanıcı onayı beklenir
  PRD Agent              → 01-prd.md + 02-brd.md
  [Halüsinasyon doğrulama ✓]
        ↓ ✋ Handoff Onayı
  PRD Reviewer           → 03-review-report.md
   ONAY ↓   ↑ RED (maks 2 iterasyon)
        ↓ ✋ Handoff Onayı
  Codebase Analyst       → 04-impact-analysis.md
  [~/.wise/knowledge-base/*.json kaynak olarak kullanır]
        ↓ ✋ Handoff Onayı
  Implementation Planner → 05-user-stories.md + 06-test-scenarios.md + 07-implementation-plan.md
        ↓ ✋ Handoff Onayı (Atlassian yazma öncesi kritik)
  Jira Creator           → Jira backlog + Confluence BRD sayfası
        ↓ ✋ Handoff Onayı
  Feedback Collector     → Analist puanlaması + kurumsal hafıza güncelleme
```

---

## Agent Zinciri (Repo Knowledge)

```
/rk-scan [repo-url]
        ↓
  Repo Scanner     → ~/.wise/knowledge-base/[servis].json
        ↓
/rk-map
        ↓
  Ecosystem Mapper → ~/.wise/knowledge-base/_ecosystem_map.json
        ↓
/rk-advise [görev]
        ↓
  Dev Advisor      → 8 başlıklı geliştirici rehberi
```

---

## Kurulum

### Adım 1 — Repo'yu Klonla

```bash
git clone https://github.com/[kullanici]/WISE.git
cd WISE
```

### Adım 2 — /wise-setup Çalıştır

Claude Code veya Copilot Chat'ten kurulum sihirbazını başlatın:

```
/wise-setup
```

Sihirbaz şunları sorar:
- **Platform:** Claude Code CLI / Claude Desktop / VS Code / GitHub Copilot
- Jira / Confluence URL ve API token
- Aktif domain (ör. `payment`)
- Analist adı ve kalite eşikleri

Sihirbaz biter bitmez tüm kullanıcı verisi `~/.wise/` altına yazılır:
- `~/.wise/config/system.yaml`
- `~/.wise/domains/[domain]/domain-context.yaml`
- `~/.wise/memory/` altındaki hafıza dosyaları
- MCP kurulum talimatları (platform'a göre exact komut/JSON) ekrana gösterilir

### Adım 3 — Servis KB'lerini Oluştur

```
/rk-scan https://github.com/[org]/[servis-repo]
```

Tüm servisleri taradıktan sonra:

```
/rk-map
```

### Adım 4 — İlk Analizi Çalıştır

```
/wise-analyze PAY-1234
```

---

## Komutlar

| Claude Code | Copilot Chat | Açıklama |
|-------------|--------------|----------|
| `/wise-analyze [ticket]` | `@wise-analyze` | Standart analiz zinciri |
| `/wise-epic-analyze [ticket]` | `@wise-epic-analyze` | Epic ölçekli analiz |
| `/wise-memory [konu]` | `@wise-memory` | Kurumsal hafıza sorgusu |
| `/wise-tbd` | `@wise-tbd` | Açık TBD'leri listele / güncelle |
| `/wise-pptx [ticket]` | `@wise-pptx` | Yönetim sunumu (PPTX) |
| `/wise-excel [ticket]` | `@wise-excel` | Teknik etki matrisi (Excel) |
| `/wise-optimize [agent?]` | `@wise-optimize` | Agent prompt'larını optimize et |
| `/wise-analytics [N\|ticket]` | `@wise-analytics` | Performans metrikleri |
| `/wise-help` | `@wise-help` | Mevcut durumu analiz et |
| `/wise-setup` | `@wise-setup` | Kurulum sihirbazı |
| `/wise-setup-boards` | `@wise-setup-boards` | Jira board keşfi |
| `/wise-update` | `@wise-update` | WISE framework'ünü güvenli güncelle |
| `/rk-scan [repo-url]` | `@rk-scan` | Repo tara → knowledge-base |
| `/rk-map` | `@rk-map` | Ekosistem haritası üret |
| `/rk-advise [görev]` | `@rk-advise` | Geliştirici yönlendirmesi |

---

## Klasör Yapısı

**Repo (git ile versiyonlanır):**

```
WISE/
├── .wise/
│   ├── agents/          ← 19 agent (.agent.md) — tek kaynak
│   ├── skills/          ← 10 skill (SKILL.md)
│   └── prompts/         ← analiz giriş noktaları
├── .claude/
│   └── commands/        ← Claude Code slash komutları
├── .github/
│   ├── agents/          ← Copilot @agent dosyaları
│   └── copilot-instructions.md
└── memory/
    └── */template.md    ← boş şablonlar (referans)
```

**Kullanıcı verisi (`~/.wise/` — git dışı, tüm platformlarda ortak):**

```
~/.wise/
├── config/system.yaml          ← sistem konfigürasyonu
├── domains/[domain-id]/        ← domain pack (/wise-setup ile oluşturulur)
├── memory/                     ← kurumsal hafıza (kararlar, TBD, feedback)
├── wise-output/                ← analiz çıktıları
└── knowledge-base/             ← servis knowledge base (repo-scanner çıktısı)
```

---

## Kurumsal Hafıza

WISE, analiz süreçlerinde kurumsal bilgiyi üç katmanda yönetir:

### Kalıcı Kararlar (`~/.wise/memory/decisions/institutional-memory.md`)

Tüm analizlerde geçerli mimari ve iş kararları (KUR-NNN formatı). Yeni analiz başlarken WISE bu kararları otomatik tarar. Çelişki tespit edilirse:
- 🔴 **Kategori A** — Analiz durur, kullanıcı karar verir
- 🟡 **Kategori B** — PRD'ye "Dikkat" bölümü eklenir
- 🔵 **Kategori C** — "Geçmiş Referanslar" bölümüne eklenir

### TBD Takibi (`~/.wise/memory/tbd-tracker/tbd-tracker.md`)

Analiz sırasında yanıtlanamayan sorular TBD olarak kaydedilir.

### Kişisel Hafıza (`~/.wise/memory/personal/[analist].md`)

Her analistin tercihler, geçmiş puanlar ve geliştirilecek alanlar.

---

## Skill'ler

| Skill | Görev |
|-------|-------|
| `elicitation` | Ticket yeterlilik skoru + yapılandırılmış diyalog |
| `hallucination-guard` | Servis adı, API, regülasyon referanslarını doğrular |
| `memory-conflict-checker` | Yeni gereksinim ile KUR kararlarını karşılaştırır |
| `brd-quality` | BRD kontrol listeleri ve şablonlar |
| `output-formats` | PPTX, Excel, Jira yorumu ve Confluence formatları |
| `integrations` | Jira ve Confluence MCP aksiyonları |
| `jira-smart-read` | Jira ticket'larını akıllı okur |
| `performance-tracker` | Her analiz için `metrics.json` üretir |
| `scan-java` | Java/Spring Boot derin tarama protokolü |
| `scan-dotnet` | .NET/C# derin tarama protokolü |

---

## Çıktı Yapısı

```
~/.wise/wise-output/PAY-1234/
├── 00-requirements-brief.md
├── 01-prd.md
├── 02-brd.md
├── 03-review-report.md
├── 04-impact-analysis.md
├── 05-user-stories.md
├── 06-test-scenarios.md
├── 07-implementation-plan.md
└── metrics.json
```

---

## Referans Dosyalar

| Dosya | Amaç |
|-------|------|
| `SETUP.md` | Kurulum rehberi ve kontrol listesi |
| `~/.wise/config/system.yaml` | Dil, platform, domain, kalite eşikleri |
| `~/.wise/domains/[domain]/domain-context.yaml` | Servisler, regülasyonlar, board'lar |
| `~/.wise/knowledge-base/_progress.json` | Hangi servisler tarandı? |
| `~/.wise/memory/decisions/institutional-memory.md` | Kurumsal kararlar (KUR-NNN) |
| `~/.wise/memory/tbd-tracker/tbd-tracker.md` | Açık belirsizlikler |
