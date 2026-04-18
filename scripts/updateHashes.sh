#!/bin/bash
#
# Script to check and start new image builds if the source repos have new releases.
# Also checks for new Golang and Alpine Linux base image versions in ./templates/.
#
# Usage: PAT=<github_pat> ./updateDockerImages.sh [--dryrun]
#
# Switches:
#   --dryrun   Show what would be updated without making any changes or git commits
#
# Environment variables:
#   PAT        GitHub Personal Access Token (reduces API rate limits for repo checks)
#
# Dependencies: curl, jq, docker (with buildx plugin), git
#
set -euo pipefail
IFS=$'\n\t'

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

DRYRUN=false
for arg in "$@"; do
	case "$arg" in
		--dryrun)
			DRYRUN=true
			echo "[dryrun] No files will be modified or committed."
			echo
			;;
		*)
			echo "Unknown argument: $arg" >&2
			exit 1
			;;
	esac
done

# $PAT variable needs to be passed into the script as an env variable
# PAT is only used to avoid API rate limits

# ---------------------------------------------------------------------------
# Helper: fetch the manifest digest for a fully-qualified image tag.
# Returns the top-level manifest list digest (first Digest: line), which is
# stable across architectures and is what belongs in a FROM pin.
# Exits with error if the image is not found or docker fails.
# ---------------------------------------------------------------------------
get_digest() {
	local tag="$1"
	local digest
	digest=$(docker buildx imagetools inspect "${tag}" 2>/dev/null \
		| grep "^Digest:" | head -1 | awk '{print $2}')
	if [[ -z "$digest" ]]; then
		echo "ERROR: could not retrieve digest for ${tag}" >&2
		return 1
	fi
	echo "$digest"
}

# ---------------------------------------------------------------------------
# check_alpine: update templates/alpine/Dockerfile and its GitHub workflow.
# Detects both version changes and same-version digest changes (e.g. security
# rebuilds), since alpine:3.23.4 may be republished with a new hash.
# ---------------------------------------------------------------------------
check_alpine() {
	local dockerfile="templates/alpine/Dockerfile"
	local workflow=".github/workflows/alpine.yml"

	echo "================================================================"
	echo "Checking Alpine Linux base image ..."
	echo "================================================================"

	# --- current state from Dockerfile ---
	# Expected line: FROM alpine:3.23.4@sha256:<digest>
	local from_line
	from_line=$(grep "^FROM alpine:" "$dockerfile")

	local current_ver current_digest
	current_ver=$(echo "$from_line"    | sed 's/FROM alpine:\([^@]*\).*/\1/')
	current_digest=$(echo "$from_line" | sed 's/.*@//')

	# --- latest version from Docker Hub ---
	# Only match fully-qualified X.Y.Z tags to avoid catching major/minor-only
	# tags (e.g. "3.23") which would incorrectly win the sort.
	local latest_ver
	latest_ver=$(curl -fsSL \
		'https://hub.docker.com/v2/repositories/library/alpine/tags?page_size=100' \
		| jq -r '.results[].name' \
		| grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
		| sort -V \
		| tail -n1)

	if [[ -z "$latest_ver" ]]; then
		echo "  ERROR: could not determine latest Alpine version." >&2
		return 1
	fi

	# Always resolve the canonical digest for the latest tag so we catch
	# same-version rebuilds (security patches, etc.) where only the hash differs.
	local latest_digest
	latest_digest=$(get_digest "alpine:${latest_ver}")

	echo "  Dockerfile version : ${current_ver}"
	echo "  Dockerfile digest  : ${current_digest}"
	echo "  Latest version     : ${latest_ver}"
	echo "  Latest digest      : ${latest_digest}"

	if [[ "$current_ver" == "$latest_ver" && "$current_digest" == "$latest_digest" ]]; then
		echo "  No update needed."
		echo
		return 0
	fi

	[[ "$current_ver"    != "$latest_ver"    ]] && echo "  Version changed : ${current_ver} → ${latest_ver}"
	[[ "$current_digest" != "$latest_digest" ]] && echo "  Digest changed  : ${current_digest} → ${latest_digest}"

	local new_from="FROM alpine:${latest_ver}@${latest_digest}"

	if $DRYRUN; then
		echo "  [dryrun] Would update ${dockerfile}: ${new_from}"
		[[ "$current_ver" != "$latest_ver" ]] && \
			echo "  [dryrun] Would update ${workflow}: BUILD_VERSION \"${latest_ver}\""
	else
		sed -i -e "s|^FROM alpine:.*|${new_from}|" "$dockerfile"
		git add "$dockerfile"

		# Only update the workflow version when the tag itself changes;
		# a digest-only update does not change the human-readable version string.
		if [[ "$current_ver" != "$latest_ver" ]]; then
			sed -i -e "s/BUILD_VERSION: \"${current_ver}\"/BUILD_VERSION: \"${latest_ver}\"/" "$workflow"
			git add "$workflow"
		fi

		git commit -S -s -m "Updated alpine to ${latest_ver} (${latest_digest})"
		git push
		echo "  Committed and pushed."
	fi
	echo
}

