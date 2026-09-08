#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Goal     : First-party CLI for CJ-Hurc/Kimi-K3 docs/assets/tech-report workspace.
# Purpose  : status/--help print usage (no side effects). validate checks
#            LICENSE + README + assets + tech report + runtime + occupancy.
# Consumers: humans, CI, complete-e2e CLI contract / universal scaffold.
# Exit codes: 0 help/status/validate/config / 1 contract fail / 2 usage
# Side effects: none for help/status/config/validate (file reads only).
# -----------------------------------------------------------------------------
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

usage() {
	cat <<'USAGE'
usage: devtools/kimi-k3/run.sh <status|--help|help|config|validate>
  status / --help   Print this help (no side effects).
  config            List first-party entrypoints.
  validate          Fail-closed contract checks on LICENSE/README/assets/report + runtime.
First-party surfaces: LICENSE, README.md, assets/kimi-logo.png, k3_tech_report.pdf,
run.sh, devtools/kimi-k3/run.sh, configs/complete-e2e/runtime.json,
configs/complete-e2e/list-runtime-clis.sh, scripts/complete-e2e/prove/{entity,repository}.py.
USAGE
}

require_file() {
	local rel="$1"
	[[ -f "$ROOT/$rel" ]] || { echo "validate fail: missing $rel" >&2; return 1; }
}

cmd="${1:-}"
case "$cmd" in
	""|status|--help|-h|help)
		usage
		exit 0
		;;
	config)
		printf '%s\n' \
			'LICENSE' \
			'README.md' \
			'assets/kimi-logo.png' \
			'k3_tech_report.pdf' \
			'run.sh' \
			'devtools/kimi-k3/run.sh' \
			'configs/complete-e2e/runtime.json' \
			'configs/complete-e2e/list-runtime-clis.sh' \
			'scripts/complete-e2e/prove/entity.py' \
			'scripts/complete-e2e/prove/repository.py'
		;;
	validate)
		require_file "LICENSE"
		require_file "README.md"
		require_file "assets/kimi-logo.png"
		require_file "k3_tech_report.pdf"
		require_file "run.sh"
		require_file "devtools/kimi-k3/run.sh"
		require_file "configs/complete-e2e/runtime.json"
		require_file "configs/complete-e2e/list-runtime-clis.sh"
		require_file "scripts/complete-e2e/prove/entity.py"
		require_file "scripts/complete-e2e/prove/repository.py"
		grep -q 'Kimi' "$ROOT/README.md" || { echo "validate fail: README identity" >&2; exit 1; }
		grep -q 'KIMI_K3_ALLOWED' "$ROOT/run.sh" || { echo "validate fail: root allow gate" >&2; exit 1; }
		grep -q 'usage:' "$ROOT/devtools/kimi-k3/run.sh" || { echo "validate fail: CLI usage banner" >&2; exit 1; }
		grep -q 'hurc-complete-e2e-runtime/v1' "$ROOT/configs/complete-e2e/runtime.json" || { echo "validate fail: runtime schema" >&2; exit 1; }
		grep -q 'kimi-k3-cli-runtime' "$ROOT/configs/complete-e2e/runtime.json" || { echo "validate fail: runtime adapter id" >&2; exit 1; }
		grep -q 'cli:kimi-k3' "$ROOT/configs/complete-e2e/list-runtime-clis.sh" || { echo "validate fail: runtime surface id" >&2; exit 1; }
		echo "ok kimi-k3 validate"
		;;
	*)
		echo "unknown command: $cmd" >&2
		usage >&2
		exit 2
		;;
esac
