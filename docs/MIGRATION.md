# Independent repository import — 2026-10-28

Stable baseline; no new runtime acceptance or release. Current branch: `main`, VERSION `0.2.0`. This is an organizational, byte-preserving import; no version bump, package rebuild, installation or runtime launch occurred. Product state remains owned by STATUS.md.

Source: [NikichMods/AsterigosMods](https://github.com/NikichMods/AsterigosMods), subtree `CombatHUD/`, source branch tip [0fb78e76c24306ade338b85f63cb5f2dbfa7f9e7](https://github.com/NikichMods/AsterigosMods/commit/0fb78e76c24306ade338b85f63cb5f2dbfa7f9e7). Plan at [0fb78e76c24306ade338b85f63cb5f2dbfa7f9e7](https://github.com/NikichMods/AsterigosMods/blob/0fb78e76c24306ade338b85f63cb5f2dbfa7f9e7/docs/REPOSITORY_SPLIT_PLAN.md); DevRules checked at c9a90c04336072e821761e376d1702d63899c4ab.

History was extracted with `git subtree split --prefix=CombatHUD <original tip>` in an isolated copy. Child IDs are rewritten IDs, not original commit identities. The extracted tree was compared byte-for-byte to every original tracked module file before adapting repository contracts, documentation and the test launcher. Runtime Lua, UI/CSS, recipe, ini fragment and VERSION remain byte-identical to their own source tip. All original local/remote refs and service checkpoints were also retained in a private full-history Git bundle; the original repository/worktrees remain intact.

| Branch | Original monorepo tip | Extracted child tip before standalone adapter |
| --- | --- | --- |
| main | `0fb78e76c24306ade338b85f63cb5f2dbfa7f9e7` | `1f7664697ead80319122b198fbee153c5398c523` |
| feature/combathud-hp-visibility | `f65d5e58d6f02b2559f5131912cfdfc9aec71dbd` | `8b3b670dda88a336db0d34d4389592ec2c52bf67` |
| research/combathud-hp-visibility | `f56e30d6dc1edf4233909177c8d02d6b8b26b409` | `9c72440451cee4aafabb5fa5208e3710042d6749` |

All original published tags and Releases remain at AsterigosMods with unchanged targets/assets. No replacement semantic tags or Releases are created here. Accepted origin links: [CombatHUD-v0.2.0](https://github.com/NikichMods/AsterigosMods/releases/tag/CombatHUD-v0.2.0), [SoulsEnemyHUD-v0.2.0](https://github.com/NikichMods/AsterigosMods/tree/SoulsEnemyHUD-v0.2.0). CombatHUD's ZIP SHA-256 is d7cd5c9e62f65ed2802d5ac2614ca11a09d5cc79a8c42852c3cd124dcaa37c0d; its checksum file SHA-256 is 0a7bf84ea9fea3c8879739d143d47eb2c875eee2c6fa2cee4e14c79d3b57624a. These remain historical artifacts, not new releases of this import.

The six modules were separated as siblings under a local game group without a parent Git repository. Existing busy source directories were not renamed or overwritten. Owner-specific ignored candidates, rollback and local evidence were copied with SHA-256 verification; the complete historical archive and original .local remain intact. Private paths and manifests are excluded from public Git.

Independent validation and final GitHub revisions are recorded in the migration report and VALIDATION.md. No fully standalone proprietary asset packaging is claimed. Shared research: [canonical index](https://github.com/NikichMods/Asterigos-Research/blob/main/docs/RESEARCH_INDEX.md).
