# mq-bypass-lab

A test repository for one question: when an actor is on the bypass list of a "Require a pull request before merging" rule, can it merge its own pull requests without an approval through auto-merge, through the merge queue, or only by calling the merge API?

Short answer from the tests below: only the merge API. Auto-merge never completes, the merge queue never accepts the PR, and `enqueuePullRequest` is refused. A human approval fixes all of it within seconds.

The full write-up is the GitHub community discussion linked here once it is posted: DISCUSSION_LINK

## How the tests were run

- `Dockerfile` has ten old base image tags, one per stage. Each test used one of them, so each test got its own pull request.
- Every pull request was opened by a private GitHub App named `mq-bypass-lab-bot`, running Renovate in Docker with that app's token. Renovate 43.268.1 for most tests, 44.111.4 for one.
- The app opened the PR, then either turned on GitHub's auto-merge (Renovate's `platformAutomerge: true`, the default) or called the merge API itself on a later run (`platformAutomerge: false`).
- `.github/workflows/ci.yml` is the only check. It runs on `pull_request` and on `merge_group`, and it was required in every test.
- "Allow auto-merge" is on in the repository settings.
- Every failed test was left for at least 20 minutes. Then something that should work was done on the same PR, to prove the setup was fine.
- All times below are from 2026-09-24, UTC.

## Which rules applied to which pull request

The rules on `main` changed between tests. Here is the state for each PR.

| PR | Rules on `main` at the time | Bypass actor | What was tried | Result |
|---|---|---|---|---|
| #1 | ruleset "approval" (1 approval), ruleset "checks" | the app, mode "For pull requests only" | app turned on auto-merge; 23 min later a human approved | blocked until the approval, merged 24 s after it |
| #2 | same rulesets | the app, mode "Always allow" | app turned on auto-merge; 20 min later the app called the merge API | blocked until the API call, then merged at once |
| #3 | classic branch protection: 1 approval, app allowed to bypass, `ci` required | the app | app turned on auto-merge; 20 min later Renovate merged it itself | blocked until Renovate's own merge |
| #4 | rulesets "approval" and "checks" | the app, mode "For pull requests only" | Renovate merged it itself on its second run | merged, no approval |
| #5 | rulesets "approval", "checks" and "queue" | the app | auto-merge for 20 min, then `enqueuePullRequest`, then the merge API with Renovate 43 and 44, then a human approval | nothing worked until the approval; then queued in 17 s and merged |
| #6 | same, and the app also on the bypass list of the "queue" ruleset | the app | Renovate merged it itself | merged directly, skipped the queue |
| #7 | rulesets "checks" and "queue", no approval rule | nobody | app turned on auto-merge | queued in 16 s, merged by the queue |
| #8 | same as #7 | nobody | the major bump of the same line as #7 | dropped by the queue as conflicting, closed by hand |
| #9 | rulesets "approval" and "checks"; "queue" turned on for one test | the Repository admin role | a human admin turned on auto-merge (20 min), called `enqueuePullRequest`, then the merge API | only the merge API worked |
| #10 | rulesets "approval" and "checks" | Organization admin | the organization owner turned on auto-merge (20 min), then the merge API | only the merge API worked |
| #11 | same as #10 | Organization admin | the major bump of the same line as #10 | closed by hand, not tested |
| #12 | classic branch protection with "Require merge queue": 1 approval, app allowed to bypass, `ci` required | the app | auto-merge for 20 min, then the merge API, then `enqueuePullRequest`, then a human approval | nothing worked until the approval; then queued in 5 s and merged |

Each PR page shows the timeline GitHub wrote: when auto-merge was enabled, when a review was added, when the PR entered or left the queue, and when it merged.

## State of the rules now

The three rulesets still exist and are all disabled. The classic branch protection rule on `main` is the one from PR #12: one required approval, the app allowed to bypass required pull requests, `ci` required, and "Require merge queue" on. Nothing here is meant to be reused. The repository is kept public so the timelines stay visible.
