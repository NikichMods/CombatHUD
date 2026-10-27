# ChatGPT Project Instructions — Asterigos CombatHUD

Project: `Asterigos — HUD скрывающийся`; repository: `NikichMods/CombatHUD`; independent repository.
Target runtime: Asterigos: Curse of the Stars, Windows x64, UE4.27. The repository documents the tested Steam 1.09/build12996889 environment; other builds require separate evidence.
Purpose: maintain and improve automatic fading of the lower HUD panels outside combat while preserving combat readability and existing game behavior. This ChatGPT Project is scoped to CombatHUD, not the sibling mods.

For NikichMods work, read the current `NikichMods/DevRules/WORKING_RULES.md` and the target repository's root `AGENTS.md`. Follow the DevRules action-based reading map and the task-relevant canonical evidence. For local checkout work also follow `CODEX_WORKFLOW.md` and recover actual files, including unpublished changes. Apply specialized engineering, runtime, Git, CI, licensing and acceptance rules when their subject applies. Preserve adopted decisions under `WORKING_RULES.md`; use available tools for authorized mechanical work. These pointers do not replace owning rules or expand permissions.

Recovery entry points:
- `README.md`, `docs/CURRENT_STATE.md`, `docs/WORKFLOW.md` — repository and workflow context.
- `docs/STATUS.md`, `docs/REQUIREMENTS.md`, `docs/VERIFIED_RUNTIME.md`, `README.md` — current component status, adopted behavior, runtime evidence and usage.
- `Scripts/`, `tests/`, `VERSION` — source, tests and canonical component version.
- `docs/BASELINE.json` — imported accepted payload identity.

Shared host research: canonical `NikichMods/Asterigos-Research/docs/RESEARCH_INDEX.md`, with historical host evidence retained in AsterigosMods. Mod-specific findings belong in `docs/VERIFIED_RUNTIME.md`. Current accepted version and deferred checks are owned by docs/STATUS.md; do not infer them from old chat summaries.

Project-specific execution constraints:
- Work primarily in ordinary ChatGPT through GitHub; use local Codex only when remote tools cannot reliably establish or implement the needed behavior. GitHub Actions may be introduced under `CI_POLICY.md` when a meaningful remote test/build can be implemented.
- Do not launch or terminate the game without explicit authorization. Do not replace mod files while the game runs or use unverified UE4SS hot reload.
- Preserve accepted CombatHUD behavior and other mod folders unless their changes are separately authorized. Offline/mock tests cannot substitute for the user's in-game visual/runtime acceptance.
- Treat local game paths, installed binaries, proprietary assets and ignored `.local` evidence as unavailable from GitHub unless explicitly supplied. Do not invent their state.

Follow canonical evidence and acceptance gates, continuous decision capture and verified immutable-artifact handoff rules. Repository evidence outranks chat memory; investigate conflicts before relying on either. Use available tools for mechanical work and ask the user only for necessary decisions, permissions or runtime/perceptual evidence. New chats can start with the actual task and should recover current state before proceeding.

This is a bootstrap adapter; mutable state and detailed policy remain in the owning repository and DevRules.
