# CORE — Company Ops Role Engine
### AI-Destekli Otonom İş Analiz Sistemi
> Jira ticket'tan tam belgelenmiş geliştirme planına — tek komutla.

---

## Nedir?

CORE, iş taleplerini (Jira ticket veya serbest metin) alarak uçtan uca analiz eden,
13 AI agent'tan oluşan otonom bir sistemdir. Her agent bir öncekinin çıktısını girdi olarak alır.

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
- Her servis için `knowledge-base/[servis].json` — API'ler, bağımlılıklar, güvenlik riskleri, test durumu
- Cross-repo bağımlılık ve etki haritası (`knowledge-base/_ecosystem_map.json`)
- Geliştirici soruları için anlık yönlendirme

---

## Agent Zinciri (Analiz)

```
/core-analyze PAY-1234
        ↓
  Interview Agent        → 00-requirements-brief.md
  [Çelişki kontrolü ✓]
        ↓ handoff
  PRD Agent              → 01-prd.md + 02-brd.md
  [Halüsinasyon doğrulama ✓]
        ↓ handoff
  PRD Reviewer           → 03-review-report.md
   ONAY ↓   ↑ RED (maks 2 iterasyon)
  Codebase Analyst       → 04-impact-analysis.md
  [knowledge-base/*.json kaynak olarak kullanır]
        ↓ handoff
  Implementation Planner → 05-user-stories.md + 06-test-scenarios.md + 07-implementation-plan.md
        ↓ handoff
  Jira Creator           → Jira backlog + Confluence BRD sayfası
        ↓
  Feedback Collector     → Analist puanlaması + kurumsal hafıza güncelleme
```

| # | Agent | Çıktı |
|---|-------|-------|
| 1 | **Interview Agent** | `00-requirements-brief.md` |
| 2 | **PRD Agent** | `01-prd.md` + `02-brd.md` |
| 3 | **PRD Reviewer** | `03-review-report.md` (ONAY / RED) |
| 4 | **Codebase Analyst** | `04-impact-analysis.md` |
| 5 | **Implementation Planner** | `05-user-stories.md` + `07-implementation-plan.md` |
| 6 | **Jira Creator** | Jira ticket'ları + Confluence sayfası |
| 7 | **Feedback Collector** | `memory/` güncellenir |

---

## Agent Zinciri (Repo Knowledge)

```
/rk-scan [repo-url]
        ↓
  Repo Scanner     → knowledge-base/[servis].json
  (tekrar çağrılır her yeni servis için)
        ↓
/rk-map
        ↓
  Ecosystem Mapper → knowledge-base/_ecosystem_map.json
        ↓
/rk-advise [görev]
        ↓
  Dev Advisor      → 8 başlıklı geliştirici rehberi
```

| # | Agent | Çıktı |
|---|-------|-------|
| 8 | **Repo Scanner** | `knowledge-base/[servis].json` — servis tüm detaylarıyla |
| 9 | **Ecosystem Mapper** | `knowledge-base/_ecosystem_map.json` — cross-repo harita |
| 10 | **Dev Advisor** | Anlık geliştirici yönlendirmesi |
| 11 | **Setup Agent** | `config/system.yaml`, `domains/*/domain-context.yaml` — kurulum |
| 12 | **Prompt Optimizer** | `.core/agents/*.agent.md` — agent kalitesini iyileştirme |
| 13 | **Orchestrator** | Tüm analiz zincirini uçtan uca yönetir |

---

## Kurulum — Claude (Claude Code CLI / Desktop)

### Adım 1 — Repo'yu Klonla

```bash
git clone https://github.com/[kullanici]/CORE.git
cd CORE
```

### Adım 2 — /core-setup Çalıştır

Claude Code'u başlatın ve kurulum sihirbazını çalıştırın:

```
/core-setup
```

Sihirbaz şunları sorar:
- **Platform:** Claude Code CLI / Claude Desktop / VS Code / GitHub Copilot
- Jira / Confluence URL ve API token
- Aktif domain (ör. `payment`)
- Analist adı
- Kalite eşikleri

