<skill id="elicitation" version="1.0">

<!-- Kullanım: Interview Agent tarafından çağrılır -->
<!-- Amaç:    Ticket'ın yeterliliğini ölç; eksikse yapılandırılmış diyalog aç -->

<purpose>
Bir talebin gerçek iş ihtiyacını ortaya çıkarmak için yapılandırılmış soru tekniklerini
ve ticket yeterlilik değerlendirmesini sağlar. Sessiz varsayım yasaktır.
Her belirsizlik kullanıcıya yansıtılır; yanıt alınmadan analiz üretilmez.
</purpose>

---

## 1 — Ticket Yeterlilik Skoru

Ticket'ı okuduktan sonra aşağıdaki 5 ekseni 0–2 puan ile değerlendir:

| Eksen | 0 = Yok | 1 = Belirsiz | 2 = Net |
|-------|---------|--------------|---------|
| **İş Değeri** | Neden yapılıyor belli değil | Genel bir sebep var | KPI / OKR / risk belli |
| **Kapsam** | Ne yapılacak belli değil | Genel fikir var | İçi + dışı net ayrılmış |
| **Kullanıcı** | Kim kullanacak belli değil | Rol belli, kanal yok | Rol + kanal + hacim belli |
| **Kısıt** | Deadline / yasal / teknik yok | Deadline var, diğerleri yok | Tüm kısıtlar belirtilmiş |
| **Başarı Kriteri** | Hiç AC yok | Bazı AC'ler var | Gherkin / ölçülebilir AC var |

**Toplam 10 puan üzerinden:**
- **8–10** → Ticket yeterli. Varsayım listesi çıkar, tek seferde onayla, devam et.
- **5–7** → Orta. Skoru 1 veya 0 olan eksenlere odaklan; **3–5 soru** sor.
- **0–4** → Yetersiz. **5–7 soru** sor; yanıt alınmadan brief üretme.

---

## 2 — Soru Teknikleri

### 2.1 Soru Üretme Kuralları

- **Tek seferde max 5 soru** — kullanıcıyı boğma. Gerekirse ikinci tur.
- **Kapalı uçlu değil, açık uçlu** — "Evet/Hayır" sorusu sorma.
  - ❌ "Bu özellik mobil de çalışacak mı?"
  - ✅ "Bu özelliği hangi kanallardan kullanıcılar tetikleyecek?"
- **Cevabı sende olanı sorma** — Jira'da yazıyorsa tekrar sorma.
- **Önemi sırala** — En kritik soru en üste.

### 2.2 Sessizlik Kuralı (BMAD'den)

Soru sorduktan sonra **cevap önerme.** Boşluğu doldurmaya çalışma.
Kullanıcı "bilmiyorum" derse → o soru "Açık TBD" olarak kaydedilir.

### 2.3 Paraphrase Tekniği

Her yanıt turunda önce şunu yap:
> "Anladığım kadarıyla: [özet]. Bu doğru mu?"

Kullanıcı düzeltirse düzeltilmiş versiyonu kaydet.

### 2.4 5 Whys (Kök Neden)

İş değeri belirsizse uygula:
1. "Bu özellik neden gerekli?" → Yanıt al
2. "Peki [yanıt] neden önemli?" → Yanıt al
3. Gerçek iş ihtiyacı/acısı ortaya çıkana kadar devam et (maks 5 tur)
4. Sonucu brief'in "İş Gereksinimi" bölümüne yaz

---

## 3 — Varsayım Onay Protokolü (Yeterli Ticket İçin)

Skor 8–10 ise diyalog aç:

```
📋 Ticket yeterince detaylı görünüyor. Şu varsayımlarla ilerleyeceğim:

1. [Varsayım 1]
2. [Varsayım 2]
3. [Varsayım 3]

Yanlış olan var mı, yoksa devam edeyim mi?
```

Kullanıcı "devam" derse → brief üret.
Düzeltme gelirse → düzelt, güncellenen varsayımı göster, onayla.

---

## 4 — "Bilmiyorum" Yönetimi

Kullanıcı bir soruya yanıt veremezse:
- O soruyu `TBD-[N]` olarak etiketle
- requirements-brief.md → "Açık Sorular" bölümüne ekle: `❓ [Soru] — TBD-[N] — Sorumlu: [kişi/ekip]`
- memory/tbd-tracker/tbd-tracker.md'ye kaydet (dry_run değilse)
- Jira ticket'a `has-open-tbd` etiketi ekle (dry_run değilse)
- **Devam et** — tek bir "bilmiyorum" zinciri durdurmamalı

---

## 5 — Diyalog Formatı

Soruları kullanıcıya şu formatta sun:

```
🎤 [Ticket ID] için [N] sorum var — yanıtlayabilirsen analizi çok daha isabetli yapabilirim:

**1.** [En kritik soru — iş değeri veya kapsam]

**2.** [İkinci soru]

**3.** [Üçüncü soru]

[varsa 4. ve 5.]

---
"Bilmiyorum" yanıtı geçerli — o noktayı TBD olarak işaretlerim.
Hazırsan yanıtla, sonra devam edelim.
```

---

<rules>
  <r>Yanıt gelmeden requirements-brief.md üretme — "bilmiyorum" yanıtı da yanıt sayılır</r>
  <r>Tek turda max 5 soru; eksikler kalırsa ikinci tura bırak ama ilk tura da brief yazma</r>
  <r>Sessizlik kuralı: cevap önerme, kullanıcı boşluğu doldursun</r>
  <r>Varsayımları sessizce yapma — her varsayımı yüzeye çıkar</r>
  <r>Skor 8–10 bile olsa varsayım onayı al; tamamen sessiz geçme</r>
</rules>

</skill>
