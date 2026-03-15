#!/usr/bin/env bash
# CORE — Temizleme Scripti
# Kullanım:
#   bash clean.sh
# Bu script init.sh tarafından oluşturulan yapılandırma dosyalarını temizler.

set -e

BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
RED="\033[0;31m"
DIM="\033[2m"
RESET="\033[0m"

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║       CORE — Temizleme Sihirbazı         ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${YELLOW}Uyarı: Bu işlem CORE yapılandırma dosyalarını (config, domain tanımları, MCP ayarları) silecektir.${RESET}"
read -p "  Devam etmek istiyor musunuz? (e/h) [varsayılan: h]: " CONFIRM
CONFIRM="${CONFIRM:-h}"

if [[ ! "$CONFIRM" =~ ^[eE] ]]; then
  echo "  İşlem iptal edildi."
  exit 0
fi

echo ""
echo -e "${CYAN}── Silinen Dosyalar ve Klasörler ──────────────────────────────${RESET}"

# 1. system.yaml
if [ -f "config/system.yaml" ]; then
  rm -f "config/system.yaml"
  echo "  🗑️  config/system.yaml silindi"
fi

# 2. .claude/commands/
if [ -d ".claude/commands" ]; then
  rm -rf ".claude/commands"
  echo "  🗑️  .claude/commands/ dizini silindi"
  # .claude klasörü boşsa onu da sil
  rmdir ".claude" 2>/dev/null || true
fi

# 3. İsteğe bağlı: Domain yapılandırmaları
echo -e "\n  ${DIM}ℹ domain-context.yaml dosyaları silinsin mi?${RESET}"
read -p "  Domain konfigürasyonları silinsin mi? (e/h) [varsayılan: h]: " DOMAIN_CONFIRM
if [[ "${DOMAIN_CONFIRM}" =~ ^[eE] ]]; then
  find domains -name "domain-context.yaml" -type f -delete 2>/dev/null || true
  echo "  🗑️  Domain konfigürasyonları silindi"
  # Boşalan domain klasörlerini sil
  find domains -type d -empty -delete 2>/dev/null || true
fi

# 4. İsteğe bağlı: Analist profilleri
echo -e "\n  ${DIM}ℹ Analist profilleri (memory/personal/*.md) silinsin mi?${RESET}"
read -p "  Analist profilleri silinsin mi? (e/h) [varsayılan: h]: " ANALYST_CONFIRM
if [[ "${ANALYST_CONFIRM}" =~ ^[eE] ]]; then
  find memory/personal -name "*.md" -not -name "template*.md" -type f -delete 2>/dev/null || true
  echo "  🗑️  Analist profilleri silindi"
fi

# 5. VS Code / Copilot / MCP dosyaları
echo -e "\n${CYAN}── Entegrasyon Dosyaları ───────────────────────────────────────${RESET}"

if [ -f ".mcp.json" ]; then
  rm -f ".mcp.json"
  echo "  🗑️  .mcp.json silindi"
fi

if [ -f ".vscode/mcp.json" ]; then
  rm -f ".vscode/mcp.json"
  echo "  🗑️  .vscode/mcp.json silindi"
  rmdir ".vscode" 2>/dev/null || true
fi

if [ -f ".github/copilot-instructions.md" ]; then
  rm -f ".github/copilot-instructions.md"
  echo "  🗑️  .github/copilot-instructions.md silindi"
  rmdir ".github" 2>/dev/null || true
fi

echo ""
echo -e "${YELLOW}── Manuel İşlem Gerektiren Adımlar ─────────────────────────────${RESET}"
echo "  1. Eğer 'Claude Code CLI' veya 'Claude Desktop' kullanıyorsanız,"
echo "     aşağıdaki yapılandırmalardan 'atlassian' MCP sunucusunu el ile silmek isteyebilirsiniz:"
echo "     - CLI İçin: ~/.claude/claude.json"
echo "     - Desktop İçin: ~/Library/Application Support/Claude/claude_desktop_config.json"
echo ""
echo -e "${GREEN}✅ CORE temizlik işlemi tamamlandı!${RESET}"
echo ""
