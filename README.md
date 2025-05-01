# cleanup-all.sh

`cleanup-all.sh` é um script de **faxina completa** para sistemas Debian/Ubuntu, que também realiza limpeza de recursos Docker. Além disso, ele faz **auto-agendamento** no cron para rodar semanalmente toda segunda-feira às 03:00.

## Funcionalidades

1. **Auto-agendamento no cron**  
   - Insere no crontab do root a linha:
     ```cron
     0 3 * * 1 /caminho/para/cleanup-all.sh >> /var/log/cleanup.log 2>&1
     ```
   - Detecta se já existe para evitar duplicação.

2. **Limpeza de APT**  
   - `apt-get clean`  
   - `apt-get autoclean -y`  
   - `apt-get autoremove --purge -y`  
   - Relatório de uso do cache antes/depois.

3. **Remoção de kernels antigos**  
   - Identifica imagens de kernel diferentes do atual (`uname -r`)  
   - Executa `apt-get purge -y` para cada um e atualiza o GRUB.

4. **Compactação de logs do systemd**  
   - `journalctl --vacuum-size=200M` para manter até 200 MB de logs.

5. **Limpeza de diretórios temporários**  
   - Remove tudo em `/tmp` e `/var/tmp`.

6. **Remoção de bibliotecas órfãs**  
   - Instala `deborphan` se necessário.  
   - `deborphan` seguido de `apt-get purge -y`.

7. **Limpeza de Snap & Flatpak**  
   - Remove revisões desabilitadas do Snap.  
   - `flatpak uninstall -y --unused` para Flatpak.

8. **Detecção de arquivos deletados ainda abertos**  
   - Instala `lsof` se necessário.  
   - `lsof +L1` para listar arquivos marcados como **(deleted)**.

9. **Faxina Docker**  
   - `docker container prune -f`  
   - `docker image prune -a -f`  
   - `docker volume prune -f`  
   - Exibe relatório de uso via `docker system df`.

10. **Resumo e relatório de espaço em disco**  
    - Cronometragem do tempo total.  
    - Exibição do uso de disco antes e depois (`df -hT`).

## Instruções de uso

1. **Clone** o script no seu repositório GitHub.  
2. Dê permissão de execução:
   ```bash
   chmod +x cleanup-all.sh
   ```
3. **Execute uma única vez** com `sudo`:
   ```bash
   sudo ./cleanup-all.sh
   ```
4. Verifique o log em:
   ```
   sudo tail -f /var/log/cleanup.log
   ```

> Após a primeira execução, o script já estará agendado para rodar automaticamente toda segunda-feira às 03:00.

---

*Mantido por TDamiao.*
