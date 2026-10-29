# Changelog

## 0.4.0 — experimental, awaiting in-game acceptance

- HP and all three quick-item slots dim after a finite six-second hold following detected damage or combat exit while injured, even when HP remains incomplete; the accepted 1-second fade remains.
- Partial healing does not prolong the hold; full healing keeps its existing brief hold only while these elements are still bright, without a flash if already fading/dim.
- Combat, other HUD timers, contextual Interact / skill-modifier reveal, native menu ownership and error containment remain unchanged.
- 0.3.1 passed its game test and received stable-promotion approval, but publication is deliberately deferred until this separately tested feature cycle concludes.

## 0.3.1 — experimental, awaiting in-game verification

- Fix native input-device getter ownership: `GenesisPlayerController:GetNowInputControllerType()` instead of `GameGlobal`.
- Correct the offline controller mock and assert that the native owner is exercised; the 0.3.0 mock had hidden this integration defect.
- Contextual input behavior and accepted 0.2.0 opacity policy otherwise unchanged. Runtime success is not yet established.

## 0.3.0 — experimental, failed in-game verification (2026-10-29)

- Pressing the currently mapped world Interact action temporarily reveals the managed HUD, even without a nearby object on the verified PC input path.
- Holding the native skill selector reveals only the two right skill groups; releasing fades them for one second without an additional hold.
- Native game/UI visibility remains authoritative. The accepted combat, damage, partial-HP and item behavior is preserved.
- Offline coverage added, but live testing proved both contextual features were blocked by a wrong native method owner. This exact installed candidate remains rejected and immutable.

## 0.2.0 — 2026-10-27

- Taking damage reveals the lower HUD immediately, including outside combat.
- Health and all three quick-item slots remain bright while HP is incomplete.
- Other elements fade independently after damage or combat; full healing starts only the health/item hold.
- Preserves the 1.5-second hold, 1-second transitions, 20% idle opacity and native menu hiding.
- User accepted damage, healing, combat and menus in game. Visible crystals and keyboard/gamepad switching are deferred until natural unlock.

## 0.1.0 — historical local baseline

Accepted combat/idle HUD fading; no packaged public release. Preserved locally for rollback.
