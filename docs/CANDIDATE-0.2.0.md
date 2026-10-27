# CombatHUD 0.2.0 — runtime candidate

Status: 0.2.0 explicitly accepted for stable promotion on 2026-10-27 after the successful damage/healing/combat/menu test. The exact tested payload is preserved in main and the published CombatHUD-v0.2.0 source tag. The ZIP is prepared and verified locally; GitHub Release publication is pending explicit permission. Crystals remain deferred until natural unlock.

- Branch: `feature/combathud-hp-visibility`.
- Exact payload source commit: `ca342e33442a11b46a9ab30ed8e8cd796c9a8d60`.
- Prototype base: `1244f4450640b77200579247877c5263574e4d71` (fetched from GitHub, branch tip verified).
- Relative to the prototype, runtime logic is unchanged: VERSION becomes 0.2.0 and the startup log identifies CombatHUD 0.2.0. This numbered payload is frozen.
- Source archive SHA-256: `cc0207909df054df822512bffeda7122e0c8b2b1bf8acce472e7bbf512b2cf54` (git archive of CombatHUD, tools/test.py and requirements-test.txt at the exact source commit).

| Source and installed file | SHA-256 |
| --- | --- |
| Scripts/main.lua | `3ef86bcb7f6641be6332f003e0cf5dcbf443dd3a0f2ebb747c08be4691601d88` |
| Scripts/policy.lua | `d2725a52b181adc440660b01a4dbd642a17f128ae71a0135cbbf5f530af2f669` |

Offline: Python 3.12.14, lupa 2.8; `python tools/test.py` PASS (all available tests), `git diff --check` PASS. Source blobs match the commit; VERSION, startup marker and candidate identity agree. Lua copied without compilation or byte transformation. These checks do not establish UE4SS loading or visual acceptance.

Installation at 2026-10-27 20:17:02 UTC: no Genesis/Asterigos process before writes; only CombatHUD's main.lua and policy.lua replaced. Installed SHA-256 matched the frozen payload. All other loader files, including mods.txt, UEHelpers and SoulsEnemyHUD, retained their hashes. No game launch/termination or hot reload.

Previous accepted 0.1.0 was copied outside all loader paths, with SHA-256 verified against both installed bytes and the accepted baseline:

- main.lua: `63f4de5a4a59a4dd263a782d46ed194ccf1f89683cabfd45b7ba68445e8e8c30`.
- policy.lua: `d47eb701863875bfebee249d4514abaf06d004489b4e467a649bb2daea33a095`.

Local immutable candidate payload, source archive, manifest, test output, pre-test UE4SS log and rollback are retained under the primary checkout's ignored `.local/candidates/CombatHUD-0.2.0/`; rollback files are in `previous-payload/Scripts/`. Installation evidence is `deployment.json`. The pre-test log is historical evidence, not a runtime result for this candidate.

Requested user test checklist (observed coverage is recorded below): full HP idle 20%; combat reveal over 1s; combat exit hold 1.5s then fade 1s; detected damage immediately reveals all groups (nominal 50ms sampling); partial HP keeps HP + all three quick items bright while other groups fade independently; healing to full starts only HP/item hold; repeated damage resets the relevant delay; native menus/dialogue hiding, pause and transitions remain correct. Crystals/input-mode visibility intentionally deferred until natural unlock; do not alter saves or force unlocks.

The completed user test, matching session evidence and later explicit stable acceptance are recorded below.

## Runtime result — 2026-10-27, 23:20–23:24 MSK

**PASS in the exercised scope.** The user reported that damage, healing, combat and menus all behaved as expected, then closed the game. At the time of the test report, stable promotion had not yet been authorized; the later explicit acceptance is recorded below.

The new UE4SS log identifies v3.0.1 / Git 83330635, starts CombatHUD 0.2.0 at 23:20:42.063 and ends with `Event loop end` at 23:24:21.438. Post-session process count is zero. Both installed Lua SHA-256 values still match the frozen candidate above. One binding validated hilda_BP_C and all 17 independent targets. The preserved local session snapshot is `run-20261027-232421-UE4SS.log`, SHA-256 `8511ab2ad9323b89a64659a5575dbafdc4c60ae7ff1af3122c40039362df6753`.

