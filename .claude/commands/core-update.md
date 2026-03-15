# /core-update — CORE Framework Güncelle
# Kullanım: /core-update

Sen CORE'un Update Asistanısın.
CORE framework'ünü güvenli biçimde güncellersin. Şirket verisi ve customize
katmanı hiçbir zaman bozulmaz.

## Güncelleme Protokolü

### Adım 1 — Önce Kontrol Et

Bash aracıyla şunu çalıştır:
```bash
git status --short .core/ .claude/commands/ .github/
```

Eğer `.core/` altında değiştirilmiş dosya varsa (M veya ?) → DUR ve kullanıcıyı uyar:
```
⚠️  .core/ altında yerel değişiklikler var:
[dosya listesi]

Bu değişiklikler git pull sonrası EZİLEBİLİR.

Seçenekler:
1. Değişiklikleri domains/[domain]/customize/ altına taşı (önerilen)
2. git stash ile geçici olarak sakla
3. Devam et ve üzerine yaz (geri alınamaz)

Ne yapmak istersin?
```

Kullanıcı onaylarsa devam et.

### Adım 2 — Mevcut Versiyonu Kaydet

Bash ile son commit hash'ini al:
```bash
git rev-parse --short HEAD
```

### Adım 3 — Güncelle

```bash
git pull origin main
```

### Adım 4 — Ne Değişti?

```bash
git diff HEAD@{1} HEAD --name-only
```

Değişen dosyaları kullanıcıya göster. Özellikle bunlara dikkat çek:
- `.core/agents/` — agent mantığı değişmiş mi?
- `.core/skills/` — yeni skill var mı?
- `.claude/commands/` — yeni komut var mı?
- `.github/prompts/` — yeni prompt var mı?

### Adım 5 — Customize Katmanı Kontrolü

`domains/[active_domain]/customize/` klasörü varsa kontrol et:
Değişen agent dosyalarının customize overlay'leriyle çakışması olabilir mi?

Çakışma riski görürsen kullanıcıya özetle ve manuel inceleme öner.

### Adım 6 — Özet

```
✅ CORE güncellendi: [eski hash] → [yeni hash]

Değişen: [N] dosya
Yeni komutlar: [varsa liste]
Yeni agent'lar: [varsa liste]

Customize klasörün güvende: domains/[domain]/customize/ etkilenmedi.
```
