#!/bin/bash
#
# Script to check and start new image builds if the source repos have new releases
#
# Usage: PAT=<actor>/<token> scripts/updateDockerImages.sh [options]
#
#   --python-deps  Also refresh uv.lock for every Python image (PYTHON_APPS),
#                  even when the app itself has no new release, so that
#                  dependency-only updates are picked up. The daily run uses it.
#                  Without it, a Python image is only refreshed when its app
#                  has a new release.
#   -n, --dryrun   Resolve versions and report every change the run would make
#                  (pins, uv.lock refreshes, commit messages) without editing,
#                  committing or pushing anything. Network lookups still run,
#                  so PAT is still required.
#   -v, --verbose  Also log each step: lookups and their results, the Alpine
#                  branch, the resolved version table, discovered pin files,
#                  uv.lock results and git operations. Logs go to stderr.
#   -h, --help     Show this help and exit.
#
# Environment:
#   PAT            "<actor>/<token>"; the token is used for GitHub API calls.
#
set -euo pipefail
IFS=$'\n\t'

PYTHON_DEPS=0
DRYRUN=0
VERBOSE=0
while (( $# > 0 )); do
	case "$1" in
		--python-deps) PYTHON_DEPS=1 ;;
		-n | --dryrun) DRYRUN=1 ;;
		-v | --verbose) VERBOSE=1 ;;
		-h | --help) sed -n '2,/^set -euo/{/^#/s/^# \{0,1\}//p;}' "$0"; exit 0 ;;
		*) echo "ERROR: unknown option '$1' (see --help)" >&2; exit 2 ;;
	esac
	shift
done

# vlog MSG...: step-level progress, only with --verbose (stderr, so it never
# mixes into captured function output).
vlog() {
	if (( VERBOSE )); then
		printf '[verbose] %s\n' "$*" >&2
	fi
}

# dry MSG...: report a change that --dryrun skipped.
DRY_CHANGES=0
dry() {
	printf '[dryrun] %s\n' "$*"
	DRY_CHANGES=$((DRY_CHANGES + 1))
}

vlog "options: python-deps=${PYTHON_DEPS} dryrun=${DRYRUN}"

# $PAT variable needs to be passed into the script as an env variable
# PAT is only used to avoid API rate limits

REPO=( 
	"AdguardTeam/adguardhome" \
	"filosottile/age" \
	"nakabonne/ali" \
	"ansible/ansible" \
	"OWASP/amass" \
	"getanteon/anteon" \
	"jauderho/bl3auto" \
	"psf/black" \
	"jauderho/cf-warp" \
	"cloudflare/cloudflared" \
	"coredns/coredns" \
	"alpine/dhcp-helper" \
	"StackExchange/dnscontrol" \
	"dkimpy/dkimpy" \
	"DNSCrypt/dnscrypt-proxy" \
	"projectdiscovery/dnsx" \
	"cloudskiff/driftctl" \
	"moncho/dry" \
	"multiprocessio/dsq" \
	"wader/fq" \
	"freenginx/freenginx" \
	"osrg/gobgp" \
	"kffl/gocannon" \
	"buger/goreplay" \
	"tomnomnom/gron" \
	"juanfont/headscale" \
	"nojima/httpie-go" \
	"projectdiscovery/httpx" \
	"go-acme/lego" \
	"0xInfection/logmepwn" \
	"xorux/lpar2rrd" \
	"johnkerl/miller" \
	"slackhq/nebula" \
	"gravitl/netmaker" \
	"nginx/nginx" \
	"binwiederhier/ntfy" \
	"cube2222/octosql" \
	"aramperes/onetun" \
	"opentofu/opentofu" \
	"prettier/prettier" \
	"cilium/pwru" \
	"rclone/rclone" \
	"astral-sh/ruff" \
	"alpine/sftpd" \
	"authzed/spicedb" \
	"jtesta/ssh-audit" \
	"nabla-c0d3/sslyze" \
	"xorux/stor2rrd" \
	"projectdiscovery/subfinder" \
	"tailscale/tailscale" \
	"hashicorp/terraform" \
	"testssl/testssl.sh" \
	"alpine/tftpd" \
	"shopify/toxiproxy" \
	"trufflesecurity/trufflehog" \
	"alpine/unbound" \
	"tsenart/vegeta" \
	"saulpw/visidata" \
	"nicholas-fedor/watchtower" \
	"likexian/whois" \
	"yggdrasil-network/yggdrasil-go" \
	"ytdl-org/youtube-dl" \
	"yt-dlp/yt-dlp" \
	"yt-dlp/yt-dlp-nightly-builds" \
	"getzola/zola" \
)

