# Independent import validation — 2026-10-28

Validated source revision before this evidence-only commit: `4a90f7146a4bdf6edcc4248dcda51f265777f09c`, branch `research/combathud-hp-visibility`.

- Extraction: every original tracked module file matched its original Git blob before repository adaptation. Production Lua, authored UI/CSS, recipe/ini and VERSION were checked in both the working copy and committed Git blobs; 7 inputs unchanged. Exact original SHA-256 values are in IMPORT_PROVENANCE.json.
- Public history: all 106 reachable blobs across the extracted branches inspected for prohibited payload paths/extensions and secret-like content; no excluded game files/fonts/binaries/local directories found. Full original refs/checkpoints remain in the private recovery bundle, not in the new public source history.
- Local Markdown targets: PASS. Git clean before and after checks; git fsck --full PASS.
- Independent checks: **PASS**. Test launcher runs only this repository's tests; research safety harnesses run separately when present. Python 3.12 / external lupa 2.8 and Node used for Lua/JS suites. Private verification log SHA-256: `aac40a32cac2766dd405c8f928178b6e81537562805c4a27211daabc94b962eb`.
- Owner-specific ignored inputs/candidates/rollback were COPY-verified by SHA-256; complete source .local and original archive preserved. No production build, installation, game launch, save or setting change performed.

These are migration/offline checks. Existing user acceptance remains historical exact evidence; unaccepted feature/research branches remain unaccepted. Fully standalone proprietary asset packaging and unobserved runtime states are not established.
