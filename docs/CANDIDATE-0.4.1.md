# CombatHUD 0.4.1 — GameThread scheduler candidate, NOT ACCEPTED

Prepared and installed 2026-10-30. Branch `fix/safe-game-thread-scheduler`.
Stable remains accepted/released 0.4.0; no main/tag/release promotion is authorized
before explicit game acceptance. This candidate reduces recurring async Lua work;
it is not a proven HildaSoftLight crash fix or universal UE4SS crash protection.

## Change and readiness

[Source/evidence gate](SCHEDULER_READINESS.md) was declared READY before mutation.
One `LoopInGameThreadWithDelay(50, callback)` replaces the async producer and
secondary dispatch; handle is saved, `pending` removed. Update runs directly in
the scheduled callback. On error, observers become inert, restoration is attempted,
then the handle is cancelled once. Cancellation errors/false results are contained
and logged once; remaining callbacks do no work. A failed release stops before
rebinding. Missing APIs/registration failure fail closed without async fallback.
Restoration precedes cancellation to avoid the pinned nested-ProcessEvent index
hazard locally. Existing lifecycle checks and input hook bodies are retained.

Policy Lua and config values are byte-identical to 0.4.0. Game time still drives
HP/combat/fade/contextual policy, including pauses. Nominal50ms scheduling uses the
host's timer and does not guarantee exact cadence. Crystals/live rebind/focus-loss
remain deferred. No game settings, saves, controls or other mods are changed.

## Exact immutable identity

Production source commit: `7547dcbc7b0e913f7a92741ed99a022e2c00bf37`.
Subsequent documentation commits must preserve these runtime bytes.

| File | SHA-256 |
| --- | --- |
| `Scripts/main.lua` | `75b572279550d0a7dfd1606bc587a950a0b6c3430cae423622a7f3b9083124e4` |
| `Scripts/policy.lua` | `323deff1ca89b2b8be0e95158978b73d55f777a50a4d1d51e43d0f097ceca3c6` |
| `VERSION` | `f62184cee8787f2f6941c82041a5725d4edc9aa293ebe5dbf664406e82ec1fe1` |

Ignored `.local/candidates/CombatHUD-0.4.1/` holds frozen `payload/`,
`manifest.json`, `CombatHUD-0.4.1.zip`, checksums, `offline-tests.log`,
`previous-payload/`, `pretest-UE4SS.log` and `deployment.json`.
ZIP SHA-256: `ce8bd0f5d36815410cdff5cb2c31280787ef91c8894fb2d52ce390a889e6a95f`.
Payload is extracted directly with `git show` from the exact source and compared
to working files; payload and backup files are read-only. Never replace this
numbered payload with different bytes. Proprietary evidence stays outside Git.

## Offline / hosted gate — PASS

- Local Python3.12.14 / lupa2.8: `python tools/test.py` PASS on baseline, then on
  changed source and again during exact-payload preparation; `git diff --check` PASS.
- Unchanged policy suite verifies combat, damage, finite6s hold, healing, pause,
  travel/invalid input and contextual overlays. Adapter retains 17-target binding,
  native menu, Interact/skill behavior, restoration and owner tests.
- Contract model adds one50ms timer, sequential delivery/no reentry or catch-up,
  game-time pause, saved-handle cancellation, stopped delivery, unavailable API,
  invalid handle/registration error, update error, restore exception/incomplete
  release, cancellation throw/false, inert callbacks/observers and no repeated logs.
  Async APIs in the fixture throw; production contains neither old API nor dispatch.
- [GitHub Actions41116473857](https://github.com/NikichMods/CombatHUD/actions/runs/41116473857):
  **success**, exact source `7547dcbc7b0e913f7a92741ed99a022e2c00bf37`, existing
  Ubuntu/Python3.12/lupa2.8 workflow. No CI workflow/configuration change was needed.

The model describes inspected source semantics. Its sequential delivery does not
prove real engine thread identity, actual cadence, native reentrancy/GC/shutdown
safety or absence of crashes. New timer invocation and all-game-state rendering
remain unverified until the user runs the installed candidate.

## Verified installation and rollback

Installation completed **2026-10-30 22:37 Moscow** with no Genesis/Asterigos
process present, rechecked immediately before each replacement. Installed three
hashes match the table; only `Scripts/main.lua` and `VERSION` needed replacement,
since `policy.lua` already matched. All49 other loader files (including mods.txt)
and observed UE4SS/Engine settings hashes match before/after. No launch, termination
or hot reload was performed. SaveGames were not written.

Before installation, all three installed0.4.0 files were compared directly to
accepted source `56631469ec8888f41bc82f0d5d02684aa44c0e9b`, copied to the ignored
`previous-payload/` outside the loader and compared again. Its expected hashes
remain in [0.4.0's record](CANDIDATE-0.4.0.md) and the private manifest.
Rollback: with game closed, restore those exact three files to CombatHUD and
verify the0.4.0 hashes. No loader/config/save changes are needed.

`pretest-UE4SS.log` is prior-session evidence, not proof of0.4.1 loading.
After gameplay, capture the accessible log and current installed hashes before
another start overwrites the log, then reconcile this record with the user's
visual observation. Loading, visual acceptance and stable publication are separate.

## Required short gameplay scenario

1. Start normally and load gameplay. HUD appears; full-HP peaceful state fades to
   20% after1.5s hold +1s fade. Verify the usual combat reveal and return to peace.
2. Take damage: whole HUD reveals immediately; HP/three quick slots stay bright
   6s, then fade1s despite missing HP. Leave combat injured and observe the same
   6s hold. Repeat damage resets it; partial healing does not; full healing after
   dimming does not flash the HUD.
3. Press mapped Interact: whole HUD temporarily reveals. Hold skill modifier:
   only right skill groups reveal; release fades them over1s. Open/close menu:
   native hiding wins and HUD returns normally. Observe a natural cut-scene if
   encountered; do not force deferred unlock/remapping/focus scenarios.
4. Continue ordinary gameplay long enough to exercise normal HUD/owner changes;
   report visible regressions, crashes or errors. A successful long session is
   useful evidence, not proof that all UE4SS threading bugs are eliminated.

Do not hot reload. On failure, preserve the session log and stop for diagnosis;
do not silently edit0.4.1 bytes. Stable release requires explicit user acceptance.

Shared source/static facts were promoted to Asterigos-Research
[`3f12d11`](https://github.com/NikichMods/Asterigos-Research/commit/3f12d11)
under R-008. Candidate implementation, hashes and acceptance remain owned here.
