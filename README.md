# CombatHUD

**0.4.0** — contextual fading of the lower HUD for *Asterigos: Curse of the Stars*.

Outside combat the HUD fades to 20% after a 1.5-second hold, with a 1-second transition. Entering combat restores full brightness over 1 second. Detected damage immediately reveals the HUD, including outside combat.

Health and all three quick-item slots stay bright for **6 seconds** after detected damage or leaving combat while injured, then fade over 1 second even if HP remains incomplete. Partial healing does not restart this timer. Full healing preserves a brief hold while these elements are still bright and does not flash an already fading or dimmed HUD.

Press the currently mapped world **Interact** action to reveal the whole managed HUD temporarily, including without a nearby object. Hold the native gamepad **skill modifier** to reveal only the two right skill groups; release fades them over 1 second without an extra hold. Native hiding in menus and other game states remains authoritative.

[Download CombatHUD 0.4.0](https://github.com/NikichMods/CombatHUD/releases/tag/CombatHUD-v0.4.0) — ZIP and SHA-256 checksums. Tested with Steam 1.09/build12996889, Windows x64, UE4.27, UE4SS v3.0.1-1181-g83330635 and DX11. Other builds are unverified.

## Install

1. Install UE4SS and its UEHelpers module separately.
2. Close the game. Copy the archive's `CombatHUD` folder into `Genesis/Binaries/Win64/ue4ss/Mods/`. Back up an existing CombatHUD folder outside loader paths before replacing it.
3. Ensure that `ue4ss/Mods/mods.txt` contains `CombatHUD : 1` exactly once, preserving other mod entries.
4. Start the game normally. Disable or remove the mod only with the game closed; do not use hot reload.

Damage is detected by nominal 50-ms HP sampling; loss and complete recovery between samples can be missed. The contextual action resolver is tested on the PC keyboard/gamepad mapping path. A live rebinding round trip and focus-loss edge cases are not separately verified. Visible crystals and their keyboard/gamepad layouts remain deferred until natural unlock.

- [Current status](docs/STATUS.md)
- [Requirements](docs/REQUIREMENTS.md)
- [Tested source, hashes and acceptance](docs/CANDIDATE-0.4.0.md)
- [Changelog](CHANGELOG.md)

Source: `Scripts/`; tests: `tests/`; canonical version: `VERSION`. Run `python tools/test.py` with dependencies from `requirements-test.txt`. Original code is MPL-2.0; see [LICENSE](LICENSE) and [licensing scope](LICENSING.md). UE4SS, UEHelpers and game assets are supplied separately.
