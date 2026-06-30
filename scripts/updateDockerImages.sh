#!/bin/bash
#
# Script to check and start new image builds if the source repos have new releases
#
set -euo pipefail
IFS=$'\n\t'

# $PAT variable needs to be passed into the script as an env variable
# PAT is only used to avoid API rate limits

REPO=( 
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
	"StackExchange/dnscontrol" \
	"dkimpy/dkimpy" \
	"DNSCrypt/dnscrypt-proxy" \
	"projectdiscovery/dnsx" \
	"cloudskiff/driftctl" \
	"moncho/dry" \
	"multiprocessio/dsq" \
	"wader/fq" \
	"osrg/gobgp" \
	"kffl/gocannon" \
	"buger/goreplay" \
	"tomnomnom/gron" \
	"juanfont/headscale" \
	"nojima/httpie-go" \
	"projectdiscovery/httpx" \
	"go-acme/lego" \
	"0xInfection/logmepwn" \
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
	"authzed/spicedb" \
	"jtesta/ssh-audit" \
	"nabla-c0d3/sslyze" \
	"projectdiscovery/subfinder" \
	"tailscale/tailscale" \
	"hashicorp/terraform" \
	"drwetter/testssl.sh" \
	"shopify/toxiproxy" \
	"trufflesecurity/trufflehog" \
	"tsenart/vegeta" \
	"saulpw/visidata" \
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
# consumed read-only by the update loop below. Standard GitHub repos are fetched
# in a SINGLE GraphQL query (one request instead of one per repo); sources that
# are not a GitHub "latest release" are handled as explicit edge cases.
#
# To add an edge case:
#   - non-GitHub source  -> list it in is_special() and emit it in resolve_special()
#   - odd tag formatting -> massage it in normalize_version()
# Everything else flows through the GraphQL batch unchanged.
# ---------------------------------------------------------------------------

VERSIONS_FILE=$(mktemp)
trap 'rm -f "$VERSIONS_FILE"' EXIT

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
		ansible | dkimpy) return 0 ;;
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

# normalize_version: massage a raw upstream version into the string the workflow
# file and download URLs expect. Applied to every program, special or not.
normalize_version() {
	local prog="$1" ver="$2"
	case "$prog" in
		# nginx tags look like "release-1.31.0"; strip the prefix so the
		# version matches what the workflow file and download URL expect.
		nginx) ver="${ver#release-}" ;;
	esac
	printf '%s' "$ver"
}

# resolve_special: emit "<prog>\t<version>" for a non-GitHub source.
resolve_special() {
	local repo="$1" prog="$2" ver=""
	case "$repo" in
		"ansible/ansible" | "dkimpy/dkimpy")
			ver=$(curl -sL "https://pypi.org/pypi/${prog}/json" | jq -r '.info.version')
			;;
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

	local resp
	resp=$(curl -sSL -X POST \
		-H "Authorization: bearer ${GH_TOKEN}" \
		-H "Content-Type: application/json" \
		-d "$(jq -n --arg q "$query" '{query: $q}')" \
		"https://api.github.com/graphql") || {
		echo "ERROR: GraphQL request to GitHub failed (network/curl)." >&2
		return 1
	}

	# A response with no '.data' object is a systemic failure (bad auth, malformed
	# query, 5xx). Surface it and bail, rather than silently treating every repo as
	# "no release" — which would otherwise let the whole run pass having done nothing.
	if ! printf '%s' "$resp" | jq -e '.data != null' >/dev/null 2>&1; then
		echo "ERROR: GraphQL returned no data; aborting batch:" >&2
		printf '%s' "$resp" | jq -r '(.errors[]?.message), (.message // empty)' >&2 2>/dev/null \
			|| printf '  %s\n' "${resp:0:200}" >&2
		return 1
	fi

	# Per-repo errors (e.g. a renamed/moved repo) are non-fatal: that alias just
	# resolves empty and is skipped later. Warn so it is visible in the logs.
	if printf '%s' "$resp" | jq -e '.errors != null' >/dev/null 2>&1; then
		echo "WARNING: GraphQL reported partial errors (affected repos will be skipped):" >&2
		printf '%s' "$resp" | jq -r '.errors[]?.message' >&2 2>/dev/null || true
	fi

	local j=0 tag
	while [ "$j" -lt "$i" ]; do
		prog="${idx_prog[$j]}"
		# jq indexes null leniently, so a missing repo/release yields empty.
		tag=$(printf '%s' "$resp" | jq -r ".data.r${j}.latestRelease.tagName // empty")
		printf '%s\t%s\n' "$prog" "$(normalize_version "$prog" "$tag")"
		j=$((j + 1))
	done
}

