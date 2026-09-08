#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Goal     : Emit kimi-k3 CLI surfaces as JSON for complete-e2e compile.
# Purpose  : Discover first-party CLI entrypoints that exist. Prefer
#            devtools/kimi-k3/run.sh so static+declarative+runtime share origins.
# Consumers: configs/complete-e2e/runtime.json adapter kimi-k3-cli-runtime.
# Outputs  : stdout JSON {surfaces:[...]} only.
# Exit codes: 0 ok / 1 missing python3
# Side effects: none.
# -----------------------------------------------------------------------------
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
command -v python3 >/dev/null 2>&1 || { echo "python3 required" >&2; exit 1; }
python3 - "$ROOT" <<'PY'
import json, sys
from pathlib import Path

root = Path(sys.argv[1])
candidates = [
    ("cli:kimi-k3", "devtools/kimi-k3/run.sh"),
]
surfaces = []
seen = set()
for sid, rel in candidates:
    if sid in seen:
        continue
    p = root / rel
    if p.is_file():
        seen.add(sid)
        surfaces.append({
            "id": sid,
            "kind": "cli",
            "path": rel,
            "origin": "runtime",
            "discovered": True,
        })
print(json.dumps({"surfaces": surfaces}))
PY
