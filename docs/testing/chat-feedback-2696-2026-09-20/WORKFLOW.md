# Delegated implementation and acceptance workflow

The primary agent owns the plan, priorities and acceptance decisions. Sub-agents own bounded implementation, investigation or verification tasks and append evidence to their assigned documents. Delegation reduces repeated investigation; it cannot guarantee that context compaction never occurs. These documents preserve decisions across context changes.

## Task contract

Before delegation, record:

- Objective and explicit exclusions.
- Exclusive production, test and evidence file ownership; shared files remain with the primary agent.
- Required behavior, acceptance checks and known platform limits.
- Evidence destination and expected handoff: changed files, commands/results, unresolved risks and proposed next step.
- Whether external changes are authorized. A task assignment does not expand the user's authorization.

Agents work concurrently only where file ownership and dependencies allow it. They do not overwrite another agent's changes, commit or publish unless assigned that action, or include credentials/private recordings in evidence. An agent needing an unowned file reports the dependency to the primary agent first.

## Gates for each step

1. **Plan:** primary agent defines a reviewable step and assigns its files.
2. **Execute:** agent implements or investigates and runs relevant checks. Failures are recorded with their actual scope.
3. **Handoff:** agent appends evidence and reports a concise result. A passing test is evidence, not automatic acceptance.
4. **Decide:** primary agent reviews the diff and evidence, checks cross-feature effects, and marks the step **accepted**, **rework**, **deferred** or **blocked** with a reason.
5. **Integrate:** primary agent integrates only accepted work, runs dependency/native checks as needed and updates the issue ledger and release documentation. Only then does it decide whether to commit, push or release within existing authorization.

## Status vocabulary

- **Planned / in progress:** implementation or verification is incomplete.
- **Implemented, checks pending:** code exists; acceptance is not established.
- **Automated checks passed:** name the suite and scope; do not imply device verification.
- **Device verified:** identify platform/build and tested behavior without recording personal account data.
- **External limitation:** preserve evidence such as upstream rate limiting; do not describe the feature as end-to-end verified.
- **Accepted:** primary agent's explicit decision for the stated scope only.

Each evidence entry includes date, revision or dependency pin, command/log reference, result, verification boundary and remaining checks. Keep earlier failures and mark superseding results rather than silently rewriting history. The Chat repository's `OPEN_ISSUES.md` remains the single unresolved-issue ledger; these documents hold execution evidence, not a competing issue list.

## Token economy

- Delegate independent, narrow tasks with `fork_turns=none`. Supply only necessary background, owned files, acceptance criteria and document links; do not copy the full conversation.
- Keep detailed logs on disk. Report outcomes and concise failure summaries with evidence paths instead of streaming successful test output into the conversation.
- Reuse the same agent for follow-up work on its existing task, retaining that agent's relevant context.
- Run tests relevant to the changed behavior. The primary agent decides whether integration risks justify a broader suite.
- Prefer durable decisions and evidence over repeated investigation. No fixed token or cost saving is promised.