# ---------------------------------------------------------------------------
# Upstream version resolution
#
# Versions are resolved up front into VERSIONS_FILE ("<prog>\t<version>" lines),
# consumed read-only by the update loops below. Standard GitHub repos are fetched
# in a SINGLE GraphQL query (one request instead of one per repo); sources that
# are not a GitHub "latest release" are handled as explicit edge cases. All
# sources are resolved in parallel, before any file is touched.
#
# To add an edge case:
#   - non-GitHub source  -> list it in is_special() and emit it in resolve_special()
#   - odd tag formatting -> massage it in normalize_version()
# Everything else flows through the GraphQL batch unchanged.
# ---------------------------------------------------------------------------

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT
VERSIONS_FILE="${WORKDIR}/versions"

# UV_EMPTY_CONFIG is an empty uv config on purpose. A user-level
# ~/.config/uv/uv.toml applies to local lock runs but not to CI, and an
# "exclude-newer" setting there silently resolves to downgrades.
UV_EMPTY_CONFIG="${WORKDIR}/empty-uv.toml"
: > "$UV_EMPTY_CONFIG"

# PAT is passed as "<actor>/<token>"; the GraphQL API needs the bare token.
: "${PAT:?PAT must be set as <actor>/<token>}"
GH_TOKEN="${PAT#*/}"
if [[ -z "$GH_TOKEN" || "$GH_TOKEN" == "$PAT" ]]; then
	echo "ERROR: could not extract a token from PAT (expected '<actor>/<token>')." >&2
	exit 1
fi

# is_special: programs whose version does NOT come from GitHub latestRelease.
# These are skipped by the GraphQL batch and resolved by resolve_special().
is_special() {
	case "$1" in
		ansible | dkimpy | lpar2rrd | stor2rrd) return 0 ;;
		dhcp-helper | sftpd | tftpd | unbound) return 0 ;;
		freenginx) return 0 ;;
		*) return 1 ;;
	esac
}

# is_valid_version: accept only plausible version strings — safe characters only
# and at least one digit. This rejects garbage (empty, "null", HTML/error bodies,
# sentinels like "git"/"nightly") AND guarantees the value is safe to drop into the
# sed substitution below: no '/', '&', '\', '"', or whitespace can ever slip through.
is_valid_version() {
	[[ "$1" =~ ^[A-Za-z0-9._+~-]+$ && "$1" =~ [0-9] ]]
}

# version_lt A B: true if version A sorts strictly before version B. sort -V
# orders "1.2-r10" after "1.2-r3", and handles "_p1" and date versions.
version_lt() {
	[[ "$1" != "$2" && "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1)" == "$1" ]]
}

# max_version: read versions on stdin, print the highest.
max_version() {
	sort -V | tail -n1
}

# normalize_version: massage a raw upstream version into the string the workflow
# file and download URLs expect. Applied to every program, special or not.
normalize_version() {
	local prog="$1" ver="$2"
	case "$prog" in
		# nginx tags look like "release-1.31.0"; strip the prefix so the
		# version matches what the workflow file and download URL expect.
		nginx) ver="${ver#release-}" ;;
		# dhcp-helper's workflow pins a "v"-prefixed Alpine version ("v1.2-r3").
		dhcp-helper) [[ -n "$ver" ]] && ver="v${ver}" ;;
	esac
	printf '%s' "$ver"
}

# fetch: GET a URL to stdout. Every request is time-bounded and retries
# transient failures (DNS, resets, 429/5xx). HTTP errors make the call fail
# (the body is still printed, for diagnostics), so callers that check the
# status never parse an error page as a version.
fetch() {
	vlog "GET ${*: -1}"
	curl -sSL --fail-with-body --connect-timeout 10 --max-time 60 \
		--retry 3 --retry-delay 2 --retry-all-errors "$@"
}

