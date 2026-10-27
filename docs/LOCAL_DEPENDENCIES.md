# External local dependencies

The complete pre-import archive and original ignored .local remain intact. New owner-specific copies are under ignored .local, with private SHA-256 copy manifests outside public repositories. Exact private locations are in .local/environment.json. No proprietary payload is tracked, and no game/settings/save/loader file is modified.

Tests use Python 3 plus external lupa==2.8 where applicable; SoulsEnemyHUD authored JS uses Node. UE4SS/UEHelpers and proprietary game resources must be supplied separately. Local tests do not prove fully standalone package reproducibility or engine rendering.
