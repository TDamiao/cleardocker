# cleardocker

`cleardocker` is a **complete cleanup script** for Debian/Ubuntu systems, which also cleans up Docker resources. In addition, it **self-schedules** in cron to run weekly every Monday at 03:00.

This project is intended to be distributed via a PPA.

## Features

*   **APT Cleanup:** Cleans cache and removes orphan packages.
*   **Old Kernel Removal:** Purges old kernel images.
*   **Log Trimming:** Reduces the size of systemd journal logs.
*   **Temporary File Cleanup:** Cleans `/tmp` and `/var/tmp`.
*   **Orphan Library Removal:** Uses `deborphan` to find and remove unused libraries.
*   **Snap & Flatpak:** Removes old and unused packages.
*   **User Caches:** Cleans caches in user home directories.
*   **Docker Cleanup:** Prunes containers, images, and volumes.
*   **Self-Scheduling:** Automatically creates a cron job for weekly execution.

## Installation from PPA

Once the package is available in the `ppa:tdamiao/cleardocker` PPA, you can install it using the following commands:

```bash
sudo add-apt-repository ppa:tdamiao/cleardocker
sudo apt-get update
sudo apt-get install cleardocker
```

The script will be installed to `/usr/sbin/cleardocker` and the cron job will be created upon the first execution.

## Usage

After installation, you can run the script manually for the first time:

```bash
sudo cleardocker
```

This will perform the initial cleanup and set up the weekly cron job. The log of executions will be saved in `/var/log/cleanup.log`.

## Building from Source (for PPA Upload)

To build the source package for uploading to your PPA, you will need to install the packaging tools:

```bash
sudo apt-get install build-essential devscripts debhelper
```

Then, from the project's root directory, run the following command:

```bash
debuild -S -sa
```

This will generate a `.changes` file in the parent directory, which you can then upload to your PPA using `dput`:

```bash
dput ppa:tdamiao/cleardocker ../cleardocker_1.0.0-1_source.changes
```

---

*Maintained by TDamiao.*
*Packaged for PPA by Gemini.*