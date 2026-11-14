#!/bin/bash
#
# Builds images from the catalog (docker-bake.hcl) for the local platform, adds the
# patch-level tags and checks that each image contains the version the catalog asks for.
#
#   bin/build.sh                      all maintained images (bake group "default")
#   bin/build.sh php mariadb-11-8     groups and/or targets, see: docker buildx bake --print
#   NAMESPACE=test bin/build.sh ...   tag as test/* instead of sandstein/*
#   TAGS_FILE=tags.txt bin/build.sh   also write every resulting image reference to a file
#
# Must be run from the repository root. Fails as soon as a build fails or a version
# cannot be determined or does not match.

set -o errexit
set -o nounset
set -o pipefail

export NAMESPACE=${NAMESPACE:-sandstein}
TAGS_FILE=${TAGS_FILE:-}

[[ $# -gt 0 ]] || set -- default

# the version inside an image, by repository; empty = the image has no patch tag
detect_version() {
  local repo=$1 image=$2 cmd
  case ${repo} in
    php)                  cmd=(php -r 'echo PHP_VERSION;') ;;
    mariadb)              cmd=(mariadbd --version) ;;
    mysql)                cmd=(mysqld --version) ;;
    node)                 cmd=(node -v) ;;
    python)               cmd=(python -V) ;;
    apache)               cmd=(httpd -v) ;;
    selenium-side-runner) cmd=(selenium-side-runner --version) ;;
    *)                    return 0 ;;
  esac
  local output found
  output=$(docker run --rm --entrypoint '' "${image}" "${cmd[@]}" 2>&1)
  # first x.y.z (or x.y) in the output, e.g. "Server version: Apache/2.4.65 (Unix)" -> 2.4.65
  found=$(grep --only-matching --perl-regexp '\d+\.\d+(\.\d+)?' <<< "${output}" | head -n1 || true)
  if [[ -z ${found} ]]; then
    echo "${image}: could not determine a version from: ${output}" >&2
    return 1
  fi
  echo "${found}"
}

definition=$(docker buildx bake --print "$@" 2>/dev/null)

docker buildx bake --load "$@"

[[ -z ${TAGS_FILE} ]] || : > "${TAGS_FILE}"

# fields are separated by "|": tab is whitespace for read and would swallow empty fields
while IFS='|' read -r target version minor_tag other_tags; do
  repo=${minor_tag#*/}
  repo=${repo%%:*}
  tags=("${minor_tag}")
  if [[ -n ${other_tags} ]]; then
    read -r -a more <<< "${other_tags}"
    tags+=("${more[@]}")
  fi

  patch=$(detect_version "${repo}" "${minor_tag}")
  if [[ -n ${patch} ]]; then
    if [[ -n ${version} ]]; then
      # the catalog version must be a prefix of the real one, e.g. 8.4 -> 8.4.15
      if [[ ${patch} != "${version}" && ${patch} != "${version}".* ]]; then
        echo "${target}: image contains ${repo} ${patch}, the catalog expects ${version}" >&2
        exit 1
      fi
      # cli-8.4-prod -> cli-8.4.15-prod
      tag=${minor_tag#*:}
      patch_tag="${minor_tag%%:*}:${tag/"${version}"/"${patch}"}"
    else
      patch_tag="${minor_tag%%:*}:${patch}"
    fi
    if [[ ${patch_tag} != "${minor_tag}" ]]; then
      docker tag "${minor_tag}" "${patch_tag}"
      tags+=("${patch_tag}")
    fi
  fi

  printf '%s:' "${target}"
  printf ' %s' "${tags[@]}"
  echo
  [[ -z ${TAGS_FILE} ]] || printf '%s\n' "${tags[@]}" >> "${TAGS_FILE}"
done < <(jq -r '.target | to_entries[]
  | [.key, (.value.args.VERSION // ""), .value.tags[0], (.value.tags[1:] | join(" "))]
  | join("|")' <<< "${definition}")
