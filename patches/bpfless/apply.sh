#!/usr/bin/env bash
# Apply port patches to a LineageOS 24.0 tree, safe to re-run
# usage: apply.sh [topic ...]   (default: all topics: bpfless frontlight eink)
set -euo pipefail

PATCHES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# patches/<dir> -> project path in the tree
declare -A PROJECTS=(
    [bionic]=bionic
    [packages_modules_Connectivity]=packages/modules/Connectivity
    [system_bpf]=system/bpf
    [system_netd]=system/netd
    [packages_frameworks_base]=frameworks/base
    [system_sepolicy]=system/sepolicy
)
ORDER_bpfless=(bionic packages_modules_Connectivity system_bpf system_netd)
ORDER_frontlight=(packages_frameworks_base system_sepolicy)
# eink's sepolicy patch applies on top of frontlight's, keep it after
ORDER_eink=(system_sepolicy)

die() { printf '\n*** ERROR: %s\n' "$*" >&2; exit 1; }

[[ -d .repo && -f build/envsetup.sh ]] || die "run this from the root of the Lineage source tree"

# git am needs a committer identity; use a neutral one if none is configured.
if ! git config user.email >/dev/null 2>&1; then
    export GIT_COMMITTER_NAME="${GIT_COMMITTER_NAME:-local}"
    export GIT_COMMITTER_EMAIL="${GIT_COMMITTER_EMAIL:-local@localhost}"
fi

TOPICS=("$@")
if (( ${#TOPICS[@]} == 0 )); then
    TOPICS=(bpfless frontlight eink)
fi

for topic in "${TOPICS[@]}"; do
    [[ -d "$PATCHES_ROOT/$topic" ]] || die "unknown topic: $topic"
    declare -n ORDER="ORDER_$topic"

    for dir in "${ORDER[@]}"; do
        project="${PROJECTS[$dir]}"
        [[ -d "$project/.git" || -f "$project/.git" ]] || die "$project is not a git checkout"
        if [[ -d "$(git -C "$project" rev-parse --git-path rebase-apply)" ]]; then
            die "$project has a git am/rebase in progress; run 'git -C $project am --abort' first"
        fi
        [[ -z "$(git -C "$project" status --porcelain --untracked-files=no)" ]] \
            || die "$project has uncommitted changes; commit or reset them first"

        for patch in "$PATCHES_ROOT/$topic/$dir"/*.patch; do
            name="$(basename "$patch")"
            if git -C "$project" apply --check --reverse "$patch" >/dev/null 2>&1; then
                echo "skip    $project: $name (already applied)"
                continue
            fi
            if ! git -C "$project" -c commit.gpgsign=false am --3way "$patch"; then
                git -C "$project" am --abort || true
                die "$name failed to apply to $project (git am error above)."
            fi
            echo "applied $project: $name"
        done
    done
done

echo
echo "All patches applied (${TOPICS[*]})."
