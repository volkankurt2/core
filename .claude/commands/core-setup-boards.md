# /core-setup-boards — Birlikte Çalışılan Board'ları Keşfet ve Analiz Et
# Kullanım: /core-setup-boards
# Açıklama: Jira'dan aktif board'ları çeker, her board'un ne iş yaptığını analiz eder,
#            kullanıcıya onaylatır ve domain-context.yaml'a yazar.

Sen CORE'un Board Kurulum Asistanısın. Aşağıdaki adımları sırayla uygula.

---

## Adım 1 — Aktif Domain'i Oku

`config/system.yaml` → `active_domain` değerini al.
Hedef dosya: `domains/[active_domain]/domain-context.yaml`
Mevcut `jira_project` değerini not al (ana board — listede gösterilmeyecek).

---

## Adım 2 — Jira'dan Projeleri ve Aktiviteyi Çek (paralel)

Şu sorguları aynı anda çalıştır:

```
A) mcp__atlassian__getVisibleJiraProjects
   → Erişilebilir tüm projeler

B) JQL: assignee = currentUser() ORDER BY updated DESC   → maxResults: 10, fields: [project]
C) JQL: reporter = currentUser() ORDER BY updated DESC   → maxResults: 10, fields: [project]
D) JQL: comment ~ currentUser() ORDER BY updated DESC    → maxResults: 10, fields: [project]
```

B+C+D sonuçlarından `project.key` ve `project.name` çıkar.
Her proje için aktivite sayısını hesapla (B+C+D toplamı, tekrarları say).
Ana board'u (`jira_project`) listeden çıkar.
Kalan projeleri aktiviteye göre sırala.

---

## Adım 3 — Listeyi Sun ve Seçim Al

```
🔍 Jira'da etkileşimde olduğun board'lar:

   #   Kod    Proje Adı                  Aktivite
   ───────────────────────────────────────────────
   1   MOB    Mobile                     12 issue
   2   INV    Fatura Entegrasyon          8 issue
   3   INFRA  Altyapı                     3 issue
   4   HR     İnsan Kaynakları            1 issue

Ana board ([JIRA_PROJECT]) hariç tutuldu.

Hangi board'larla birlikte çalışıyorsun?
Numara gir (virgülle ayır), "hepsi" veya "hiçbiri":
```

Kullanıcının cevabını bekle. "hiçbiri" ise Adım 7'ye geç.

---

## Adım 4 — Seçilen Board'ları Analiz Et (paralel subagent'lar)

**Context optimizasyonu için:** Her board ayrı bir subagent'a ver, paralel çalıştır.

Seçilen **her board için** ayrı bir subagent başlat (Task tool, model: haiku):

```python
Task(
  subagent_type="general-purpose",
  model="haiku",
  description=f"Analyze {board_key} board",
  prompt=f"""
Sen bir Jira board analisti. Verilen board'u analiz edip yapılandırılmış sonuç çıkar.

Board: {board_key} - {board_name}

## Adım 1: Veri Topla

JQL sorgusunu çalıştır:
  project = {board_key} ORDER BY updated DESC
  → maxResults: 30
  → fields: [summary, description, issuetype, labels, components]

## Adım 2: Analiz Et

Issue başlıklarını, açıklamalarını, type/label/component'lerini analiz et:

1. **purpose** — Bu board ne iş yapıyor? (1-2 cümle Türkçe özet)
2. **issue_types** — Hangi tür işler açılıyor? (örn: Story %60, Bug %30, Task %10)
3. **auto_keywords** — Issue başlıklarından çıkarılan anahtar kelimeler (en sık geçen 10 teknik terim, küçük harfe çevir)
4. **auto_teams** — Component/label değerlerinden ekip adları

## Adım 3: Formatla

Sonucu şu YAML formatında dön:

```yaml
board_key: {board_key}
board_name: {board_name}
purpose: |
  [1-2 cümle Türkçe açıklama]
issue_types:
  - type: Story
    percentage: 60
  - type: Bug
    percentage: 30
  - type: Task
    percentage: 10
keywords:
  - anahtar kelime 1
  - anahtar kelime 2
  - ...
teams:
  - Ekip Adı 1
  - Ekip Adı 2
```

SADECE YAML formatında dön, başka yorum yapma.
  """,
  run_in_background=True
)
```

**ÖNEMLI:** Tüm subagent'ları aynı anda başlat (paralel execution).

Her subagent bitene kadar bekle (AgentOutputTool ile sonuçları topla).

---

## Adım 5 — Subagent Sonuçlarını Topla ve Kullanıcıya Onayla

Her subagent'ın döndüğü YAML sonucunu parse et.

Her board için şu formatla sun:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 MOB — Mobile  (30 issue analiz edildi)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Tespit edilen amaç:
  iOS ve Android mobil uygulama geliştirme board'u.
  Push notification, deep link ve app store süreçlerini yönetir.

Issue tipleri: Story %60 | Bug %30 | Task %10

Otomatik tespit edilen tetikleyiciler:
  Anahtar kelimeler : ios, android, push notification, deep link,
                      app store, mobil, uygulama, native
  Ekip/component    : iOS Team, Android Team, Mobile

Düzenlemek istiyor musun? (Enter = onayla / değişiklik yaz):
```

Kullanıcı onayını veya düzeltmesini bekle.
Düzeltme varsa ilgili alanları güncelle.

---

## Adım 6 — domain-context.yaml'ı Güncelle

`domains/[active_domain]/domain-context.yaml` dosyasını oku.
`collaborating_boards` bölümünü doldur:

```yaml
collaborating_boards:
  - id: mob
    jira_project: MOB
    display_name: Mobile
    purpose: >
      iOS ve Android mobil uygulama geliştirme board'u.
      Push notification, deep link ve app store süreçlerini yönetir.
    issue_types: [Story, Bug, Task]
    triggers:
      keywords:
        - ios
        - android
        - push notification
        - deep link
        - mobil
        - uygulama
      owner_teams:
        - iOS Team
        - Android Team

  - id: inv
    jira_project: INV
    display_name: Fatura Entegrasyon
    purpose: >
      e-Fatura ve e-arşiv entegrasyon board'u.
      GİB entegrasyonu, belge imzalama ve fatura sorgulama işlerini kapsar.
    issue_types: [Story, Task]
    triggers:
      keywords:
        - fatura
        - e-fatura
        - efatura
        - gib
        - e-arşiv
        - invoice
      owner_teams:
        - Billing
```

Dosyayı kaydet.

---

## Adım 7 — Özet Yaz

```
✅ Board yapılandırması tamamlandı!

Ana board : [JIRA_PROJECT] — [domain display_name]

Birlikte çalışılan board'lar:
  • MOB  — Mobile
    Amaç    : iOS ve Android geliştirme
    Trigger : ios, android, mobil, push notification...

  • INV  — Fatura Entegrasyon
    Amaç    : e-Fatura, GİB entegrasyonu
    Trigger : fatura, e-fatura, gib...

Nasıl çalışır:
  Analiz sırasında her user story'nin içeriği bu board'larla eşleştirilir.
  Eşleşen story'ler ilgili board'a, diğerleri [JIRA_PROJECT]'e açılır.

Dosya güncellendi: domains/[active_domain]/domain-context.yaml
Tekrar çalıştırmak için: /core-setup-boards
```
