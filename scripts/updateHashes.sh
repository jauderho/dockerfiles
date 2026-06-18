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
# State shared between the check_* and update_ghcr_* phases.
#   *_TARGET_*       : the base-image version/tag the consumer Dockerfiles should track,
#                      always exported by check_* (whether or not a bump occurs).
#   *_BUILD_TRIGGERED: true only when check_* pushed a base bump this run, meaning a ghcr
#                      rebuild is on its way; used to decide whether it is safe to
#                      block-and-wait for a not-yet-published new tag.
# ---------------------------------------------------------------------------
ALPINE_TARGET_VER=""
ALPINE_BUILD_TRIGGERED=false
GOLANG_TARGET_TAG=""
GOLANG_BUILD_TRIGGERED=false

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
# Helper: portable in-place sed edit.
# GNU and BSD sed disagree on `-i` (BSD treats the next token as a backup suffix,
# so `sed -i -E ...` silently writes <file>-E backups and runs in basic-regex mode).
# Editing through a temp file and writing back with `cat` sidesteps the incompatibility,
# preserves the original file's permissions, and never leaves a backup behind.
# Always uses extended regex (-E).
# ---------------------------------------------------------------------------
sed_inplace() {
	local expr="$1" file="$2" tmp
	tmp=$(mktemp)
	if sed -E "$expr" "$file" > "$tmp"; then
		cat "$tmp" > "$file"
	fi
	rm -f "$tmp"
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

	# Export the version the consumer Dockerfiles should track. This is the ghcr tag
	# update_ghcr_alpine reconciles against, set regardless of whether a bump happens.
	ALPINE_TARGET_VER="$latest_ver"

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
		sed_inplace "s|^FROM alpine:.*|${new_from}|" "$dockerfile"
		git add "$dockerfile"

		# Only update the workflow version when the tag itself changes;
		# a digest-only update does not change the human-readable version string.
		if [[ "$current_ver" != "$latest_ver" ]]; then
			sed_inplace "s/BUILD_VERSION: \"${current_ver}\"/BUILD_VERSION: \"${latest_ver}\"/" "$workflow"
			git add "$workflow"
		fi

		git commit -S -s -m "Updated alpine to ${latest_ver} (${latest_digest})"
		git push
		echo "  Committed and pushed."

		# A ghcr rebuild of this version is now on its way; allow update_ghcr_alpine to
		# block-and-wait for a brand-new tag to publish.
		ALPINE_BUILD_TRIGGERED=true
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

	# Export the tag the consumer Dockerfiles should track. This is the ghcr tag
	# update_ghcr_golang reconciles against, set regardless of whether a bump happens.
	GOLANG_TARGET_TAG="$latest_full_tag"

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
		sed_inplace "s|^FROM golang:.*|${new_from}|" "$dockerfile"
		git add "$dockerfile"

		# Only update the workflow version when the tag itself changes;
		# a digest-only update does not change the human-readable version string.
		if [[ "$current_full_tag" != "$latest_full_tag" ]]; then
			sed_inplace "s/BUILD_VERSION: \"${current_full_tag}\"/BUILD_VERSION: \"${latest_full_tag}\"/" "$workflow"
			git add "$workflow"
		fi

		git commit -S -s -m "Updated golang to ${latest_full_tag} (${latest_digest})"
		git push
		echo "  Committed and pushed."

		# A ghcr rebuild of this tag is now on its way; allow update_ghcr_golang to
		# block-and-wait for a brand-new tag to publish.
		GOLANG_BUILD_TRIGGERED=true
	fi
	echo
}

# ---------------------------------------------------------------------------
# expected_platforms: echo (newline-separated) the architectures a base-image workflow
# builds, taken from its active `platforms:` line. Commented (#platforms:) lines are
# ignored, and all whitespace is stripped so each token is a bare platform string.
# ---------------------------------------------------------------------------
expected_platforms() {
	grep -E '^[[:space:]]*platforms:' "$1" | head -1 \
		| sed 's/.*platforms:[[:space:]]*//' \
		| tr ',' '\n' \
		| sed 's/[[:space:]]//g' \
		| grep -v '^$'
}

# ---------------------------------------------------------------------------
# manifest_complete: return 0 if the ghcr image resolves AND its manifest list advertises
# every platform the workflow builds. The trailing unknown/unknown attestation entry is
# ignored because it never matches a concrete platform string.
# ---------------------------------------------------------------------------
manifest_complete() {
	local image="$1" wf="$2" inspect p
	inspect=$(docker buildx imagetools inspect "$image" 2>/dev/null) || return 1
	while IFS= read -r p; do
		echo "$inspect" | grep -qE "Platform:[[:space:]]+${p}$" || return 1
	done < <(expected_platforms "$wf")
	return 0
}

