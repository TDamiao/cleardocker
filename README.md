# cleardocker

[![Debian Package](https://img.shields.io/badge/debian-package-blue)](https://tdamiao.github.io/cleardocker/apt)

`cleardocker` is a comprehensive cleanup script for Debian-based systems (like Debian, Ubuntu, etc.) designed to free up significant disk space by removing unnecessary files, packages, and Docker resources.

[![Buy Me a Coffee](https://cdn.buymeacoffee.com/buttons/v2/arial-yellow.png)](https://www.buymeacoffee.com/tdamiao)


## Features

- **APT Cleanup:** Cleans package cache (`/var/cache/apt`) and removes orphan packages (`autoremove`).
- **Old Kernel Removal:** Purges old, unused kernel images that are safe to remove.
- **Log Trimming:** Reduces the size of systemd journal logs to a configured limit (200MB).
- **Temporary File Cleanup:** Cleans `/tmp` and `/var/tmp`.
- **Orphan Library Removal:** Uses `deborphan` to find and remove unused libraries.
- **Snap & Flatpak:** Removes disabled Snap packages and unused Flatpak runtimes.
- **Docker Cleanup:** Prunes stopped containers, dangling images, and unused volumes.
- **User Caches:** Cleans caches in all user home directories.

## Installation (via APT)

`cleardocker` can be installed from a dedicated APT repository, allowing for easy installation and updates.

### 1. Add the Repository GPG Key

First, add the GPG key used to sign the packages. This ensures the authenticity of the software.

```bash
curl -sS 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xDB97C87E0047334C67C87184B9C6413510FA0858' | sudo gpg --dearmor -o /usr/share/keyrings/cleardocker-keyring.gpg
```

### 2. Add the Repository to APT Sources

Next, add the `cleardocker` repository to your system's software sources.

```bash
echo "deb [signed-by=/usr/share/keyrings/cleardocker-keyring.gpg] https://tdamiao.github.io/cleardocker/apt/ ./" | sudo tee /etc/apt/sources.list.d/cleardocker.list
```

### 3. Install cleardocker

Finally, update your package list and install `cleardocker`.

```bash
sudo apt-get update
sudo apt-get install cleardocker
```

## Usage

### Running the Script

After installation, simply run the script with `sudo`:

```bash
sudo cleardocker
```

The script must be run as root to perform system-wide cleanup tasks.

### Understanding the Output

The script provides detailed, real-time feedback on its actions. Here's what to look for:

- `📊 Disk usage BEFORE`: Shows the state of your disk before the cleanup begins.
- `🧹 APT – cache & orphans`: Details the removal of old package files and unused dependencies.
- `🧹 Removing old kernels`: Lists any old kernel versions being removed.
- `🧹 Trimming systemd logs`: Shows how much log space was freed.
- `🐳 Docker cleanup`: Reports on pruned containers, images, and volumes, and shows a final summary of Docker's disk usage.
- `💾 Disk usage AFTER`: Shows the state of your disk after the cleanup, allowing you to see how much space was recovered.

## Automatic Scheduling (Optional)

`cleardocker` does **not** schedule itself to run automatically. If you wish to have it run on a weekly basis, you can add it to the root user's crontab.

1.  Open the root crontab editor:
    ```bash
    sudo crontab -e
    ```
    (If prompted, choose a text editor like `nano`.)

2.  Add the following line to the end of the file:
    ```
    0 3 * * 1 /usr/sbin/cleardocker >> /var/log/cleardocker.log 2>&1
    ```
    This configuration will run `cleardocker` every Monday at 3:00 AM and save a log of its execution to `/var/log/cleardocker.log`.

3.  Save the file and exit the editor.

## Contributing

Contributions are welcome and appreciated! This project is open-source, and you can help in many ways:

- **Reporting Bugs:** If you find a bug, please open an issue on the GitHub repository.
- **Suggesting Enhancements:** Have an idea for a new feature or an improvement? Open an issue to discuss it.
- **Submitting Pull Requests:** If you want to contribute code, please fork the repository, create a new branch for your feature or fix, and submit a pull request.

### Building from Source

If you want to build the `.deb` package from the source code, you'll need the following tools:

```bash
sudo apt-get install build-essential devscripts
```

Then, from the project's root directory, run the `debuild` command:

```bash
# This command builds the binary package without signing it
debuild -b -uc -us
```

The resulting `.deb` file will be created in the parent directory.

## License

This project is licensed under the MIT License.
