#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Goal     : Machine-prove kimi-k3 CLI scaffold for accepted proof receipt.
# Purpose  : Kernel command for complete-e2e P11 issue-accepted-receipt.
# Exit: 0 pass / nonzero fail
# -----------------------------------------------------------------------------
set -uo pipefail
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
	echo "Usage: scripts/complete-e2e/prove.sh"
	echo "Help: prove kimi-k3 dual-origin CLI + validate occupancy scripts."
	exit 0
fi
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT" || exit 2
fail=0
pass() { printf 'PASS %s\n' "$*"; }
fail_one() { printf 'FAIL %s\n' "$*"; fail=1; }

bash devtools/kimi-k3/run.sh validate || fail_one "kimi-k3 validate"
bash devtools/kimi-k3/run.sh status >/dev/null || fail_one "kimi-k3 status"
bash configs/complete-e2e/list-runtime-clis.sh | grep -q '"id": "cli:kimi-k3"' || fail_one "runtime missing cli:kimi-k3"
[[ -f scripts/complete-e2e/prove/repository.py ]] || fail_one "repository.py missing"
[[ -f scripts/complete-e2e/prove/entity.py ]] || fail_one "entity.py missing"
python3 -m py_compile scripts/complete-e2e/prove/repository.py scripts/complete-e2e/prove/entity.py || fail_one "prove py_compile"
[[ "$fail" -eq 0 ]] || exit 1
printf 'OK kimi-k3-complete-e2e-prove\n'
exit 0
