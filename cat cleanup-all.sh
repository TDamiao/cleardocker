cat << 'EOF' > cleanup-all.sh
#!/usr/bin/env bash
###############################################################################
# cleanup-all.sh – Faxina completa + auto-agendamento semanal no cron
# Uso: sudo ./cleanup-all.sh
###############################################################################
set -euo pipefail
IFS=$'\n\t'

# Funções de formatação
blue()  { printf "\033[1;34m%s\033[0m\n" "$*"; }
green() { printf "\033[1;32m%s\033[0m\n" "$*"; }
separator() {
  echo -e "\n=============================="
  blue  "$1"
  echo   "=============================="
}

# Garante execução como root
[[ $EUID -ne 0 ]] && { echo "⚠️  Execute como root (sudo)."; exit 1; }

# Caminho absoluto deste script
SCRIPT_PATH="$(readlink -f "$0")"

# 1. Auto-agendamento no cron (somente na 1ª execução)
CRON_LINE="0 3 * * 1 $SCRIPT_PATH >> /var/log/cleanup.log 2>&1"
if crontab -l 2>/dev/null | grep -F "$SCRIPT_PATH" >/dev/null; then
  separator "⏱️ Cron já configurado"
else
  (crontab -l 2>/dev/null; echo "$CRON_LINE") | crontab -
  separator "✅ Agendado: toda segunda às 03:00"
fi

# Inicia timer
START=$(date +%s)

# 2. Uso de disco antes
separator "📊 Uso de disco ANTES"
df -hT | awk 'NR==1 || /\/dev\/sda1/'

# 3. APT – cache, pacotes órfãos
separator "🧹 APT – cache & órfãos"
CACHE_BEFORE=$(du -sh /var/cache/apt 2>/dev/null | cut -f1)
apt-get clean
apt-get autoclean -y
apt-get autoremove --purge -y
CACHE_AFTER=$(du -sh /var/cache/apt 2>/dev/null | cut -f1)
echo "➜ Cache APT: $CACHE_BEFORE → $CACHE_AFTER"

# 4. Kernels antigos
separator "🧹 Removendo kernels antigos"
CURRENT=$(uname -r)
for K in $(dpkg -l 'linux-image-*' | awk '/^ii/{print $2}' | grep -v "$CURRENT"); do
  echo "➜ Removendo $K"
  apt-get purge -y "$K" || true
done
command -v update-grub &>/dev/null && update-grub

# 5. Journald
separator "🧹 Enxugando logs do systemd (200 MB)"
journalctl --vacuum-size=200M

# 6. /tmp e /var/tmp
separator "🧹 Limpando /tmp e /var/tmp"
find /tmp /var/tmp -mindepth 1 -maxdepth 1 -exec rm -rf {} +

# 7. Bibliotecas órfãs (deborphan)
separator "🧹 Bibliotecas órfãs"
command -v deborphan &>/dev/null || apt-get install -y deborphan
deborphan | xargs --no-run-if-empty apt-get purge -y

# 8. Snap / Flatpak
separator "🧹 Snap & Flatpak"
if command -v snap &>/dev/null; then
  snap list --all | awk '/disabled/{print $1,$3}' | \
    while read name rev; do snap remove "$name" --revision="$rev"; done || true
fi
command -v flatpak &>/dev/null && flatpak uninstall -y --unused || true

# 9. Arquivos “deleted” abertos
separator "🔍 Arquivos deletados abertos"
command -v lsof &>/dev/null || apt-get install -y lsof
lsof +L1 | awk '{printf "• %s (%s bytes)\n",$9,$7}' | head -n20 || echo "Nada encontrado."

# 10. Docker cleanup
if command -v docker &>/dev/null; then
  separator "🐳 Limpeza Docker"
  echo -e "\n🔍 Containers parados…";    docker container prune -f
  echo -e "\n🧼 Imagens não usadas…";    docker image prune -a -f
  echo -e "\n🧹 Volumes órfãos…";        docker volume prune -f
  echo -e "\n📦 Estado atual:";          docker system df
else
  separator "🐳 Docker não encontrado – pulando"
fi

# 11. Resumo e uso de disco depois
END=$(date +%s)
separator "✅ Faxina concluída em $((END-START)) segundos"
green "💾 Uso de disco DEPOIS:"
df -hT | awk 'NR==1 || /\/dev\/sda1/'

echo -e "\n🚀 Pronto! Este script agora roda toda segunda às 03:00."