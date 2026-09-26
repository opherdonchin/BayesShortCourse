# Known issues in sleep notebooks 01–05 (instructor-authored, not fixed here)

Found while analyzing the revision pattern of notebooks 01–05 to build
`sleep/REVISION_PLAYBOOK.md` (see
`sleep/revision_logs/_shared/nb01-05_revision_pattern_report.md` §8 for full detail).
Notebooks 01–05 were authored and committed directly by the instructor; this pass was
scoped to notebooks 06–12, so these are flagged rather than fixed. Two closely related,
purely mechanical bugs *were* fixed as noted in `REVISION_PLAYBOOK.md` §4 (missing
`ci_kind="hdi"` in NB04/05 plots, and NB01's self-work `FIG_DIR` path) because they were
unambiguous and required no interpretive judgment. Everything below was left as-is.

## Possibly-stale numeric answers

- **NB01, §5.3** (solved): the markdown answer states "Approximately **257–283 ms**",
  but the committed `azs.summary` output for `b0`'s 90% HDI is 254.82–281.49 ms.
- **NB04, §6.12** (solved): the markdown hard-codes "Notebook 1 gave a 90% HDI …
  approximately 7.94 to 14.07 ms/day" for comparison, but NB01's own committed output
  for that interval is 8.20–14.46 ms/day.

These could be genuine authoring slips (drafted before a final re-run), or they could
reflect a legitimate small numeric difference from re-running on a different machine/
platform than the one that produced the currently-committed output — sampling with a
fixed seed is not bit-for-bit identical across BLAS backends, thread counts, or OS
(confirmed directly in this session: an unrelated re-execution test on NB01 produced
different sample values than its committed output, from a fixed seed, when run in this
container instead of the instructor's original Windows environment). Distinguishing
the two would require re-deriving the exact original execution environment, which is
out of scope here.

## Hedged answers in NB04 (solved)

Several answers are phrased conditionally instead of stating the actual result:
- §5.4: "Yes, provided the executed notebook shows no divergences…"
- §5.10: "Yes, provided their R-hat, ESS, and traces meet…"
- §6.13: "In the executed notebook, compare the two displayed values directly."

The committed outputs give definite answers (0 divergences, R-hat 1.00, a specific
width comparison), so these could be tightened to state the result directly, matching
the concrete style NB05 uses elsewhere ("every reported population-level R-hat is
1.00 … ESS values are all comfortably above 2,800").

## `print(model)` taught as useful (NB04, solved)

NB04 calls `print(model)` 13 times, and §2.1's answer names it as "the textual
representation" of the model. In PyMC 6.3.2, `Model` has no `__str__`, so the actual
committed output is `<pymc.model.core.Model object at 0x...>` — not informative. A
working alternative is `print(model.str_repr())`, or leaving `model` as a cell's last
expression (rich display). Left as-is here since fixing it changes what §2.1's answer
teaches, not just a plot argument.

## "Recall, then reveal" redundancy (NB02, solved, §2.3 and §4.3)

A recall question ("What criteria did we establish in Notebook 1…?") has a `solution`
answer, immediately followed by a separate `given` cell that restates the same
criteria in full. In the self-work notebook this puts the answer blank directly above
its own reveal, which may or may not be the intended pedagogy (recall-then-consolidate)
— flagged as worth a deliberate look rather than assumed to be a mistake.

## Self-work notebook metadata leftovers

The self-work (student) copies of NB01–05 still carry per-cell `metadata.execution`
timestamps and notebook-level `metadata.widgets` state copied from the solved run at
generation time. Harmless (outputs themselves are cleared), but it is metadata churn
that AGENTS.md's "Notebook outputs" section asks to avoid. The NB06–12 generation
process strips these (see `REVISION_PLAYBOOK.md` §2).

## README statements that were already stale before NB06–12 (partially addressed)

`sleep/solved/README.md` contains several statements written for the pre-revision
NB1–5 style that NB4–05 already contradict (e.g. the `population_mu`/`population_mean_rt`
paragraph, the per-notebook question-numbering description, "both plot helpers …
defined once per notebook"). These are corrected as part of the NB06–12 work per
`REVISION_PLAYBOOK.md` §1.6, since the README needs to describe the target style that
now spans all 12 notebooks — see the README diff in the commit(s) that revise NB06–12.