# gh_rest: GET a GitHub REST API path with the PAT token (avoids rate limits).
gh_rest() {
	fetch -H "Authorization: bearer ${GH_TOKEN}" \
		-H "Accept: application/vnd.github+json" \
		"https://api.github.com/$1"
}

# resolve_pypi: latest version of a PyPI package.
resolve_pypi() {
	local json
	json=$(fetch "https://pypi.org/pypi/$1/json") || return 0
	jq -r '.info.version // empty' <<<"$json" 2>/dev/null || true
}

# alpine_pkg: map an image built from an Alpine package to "<repo>/<package>".
# The image name is not always the package name (sftpd ships openssh).
alpine_pkg() {
	case "$1" in
		dhcp-helper) echo "community/dhcp-helper" ;;
		sftpd) echo "main/openssh" ;;
		tftpd) echo "main/tftp-hpa" ;;
		unbound) echo "main/unbound" ;;
	esac
}

# apkindex BRANCH REPO: print the path of the extracted APKINDEX for one Alpine
# repo. Each index is downloaded once per run, however many images use it.
apkindex() {
	local f="${WORKDIR}/APKINDEX.$1.$2"
	if [[ ! -s "$f" ]]; then
		if ! fetch "https://dl-cdn.alpinelinux.org/alpine/$1/$2/x86_64/APKINDEX.tar.gz" \
			| tar -xzOf - APKINDEX > "${f}.tmp"; then
			rm -f "${f}.tmp"
			return 1
		fi
		mv "${f}.tmp" "$f"
	fi
	printf '%s' "$f"
}

# resolve_alpine: print the version of an Alpine package from the official
# APKINDEX. The Alpine branch (e.g. v3.24) comes from the FROM line of
# templates/alpine/Dockerfile (the source of ghcr.io/jauderho/alpine), so the
# check follows Alpine release bumps. Prints nothing on any failure.
resolve_alpine() {
	local prog="$1" spec branch index
	spec=$(alpine_pkg "$prog")
	[[ -n "$spec" ]] || return 0
	branch=$(sed -nE 's|^FROM[[:space:]]+alpine:([0-9]+)\.([0-9]+).*|v\1.\2|p' templates/alpine/Dockerfile | head -n1)
	[[ -n "$branch" ]] || return 0
	vlog "alpine: $prog -> ${spec} on ${branch}"
	index=$(apkindex "$branch" "${spec%%/*}") || return 0
	awk -v pkg="${spec#*/}" '/^P:/ { p = substr($0, 3) } /^V:/ && p == pkg && v == "" { v = substr($0, 3) } END { if (v != "") print v }' "$index"
}

# resolve_xormon: XoruX products (lpar2rrd, stor2rrd) have no GitHub releases.
# Scrape the "<prog>-X.YY.tar" link from the download page; keep the highest.
resolve_xormon() {
	local prog="$1" page
	page=$(fetch "https://${prog}.com/download.php") || return 0
	grep -oE "${prog}-[0-9]+(\.[0-9]+)+\.tar" <<<"$page" \
		| sed -E "s/^${prog}-//; s/\.tar$//" \
		| max_version || true
}

# resolve_openssl: highest final OpenSSL release. Uses published, non-draft,
# non-prerelease GitHub releases (not bare tags): the Dockerfiles download the
# tarball from releases/download, which exists only once the release is out.
resolve_openssl() {
	local json
	json=$(gh_rest "repos/openssl/openssl/releases?per_page=100") || return 0
	jq -r '.[] | select(.draft == false and .prerelease == false) | .tag_name' <<<"$json" 2>/dev/null \
		| sed -nE 's/^openssl-([0-9]+\.[0-9]+\.[0-9]+)$/\1/p' \
		| max_version || true
}

