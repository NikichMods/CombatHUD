# CombatHUD 0.2.0 — runtime candidate

Status: installed 2026-10-27; user runtime acceptance pending. Not stable; no main merge or release.

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

User test: full HP idle 20%; combat reveal over 1s; combat exit hold 1.5s then fade 1s; detected damage immediately reveals all groups (nominal 50ms sampling); partial HP keeps HP + all three quick items bright while other groups fade independently; healing to full starts only HP/item hold; repeated damage resets the relevant delay; native menus/dialogue hiding, pause and transitions remain correct. Crystals/input-mode visibility intentionally deferred until natural unlock; do not alter saves or force unlocks.

Next: after the user's run, snapshot the new UE4SS log before restart, verify installed hashes and the 0.2.0 startup marker, correlate state/containment lines with user observations. Record only supported findings, retain unresolved cases and synchronize the feature branch. No runtime result or acceptance is recorded yet.
