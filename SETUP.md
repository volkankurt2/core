# CORE — Kurulum Rehberi

---

## Hızlı Kurulum (Önerilen)

```bash
git clone https://github.com/[kullanıcı]/CORE.git
cd CORE
```

Ardından Claude Code veya Copilot Chat'ten kurulum sihirbazını başlatın:

```
/core-setup
```

`/core-setup` her şeyi `~/.core/` altına yazar — proje klasörüne dokunmaz.

---

## Kurulum Kontrol Listesi

### 1. MCP Bağlantısı (Zorunlu)

Platform'a göre MCP yapılandırması `/core-setup` tarafından gösterilir. Manuel kurulum:

**Claude Desktop** — `~/Library/Application Support/Claude/claude_desktop_config.json`:
```json
{
  "mcpServers": {
    "atlassian": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-atlassian"],
      "env": {
        "ATLASSIAN_URL":       "https://[ŞİRKET].atlassian.net",
        "ATLASSIAN_USERNAME":  "[email@sirket.com]",
        "ATLASSIAN_API_TOKEN": "[api-token]"
      }
    }
  }
}
```

**VS Code / Copilot** — proje kökünde `.vscode/mcp.json`:
```json
{
  "servers": {
    "atlassian-rovo": {
      "url": "https://mcp.atlassian.com/v1/mcp",
      "type": "http"
    }
  }
}
```

API token: https://id.atlassian.com/manage-profile/security/api-tokens

- [ ] MCP yapılandırıldı
- [ ] Test: "Jira'daki son 3 ticket'ı listele" çalışıyor

---

### 2. Sistem Konfigürasyonu (Zorunlu)

`/core-setup` ile otomatik oluşturulur: `~/.core/config/system.yaml`

Manuel düzenleme gerekirse:

```yaml
output_language: tr           # tr veya en
hallucination_threshold: 0.85
prd_max_review_iterations: 2
min_quality_score: 3.0

integrations:
  dry_run: false              # true → Jira/Confluence'e hiçbir şey yazılmaz
  jira:
    enabled: true
  confluence:
    enabled: true
```

- [ ] Dil ve entegrasyon ayarları kontrol edildi

---

### 3. Domain Kurulumu (Zorunlu)

`/core-setup` ile otomatik oluşturulur: `~/.core/domains/[domain]/domain-context.yaml`

Manuel oluşturmak için şablonu kullanın:

```bash
mkdir -p ~/.core/domains/[domain-id]
cp .core/domains/_template/domain-context.yaml ~/.core/domains/[domain-id]/domain-context.yaml
```

`domain-context.yaml` içinde doldurulması gereken alanlar:

#### Zorunlu Alanlar

| Alan | Açıklama | Örnek |
|------|----------|-------|
| `domain` | Benzersiz domain ID | `insurance` |
| `display_name` | Okunabilir isim | `Sigorta Servisleri` |
| `jira_project` | Jira proje kodu | `INS` |
| `confluence_space` | Confluence space kodu | `INS` |

#### services (en az 1)

```yaml
services:
  - id: my-service
    name: My Service
    description: Ne yapar?
    tech: Java / Spring Boot
    criticality: P0          # P0 / P1 / P2
    owner_team: Backend
    kb: knowledge-base/my-service.json    # /rk-scan ile oluşturulur
```

#### regulations (en az 1)

```yaml
regulations:
  - id: KVKK
    scope: Kişisel veri işleyen tüm işlemler
    risk_if_missed: Düzenleyici para cezası
    analyst_checklist:
      - 'Veri minimizasyonu sağlandı mı?'
      - 'Açık rıza alındı mı?'
```

#### Opsiyonel Alanlar

- `prd_review_extra_criteria` — domain'e özgü PRD denetim maddeleri (`mandatory` / `warning`)
- `test_scenario_templates` — zorunlu test senaryosu şablonları
- `glossary` — domain terimleri sözlüğü

Şablon: `.core/domains/_template/domain-context.yaml`

- [ ] domain-context.yaml dolduruldu (jira_project, confluence_space, services, regulations)

---

### 4. Servis Knowledge Base'leri (Önemli)

Codebase Analyst, etki analizi için `~/.core/knowledge-base/*.json` dosyalarına ihtiyaç duyar.

```
/rk-scan https://github.com/[org]/[servis-repo]
```

Tüm servisleri taradıktan sonra cross-repo haritayı üretin:

```
/rk-map
```

- [ ] Tüm servisler için `/rk-scan` çalıştırıldı
- [ ] `/rk-map` ile ekosistem haritası oluşturuldu

---

### 5. Analist Profili (Tavsiye)

`/core-setup` ile otomatik oluşturulur: `~/.core/memory/personal/[isim].md`

Manuel oluşturmak için:

```bash
cp memory/personal/template.md ~/.core/memory/personal/[isim].md
```

