# CombatHUD

**0.2.0** — health-aware fading of the lower HUD for *Asterigos: Curse of the Stars*.

Outside combat the HUD fades to 20% after a 1.5-second hold, with a 1-second transition. Combat restores full brightness over 1 second. Detected damage immediately reveals the HUD, including outside combat. While HP is incomplete, the health bar and all three quick-item slots stay bright; other elements fade independently. Healing to full starts a separate hold for health and items. Native menu hiding remains controlled by the game.

[Download CombatHUD 0.2.0](https://github.com/NikichMods/AsterigosMods/releases/tag/CombatHUD-v0.2.0). Tested with Steam 1.09/build12996889, Windows x64, UE4.27, UE4SS v3.0.1-1181-g83330635 and DX11. Other builds are unverified.

## Install

1. Install UE4SS and its UEHelpers module separately.
2. Close the game. Copy the archive's `CombatHUD` folder into `Genesis/Binaries/Win64/ue4ss/Mods/`. Back up an existing CombatHUD folder outside loader paths before replacing it.
3. Ensure that `ue4ss/Mods/mods.txt` contains `CombatHUD : 1` exactly once, preserving other mod entries.
4. Start the game normally. Disable or remove the mod only with the game closed; do not use hot reload.

Damage is detected by nominal 50-ms HP sampling; loss and complete recovery between samples can be missed. Visible crystals and keyboard/gamepad switching remain unverified, with testing deferred until natural unlock.

- [Current status](docs/STATUS.md)
- [Requirements](docs/REQUIREMENTS.md)
- [Runtime evidence](docs/VERIFIED_RUNTIME.md)
- [Tested source, hashes and acceptance](docs/CANDIDATE-0.2.0.md)
- [Changelog](CHANGELOG.md)

Source: `Scripts/`; tests: `tests/`; canonical version: `VERSION`. From the repository root run `python tools/test.py` with dependencies from `requirements-test.txt`. Offline tests complement the user's runtime acceptance.

Original code is MPL-2.0; see the repository LICENSE and LICENSING.md. Game assets, UE4SS and UEHelpers are not included.

## Independent repository

[Migration and exact source provenance](docs/MIGRATION.md) · [Shared Asterigos Research](https://github.com/NikichMods/Asterigos-Research/blob/main/docs/RESEARCH_INDEX.md) · [Local external dependencies](docs/LOCAL_DEPENDENCIES.md). Original release URLs and frozen artifacts remain in AsterigosMods.