# resolve_docker_cli: highest final Docker CLI release from moby/moby. That repo
# also publishes "client/", "api/" and old-scheme "v25.0.x" maintenance
# releases; only final "docker-vX.Y.Z" releases count. Workflows download the
# static CLI from download.docker.com, which can lag the GitHub release, so a
# version is only accepted once its tarball is published there.
resolve_docker_cli() {
	local json ver
	json=$(gh_rest "repos/moby/moby/releases?per_page=100") || return 0
	ver=$(jq -r '.[] | select(.draft == false and .prerelease == false) | .tag_name' <<<"$json" 2>/dev/null \
		| sed -nE 's/^docker-v([0-9]+\.[0-9]+\.[0-9]+)$/\1/p' \
		| max_version || true)
	[[ -n "$ver" ]] || return 0
	fetch -o /dev/null --head "https://download.docker.com/linux/static/stable/x86_64/docker-${ver}.tgz" \
		|| return 0
	printf '%s\n' "$ver"
}

# resolve_freenginx: highest "release-X.Y.Z" tag of freenginx/nginx. Several
# trains are tagged in parallel (e.g. 1.30.x stable, 1.31.x mainline); the
# newest train always holds the highest version, so the max across all tags is
# the latest release of the latest train. git ls-remote lists every tag in one
# request, with no API pagination. The low-speed limit bounds a stalled fetch.
resolve_freenginx() {
	local refs
	refs=$(GIT_HTTP_LOW_SPEED_LIMIT=1000 GIT_HTTP_LOW_SPEED_TIME=30 \
		git ls-remote --tags --refs https://github.com/freenginx/nginx.git 'release-*') || return 0
	sed -nE 's|.*refs/tags/release-([0-9]+\.[0-9]+\.[0-9]+)$|\1|p' <<<"$refs" \
		| max_version || true
}

# resolve_special: emit "<prog>\t<version>" for a non-GitHub-release source.
resolve_special() {
	local repo="$1" prog="$2" ver=""
	case "$repo" in
		"ansible/ansible" | "dkimpy/dkimpy") ver=$(resolve_pypi "$prog") ;;
		alpine/*) ver=$(resolve_alpine "$prog") ;;
		xorux/*) ver=$(resolve_xormon "$prog") ;;
		"freenginx/freenginx") ver=$(resolve_freenginx) ;;
	esac
	printf '%s\t%s\n' "$prog" "$(normalize_version "$prog" "$ver")"
}

# resolve_github_batch: fetch latestRelease.tagName for every non-special repo in
# a single aliased GraphQL query, then emit "<prog>\t<version>" for each.
resolve_github_batch() {
	local query="query {" i=0 repo owner name prog
	local idx_prog=()
	for repo in "${REPO[@]}"; do
		prog="${repo##*/}"
		is_special "$prog" && continue
		owner="${repo%%/*}"
		name="${repo##*/}"
		query+=" r${i}: repository(owner: \"${owner}\", name: \"${name}\") { latestRelease { tagName } }"
		idx_prog[i]="$prog"
		i=$((i + 1))
	done
	query+=" }"
	vlog "github: one GraphQL query for ${i} repos"

	local resp
	if ! resp=$(fetch -X POST \
		-H "Authorization: bearer ${GH_TOKEN}" \
		-H "Content-Type: application/json" \
		-d "$(jq -n --arg q "$query" '{query: $q}')" \
		"https://api.github.com/graphql"); then
		echo "ERROR: GraphQL request to GitHub failed:" >&2
		jq -r '(.errors[]?.message), (.message // empty)' <<<"$resp" >&2 2>/dev/null \
			|| printf '  %s\n' "${resp:0:200}" >&2
		return 1
	fi

	# A response with no '.data' object is a systemic failure (bad auth, malformed
	# query). Surface it and bail, rather than silently treating every repo as
	# "no release" — which would otherwise let the whole run pass having done nothing.
	if ! jq -e '.data != null' <<<"$resp" >/dev/null 2>&1; then
		echo "ERROR: GraphQL returned no data; aborting batch:" >&2
		jq -r '(.errors[]?.message), (.message // empty)' <<<"$resp" >&2 2>/dev/null \
			|| printf '  %s\n' "${resp:0:200}" >&2
		return 1
	fi

	# Per-repo errors (e.g. a renamed/moved repo) are non-fatal: that alias just
	# resolves empty and is skipped later. Warn so it is visible in the logs.
	if jq -e '.errors != null' <<<"$resp" >/dev/null 2>&1; then
		echo "WARNING: GraphQL reported partial errors (affected repos will be skipped):" >&2
		jq -r '.errors[]?.message' <<<"$resp" >&2 2>/dev/null || true
	fi

	# One jq pass emits "<index>\t<tag>" for every alias ("r12" -> "12"). A missing
	# repo or release yields an empty tag, which is skipped later.
	local j tag
	jq -r '.data | to_entries[] | "\(.key[1:])\t\(.value.latestRelease.tagName // "")"' <<<"$resp" \
		| while IFS=$'\t' read -r j tag; do
			prog="${idx_prog[$j]}"
			printf '%s\t%s\n' "$prog" "$(normalize_version "$prog" "$tag")"
		done
}