- [ ] Analist profili oluşturuldu

---

### 6. Confluence BRD Arşivi (Tavsiye)

`.core/agents/jira-creator.agent.md` → Adım 5 → `parentId` alanını bulun.
Confluence'tan BRD Arşivi sayfasının ID'sini alıp yazın.
_(Confluence → Sayfa → ... → Sayfa Bilgileri → URL'de `pageId=XXXXX`)_

- [ ] Confluence BRD Arşivi page ID güncellendi

---

### 7. Kurumsal Kararlar (Opsiyonel)

`~/.core/memory/decisions/institutional-memory.md` — Ekibinizin bilinen mimari kararlarını,
düzenleme yorumlarını ve standartlarını ekleyin. CORE her analizde bunları bağlam olarak kullanır.

- [ ] Bilinen kurumsal kararlar eklendi

---

### 8. Domain Customize Overlay (Opsiyonel)

`.core/agents/` dosyalarını doğrudan düzenlemek yerine, şirkete özgü kuralları overlay katmanına yazın.
Bu sayede `git pull` ile CORE güncellemesi yapabilirsiniz.

```bash
mkdir -p ~/.core/domains/[domain-id]/customize
cp .core/domains/_template/customize/_example.customize.yaml \
   ~/.core/domains/[domain-id]/customize/prd.customize.yaml
```

Overlay dosyası yapısı:

```yaml
agent: prd            # hangi agent için

extra_rules:
  - "Tüm PRD'ler KVKK madde 12 kontrolü içermeli"

workflow_injections:
  after_step_1:
    - "Yetkili imza zorunlu mu? Kontrol et."

memories:
  - "Prod deploy'lar Salı-Perşembe 10:00-16:00 arası"
```

---

## Minimum Başlangıç

Yalnızca bunları yaparsanız sistem çalışır:
1. MCP bağlantısı (Madde 1)
2. `/core-setup` → domain ve Jira anahtarları
3. `/core-analyze [ticket-no]`

---

## Yeni Domain Ekleme

```bash
mkdir -p ~/.core/domains/[domain-id]
cp .core/domains/_template/domain-context.yaml ~/.core/domains/[domain-id]/domain-context.yaml
# domain-context.yaml'ı düzenle
# ~/.core/config/system.yaml → active_domain: [domain-id]
```

Kontrol listesi:
- [ ] Interview Agent domain sözlüğünü ve servis listesini biliyor
- [ ] PRD Agent doğru yasal çerçeveye atıfta bulunuyor
- [ ] PRD Reviewer regülasyon kontrol listesini uyguluyor
- [ ] Jira Creator doğru proje ve space kodlarını kullanıyor

---

## Dizin Yapısı

**Repo (git):**
```
CORE/
├── .core/                   ← agent/skill/prompt — tek kaynak
│   ├── agents/
│   ├── skills/
│   ├── prompts/
│   └── domains/_template/   ← domain şablonu
├── .claude/commands/        ← Claude Code slash komutları
├── .github/
│   ├── agents/              ← Copilot @agent dosyaları
│   └── copilot-instructions.md
└── memory/*/template.md     ← boş şablonlar (referans)
```

**Kullanıcı verisi (`~/.core/`):**
```
~/.core/
├── config/system.yaml
├── domains/[domain-id]/
│   ├── domain-context.yaml
│   └── customize/           ← agent overlay (opsiyonel)
├── memory/
│   ├── decisions/institutional-memory.md
│   ├── tbd-tracker/tbd-tracker.md
│   ├── feedback/feedback-log.md
│   └── personal/[analist].md
├── core-output/[TICKET]/    ← analiz çıktıları
└── knowledge-base/          ← repo-scanner çıktısı
```

---

## Sık Sorulan Sorular

**Birden fazla domain destekliyor musunuz?**
Evet. `~/.core/domains/` altına istediğiniz kadar domain ekleyebilirsiniz. `~/.core/config/system.yaml` içindeki `active_domain` değerini değiştirerek geçiş yapın.

**Türkçe dışında dil kullanabilir miyim?**
Evet. `~/.core/config/system.yaml` içinde `output_language: en` yapın.

**Jira olmadan kullanabilir miyim?**
Evet, kısmi olarak. `integrations.jira.enabled: false` yapın. Jira Creator agent çalışmaz ama diğer agent'lar sorunsuz çalışır.

**Sadece doküman üretmek, Atlassian'a yazmak istemiyorum.**
`~/.core/config/system.yaml` içinde `integrations.dry_run: true` yapın veya analiz sırasında `--dry-run` argümanı kullanın.

**`git pull` yaptım, verilerim kaybolur mu?**
Hayır. Tüm kullanıcı verisi `~/.core/` altındadır — git repo'suyla ilgisi yoktur.