# ---------------------------------------------------------------------------
# check_golang: update templates/golang/Dockerfile and its GitHub workflow.
# Compares the full X.Y.Z-alpineA.B tag AND its digest against Docker Hub,
# detecting a Go version bump, an Alpine variant bump, and same-tag rebuilds
# (e.g. golang:1.26.2-alpine3.23 republished with a new hash) as distinct
# reasons to update.
# ---------------------------------------------------------------------------
check_golang() {
	local dockerfile="templates/golang/Dockerfile"
	local workflow=".github/workflows/golang.yml"

	echo "================================================================"
	echo "Checking Golang base image ..."
	echo "================================================================"

	# --- current state from Dockerfile ---
	# Expected line: FROM golang:1.26.2-alpine3.23@sha256:<digest>
	local from_line
	from_line=$(grep "^FROM golang:" "$dockerfile")

	local current_full_tag current_digest
	current_full_tag=$(echo "$from_line" | sed 's/FROM golang:\([^@]*\).*/\1/')
	current_digest=$(echo "$from_line"   | sed 's/.*@//')

	# --- latest full tag from Docker Hub ---
	# Match only X.Y.Z-alpineA.B tags; sort Go version as primary key and
	# Alpine version as secondary so both bumps are handled correctly.
	local latest_full_tag
	latest_full_tag=$(curl -fsSL \
		'https://hub.docker.com/v2/repositories/library/golang/tags?page_size=100' \
		| jq -r '.results[].name' \
		| grep -E '^[0-9]+\.[0-9]+\.[0-9]+-alpine[0-9]+\.[0-9]+$' \
		| sort -t- -k1,1V -k2,2V \
		| tail -n1)

	if [[ -z "$latest_full_tag" ]]; then
		echo "  ERROR: could not determine latest Golang tag." >&2
		return 1
	fi

	# Always resolve the canonical digest for the latest tag so we catch
	# same-tag rebuilds where only the hash differs.
	local latest_digest
	latest_digest=$(get_digest "golang:${latest_full_tag}")

	echo "  Dockerfile tag     : ${current_full_tag}"
	echo "  Dockerfile digest  : ${current_digest}"
	echo "  Latest tag         : ${latest_full_tag}"
	echo "  Latest digest      : ${latest_digest}"

	if [[ "$current_full_tag" == "$latest_full_tag" && "$current_digest" == "$latest_digest" ]]; then
		echo "  No update needed."
		echo
		return 0
	fi

	[[ "$current_full_tag" != "$latest_full_tag" ]] && echo "  Tag changed    : ${current_full_tag} → ${latest_full_tag}"
	[[ "$current_digest"   != "$latest_digest"   ]] && echo "  Digest changed : ${current_digest} → ${latest_digest}"

	local new_from="FROM golang:${latest_full_tag}@${latest_digest}"

	if $DRYRUN; then
		echo "  [dryrun] Would update ${dockerfile}: ${new_from}"
		[[ "$current_full_tag" != "$latest_full_tag" ]] && \
			echo "  [dryrun] Would update ${workflow}: BUILD_VERSION \"${latest_full_tag}\""
	else
		sed -i -e "s|^FROM golang:.*|${new_from}|" "$dockerfile"
		git add "$dockerfile"

		# Only update the workflow version when the tag itself changes;
		# a digest-only update does not change the human-readable version string.
		if [[ "$current_full_tag" != "$latest_full_tag" ]]; then
			sed -i -e "s/BUILD_VERSION: \"${current_full_tag}\"/BUILD_VERSION: \"${latest_full_tag}\"/" "$workflow"
			git add "$workflow"
		fi

		git commit -S -s -m "Updated golang to ${latest_full_tag} (${latest_digest})"
		git push
		echo "  Committed and pushed."
	fi
	echo
}

# ---------------------------------------------------------------------------
# setup git
# ---------------------------------------------------------------------------
#git config --local user.name "Jauder Ho Bot"
#git config --local user.email "jauderho-bot@users.noreply.github.com"
#git config --local pull.rebase false

# ---------------------------------------------------------------------------
# Check base images first
# ---------------------------------------------------------------------------
check_alpine
check_golang