# DEP_PINS: dependency pins, as "<VAR>:<resolver>:<label>". These are not an
# image's BUILD_VERSION: each is resolved once and applied to EVERY workflow
# that sets VAR in its env block, found at run time (no per-file list to keep).
DEP_PINS=(
	"OPENSSL_VERSION:resolve_openssl:OpenSSL"
	"DOCKER_CLI_VERSION:resolve_docker_cli:Docker CLI"
)

# resolve_all_versions: run the GitHub batch, every special source, and the
# dependency-pin lookups in parallel, each into its own file, then merge. Alpine images
# run in one job, in order, so they share each downloaded APKINDEX.
resolve_all_versions() {
	local repo prog gh_pid pin rest alpine=()
	resolve_github_batch > "${WORKDIR}/out.github" &
	gh_pid=$!
	for repo in "${REPO[@]}"; do
		prog="${repo##*/}"
		is_special "$prog" || continue
		case "$repo" in
			alpine/*) alpine+=("$repo") ;;
			*) resolve_special "$repo" "$prog" > "${WORKDIR}/out.${prog}" & ;;
		esac
	done
	(
		for repo in ${alpine[@]+"${alpine[@]}"}; do
			resolve_special "$repo" "${repo##*/}"
		done
	) > "${WORKDIR}/out.alpine" &
	for pin in "${DEP_PINS[@]}"; do
		rest="${pin#*:}"
		"${rest%%:*}" > "${WORKDIR}/dep.${pin%%:*}" &
	done

	# The GitHub batch is the only fatal source; wait for it, then the rest.
	wait "$gh_pid" || { wait; return 1; }
	wait
	cat "${WORKDIR}"/out.*
}

vlog "resolving upstream versions in parallel (workdir ${WORKDIR})"
RESOLVE_START=$SECONDS
if ! resolve_all_versions > "$VERSIONS_FILE"; then
	echo "ERROR: upstream version resolution failed; aborting without changes." >&2
	exit 1
fi
vlog "resolved $(wc -l < "$VERSIONS_FILE" | tr -d ' ') versions in $((SECONDS - RESOLVE_START))s"
if (( VERBOSE )); then
	sort "$VERSIONS_FILE" | while IFS=$'\t' read -r p v; do
		vlog "  ${p} = ${v:-<unresolved>}"
	done
	for pin in "${DEP_PINS[@]}"; do
		vlog "  ${pin%%:*} = $(cat "${WORKDIR}/dep.${pin%%:*}")"
	done
fi

# A run where not a single repo resolved to a version is a systemic failure;
# fail loudly rather than silently updating nothing.
if ! awk -F'\t' 'NF >= 2 && $2 != "" { ok = 1 } END { exit ok ? 0 : 1 }' "$VERSIONS_FILE"; then
	echo "ERROR: no versions resolved for any repo; aborting without changes." >&2
	exit 1
fi

# ---------------------------------------------------------------------------
# Updating
#
# A failure on one program never stops the run: it is logged, counted, and the
# script exits non-zero at the end so CI still shows it.
# ---------------------------------------------------------------------------

FAILURES=0

# read_pin WORKFLOW VAR: the quoted value on the first "VAR: "..."" line, or
# empty. Anchored + -m1 so a stray "VAR" elsewhere can never match.
read_pin() {
	grep -m1 -E "^[[:space:]]*$2:[[:space:]]*\"" "$1" 2>/dev/null | cut -d '"' -f 2 || true
}

