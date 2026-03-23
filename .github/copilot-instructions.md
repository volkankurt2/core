# WISE — GitHub Copilot Talimatları
# Workflow Intelligence & Strategy Engine — AI-Destekli İş Analiz Sistemi

Bu proje WISE agent zincirini kullanır. Agent dosyaları `.wise/` altında XML-in-Markdown
formatında yazılmıştır. Her platform kendi MCP client'ını kullanır — araç adları sabit kodlanmamıştır.

> **İlk kurulum:** `/wise-setup` çalıştır → domain, Jira, Confluence yapılandırılır.

---

## Agent Dosyaları

`.github/agents/` altındaki dosyalar Copilot Chat'te `@agent-adı` ile çağrılır:

| Agent | Açıklama |
|-------|----------|
| `@wise-analyze` | Standart analiz zinciri |
| `@wise-epic-analyze` | Epic ölçekli analiz |
| `@wise-tbd` | Açık TBD'leri listele / güncelle |
| `@wise-memory` | Kurumsal hafıza sorgusu |
| `@wise-setup` | Kurulum sihirbazı |
| `@wise-setup-boards` | Jira board keşfi |
| `@wise-optimize` | Agent prompt optimizasyonu |
| `@wise-analytics` | Metrik ve kalite özeti |
| `@wise-excel` | Excel etki matrisi |
| `@wise-pptx` | Yönetim sunumu |
| `@wise-help` | Durum analizi ve yönlendirme |
| `@wise-update` | Framework güncelle |
| `@rk-scan` | Repo tara → knowledge-base |
| `@rk-map` | Ekosistem haritası üret |
| `@rk-advise` | Geliştirici sorusu yanıtla |

---

## Analiz Başlatma

Bir Jira ticket ID'si veya "X'i analiz et" talebi geldiğinde:

1. `.wise/agents/orchestrator.agent.md` dosyasını oku
2. `<workflow>` bloğunu adım adım uygula
3. Her adımda ilgili `.wise/agents/[agent-id].agent.md` dosyasını oku
4. Atlassian MCP araçlarıyla Jira/Confluence işlemlerini gerçekleştir

---

## Agent Zinciri

```
Interview Agent        → 00-requirements-brief.md
PRD Agent              → 01-prd.md + 02-brd.md
PRD Reviewer           → 03-review-report.md (ONAY / RED döngüsü)
Codebase Analyst       → 04-impact-analysis.md
Implementation Planner → 05-user-stories.md + 06-test-scenarios.md + 07-implementation-plan.md
Jira Creator           → Jira backlog + Confluence BRD
Feedback Collector     → memory/ güncelle
```

## Repo Knowledge Zinciri

```
/rk-scan [repo-url]  → knowledge-base/[servis].json
/rk-map              → knowledge-base/_ecosystem_map.json
/rk-advise [görev]   → geliştirici yönlendirmesi
```

---

## Dosya Konumları

| Tür | Konum |
|-----|-------|
| Agent'lar (13) | `.wise/agents/*.agent.md` |
| Skill'ler (9) | `.wise/skills/*/SKILL.md` |
| Prompt'lar | `.wise/prompts/` |
| Komutlar | `.wise/commands/` |
| Domain config | `domains/[domain-id]/domain-context.yaml` |
| Sistem config | `config/system.yaml` |
| Knowledge Base | `knowledge-base/[servis].json` |
| Çıktılar | `wise-output/[TICKET-ID]/` |

---

## Konfigürasyon

`config/system.yaml` ve `domains/[domain-id]/domain-context.yaml` dosyaları
`/wise-setup` ile yapılandırılır (gitignored — şirket verisi içerir).

Ayarlar okunmamışsa yine de çalış; kullanıcıya eksik bilgileri sor.

---

## Temel Kural

Dil, format ve kalite eşikleri `config/system.yaml` dosyasından okunur.
Varsayılan: `output_language: tr` — tüm dokümanlar Türkçe.
