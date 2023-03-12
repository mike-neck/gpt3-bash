#!/usr/bin/env bash

set -eu

readonly selfDir="$(cd "$(dirname "${0}")" && pwd)"
readonly utilDir="${selfDir}/util"
readonly authorizationToken="${utilDir}/header.sh"

curl  --request GET \
      --silent \
      --location \
      --header "$("${authorizationToken}")" \
      --url "https://api.openai.com/v1/models" |
  jq  --compact-output '.data[]'