Sihirbaz biter bitmez:
- `config/system.yaml` oluşturulur
- `domains/[domain]/domain-context.yaml` oluşturulur
- `.claude/commands/` altına tüm slash komutları kopyalanır
- MCP kurulum talimatları (platform'a göre exact komut/JSON) gösterilir

### Adım 3 — Servis KB'lerini Oluştur

Codebase Analyst, etki analizi için `knowledge-base/*.json` dosyalarına ihtiyaç duyar.
Her servis için Repo Scanner'ı çalıştır:

```
/rk-scan https://github.com/[org]/[servis-repo]
```

Scanner tamamlandığında `knowledge-base/[servis].json` oluşturulur.
`domain-context.yaml`'daki `kb:` alanı otomatik olarak bu dosyaya işaret eder.

Tüm servisleri taradıktan sonra cross-repo haritayı üret:

```
/rk-map
```

### Adım 4 — İlk Analizi Çalıştır

```
/core-analyze PAY-1234
```

---

## Kurulum — GitHub Copilot

### Ön Koşul: VS Code + MCP

1. VS Code'a **GitHub Copilot** extension kur
2. VS Code'a **Atlassian MCP** extension kur veya `/core-setup` ile yapılandır

### Adım 1 — Repo'yu Klonla

```bash
git clone https://github.com/[kullanici]/CORE.git
cd CORE
```

### Adım 2 — /core-setup Çalıştır (Copilot Platformu)

Claude Code'u başlatın:

```
/core-setup
```

Sihirbazda **Platform:** `4 → GitHub Copilot` seçin.

Sihirbaz şunları otomatik oluşturur:
- `.github/copilot-instructions.md` → Copilot'a tüm agent talimatlarını tanıtır
- `.vscode/mcp.json` için exact JSON içeriği gösterilir (manuel oluşturmanız gerekir)

### Adım 3 — Domain ve KB Yapılandır

Claude kurulumundaki Adım 3 ve 4 ile aynıdır.

### Adım 4 — Copilot Chat'ten Kullan

VS Code'da Copilot Chat panelini aç (`Ctrl+Shift+I` / `Cmd+Shift+I`):

```
@workspace /core-analyze PAY-1234
```

veya doğrudan:

```
CORE sistemi ile PAY-1234 ticket'ını analiz et
```

> Copilot, `.github/copilot-instructions.md` sayesinde tüm agent zincirini otomatik çalıştırır.

---

## Komutlar

Komutlar platforma göre farklı mekanizma kullanır — içerik aynı, format farklı:

| Claude Code (slash) | Copilot (prompt) | Açıklama |
|---------------------|------------------|----------|
| `/core-analyze [ticket]` | `#core-analyze` | Standart analiz zinciri |
| `/core-epic-analyze [ticket]` | `#core-epic-analyze` | Epic ölçekli analiz |
| `/core-memory [konu]` | `#core-memory` | Kurumsal hafıza sorgusu |
| `/core-tbd` | — | Açık TBD'leri listele |
| `/core-pptx [ticket]` | — | Yönetim sunumu (PPTX) |
| `/core-excel [ticket]` | — | Teknik etki matrisi (Excel) |
| `/core-optimize [agent?]` | — | Agent prompt'larını optimize et |
| `/core-analytics [N\|ticket]` | — | Performans metrikleri |
| `/core-setup` | `#core-setup` | Kurulum sihirbazı |
| `/core-setup-boards` | `#core-setup-boards` | Jira board keşfi |
| `/rk-scan [repo-url]` | `#rk-scan` | Repo tara → knowledge-base |
| `/rk-map` | `#rk-map` | Ekosistem haritası üret |
| `/rk-advise [görev]` | `#rk-advise` | Geliştirici yönlendirmesi |
| — | `#core-help` | Durum ve yardım |

> **Claude Code:** `.claude/commands/` altındaki dosyalar slash komutu olarak görünür.
> **Copilot:** `.github/prompts/` altındaki `.prompt.md` dosyaları `#` ile çağrılır.

### Örnek Kullanımlar

```
# Claude Code
/core-analyze PROJ-1234
/rk-scan https://github.com/[org]/[servis-repo]
/rk-advise Ödeme limitini hangi servise, hangi katmana yazmalıyım?

# Copilot Chat
#core-analyze   → input: PROJ-1234
#rk-scan        → input: https://github.com/[org]/[servis-repo]
#rk-advise      → input: Ödeme limitini hangi servise yazmalıyım?
#core-help      → mevcut analiz durumu ve komut listesi
```

---

## Knowledge Base (knowledge-base/)

CORE, etki analizini gerçek codebase verisiyle besler. Manuel README yerine her servisin otomatik taranan JSON KB dosyası kullanılır.

```
knowledge-base/
├── _progress.json          ← Hangi repolar tarandı, ne zaman?
├── _ecosystem_map.json     ← Cross-repo bağımlılık haritası (rk-map üretir)
├── payment.json            ← Payment Service KB
├── okc.json                ← OKC Service KB
├── payment-handler.json    ← Payment Handler KB
├── mobile.json             ← Mobile Backend KB
└── ...                     ← Diğer servisler
```

Her `knowledge-base/[servis].json` dosyası şunları içerir:
- API endpoint kataloğu (controller + metod düzeyinde)
- Servis bağımlılık grafiği
- DTO şemaları ve enum kataloğu
- Güvenlik haritası ve riskleri
- Test durumu ve kapsanmayan kritik sınıflar
- Teknik borç ve performans riskleri
- Migration durumu

**KB ne zaman güncellenir?** Repo'da önemli bir değişiklik olduğunda `/rk-scan` yeniden çalıştırılır. `_progress.json` hangi servislerin güncel olduğunu gösterir.

---

## Yeni Domain Ekle

```bash
mkdir -p domains/[domain-id]
cp .core/domains/_template/domain-context.yaml domains/[domain-id]/domain-context.yaml
# domain-context.yaml'ı düzenle (domain, jira_project, services, regulations)
# services altında her servis için:
#   kb: knowledge-base/[servis-id].json   ← repo-scanner ile oluşturulan dosya

# Aktif yap:
# config/system.yaml → active_domain: [domain-id]
```

> Adım adım kılavuz: `SETUP.md`

---

## Kurumsal Hafıza

CORE, analiz süreçlerinde kurumsal bilgiyi üç katmanda yönetir:

### Kalıcı Kararlar (`memory/decisions/institutional-memory.md`)

Tüm analizlerde geçerli mimari ve iş kararları (KUR-NNN formatı):

| Karar | Başlık |
|-------|--------|
| KUR-001 | *(Örnek)* API Versiyon Politikası — yeni entegrasyonlarda v2 zorunlu |
| KUR-NNN | Kendi kurumsal kararlarınız otomatik eklenir |

Yeni analiz başlarken CORE bu kararları otomatik tarar. Çelişki tespit edilirse:
- 🔴 **Kategori A** — Analiz durur, kullanıcı karar verir
- 🟡 **Kategori B** — PRD'ye "Dikkat" bölümü eklenir
- 🔵 **Kategori C** — "Geçmiş Referanslar" bölümüne eklenir

### TBD Takibi (`memory/tbd-tracker/tbd-tracker.md`)

Analiz sırasında yanıtlanamayan sorular TBD olarak kaydedilir, Jira'da `has-open-tbd` etiketiyle işaretlenir.

### Kişisel Hafıza (`memory/personal/[analist].md`)

Her analistin tercih ettiği yaklaşımlar, geçmiş puanlar ve geliştirilecek alanlar.

---

## Skill'ler

| Skill | Görev |
|-------|-------|
| `elicitation` | Ticket yeterlilik skoru + yapılandırılmış diyalog: 5 Whys, sessizlik kuralı, varsayım onayı |
| `hallucination-guard` | Servis adı, API, regülasyon referanslarını `knowledge-base/*.json` ve `domain-context.yaml`'a karşı doğrular |
| `memory-conflict-checker` | Yeni gereksinim ile KUR kararlarını karşılaştırır |
| `brd-quality` | BRD için kontrol listeleri ve şablonlar |
| `output-formats` | PPTX, Excel, Jira yorumu ve Confluence sayfa formatları |
| `integrations` | Jira ve Confluence MCP aksiyonları (okuma + yazma) |
| `jira-smart-read` | Jira ticket'larını ve bağlı issue'ları akıllı okur |
| `performance-tracker` | Her analiz için `metrics.json` üretir |
| `scan-java` | Repo Scanner için Java/Spring Boot derin tarama protokolü |
| `scan-dotnet` | Repo Scanner için .NET/C# derin tarama protokolü |

---

## Çıktı Yapısı

```
core-output/PAY-1234/
├── 00-requirements-brief.md   ← Gereksinim özeti
├── 01-prd.md                  ← GGD
├── 02-brd.md                  ← BRD
├── 03-review-report.md        ← ONAY / RED kararı
├── 04-impact-analysis.md      ← Etkilenen servisler, risk, efor
├── 05-user-stories.md         ← Gherkin AC formatında user stories
├── 06-test-scenarios.md       ← Test senaryoları
├── 07-implementation-plan.md  ← Sprint planı
├── metrics.json               ← Performans ve maliyet metrikleri
└── teknik-etki-matrisi.xlsx   ← Excel etki matrisi (opsiyonel)
```

---

## Klasör Yapısı

```
CORE/
├── CLAUDE.md                              ← Her oturumda otomatik yüklenir
├── SETUP.md                               ← Kurulum rehberi + domain kılavuzu
│
├── .core/                                 ← Tek kaynak — git'te versiyonlanır
│   ├── agents/                            ← 13 agent (.agent.md)
│   │   ├── interview.agent.md             ← Analiz zinciri (9 agent)
│   │   ├── prd.agent.md
│   │   ├── prd-reviewer.agent.md
│   │   ├── codebase-analyst.agent.md
│   │   ├── implementation-planner.agent.md
│   │   ├── jira-creator.agent.md
│   │   ├── feedback-collector.agent.md
│   │   ├── pptx-generator.agent.md
│   │   ├── excel-generator.agent.md
│   │   ├── repo-scanner.agent.md          ← RK zinciri (3 agent)
│   │   ├── ecosystem-mapper.agent.md
│   │   └── dev-advisor.agent.md
│   │
│   ├── skills/                            ← 10 skill (SKILL.md)
│   │   ├── hallucination-guard/
│   │   ├── memory-conflict-checker/
│   │   ├── brd-quality/
│   │   ├── output-formats/
│   │   ├── integrations/
│   │   ├── jira-smart-read/
│   │   ├── performance-tracker/
│   │   ├── scan-java/                     ← RK skill'leri
│   │   └── scan-dotnet/
│   │
│   └── prompts/                           ← Analiz giriş noktaları
│
├── .claude/
│   └── commands/                          ← Claude Code slash komutları (git'te)
│
├── .github/
│   ├── copilot-instructions.md            ← Copilot sistem talimatları
│   └── prompts/                           ← Copilot prompt dosyaları (slash komut eşdeğeri)
│
├── domains/
│   └── [domain-id]/domain-context.yaml   ← Aktif domain pack (gitignored)
│
├── knowledge-base/                                    ← Servis knowledge base (gitignored)
│   ├── _progress.json                     ← Tarama durumu
│   ├── _ecosystem_map.json                ← Cross-repo harita
│   └── [servis].json                      ← repo-scanner ile üretilir
│
├── memory/                                ← Kurumsal hafıza (kısmen gitignored)
│   ├── decisions/institutional-memory.md
│   ├── tbd-tracker/tbd-tracker.md
│   ├── feedback/feedback-log.md
│   └── personal/
│
├── config/
│   └── system.yaml                        ← Tüm konfigürasyon
│
└── core-output/                           ← Analiz çıktıları (gitignored)
```

---

## Referans Dosyalar

| Dosya | Amaç |
|-------|------|
| `CLAUDE.md` | Agent zinciri ve proje kuralları — her oturumda yüklenir |
| `SETUP.md` | Kurulum rehberi, kontrol listesi, domain kılavuzu |
| `config/system.yaml` | Dil, platform, domain, entegrasyon, kalite eşikleri |
| `domains/[domain]/domain-context.yaml` | Servisler (`kb:` alanı), regülasyonlar, board'lar |
| `knowledge-base/_progress.json` | Hangi servisler tarandı ve güncel mi? |
| `knowledge-base/_ecosystem_map.json` | Cross-repo bağımlılık ve etki haritası |
| `memory/decisions/institutional-memory.md` | Kurumsal kararlar (KUR-NNN) |
| `memory/tbd-tracker/tbd-tracker.md` | Açık belirsizlikler |
| `memory/personal/template.md` | Analist hafıza şablonu |