# push_changes: push local commits. If the push is rejected (someone pushed
# while this run was working), rebase onto upstream once and retry.
push_changes() {
	vlog "git push"
	git push --quiet && return 0
	vlog "push rejected; rebasing onto upstream and retrying"
	if git pull --rebase --quiet && git push --quiet; then
		return 0
	fi
	git rebase --abort >/dev/null 2>&1 || true
	return 1
}

# restore_paths PATH...: undo uncommitted edits (staged or not) to PATHs.
restore_paths() {
	local f
	for f in "$@"; do rm -f "${f}.bak"; done
	git reset --quiet -- "$@" 2>/dev/null || true
	git checkout --quiet -- "$@" 2>/dev/null || true
}

# set_pin WORKFLOW VAR VERSION: set VAR's quoted value in WORKFLOW; verify it.
set_pin() {
	local wf="$1" var="$2" ver="$3"
	# -i.bak + rm: the one in-place form that works with GNU and BSD sed.
	sed -i.bak -e "/^[[:space:]]*${var}:/ s/\"[^\"]*\"/\"${ver}\"/" "$wf" \
		&& rm -f "${wf}.bak" \
		&& [[ "$(read_pin "$wf" "$var")" == "$ver" ]]
}

# commit_paths MESSAGE PATH...: commit PATHs as ONE commit, then push. If the
# commit fails, PATHs are restored so a half-done change can never leak into
# the next commit. A failed push keeps the commit; the final push retries it.
commit_paths() {
	local msg="$1"
	shift
	vlog "git commit '${msg}': $*"
	if git add -- "$@" && git commit -S -s --quiet -m "$msg"; then
		push_changes || echo "WARNING: push failed; the final push will retry it" >&2
		return 0
	fi
	echo "ERROR: could not commit $*; restoring" >&2
	restore_paths "$@"
	return 1
}

# bump_pin WORKFLOW VAR VERSION MESSAGE: set VAR in WORKFLOW and commit it.
bump_pin() {
	local wf="$1" var="$2" ver="$3" msg="$4"
	if (( DRYRUN )); then
		dry "would set ${var} to \"${ver}\" in ${wf} and commit '${msg}'"
		return 0
	fi
	if ! set_pin "$wf" "$var" "$ver"; then
		echo "ERROR: could not update ${var} in ${wf}; restoring the file" >&2
		restore_paths "$wf"
		return 1
	fi
	commit_paths "$msg" "$wf"
}

# ---------------------------------------------------------------------------
# Python images
#
# Each image in PYTHON_APPS installs its app and dependencies from <app>/uv.lock
# ("uv sync --frozen"). The lock is therefore what the image really contains,
# and BUILD_VERSION is only its tag. update_python_app refreshes the lock and
# sets BUILD_VERSION from it in the SAME commit, so:
#   - an app release lands as one commit (and one image build) whose tag
#     matches what the image installs;
#   - a dependency-only change lands as a "requirements" commit.
# The hourly run refreshes an app only when its upstream has a new release;
# --python-deps (the daily run) refreshes all of them.
# ---------------------------------------------------------------------------

PYTHON_APPS=( "ansible" "catprinter" "dkimpy" "docker-autocompose" "ruff" "sslyze" "visidata" )

# in_list ITEM LIST...: true if ITEM is one of LIST.
in_list() {
	local item="$1" x
	shift
	for x in "$@"; do
		[[ "$x" == "$item" ]] && return 0
	done
	return 1
}

is_python_app() {
	in_list "$1" "${PYTHON_APPS[@]}"
}

