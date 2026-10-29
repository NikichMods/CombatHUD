# Changelog

## 0.3.0 — experimental, not yet accepted

- Pressing the currently mapped world Interact action temporarily reveals the managed HUD, even without a nearby object on the verified PC input path.
- Holding the native skill selector reveals only the two right skill groups; releasing fades them for one second without an additional hold.
- Native game/UI visibility remains authoritative. The accepted combat, damage, partial-HP and item behavior is preserved.
- Offline coverage added; actual input hooks, remapping, focus changes and controller presentation require in-game verification before promotion.

## 0.2.0 — 2026-10-27

- Taking damage reveals the lower HUD immediately, including outside combat.
- Health and all three quick-item slots remain bright while HP is incomplete.
- Other elements fade independently after damage or combat; full healing starts only the health/item hold.
- Preserves the 1.5-second hold, 1-second transitions, 20% idle opacity and native menu hiding.
- User accepted damage, healing, combat and menus in game. Visible crystals and keyboard/gamepad switching are deferred until natural unlock.

## 0.1.0 — historical local baseline

Accepted combat/idle HUD fading; no packaged public release. Preserved locally for rollback.
