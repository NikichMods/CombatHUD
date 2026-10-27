# Opacity experiment 02 — item content binding correction

Same visual modes, one-writer installation, bounded monitoring and cleanup as [attempt 01](../opacity-experiment-01/README.md). Identity `combathud-opacity-02`; no mod VERSION change. First source/installed bytes and raw session are frozen.

Attempt 01 reached QuickItem0 and its content panel, but rejected a redundant internal reflected-field vs child-name lookup before READY or any opacity write. The first log does not identify the failing alias or actual child spelling; do not assert an established FName/casing root cause. It records no MODE/WRITE and rollback restored zero targets. This is a probe binding failure, not a failed RenderOpacity mechanism or evidence that the key API is broken.

Attempt 02 logs the actual five content children with their classes, parents, alpha and Visibility; requires four Images and one TextBlock beneath the verified item content panel. It records each internal reflected field/address and whether it matches any child by address, without using displayed FName spelling as a Lua-key identity test. These fields are never write targets: the enclosing verified QuickItem_Panel is the only item opacity writer. All prior outer ownership, slot-count, selected-target identity, native conflict and rollback checks remain. CONTROL markers distinguish received shortcuts from later mode application.

Offline checks include a varied child display spelling fixture, which proves that spelling does not need to govern this parent opacity experiment; it is not evidence of the live failure's cause. No HP, gameplay, Visibility, layout, text or save writes.

Use the same Ctrl+F8 split, Ctrl+F9 all-bright, Ctrl+F10 restore-and-stop sequence. With split active, inspect item icon/count/key/frame, dark stamina/experience/crystals/right skills, and available menus. Then restore, close the game and report observations. The accepted CombatHUD remains disabled only in the backed-up temporary loader list until this experiment is removed closed-game and the original list is restored exactly.