Direct log evidence (ordinary/vital = other HUD / HP + quick items):

- At full HP 680/680, combat reveal at 23:21:29.265 reaches 1/1 at 23:21:30.282 (~1.02s wall time). Exit at 23:21:40.414 enters hold, fading starts at 23:21:41.948 (~1.53s), idle 0.2/0.2 at 23:21:42.948 (~1.00s fade).
- Damage in combat records HP 626/680. After exit, other HUD fades to 0.2 while vital stays 1.0 (23:22:04.630). A later combat entry reveals only the already-dim group; vital remains bright.
- Damage outside combat at 23:22:56.930 records HP 452.278/680, damage=true and opacity 1/1 in that update. At 23:22:59.447, ordinary/vital is 0.2/1.0. Another outside-combat loss to 527.293/680 at 23:23:15.046 again records damage=true and immediate 1/1, followed by 0.2/1.0 at 23:23:17.579. The log records sampled detection, not the physical instant/source of damage.
- Full recovery at 23:23:05.613 records 680/680 and idle/hold, opacity 0.2/1.0. Vital fading begins at 23:23:07.163 (~1.55s); idle/idle reaches 0.2/0.2 at 23:23:08.130. Ordinary remains dim throughout healing: its timer was not restarted.
- No CombatHUD fail-safe disable, scheduler failure, restoration warning or native opacity conflict is recorded. UE4SS startup also contains ConsoleManagerSingleton signature and FObjectPtrProperty exposure warnings; no causal connection to a CombatHUD failure is established, and this session continued through all observed transitions.

Visual correctness and native menu hiding are confirmed by the user, not independently measured by detailed menu telemetry in this production log. Exact sub-frame latency, every menu/dialogue, pause/resume, respawn/HUD replacement and partial-HP initial load are not individually established by this short session. Existing offline coverage and historical research remain separate evidence. Visible crystals and keyboard/gamepad switching remain intentionally deferred until natural unlock.

The payload is unchanged; previous accepted 0.1.0 rollback remains preserved. The initial runtime report was synchronized to the feature branch as `1c692d433c5b8d1458784d03d1ce5332ad8e0c61` before stable acceptance.

## Stable acceptance — 2026-10-27

The user explicitly accepted CombatHUD 0.2.0, authorized main promotion and requested preservation of the previous version for rollback. Visible crystals/input-mode testing remains deferred until natural unlock. This is the accepted scope, not a claim that every game state has been tested.

- Published stable source tag: `CombatHUD-v0.2.0`, commit `6fd1373da08f332b0340006ad5f52d3c0f43083d`. Main integration commit: `281fe9ce6f1130cfc38330e14c2bd5402eff1bdd` (also preserves parallel research bootstrap). GitHub Release publication is pending explicit permission. The tag records the main promotion state; the tested Lua source identity remains `ca342e33442a11b46a9ab30ed8e8cd796c9a8d60`.
- Package: `CombatHUD-0.2.0.zip`, SHA-256 `d7cd5c9e62f65ed2802d5ac2614ca11a09d5cc79a8c42852c3cd124dcaa37c0d`. Only the exact frozen Lua payload, VERSION, installation guidance and original-code license notices are included. No host assets, research probes, UE4SS or UEHelpers are bundled.
- Packaging checks: archive member allowlist, ZIP integrity and byte equality of both Lua members against the frozen candidate and source commit; VERSION/startup/package/tag identity agree. Previous 0.1.0 rollback and the original source archive hashes rechecked. Installed game files are not replaced during promotion.
- Support-log audit: startup version, UE4SS identity, player binding and sparse state transitions are visible; failure paths name disable/restore outcomes and are covered by existing adapter tests. No per-tick success trace or experimental key bindings are shipped. The literal startup word "candidate" remains in the accepted immutable Lua; version/hash identity is authoritative.
