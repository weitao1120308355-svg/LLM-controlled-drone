#!/usr/bin/env bash
# Install the custom Gazebo demo world into PX4-Autopilot.
#
# This prevents the common "I only see the drone" problem caused by launching
# PX4's default empty world instead of this repository's drone_demo world.
#
# Usage:
#   bash scripts/install_demo_world.sh
#   PX4_DIR=~/PX4-Autopilot bash scripts/install_demo_world.sh
#   bash scripts/install_demo_world.sh --copy

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WORLD_SRC="$REPO_ROOT/worlds/drone_demo.sdf"
PX4_DIR="${PX4_DIR:-$HOME/PX4-Autopilot}"
PX4_WORLDS_DIR="$PX4_DIR/Tools/simulation/gz/worlds"
WORLD_DST="$PX4_WORLDS_DIR/drone_demo.sdf"
MODE="symlink"

if [[ "${1:-}" == "--copy" ]]; then
  MODE="copy"
elif [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  sed -n '1,14p' "$0"
  exit 0
fi

if [[ ! -f "$WORLD_SRC" ]]; then
  echo "ERROR: world file not found: $WORLD_SRC" >&2
  exit 1
fi

if [[ ! -d "$PX4_DIR" ]]; then
  echo "ERROR: PX4_DIR does not exist: $PX4_DIR" >&2
  echo "Set PX4_DIR to your PX4-Autopilot path, for example:" >&2
  echo "  PX4_DIR=/path/to/PX4-Autopilot bash scripts/install_demo_world.sh" >&2
  exit 1
fi

mkdir -p "$PX4_WORLDS_DIR"

if [[ -e "$WORLD_DST" || -L "$WORLD_DST" ]]; then
  rm -f "$WORLD_DST"
fi

if [[ "$MODE" == "copy" ]]; then
  cp "$WORLD_SRC" "$WORLD_DST"
  echo "Copied demo world to: $WORLD_DST"
else
  ln -s "$WORLD_SRC" "$WORLD_DST"
  echo "Linked demo world to: $WORLD_DST"
fi

cat <<EOF

Launch PX4 SITL with the demo world:

  cd "$PX4_DIR"
  PX4_GZ_WORLD=drone_demo make px4_sitl gz_x500_mono_cam

Headless mode:

  cd "$PX4_DIR"
  HEADLESS=1 PX4_GZ_WORLD=drone_demo make px4_sitl gz_x500_mono_cam

Expected scene objects:
  - person_1 about 20 m north of origin
  - car_1 about 25 m east of origin

If you still see only the drone, check Gazebo Fuel model download errors in the terminal logs.
EOF
