#!/bin/bash

export PATH=/usr/bin:/bin:"$PATH"
export LC_ALL=UTF-8

BIN_DIR="$(cd "$(dirname "$0")" && pwd )"
BASE_DIR="$(dirname "$BIN_DIR")"
PROJECT_DIR=$(dirname "$BASE_DIR")

unset help exit tweaker_before_linking
while getopts "hl" option; do #{{{
  case $option in
    h)
      help=1
      ;;
    l)
      tweaker_before_linking=1
      ;;
    *)
      exit=1
      ;;
  esac
done #}}}
shift $(($OPTIND - 1))

[ -z "$help" ] || { #{{{
  cat << EOF
Usage:
$0 [<options>] <xcode_dir> <app_key>

  -l                     set tweaker script phase before the linking phase
  -h                     this help message
EOF
  exit
} #}}}

xcode_dir="$1"
app_key=$2

[ -d "$xcode_dir" ] || { echo "Can't find xcode project dir ($xcode_dir)"; exit=1; }
[ -n "$app_key" ] || { echo "app_key is required"; exit=1; }

[ -z "$exit" ] || exit 1

"$BIN_DIR"/xcode_ruby_helpers/install.rb << EOF
{
  "xcode_dir": "$xcode_dir",
  "app_key": "$app_key",
  "files_to_add": [
    "Rollout-ios-SDK/Rollout/RolloutDynamic.m",
    "Rollout-ios-SDK/auto_generated_code/RolloutDynamic_structs.h",
    `seq -f '"Rollout-ios-SDK/auto_generated_code/RolloutDynamic_%02g.m",' 1 20`
    "Rollout-ios-SDK/Rollout/Rollout.framework"
  ],
  "weak_system_frameworks": [
    "System/Library/Frameworks/JavaScriptCore.framework"
  ],
  `[ -z "$tweaker_before_linking" ] || echo "\"tweaker_phase_before_linking\": 1,"`
  "sdk_subdir": "Rollout-ios-SDK"
}
EOF