# locked_version DIR PKG: the version of package PKG in DIR/uv.lock, or empty.
locked_version() {
	awk -v pkg="$2" '
		/^\[\[package\]\]/ { n = "" }
		/^name = /    { n = $3; gsub(/"/, "", n) }
		/^version = / && n == pkg { v = $3; gsub(/"/, "", v); print v; exit }
	' "$1/uv.lock" 2>/dev/null || true
}

# update_python_app APP: refresh APP's uv.lock, set BUILD_VERSION to the app
# version now in the lock, and commit both as one commit. No change, no commit.
# uv runs on a copy in WORKDIR (so --dryrun writes nothing and no build
# artifacts land in the repo); the new lock is copied back only when applied.
update_python_app() {
	local app="$1" wf=".github/workflows/$1.yml" tmp="${WORKDIR}/py/$1"
	local cur locked new="" msg lock_changed=0

	echo "Refreshing python dependencies for $app ..."
	if ! command -v uv >/dev/null 2>&1; then
		echo "    ERROR: uv is not installed" >&2
		return 1
	fi
	mkdir -p "$tmp"
	cp "$app/pyproject.toml" "$app/uv.lock" "$tmp/"
	vlog "uv lock -U for $app in $tmp"
	if ! (cd "$tmp" && UV_CONFIG_FILE="$UV_EMPTY_CONFIG" uv lock -U --quiet); then
		echo "    ERROR: uv lock failed for $app" >&2
		return 1
	fi
	cmp -s "$tmp/uv.lock" "$app/uv.lock" || lock_changed=1

	# Only a managed release pin follows the lock; "git" pins stay as they are.
	# If upstream released but PyPI does not serve it yet, the lock (and so the
	# tag) keeps the old version and a later run picks the release up.
	cur=$(read_pin "$wf" BUILD_VERSION)
	locked=$(locked_version "$tmp" "$app")
	vlog "$app: pinned ${cur:-<none>}, locked ${locked:-<none>}, lock changed: ${lock_changed}"
	if is_valid_version "$cur" && is_valid_version "$locked"; then
		# Keep the pin's style: visidata pins "v3.5" for lock version "3.5".
		if [[ "$cur" == v* && "$locked" != v* ]]; then
			locked="v${locked}"
		fi
		if [[ "$cur" != "$locked" ]]; then
			if version_lt "$locked" "$cur"; then
				echo "    Not changing BUILD_VERSION: locked $locked is older than pinned $cur" >&2
			else
				new="$locked"
			fi
		fi
	fi

	if (( ! lock_changed )) && [[ -z "$new" ]]; then
		echo "No update needed ..."
		return 0
	fi
	if [[ -n "$new" ]]; then
		msg="Updated ${app} to ${new}"
	else
		msg="Update requirements for ${app} ..."
	fi

	if (( DRYRUN )); then
		dry "would commit '${msg}'${new:+ (BUILD_VERSION ${cur} -> ${new})}$( (( lock_changed )) && printf ' with a refreshed %s' "$app/uv.lock")"
		return 0
	fi

	if [[ -n "$new" ]]; then
		echo "Updating to ${new} ..."
	else
		echo "Updating requirements ..."
	fi
	cp "$tmp/uv.lock" "$app/uv.lock"
	if [[ -n "$new" ]] && ! set_pin "$wf" BUILD_VERSION "$new"; then
		echo "    ERROR: could not update BUILD_VERSION in $wf; restoring its files" >&2
		restore_paths "$wf" "$app/uv.lock"
		return 1
	fi
	commit_paths "$msg" "$wf" "$app/uv.lock"
}

# check_pin LABEL CURRENT LATEST: print the comparison and decide. Returns 0 only
# when LATEST is a valid version newer than CURRENT; it never downgrades.
check_pin() {
	local label="$1" cur="$2" new="$3"
	echo
	echo "    Workflow ${label} is $cur"
	echo "    Upstream ${label} is $new"
	echo

	# Skip workflows intentionally pinned to a non-release value (e.g. "git",
	# "nightly"): the bumper only manages real, release-versioned pins.
	if ! is_valid_version "$cur"; then
		echo "    Skipping: pinned value '$cur' is not a managed release version"
		return 1
	fi
	# Skip if the upstream version failed to resolve or looks malformed. This is the
	# gate that keeps an unvalidated string from ever reaching the sed substitution.
	if ! is_valid_version "$new"; then
		echo "    Skipping: resolved version '$new' is empty or not a valid version" >&2
		return 1
	fi
	if [[ "$cur" == "$new" ]]; then
		echo "No update needed ..."
		return 1
	fi
	# Upstream "latest" can point at an older line (e.g. a backport release).
	if version_lt "$new" "$cur"; then
		echo "    Skipping: upstream $new is older than pinned $cur (no downgrade)" >&2
		return 1
	fi
	return 0
}

# setup git
#git config --local user.name "Gromit Bot"
#git config --local user.email "gromit-bot@users.noreply.github.com"
#git config --local pull.rebase false

# Python apps already refreshed by the BUILD_VERSION pass (skipped below).
PYTHON_DONE=()

# BUILD_VERSION pass: bump each image whose upstream has a newer release.
for i in "${REPO[@]}"
do
	prog="${i##*/}"
	wf=".github/workflows/${prog}.yml"

	echo "Checking repo ... $prog"

	if [[ ! -f "$wf" ]]; then
		echo "    ERROR: workflow $wf not found" >&2
		FAILURES=$((FAILURES + 1))
		echo; echo; echo
		continue
	fi

	dver=$(read_pin "$wf" BUILD_VERSION)
	# Version resolved up front by resolve_all_versions (see VERSIONS_FILE above).
	rver=$(awk -F'\t' -v p="$prog" '$1 == p { print $2; exit }' "$VERSIONS_FILE")

	if check_pin "BUILD_VERSION" "$dver" "$rver"; then
		if is_python_app "$prog"; then
			# The lock, not the upstream API, decides the new version: one
			# commit with the refreshed lock and the matching BUILD_VERSION.
			PYTHON_DONE+=( "$prog" )
			update_python_app "$prog" || FAILURES=$((FAILURES + 1))
		else
			echo "Updating to ${rver} ..."
			bump_pin "$wf" BUILD_VERSION "$rver" "Updated ${prog} to ${rver}" \
				|| FAILURES=$((FAILURES + 1))
		fi
	fi

	echo
	echo
	echo
done

# Python pass (--python-deps): refresh every Python image not refreshed above,
# so dependency-only updates (and app releases that only the lock shows, e.g.
# for "git" pins) are picked up.
if (( PYTHON_DEPS )); then
	for app in "${PYTHON_APPS[@]}"
	do
		if in_list "$app" ${PYTHON_DONE[@]+"${PYTHON_DONE[@]}"}; then
			continue
		fi
		echo "Checking python dependencies for ... $app"
		update_python_app "$app" || FAILURES=$((FAILURES + 1))
		echo
		echo
		echo
	done
fi

# Dependency-pin pass: for each DEP_PINS entry, bump VAR in every workflow that
# sets it. It runs after the BUILD_VERSION loop and edits only the VAR line, so
# a BUILD_VERSION bump and a dependency bump in the same file never collide:
# each is its own commit.
for pin in "${DEP_PINS[@]}"
do
	var="${pin%%:*}"
	rest="${pin#*:}"
	label="${rest#*:}"
	new=$(cat "${WORKDIR}/dep.${var}")
	vlog "${var}: latest ${new:-<unresolved>}; pinned in: $(grep -lE "^[[:space:]]*${var}:[[:space:]]*\"" .github/workflows/*.yml | tr '\n' ' ' || true)"

	while IFS= read -r wf; do
		prog=$(basename "$wf" .yml)
		echo "Checking ${label} for ... $prog"

		dver=$(read_pin "$wf" "$var")
		if check_pin "$var" "$dver" "$new"; then
			echo "Updating ${label} to ${new} ..."
			bump_pin "$wf" "$var" "$new" "Updated ${prog} ${label} to ${new}" \
				|| FAILURES=$((FAILURES + 1))
		fi

		echo
		echo
		echo
	done < <(grep -lE "^[[:space:]]*${var}:[[:space:]]*\"" .github/workflows/*.yml || true)
done

# Final push: retry any commit whose push failed above.
if (( DRYRUN )); then
	echo "Dry run: ${DRY_CHANGES} change(s) would be committed; nothing was edited, committed or pushed."
elif [[ -n "$(git log --oneline '@{upstream}..' 2>/dev/null || true)" ]]; then
	echo "Pushing commits left over from failed pushes ..."
	if ! push_changes; then
		echo "ERROR: could not push local commits" >&2
		FAILURES=$((FAILURES + 1))
	fi
fi

if (( FAILURES > 0 )); then
	echo "ERROR: ${FAILURES} update(s) failed; see the messages above." >&2
	exit 1
fi
