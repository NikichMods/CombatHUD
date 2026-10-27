# HP read-only probe — attempt 02

Same read-only scope, bounds, observation matrix and cleanup as [attempt 01](../hp-readonly-probe/README.md). Identity `combathud-hp-readonly-02`; no mod VERSION change. Attempt 01 source and its installed bytes are frozen.

The first runtime session confirmed both reflected signatures and the GameGlobal CDO, but stopped with zero HP samples when the early viewport HUD returned a pawn outside the verified GenesisCharacter ancestry. Accepted CombatHUD validated hilda_BP_C about 10 seconds later. Attempt 02 treats missing/wrong-type owning pawn as an unavailable sample, matching the production adapter; it reacquires HUD no faster than once per second. Multiple in-viewport HUDs also defer discovery rather than invoking a guessed owner. No guessed fallback pawn is used. Unexpected getter signatures/data and actual hierarchy contract errors still stop the observer.

Minimum user action remains one natural incomplete-to-full HP cycle, adding a small ordinary hit first only if starting at full HP. Collect logs directly, then remove the distinct probe only with the game closed. This attempt does not perform opacity writes or alter production payloads.
