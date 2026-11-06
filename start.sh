#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HOST="${HOST:-127.0.0.1}"
PORT="${PORT:-7860}"

usage() {
    echo "Usage: ./start.sh [--host ADDRESS] [--port PORT]"
    echo "Defaults: host 127.0.0.1, port 7860"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --host)
            if [[ $# -lt 2 || -z "$2" ]]; then
                echo "start.sh: --host requires an address" >&2
                exit 2
            fi
            HOST="$2"
            shift 2
            ;;
        --host=*)
            HOST="${1#*=}"
            if [[ -z "$HOST" ]]; then
                echo "start.sh: --host requires an address" >&2
                exit 2
            fi
            shift
            ;;
        --port)
            if [[ $# -lt 2 ]]; then
                echo "start.sh: --port requires a number" >&2
                exit 2
            fi
            PORT="$2"
            shift 2
            ;;
        --port=*)
            PORT="${1#*=}"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "start.sh: unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

if ! [[ "$PORT" =~ ^[1-9][0-9]*$ ]] || (( PORT > 65535 )); then
    echo "start.sh: --port must be 1..65535" >&2
    exit 2
fi

if [[ ! -d "$ROOT/.venv" ]]; then
    echo "start.sh: missing virtual environment at $ROOT/.venv" >&2
    if command -v python3 >/dev/null 2>&1; then
        echo "Create it with: python3 -m venv .venv && .venv/bin/python -m pip install -r requirements.txt" >&2
    else
        echo "Python 3 was not found on PATH. Install Python 3.11 or 3.12, then create .venv." >&2
    fi
    exit 1
fi

PYTHON="$ROOT/.venv/bin/python"
if [[ ! -x "$PYTHON" ]]; then
    echo "start.sh: missing executable Python at $PYTHON" >&2
    echo "Recreate the virtual environment with: python3 -m venv .venv" >&2
    exit 1
fi

if [[ "$HOST" == '0.0.0.0' || "$HOST" == '::' ]]; then
    echo "Handdraw listening on all interfaces at port $PORT."
    echo "Use this machine's IP address from another device if the network allows it."
else
    echo "Handdraw: http://$HOST:$PORT"
fi

cd "$ROOT"
exec "$PYTHON" "$ROOT/app.py" --host "$HOST" --port "$PORT"
