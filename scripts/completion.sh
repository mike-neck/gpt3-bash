#!/usr/bin/env bash

# completion.sh
#
# 1. model
# 2. maxToken
# 3. temperature (0..2) # randomness
# 4. prompt

set -e

readonly selfDir="$(cd "$(dirname "${0}")" && pwd)"
readonly utilDir="${selfDir}/util"
readonly authorizationToken="${utilDir}/header.sh"

readonly authorizationHeader="$("${authorizationToken}")"
if [[ -z "${authorizationHeader}" ]]; then
  echo "header not found" > /dev/stderr
  exit 100
fi

readonly model="${1}"
if [[ -z "${model}" ]]; then
  echo "empty model name" > /dev/stderr
  exit 1
fi

shift
readonly maxToken="${1}"
if [[ -z "${maxToken}" ]] || [[ ! "${maxToken}" =~ ^[0-9]+$ ]]; then
  echo "maxToken(2: ${maxToken}) is not number" > /dev/stderr
  exit 2
fi

shift
readonly temperature="${1}"
if [[ -z "${temperature}" ]] || [[ ! "${temperature}" =~ ^[012]$ ]]; then
  echo "temperature(3: ${temperature}) is 0 or 1 or 2." > /dev/stderr
  exit 3
fi

shift
readonly prompt="${1}"
if [[ -z "${prompt}" ]]; then
  echo "prompt(4) is empty." > /dev/stderr
  exit 4
fi

set -u

readonly OLD_IFS="${IFS}"
declare -a query=()

query+=("model: \"${model}\"")
query+=("max_tokens: ${maxToken}")
query+=("temperature: ${temperature}")
query+=("prompt: \"${prompt}\"")

IFS=","
readonly body="$(jq --null-input --compact-output "{${query[*]}}")"
IFS="${OLD_IFS}"

curl  --request POST \
      --silent \
      --location \
      --header 'accept: application/json' \
      --header 'content-type: application/json' \
      --header "${authorizationHeader}" \
      --url "https://api.openai.com/v1/completions"\
      --data "${body}"