# ---------------------------------------------------------------------------
# wait_for_ghcr_image: block until <image> resolves with all expected architectures.
# Used only when a base bump was pushed this run and the new ghcr tag is still building
# (a 10-15 min job). Polls every 30s and gives up after the timeout.
# ---------------------------------------------------------------------------
wait_for_ghcr_image() {
	local image="$1" wf="$2"
	local interval=30 timeout=1200 elapsed=0
	echo "  Waiting for ${image} to publish with all architectures ..."
	while (( elapsed < timeout )); do
		if manifest_complete "$image" "$wf"; then
			echo "  ${image} is available."
			return 0
		fi
		sleep "$interval"
		elapsed=$(( elapsed + interval ))
		echo "  ... still waiting (${elapsed}s / ${timeout}s)"
	done
	echo "  ERROR: timed out waiting for ${image} after ${timeout}s" >&2
	return 1
}

# ---------------------------------------------------------------------------
# _update_ghcr: reconcile every consumer Dockerfile that pins <image_base> to the digest
# ghcr currently publishes for <target>. Detection is a single comparison: if the resolved
# ghcr ref differs from what a Dockerfile pins (version or digest), the line is rewritten.
# A brand-new tag that has not finished building is waited for only when <build_triggered>
# is true; a same-tag rebuild that has not landed yet is simply reconciled on a later run.
# Commits + pushes one change set when anything actually differs.
# ---------------------------------------------------------------------------
_update_ghcr() {
	local image_base="$1" target="$2" build_triggered="$3" wf="$4"
	# Match only the image token so the #, FROM, and "AS build" context is preserved.
	local regex="${image_base//./\\.}:[^@[:space:]]+@sha256:[0-9a-f]+"

	echo "================================================================"
	echo "Reconciling ${image_base} references ..."
	echo "================================================================"

	if [[ -z "$target" ]]; then
		echo "  No target version resolved; skipping."
		echo
		return 0
	fi

	local g
	g=$(get_digest "${image_base}:${target}" 2>/dev/null || true)

	if [[ -z "$g" ]]; then
		if [[ "$build_triggered" == true ]]; then
			wait_for_ghcr_image "${image_base}:${target}" "$wf" || return 1
			g=$(get_digest "${image_base}:${target}")
		else
			echo "  ghcr has no ${image_base}:${target} yet; will reconcile on a later run."
			echo
			return 0
		fi
	elif ! manifest_complete "${image_base}:${target}" "$wf"; then
		echo "  ${image_base}:${target} is missing architectures (still publishing?); skipping."
		echo
		return 0
	fi

	local new_ref="${image_base}:${target}@${g}"
	echo "  Target ghcr image : ${new_ref}"

	# Match every Dockerfile flavour (Dockerfile, Dockerfile.alpine, Dockerfile.nightly,
	# templates/Dockerfile.*, ...) so all pins in the repo are reconciled.
	local files
	files=$(grep -rlE "$regex" --include='Dockerfile*' . 2>/dev/null || true)
	if [[ -z "$files" ]]; then
		echo "  No Dockerfiles reference ${image_base}."
		echo
		return 0
	fi

	local f
	if $DRYRUN; then
		while IFS= read -r f; do
			[[ -z "$f" ]] || grep -qF "$new_ref" "$f" || echo "  [dryrun] would update: $f"
		done <<< "$files"
		echo
		return 0
	fi

	while IFS= read -r f; do
		[[ -z "$f" ]] && continue
		sed_inplace "s|${regex}|${new_ref}|g" "$f"
		git add "$f"
	done <<< "$files"

	if git diff --cached --quiet; then
		echo "  All ${image_base} references already up to date."
	else
		git commit -S -s -m "Update ghcr ${image_base##*/} base to ${target} (${g})"
		git push
		echo "  Committed and pushed."
	fi
	echo
}

# ---------------------------------------------------------------------------
# update_ghcr_alpine / update_ghcr_golang: thin wrappers binding each base image to its
# target (from check_*), build-triggered flag, and workflow (for the arch list).
# ---------------------------------------------------------------------------
update_ghcr_alpine() {
	_update_ghcr "ghcr.io/jauderho/alpine" "$ALPINE_TARGET_VER" \
		"$ALPINE_BUILD_TRIGGERED" ".github/workflows/alpine.yml"
}

update_ghcr_golang() {
	_update_ghcr "ghcr.io/jauderho/golang" "$GOLANG_TARGET_TAG" \
		"$GOLANG_BUILD_TRIGGERED" ".github/workflows/golang.yml"
}

# ---------------------------------------------------------------------------
# setup git
# ---------------------------------------------------------------------------
#git config --local user.name "Jauder Ho Bot"
#git config --local user.email "jauderho-bot@users.noreply.github.com"
#git config --local pull.rebase false

# ---------------------------------------------------------------------------
# 1. Refresh the base-image templates against upstream (may trigger a ghcr rebuild).
# 2. Reconcile every consumer Dockerfile to the ghcr base image once it is available.
# ---------------------------------------------------------------------------
check_alpine
check_golang
update_ghcr_alpine
update_ghcr_golang

