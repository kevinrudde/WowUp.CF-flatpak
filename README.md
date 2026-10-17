# WowUp Flatpak

Unofficial [Flatpak](https://flatpak.org/) repository for [WowUp](https://wowup.io/) (CurseForge variant).

Two branches are published:

- `stable`: latest WowUp.CF release
- `beta`: latest WowUp.CF release including prereleases

## Installation

    flatpak remote-add --user --if-not-exists wowup-flatpak https://kevinrudde.github.io/WowUp.CF-flatpak/index.flatpakrepo
    flatpak install --user wowup-flatpak io.wowup.WowUp//stable   # or //beta
    flatpak run io.wowup.WowUp

Update with `flatpak update`.

## Game folder access

The app has no filesystem access by default. Grant it to your WoW install folder once, for example for Faugus:

    flatpak override --user --filesystem=$HOME/Faugus/battlenet io.wowup.WowUp 

> **Note:** WowUp does not support scanning for WoW installations created by Faugus. Add your install manually in WowUp, using the folder you granted access to above.

Overrides are stored per user and per app ID. They survive updates and apply to both `stable` and `beta`.

Revoke with `flatpak override --user --nofilesystem=$HOME/Faugus/battlenet io.wowup.WowUp`, or manage it in [Flatseal](https://flathub.org/apps/com.github.tchx84.Flatseal).

## Maintenance

- `Update` workflow runs daily, runs `scripts/update-manifest.sh` per channel and opens a pull request when upstream has a new release.
- Workflow action versions are pinned by `.github/workflows/actions.lock`. After adding or changing a `uses:` entry, run `gh actions-lock` (extension: `gh extension install github/gh-actions-lock`) and commit the result. The `Lockfile` workflow verifies this on pull requests.
- Merging that pull request triggers `Deploy`, which builds, signs and publishes the repository to GitHub Pages.