# resolve_all_versions: GitHub batch + every special source.
resolve_all_versions() {
	resolve_github_batch || return 1
	local repo prog
	for repo in "${REPO[@]}"; do
		prog="${repo##*/}"
		is_special "$prog" && resolve_special "$repo" "$prog"
	done
	# Explicit success: the loop's last command is a (frequently false) is_special
	# test, whose status must not be mistaken for a resolution failure.
	return 0
}

if ! resolve_all_versions > "$VERSIONS_FILE"; then
	echo "ERROR: upstream version resolution failed; aborting without changes." >&2
	exit 1
fi

# A run where not a single repo resolved to a version is a systemic failure;
# fail loudly rather than silently updating nothing.
if ! awk -F'\t' 'NF >= 2 && $2 != "" { ok = 1 } END { exit ok ? 0 : 1 }' "$VERSIONS_FILE"; then
	echo "ERROR: no versions resolved for any repo; aborting without changes." >&2
	exit 1
fi

# setup git
#git config --local user.name "Jauder Ho Bot"
#git config --local user.email "jauderho-bot@users.noreply.github.com"
#git config --local pull.rebase false

# Fetch the latest version from GitHub and if there is a newer version, update GitHub Action to trigger a new build
# Right now it is just a string compare
for i in "${REPO[@]}"
do

	prog="${i##*/}"
	# Current pinned version: the quoted value on the first (env-block) BUILD_VERSION
	# line. Anchored + -m1 so a stray "BUILD_VERSION" elsewhere can never match.
	dver=$(grep -m1 -E '^[[:space:]]*BUILD_VERSION:[[:space:]]*"' ".github/workflows/${prog}.yml" | cut -d '"' -f 2)

	# Version resolved up front by resolve_all_versions (see VERSIONS_FILE above).
	rver=$(awk -F'\t' -v p="$prog" '$1 == p { print $2; exit }' "$VERSIONS_FILE")

	echo "Checking repo ... $prog"
	echo
	echo "    Dockerfile version is $dver"
	echo "    Repo version is	  $rver"
	echo

	# Skip workflows intentionally pinned to a non-release value (e.g. "git",
	# "nightly"): the bumper only manages real, release-versioned BUILD_VERSIONs.
	if ! is_valid_version "$dver"; then
		echo "    Skipping: BUILD_VERSION '$dver' is not a managed release version"
		continue
	fi

	# Skip if the upstream version failed to resolve or looks malformed. This is the
	# gate that keeps an unvalidated string from ever reaching the sed substitution.
	if ! is_valid_version "$rver"; then
		echo "    Skipping: resolved version '$rver' is empty or not a valid version" >&2
		continue
	fi

	# Version check
	if [ "$dver" != "$rver" ]; then

		# Update python requirements as necessary
		case $i in 			
			"ansible/ansible" | \
			"dkimpy/dkimpy" | \
			"astral-sh/ruff" | \
			"nabla-c0d3/sslyze" | \
			"saulpw/visidata")
				echo
				echo "Checking python dependencies ..."
				scripts/updatePythonDeps.sh "$prog"
				;;
			*)
				# not a Python program
				;;
		esac

		echo "Updating to ${rver} ..." 

		sed -i -e "/^[[:space:]]*BUILD_VERSION:/ s/\"[^\"]*\"/\"${rver}\"/" ".github/workflows/${prog}.yml" && \
		git add ".github/workflows/${prog}.yml" && \
		git commit -S -s -m "Updated ${prog} to ${rver}" && \
		git push

	else
		echo "No update needed ..."
	fi

	echo
	echo
	echo
done
