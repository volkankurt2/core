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

`/core-setup` şunları yapar:
- Jira / Confluence bağlantısını yapılandırır
- Domain konfigürasyonu oluşturur
- Analist profili oluşturur
- Kalite eşiklerini ayarlar
- MCP kurulum talimatlarını platform'a göre gösterir

---

## Kurulum Kontrol Listesi

### 1. MCP Bağlantısı (Zorunlu)

Dosya: `~/Library/Application Support/Claude/claude_desktop_config.json`

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

API token: https://id.atlassian.com/manage-profile/security/api-tokens

- [ ] ATLASSIAN_URL dolduruldu
- [ ] ATLASSIAN_USERNAME dolduruldu
- [ ] ATLASSIAN_API_TOKEN oluşturuldu ve eklendi
- [ ] Test: "Jira'daki son 3 ticket'ı listele" çalışıyor

---

### 2. Sistem Konfigürasyonu (Zorunlu)

`config/system.yaml` dosyasını düzenleyin:

```yaml
output_language: tr    # tr veya en
hallucination_threshold: 0.85
prd_max_review_iterations: 2
min_quality_score: 3.0
chain_mode: auto_handoff

integrations:
  dry_run: false        # true → Jira/Confluence'e hiçbir şey yazılmaz
  jira:
    enabled: true
  confluence:
    enabled: true
```

- [ ] Dil ayarlandı
- [ ] Entegrasyon ayarları kontrol edildi

---

### 3. Domain Kurulumu (Zorunlu)

```bash
# Şablondan yeni domain oluştur
mkdir -p domains/[domain-id]
cp .core/domains/_template/domain-context.yaml domains/[domain-id]/domain-context.yaml

# Aktif domain'i ayarla — config/system.yaml:
active_domain: [domain-id]
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
  - id: [REGULASYON_ID]         # Örn: GDPR, HIPAA, KVKK, sektörünüze özgü
    scope: [Hangi işlemler kapsanıyor]
    risk_if_missed: [Uyumsuzlukta ne olur]
    analyst_checklist:
      - '[Kontrol edilmesi gereken soru]'
```

#### Opsiyonel Alanlar

- `prd_review_extra_criteria` — domain'e özgü PRD denetim maddeleri (`mandatory` / `warning`)
- `test_scenario_templates` — zorunlu test senaryosu şablonları
- `glossary` — domain terimleri sözlüğü

Şablon dosyasına bakın: `.core/domains/_template/domain-context.yaml`

- [ ] system.yaml güncellendi
- [ ] domain-context.yaml dolduruldu (jira_project, confluence_space, services, regulations)

---

### 4. Jira Proje Anahtarları (Zorunlu)

`domains/[domain]/domain-context.yaml` içinde:

```yaml
jira_project: PAY        # Jira proje kodu
confluence_space: PAY    # Confluence space kodu
```

- [ ] Jira project key dolduruldu
- [ ] Confluence space key dolduruldu

---

### 5. Servis Knowledge Base'leri (Önemli)

Codebase Analyst agent, etki analizi için `knowledge-base/*.json` dosyalarına ihtiyaç duyar.
Her servis için Repo Scanner'ı çalıştırın:

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

### 6. Analist Profili (Tavsiye)

```bash
cp memory/personal/template.md memory/personal/[isim].md
```

Dosyada `analyst_id`, `role` ve `domain` alanlarını doldurun.

- [ ] Kişisel hafıza dosyası oluşturuldu

---

### 7. Confluence BRD Arşivi (Tavsiye)

