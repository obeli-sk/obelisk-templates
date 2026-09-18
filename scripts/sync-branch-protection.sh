#!/usr/bin/env bash

set -euo pipefail
cd "$(dirname "$0")/.."

mapfile -t contexts < <(
    for workflow in .github/workflows/*.yml .github/workflows/*.yaml; do
        [[ -f "$workflow" ]] || continue
        yq -o=json '.' "$workflow" | jq -r '
            select((.on | type == "object" and has("pull_request")) or (.on | type == "string" and .on == "pull_request") or (.on | type == "array" and index("pull_request")))
            | .jobs | to_entries[]
            | .key as $job_id
            | (.value.name // $job_id) as $job_name
            | if .value.strategy.matrix then
                .value.strategy.matrix | to_entries[]
                | select(.key != "include" and .key != "exclude")
                | .value[] | "\($job_name) (\(.))"
              else $job_name end'
    done
)

if ((${#contexts[@]} == 0)); then
    echo "No pull request checks found" >&2
    exit 1
fi

printf 'Required checks:\n'
printf '  %s\n' "${contexts[@]}"

payload=$(printf '%s\n' "${contexts[@]}" | jq -Rsc '
    split("\n")[:-1]
    | {required_status_checks: {strict: true, contexts: .}, enforce_admins: true,
       required_pull_request_reviews: {required_approving_review_count: 0},
       restrictions: null}')

if [[ ${DRY_RUN:-0} == 1 ]]; then
    jq . <<<"$payload"
else
    repo=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
    gh api --method PUT "repos/$repo/branches/main/protection" --input - <<<"$payload"
fi
