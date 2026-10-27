# HP read-only probe

Research-only companion to the unchanged CombatHUD 0.1.0. No mod version or production payload change.

## Method and stop condition

Static findings already identify the getters and widget slots. Remaining questions depend on UE4SS runtime binding and live object ownership; replaying extraction or relying on mock objects cannot prove them. A separate Lua observer is the smallest sufficient test: reuse the production discovery/owning-pawn/game-thread pattern, inspect only two UFunctions and the known widget neighborhood, read HP on the adopted nominal 50-ms cadence. No damage hooks or visual experiment.

The probe performs no host writes, health changes, synthetic state, save operations or hook registration. Host data access runs in game-thread callbacks with at most one queued callback. HUD discovery is at most once per second while unbound. Widget inspection occurs once per HUD/pawn generation (maximum four); sibling enumeration is limited to 24 children. HP changes and sparse 30-second heartbeats are logged in UE4SS.log. Maximum 400 log lines and 15 minutes from loading; it also stops after full, incomplete and recovered health have all been observed. A contract error disables only the probe. No automatic game launch/termination or hot reload.

## Minimum observation matrix

| Question | User action | Evidence | Failure meaning |
| --- | --- | --- | --- |
| Getters bind and return plausible current/max numbers | Load ordinary gameplay | FUNCTION/FIELD/SOURCE/BEFORE_READ/AFTER_READ/HP | Missing/wrong binding: stop, no alternate guessed API |
| Full and incomplete HP differ; recovery is exact | With full HP, naturally lose a small amount, then heal fully; if initially hurt, heal first | HP values/deltas/full state and STOP summary | Missing state or implausible values remains unproved |
| HP layers and independent neighbors can be addressed | No additional action | WIDGET/SIBLING/STRUCTURE_OK with parent and address matches | Stop on missing/ambiguous ownership |

Natural loss/recovery is performed by the user; the probe does not manufacture it. No need to repeat poison/fire/fall matrices or test every damage source. This does not accept rendering, native opacity final-writer ownership, transition policy or pawn-change behavior without an actual corresponding observation.

## Installation and cleanup

Install only after confirming the game is closed. Copy this file to the distinct loader folder `CombatHUDHPProbe/Scripts/main.lua`, and use its `enabled.txt` marker. Preserve any pre-existing probe destination rather than overwriting it. Do not edit CombatHUD, SoulsEnemyHUD, shared helpers, or mods.txt. Record exact source commit and SHA256; compare installed bytes. Preserve the pre-run UE4SS log outside loader paths before the next start.

After the session, collect the accessible log directly and verify its identity against the installed probe. With the game closed, remove only the recorded probe marker and payload, preserving evidence outside loader paths. No hooks or mutated host state need restoring. Automatic stop ends reads in the current session; deleting enabled.txt disables subsequent loading. Do not replace loaded files. This observer has no save-persistent action.
