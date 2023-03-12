#!/usr/bin/env bash

# token order
# 1. .config/gpt3-bash/config.yml in current directory
# 2. $HOME/.config/gpt3-bash/config.yml

readonly configFile=".config/gpt3-bash/config.yml"
readonly currentDir="$(pwd)"

function getToken() {
  local filePath="${1}"
  [[ -f "${filePath}" ]] || return 1
  grep 'token:' "${filePath}" |
    head -n 1|
    cut -d ':' -f2 |
    tr -d ' '
}

declare -a configCandidates

configCandidates+=("${currentDir/%\//}/${configFile}")
configCandidates+=("${HOME/%\//}/${configFile}")

declare token
for candidate in "${configCandidates[@]}" ; do
  token="$(getToken "${candidate}")"
  if [[ -n "${token}" ]]; then
    echo "authorization: Bearer ${token}"
    exit 0
  fi
done

echo "Get API token via https://platform.openai.com/account/api-keys" > /dev/stderr
exit 1
