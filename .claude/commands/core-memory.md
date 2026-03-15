# /core-memory — Kurumsal Hafızayı Sorgula
# Kullanım: /core-memory [opsiyonel: doğal dil sorgu]
# Örnek: /core-memory "idempotency kuralımız ne?"
# Örnek: /core-memory "servis A timeout politikası"
# Örnek: /core-memory (argümansız → tüm kararları özetle)

memory/decisions/institutional-memory.md dosyasını oku.
.core/skills/memory-conflict-checker/SKILL.md içindeki etiket haritasını referans al.

## Argüman Yoksa
Tüm geçerli KUR kararlarını konu başlıklarına göre grupla ve özetle (Türkçe).

Format:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📚 CORE Kurumsal Hafıza — Tüm Kararlar
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Güvenlik & Kimlik Doğrulama
[Bu kategorideki KUR'lar]

## Mimari Standartlar
[Bu kategorideki KUR'lar]

## Yasal Uyumluluk
[Bu kategorideki KUR'lar]

Toplam karar: [N] | Son güncelleme: [tarih]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Argüman Varsa — Semantik Arama
`$ARGUMENTS` doğal dil sorgusu olarak değerlendir.

### Adım 1 — Sorguyu Genişlet
Kullanıcının sorgusundaki anahtar kelimeleri tespit et ve eş anlamlılarla genişlet.
Örnekler:
- "idempotency" → idempotent, duplicate, mükerrer, retry, tekrarlama, tekrar istek
- "retry" → tekrar, yeniden deneme, idempotency
- "timeout" → zaman aşımı, süre, limit, ms
- "güvenlik" → auth, token, şifreleme, ssl, tls
- "entegrasyon" → servis, api, bağlantı, istemci

### Adım 2 — Kararları Tara
.core/skills/memory-conflict-checker/SKILL.md'deki etiket haritasını kullan.
Genişletilmiş sorgudaki kelimelerden herhangi birini içeren KUR kararlarını bul.

### Adım 3 — İlgili Kararları Göster

Bulunan kararlar için:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 CORE Hafıza Araması: "[sorgu]"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[N] karar bulundu:

### KUR-NNN: [Başlık]
- Karar  : [Karar metni]
- Kapsam : [Kapsamı]
- İstisna: [İstisna varsa]
- Tarih  : [YYYY-AA-GG]

[Sonraki kararlar...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Adım 4 — Confluence'ta Da Ara
```
confluence_search("$ARGUMENTS", spaceKey="[CONFLUENCE_SPACE]")
# [CONFLUENCE_SPACE] aktif domain context'ten al: domains/[domain]/domain-context.yaml → confluence_space
```
Confluence sonuçlarını ayrı bir bölümde göster.

### Adım 5 — Bulunamadıysa
```
ℹ️ "$ARGUMENTS" için kurumsal hafızada kayıtlı karar bulunamadı.

İlgili açık TBD'ler:
[memory/tbd-tracker/tbd-tracker.md dosyasında "$ARGUMENTS" konusuna yakın TBD var mı kontrol et]

Bu konuda bir karar belgelemek ister misiniz?
→ /core-analyze ile yeni bir analiz başlatın veya directly memory/decisions/institutional-memory.md dosyasına KUR ekleyin.
```
