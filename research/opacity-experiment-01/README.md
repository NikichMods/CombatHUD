# CombatHUD opacity experiment 01

> Historical research artifact, completed before CombatHUD 0.2.0 acceptance. Do not install or rerun as a current task; see ../../docs/STATUS.md for current scope and evidence.


Research identity `combathud-opacity-01`; no production Lua or mod VERSION changes. Starting decision baseline: `e0cd8ddc77147b95341296c13ffb7c83d466eea6`.

## Question and minimum method

HP getters and HP ownership already passed. The new uncertainty is the three item slots and whether disjoint opacity groups survive native rendering/visibility and can be restored. Existing static item exports identify `HUDUseItemUMG_BP.QuickItem0/1/2` under `QuickItem_Panel`; `CrystalList_Panel` and `HUDCrystalUMG_Pad_BP` are siblings. `HUDItemSlotUMG_BP` contains `Bg_Image`, `Icon_Image`, `ValueBg_Image`, `Value_Text`, `Key_Image` under `MainPanel`. SlotIndex 1/2 are explicit in the static export; index 0 uses defaults. Live identities/content remain to be checked. Raw exports are local only.

Use one manual visual projection, without reimplementing the new HP/combat/timer policy or repeating damage/healing. This avoids coupling untested rendering to a new state machine. It proves the visual states and rollback, not automatic reveal timing after damage, full-health hold or production acceptance. No HP, gameplay, save, native Visibility, brush, text or layout writes.

Reparenting, duplicated widgets, material changes, absolute alpha compensation and a general HUD framework are unnecessary: verified status siblings and new item siblings provide non-overlapping boundaries.

## One writer and exact identity

At closed-game install, back up the entire original mods.txt bytes, accepted CombatHUD payload, its hashes, the current SoulsEnemyHUD hashes and the pre-run UE4SS log outside loader paths. Change only `CombatHUD : 1` to `CombatHUD : 0`; verify no independent CombatHUD enabled.txt exists. Accepted Lua remains at its original location with identical hashes. Enable only the separate `CombatHUDOpacityExperiment` research folder. Do not touch SoulsEnemyHUD or other mods. If the destination or loader state differs, inspect rather than overwrite.

At cleanup, after the user closes the game: preserve the session log and installed research source; remove only recorded experiment files/empty directories; restore mods.txt byte-for-byte from its pre-run snapshot after checking it still equals the installed temporary list. Verify production hashes, original loader list and absence of the experiment marker. No hot reload. The source commit/hash and installed bytes are recorded in a private deployment manifest; numbered experiment source is frozen after handoff.

## Runtime controls and matrix

The experiment starts **passive**, waiting for a verified GenesisCharacter owning pawn. It performs a bounded binding once per HUD generation and records exact owner/child/address matches. Ctrl+F8/F9 request a mode; writes occur only in the next game-thread callback. Ctrl+F10 restores and ends the observer. No opacity writes repeat every tick, so a native overwrite is not concealed by reassertion.

| Action | Visual projection / evidence | Required user observation |
| --- | --- | --- |
| Load gameplay, wait a few seconds | READY; 17 separate targets, 18 item/part records; no writes yet | Baseline appearance |
| Ctrl+F8 | HP eight layers and QuickItem_Panel at original brightness; other status children, keyboard/pad crystal siblings and both right skill panels multiplied by 0.20 | All three item icons, counts, 1/2/3 labels and frames remain coherent/bright; stamina, experience, F1/F2/F3 and right skills dim; no flicker |
| Ctrl+F9, then Ctrl+F8 | Full-original versus split, only manual visual state | Compare the same elements; no health loss/healing required |
| With split active, open/close available inventory/profile/system menus; an existing dialogue only if convenient | Read-only NATIVE_CONTEXT for untouched ancestor opacity/visibility | Native hiding/attenuation remains correct; return to split correctly; name exactly which states were available |
| Ctrl+F10, remain in gameplay briefly | Restore only our unchanged last-written values; readback verification and ROLLBACK/STOP | Original baseline visible again, no stranded dim elements |
| Close game, report observations | Installer cleanup and exact production/loader restore | No further game actions required for installation cleanup |

The bright quick-item panel includes all three slots and their internal icon/background/count/key widgets; their inner alpha/Visibility remain native. The keyboard crystal sibling includes four native KBCrystalSlot0..3, even if only three F-key hints are displayed. Do not force hidden native children visible. Static key-index interpretation and actual labels must be distinguished until the user checks rendering.

## Ownership and monitoring

12 status children + QuickItem_Panel + CrystalList_Panel + HUDCrystalUMG_Pad_BP + two right panels = 17 targets. Do not dim their common left/item/status ancestors. Original RenderOpacity is captured once; split applies original times 0.20 for dim groups and original times 1 for HP/items. No selected target is an ancestor of another selected target.

The 50-ms read-only monitor compares target opacity against the last exact write. Any mismatch logs NATIVE_WRITE and disables the experiment with rollback; it does not fight native code. Rollback restores a target only if its value still equals the experiment's last write, or recognises an already-restored original. A newer differing native value is preserved and cleanup is reported incomplete. Destroyed widgets are recorded as expired. A scheduler failure cannot safely restore off-thread; it logs cleanup=false and requires closing the game to discard session-only values.

Untouched common ancestors are observed, not forced to 1 or to visible. `GetParent()` ends at inner UserWidget roots; reflected outer ownership bridges that boundary. Observing no conflicts proves only the sampled interval/scenarios; transient writes between samples and untested states remain limitations. Human observation is required for flicker, icons, text, frames and effective parent transparency.

Bounds: one queued callback; no broad per-frame discovery; at most one discovery/sec while unbound; at most four HUD generations; 15-minute or log-bound stop invokes rollback. Key handlers after stop are inert until process exit; no hot reload/unregister assumption. Research values are session-only, with no save-persistent action. The game is only launched/closed by the user.

## Offline checks

`python CombatHUD/research/opacity-experiment-01/test_harness.py` with the existing Lupa dependency verifies passive startup, split/full, no per-tick writes, untouched native ancestor hiding, rollback/readback, preserving a newer native target value on conflict, and ignoring startup DefaultPawn. These are safety checks, not UE4SS binding or visual acceptance.
