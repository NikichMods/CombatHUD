# GameThread scheduler — evidence and readiness, 2026-10-30

Current outcome:0.4.1 passed the user scenario and completed-session log review
on2026-10-31; [acceptance and release identity](CANDIDATE-0.4.1.md). The gate below
records pre-implementation evidence; upstream limitations remain in force.

Scope: preventive reduction of concurrent Lua execution in CombatHUD. No causal
link to the HildaSoftLight native crash has been established; this is not its fix.
Stable 0.4.0 source `56631469ec8888f41bc82f0d5d02684aa44c0e9b`, tag and release
remain immutable. Work branch: `fix/safe-game-thread-scheduler`, based on freshly
fetched `origin/main` = `184dea71dbd112e434cca4ccc454e6fcc2743bcd`; clean checkout,
no unpublished commits or other worktrees at recovery. Ignored inputs preserved.

## Production evidence gate — READY for a candidate, not runtime acceptance

- Property: replace the recurring async Lua producer with one nominal 50-ms
  GameThread timer. Owner: UE4SS delayed-action registry, not CombatHUD policy.
- Exact dependency: UE4SS `8333063595fa3c49ad307f3b0f732accbb760d25`,
  `UE4SS/src/Mod/LuaMod.cpp`. Final callback consumer is
  `process_delayed_actions<EngineTick/ProcessEvent>`; CombatHUD's final UI writer
  remains `apply()` and its existing checked RenderOpacity targets.
- Blast radius: scheduling of all 17 targets, owner refresh and fail-safe cleanup.
  Policy, HP/combat clocks, config, contextual overlays, native menu visibility
  and hook bodies/signature are preserved. `RegisterHook` observes input directly;
  it has no dependency on the removed async producer or `pending` flag.
- Evidence: exact source inspection, installed DLL identity/API strings and prior
  accepted target/getter/menu evidence. Baseline offline suites PASS. Changed
  adapter contract/failure paths are checked offline; actual binary API invocation,
  cadence, visuals and native lifecycle safety remain a separate game-test gate.
- Choice: documented repeating delayed action is sufficient. Repeated one-shot
  registration adds unnecessary references/lifecycle states; async fallback would
  retain the risk being removed. No scheduler framework or new hook is needed.

## Exact source contract

[Pinned LuaMod.cpp](https://github.com/UE4SS-RE/RE-UE4SS/blob/8333063595fa3c49ad307f3b0f732accbb760d25/UE4SS/src/Mod/LuaMod.cpp):

| Lines | Established behavior |
| --- | --- |
| 3106–3135, 7285–7343 | `LoopAsync` executes through the async Lua state; boolean callback result removes the old loop. `pending` only bounded queued updates, not concurrent Lua execution. |
| 4716–4792 | `LoopInGameThreadWithDelay(delayMs, callback)` creates one looping record and returns an integer handle. Uses configured executor with availability fallback; throws if neither hook works. |
| 3949–4090 | Eligible actions become Executing before callbacks; executing actions and nested game-action execution are skipped. Callback has zero results. Loop rearm uses steady-clock time after the batch plus delay; overdue periods do not create catch-up callbacks. |
| 4093–4164 | Delayed processing is called from ProcessEvent/EngineTick hooks. This is source-level executor behavior, not proof that every ProcessEvent caller is on the game thread. |
| 5115–5159 | `CancelDelayedAction(handle)` checks mod ownership, marks an active or pending action PendingRemoval and returns boolean success. Current callback finishes; cleanup skips rearm and later unreferences it. |

Therefore no CombatHUD `pending` flag or second dispatch is needed. Cancellation
uses the saved handle, never the old `return true` convention. The timer's clock
only schedules delivery; `GetTimeSeconds(hud)` still governs every visual timer.
50 ms is nominal, affected by callback duration, FPS, executor availability and
pauses; sampled HP can still miss damage followed by recovery between samples.

Fail-safe first disables observers, attempts opacity restoration under `pcall`,
then attempts cancellation once. A false/throwing cancellation is logged once;
any remaining callbacks return without work. A failed owner-release stops before
rebinding. Missing APIs, registration exceptions or invalid handles disable the
adapter without async fallback. Native faults are outside Lua `pcall` containment.

Ordering matters: this source retains vector indices across unlocked callback
execution (4013/4041), and nested processing still erases PendingRemoval records
(4082). Restore BEFORE cancellation avoids CombatHUD calling a UFunction after
marking its own action for removal. This removes that local sequence, not the
global UE4SS hazard from other actions/mods. No hot reload/restart tests are used.

## Installed evidence and upstream limits

Installed DLL SHA-256:
`ce5e3c46a920cc00b2817ac61e438c9162830290379d0b5b9c4dfc2b29459290`.
Read-only inspection found ASCII API names at offsets 17755761 and 17759041,
and version string `83330635` at 17709520. Existing 2026-10-30 log reports that
revision, GameEngineTick discovery and LuaModImpl prehook registration; settings
select EngineTick. Installed CombatHUD's three hashes match accepted 0.4.0.
These observations support binary identity/presence, not successful invocation
of the new timer. Private source/log evidence remains ignored under `.local`.

- [Official delayed actions](https://docs.ue4ss.com/dev/lua-api/global-functions/delayedactions.html)
  and [migration guide](https://docs.ue4ss.com/dev/upgrade-guide.html) describe
  GameThread replacement APIs; current dev docs are checked against the pinned source.
- [#1345](https://github.com/UE4SS-RE/RE-UE4SS/issues/1345): report distinguishes
  hook-thread anchoring and concurrent async/game Lua. Maintainer recommends
  delayed GameThread APIs. It does not establish a CombatHUD crash cause.
- [#1456](https://github.com/UE4SS-RE/RE-UE4SS/issues/1456): another UE4.27 game,
  revision `5e627997`, queued callbacks plus async functions; closed with a
  maintainer request to replace async APIs. The reporter's wrapper-bug diagnosis
  is a hypothesis, not a confirmed cause applicable to Asterigos.
- [#1445](https://github.com/UE4SS-RE/RE-UE4SS/issues/1445): reproduction on another
  game reports load/teardown races even without async functions. Pinned source
  runs batches outside the queue mutex; pinned `luauser.c` deletes the shared lock
  at state close. Relevant hazards remain beyond this mod's scheduler replacement.
  [#1472](https://github.com/UE4SS-RE/RE-UE4SS/pull/1472) merged later as
  `cdbc0b66cb2bb5b4a3d2f69b6e61a8460961e54c` (2026-10-25); queued-event lock fix
  is absent from installed 83330635. Subsequent lifecycle fixes
  [#1473](https://github.com/UE4SS-RE/RE-UE4SS/pull/1473) and
  [#1474](https://github.com/UE4SS-RE/RE-UE4SS/pull/1474) are still OPEN/unmerged
  at this review. Do not describe their proposed fixes as installed or merged.

No UE4SS upgrade, other-mod change, game launch/termination or hot reload belongs
to this task. Successful extended gameplay can reveal failures but cannot prove
the absence of native threading/lifecycle bugs. Crystals, live rebinding and
focus-loss remain outside this acceptance scope.