`.core/agents/jira-creator.agent.md` → Adım 5 → `parentId` alanını bulun.
Confluence'tan BRD Arşivi sayfasının ID'sini alıp yazın.
_(Confluence → Sayfa → ... → Sayfa Bilgileri → URL'de `pageId=XXXXX`)_

- [ ] Confluence BRD Arşivi page ID güncellendi: ___________

---

### 8. Kurumsal Kararlar (Opsiyonel)

`memory/decisions/institutional-memory.md` — Ekibinizin bilinen mimari kararlarını,
düzenleme yorumlarını ve standartlarını ekleyin. CORE her analizde bunları bağlam olarak kullanır.

- [ ] Bilinen kurumsal kararlar eklendi

---

### 9. Domain Customize Overlay (Opsiyonel)

`.core/agents/` dosyalarını doğrudan düzenlemek yerine, şirkete özgü kuralları **overlay** katmanına yazın.
Bu sayede `git pull` ile CORE güncellemesi yapabilirsiniz — `.core/` değişiminden customize katmanınız etkilenmez.

```bash
mkdir -p domains/[domain-id]/customize
cp .core/domains/_template/customize/_example.customize.yaml \
   domains/[domain-id]/customize/prd.customize.yaml
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

Her agent kendi overlay dosyasını `<activation>` adımında okur; dosya yoksa atlar.
Desteklenen agent'lar: `interview`, `prd`, `prd-reviewer`, `codebase-analyst`, `implementation-plan`

---

## Minimum Başlangıç

Yalnızca bunları yaparsanız sistem çalışır:
1. MCP bağlantısı (Madde 1)
2. Domain kurulumu (Madde 3) + Jira anahtarları (Madde 4)
3. `/core-analyze [ticket-no]`

---

## Yeni Domain Ekleme

```bash
mkdir -p domains/[domain-id]
cp .core/domains/_template/domain-context.yaml domains/[domain-id]/domain-context.yaml
# domain-context.yaml'ı düzenle
# config/system.yaml → active_domain: [domain-id]
```

Kurulumu doğrulamak için bir test analizi çalıştırın:

```
/core-analyze [test-ticket-id]
```

Kontrol listesi:
- [ ] Interview Agent domain sözlüğünü ve servis listesini biliyor
- [ ] PRD Agent doğru yasal çerçeveye atıfta bulunuyor
- [ ] PRD Reviewer regülasyon kontrol listesini uyguluyor
- [ ] Jira Creator doğru proje ve space kodlarını kullanıyor

---

## Dashboard

```bash
cd dashboard
pip install -r requirements.txt
streamlit run app.py
```

Tarayıcı: `http://localhost:8501`

---

## İlk Analiz

```
/core-analyze [JIRA-TICKET-NO]
```

---

## Dizin Yapısı

```
CORE/
├── .core/                   # Tek kaynak — agent/skill/prompt dosyaları
│   ├── agents/              # Agent zinciri (.agent.md)
│   ├── skills/              # Yardımcı skill'ler
│   ├── prompts/             # Analiz giriş noktaları
│   └── domains/_template/   # Domain şablonu + customize overlay örneği
├── .claude/commands/        # Claude Code slash komutları (git'te doğrudan)
├── .github/
│   ├── copilot-instructions.md  # Copilot sistem talimatları
│   └── prompts/             # Copilot #komut dosyaları (git'te doğrudan)
├── domains/
│   └── [domain-id]/         # Aktif domain pack'ler (gitignored)
│       ├── domain-context.yaml
│       └── customize/       # Agent üzerine yazma katmanı (opsiyonel)
├── knowledge-base/          # Servis KB'leri — repo-scanner ile üretilir (gitignored)
├── memory/                  # Kurumsal hafıza (kısmen gitignored)
│   ├── decisions/
│   ├── personal/
│   ├── feedback/
│   └── tbd-tracker/
├── config/
│   └── system.yaml          # Sistem konfigürasyonu (gitignored)
└── core-output/             # Analiz çıktıları (otomatik oluşur, gitignored)
```

> **Tek Kaynak:** `.core/agents/` ve `.core/skills/` git'te versiyonlanır.
> Platform komutları doğrudan `.claude/commands/` ve `.github/prompts/` altındadır.

---

## Sık Sorulan Sorular

**Birden fazla domain destekliyor musunuz?**
Evet. `domains/` altına istediğiniz kadar domain ekleyebilirsiniz. `config/system.yaml` içindeki `active` değerini değiştirerek geçiş yapın.

**Aynı anda birden fazla domain kullanabilir miyim?**
Hayır. Tek bir `active` domain tanımlanır. Farklı projeler için `active` alanını güncelleyin.

**Türkçe dışında dil kullanabilir miyim?**
Evet. `config/system.yaml` içinde `output_language: en` yapın.

**Jira olmadan kullanabilir miyim?**
Evet, kısmi olarak. `integrations.jira.enabled: false` yapın. Jira Creator agent çalışmaz ama diğer 6 agent sorunsuz çalışır.

**Sadece doküman üretmek, Atlassian'a yazmak istemiyorum.**
`config/system.yaml` içinde `integrations.dry_run: true` yapın.

**Dashboard neye ihtiyaç duyuyor?**
`core-output/[TICKET]/metrics.json` dosyaları ve `memory/` altındaki markdown dosyaları. İlk analizden önce dashboard boş görünür.

**domain-context.yaml'da olmayan bir alan ekleyebilir miyim?**
Evet. YAML genişletilebilirdir. Ekstra alanlar görmezden gelinir; kullanmak istiyorsanız ilgili agent dosyasına okuma notu ekleyin.
