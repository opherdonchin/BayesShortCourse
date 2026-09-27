# Sleep notebooks review — pass 2: consolidated

This version merges the notebook-by-notebook findings of `1_review_by_notebook.md` into issues, each with enough context to decide it without opening the notebooks. Cross-notebook issues are merged; the source items from pass 1 are cited in brackets (e.g. [06.Q2]) so you can drill down.

Issue IDs defined here (P = pedagogy/content, S = style/presentation, I = infrastructure, F = fix already made) are reused unchanged in pass 3.

Sources used for "the book": Chapter 17 of `Bayesian-Workflow.pdf` (pp. 275–292) for NB1–7 and NB12; the online case-study code (`avehtari/Bayesian-Workflow/sleep_study/sleep_study.R`) for the distributional, ex-Gaussian, default-prior, and flat-prior models (NB8–11), which are not in the printed chapter. The Python port (*Bayesian Workflow case studies in Python*, sleep study; PDF supplied after pass 1) covers only book sections 1–7, i.e. NB1–NB4; its bearing is summarized in the addendum to pass 1 and folded into P7, P8, P10, and S5 below.

---

## Part 1 — Fixes already made (veto list)

All on branch `claude/sleep-notebooks-review-m0u2y9`, commit `3a48fa8`. No sampling cell was re-run; all posterior numbers are unchanged.

| ID | Notebook | Change | Why |
|---|---|---|---|
| F1 | NB10 self-work | Colab badge pointed at the *solved* notebook; now points at `sleep/10_…` | Students would have opened the solutions |
| F2 | NB1 §5.3 | "257–283 ms" → "255–281 ms" | Output HDI is 254.82–281.49 |
| F3 | NB4 §6.12 | NB1 slope HDI 7.94–14.07 → 8.20–14.46 (text, code, table output: width 6.26 vs 3.59) | Matches NB1's committed output |
| F4 | NB4 §5.4, §5.10, §6.13 | "Yes, provided the executed notebook shows…" → actual results | Hedged answers; §6.13 also gained one explanatory sentence (`sd_y` 51 → 30 ms) — **new content, veto if unwanted** |
| F5 | NB4 (13 cells), NB5 (1 cell), NB4 §2.1 | `print(model)` → `print(model.str_repr())`; outputs regenerated | In PyMC 6.3.2 `print(model)` prints only `<Model object at 0x…>`; §2.1 taught it as the text representation |
| F6 | NB5 §3.3, §4.3, §4.6 | ESS "above 2,800" → "2,700"; HDIs 7.94–14.71 → 8.07–14.62, 4.74–10.06 → 4.61–9.96 | Did not match committed output |
| F7 | NB5 §7.4 | Removed final sentence previewing NB6 | Closing-section instruction (playbook §3.10) |
| F8 | NB1 | `### Data` → `## Data` | Every other notebook; also makes the slide figure name `01_linear_baseline_data.svg` follow the `AGENTS.md` naming rule |
| F9 | NB1, NB2 | Setup cells tagged `given` | Playbook §2: untagged cells are an error |
| F10 | NB2 | Removed unused `plot_population` | README/playbook: define only where called |
| F11 | NB3 §1.2 | Folded an untitled `exercise-question` cell into §1.2 | Tag/heading scheme |
| F12 | NB1–5 self-work | Stripped leftover execution timestamps and widget metadata | Known issue; metadata churn |
| F13 | NB1, NB2 code comments; README | "orange mean line" → `C1` (pink under `arviz-variat`) | The line renders pink; NB12 already says "pink" |
| F14 | README | `pm.ExGaussian`'s `mu` is the Gaussian location; brms's `exgaussian` `mu` is the distribution mean | README claimed the parameterizations match |

---

## Part 2 — Content and pedagogy

### P1. NB10's "naive" priors are the book's own informed priors [10.Q1]

**Context.** NB10 (file `10_exgaussian_default_priors`, title "Priors that ignore the log link") replaces three of NB9's priors with `mu_log_sd_y ~ Normal(0, 5)`, `log_nu ~ Normal(0, 5)`, `sd_log_sd_y ~ Exponential(scale=5)`, calling them "the kind of prior written by default rather than by thinking about the quantity it constrains". It shows the prior predictive check fails badly (44% of simulated experiments contain an RT above 10 s) and the fit fails (100% max tree depth, R-hat up to 1.04).

**The problem.** In the online case study these exact three priors are the authors' deliberately chosen priors for their ex-Gaussian model (`prior7`: `normal(0, 5)` on the log-linked sigma intercept and on the log-linked `beta`, `exponential(0.2)`—mean 5—on the SD of the sigma effects), and brms fits that model fine (with `init = 0`). Separately, the book's "default priors" section (model 8) makes the *opposite* point to NB10: brms's defaults are "sensible(ish)", and swapping them in "barely matters… except for the skewness parameter". The README says NB10 exists because these priors made an early draft of NB9 fail, and that PyMC has no software defaults to demonstrate.

**Why it matters.** Students reading the book alongside will find the authors using the priors NB10 calls thoughtless. The prior-predictive critique is still valid on its own terms (these priors really do imply absurd RTs), but the notebook's framing and filename misrepresent its relation to the source.

**Options.** (a) Keep the content, reframe honestly: "the book uses these priors with brms; here is what they imply in milliseconds, and here is what happens in PyMC". (b) Reframe as the book's "default priors" lesson: use Bambi's defaults for an ex-Gaussian model (Bambi is already in the course, NB12 uses its Student-t default) and show that, as the book says, they barely matter except for the tail. (c) Drop NB10 (its lesson is also in NB6 §1 and NB8 §1.7; see P5). At minimum, rename the file or retitle so they agree.

### P2. NB10's sampling failure is a PyMC implementation artifact [10.Q2]

**Context.** NB10 §4.5 explains the failed fit: PyMC 6.3.2 computes the ex-Gaussian log-density with the plain Gaussian formula once `nu < 0.05·sigma`; at each participant's switch point the density jumps slightly; the sampler shrinks its step size to ~0.0025; every draw hits max tree depth.

**Why it matters.** The prior-predictive failure is version-independent. The sampling failure — and a full answer's worth of teaching — depends on one line of PyMC internals that may change in a future release, silently invalidating §3–4. It is also far below the level of the rest of the course.

**Options.** Keep §2 (prior predictive) as the core of NB10; reduce §3–4 to "the fit also fails; zero divergences is not a clean bill of health" (the genuinely valuable point in §3.4) without the implementation explanation. Or keep as is and accept version fragility.

### P3. The ex-Gaussian tail is barely identified, and NB9–11 rest on it [09.Q1, 09.Q2, 11.Q3]

**Context.** NB9 fits `nu` (the mean of the exponential tail) with prior median 50 ms. Posterior: mean 7.4 ms, 90% HDI 3.7–11 ms; NB9 §4.4 says the lower end is where the prior stops the posterior. NB9 §4.5 then explains why: each observation is a *session-average* RT, so single-trial skew is averaged away. NB10's and NB11's failures both come from this parameter being unbounded below by the data.

**Why it matters.** The three ex-Gaussian notebooks are a lesson about priors on a parameter the data barely inform — which is the book's point too ("priors matter… for the skewness parameter"). But NB9 never measures that dependence (no power-scaling section, although NB1–3, NB6, NB7 have one), and the scientific reason (averaging) arrives only after the fit, making the short tail look like a surprise rather than a prediction.

**Options.** Add a power-scaling check on `nu` to NB9 (short; the machinery is already familiar). Move the "these are session averages" point into the tail-prior elicitation (§1.12). In NB11, consider making only the tail prior flat (it currently flattens `mu_b0` and `mu_b1` too, which the data identify well), so the failure's source is unambiguous.

### P4. NB11: run-specific text and very high teaching load [11.Q1, 11.Q2]

**Context.** NB11 (flat priors) teaches that a flat prior on a parameter the data cannot bound gives an improper posterior. Its text hard-codes one run: chain 3 stuck, 1,488 divergences, `log_nu` bottoming out at −372 because of floating-point underflow (`5×10⁻³²⁴`, NaN in the gradient), and §3.4's solution selects chains `[0, 1, 2]` by index. The notebook reports that across ten test runs 40% of chains got stuck and one run had no stuck chain; the README warns results depend on PyTensor/Numba cache state and tells instructors to re-run in Colab before lecturing.

**Why it matters.** Following the README's own advice will likely make the text wrong in front of students. And the explanation (underflow, NaN gradients, mass-matrix scaling, "walls") is far beyond a short course; the key lessons fit in a few sentences.

**Keep regardless:** §1.5 (no prior predictive check is possible with a flat prior) and §3.7 (a PPC cannot detect that the posterior doesn't exist) are compact and strong.

**Options.** (a) Rewrite the diagnosis generically ("look for a chain that sits apart…") and select chains by a computed criterion rather than by index; cut the floating-point material to one sentence. (b) Keep as a take-home/advanced notebook with an explicit "your run will differ" banner. (c) Drop NB11 and fold its two strong lessons into NB10 or NB9.

### P5. Scope of the NB6–NB11 arc; the same lesson three times [10.Q3]

**Context.** "A prior that looks vague on the log scale can be extreme on the natural scale" is taught in NB6 §1 (Gaussian-scale priors on a lognormal model, median RT 10¹⁰⁸ ms), NB8 §1.7 (a log-scale center of 0 implies residual scale 1), and NB10 (the whole notebook). NB10 and NB11 each take ~5 minutes to sample (I1).

**Why it matters.** Six notebooks after NB5 is a long arc for a short course; the repeated lesson adds length without new ideas. The book itself covers NB10/NB11's material in two short paragraphs.

**Options.** Decide the intended stopping point for class use vs self-study; consider merging NB10 into NB9 as a single "what if we had not translated the priors?" section, or making NB10–11 optional.

### P6. No predictive comparison across likelihood families; NB9 ↔ NB12 link [12.Q1, 12.Q2]

**Context.** NB6–9 introduce lognormal and ex-Gaussian likelihoods; NB12 introduces PSIS-LOO but compares only Gaussian vs Student-t (NB4/NB5 structures). The book compares normal vs lognormal (lognormal better by 10.6 ± 4.1) and t vs log-t.

**Why it matters.** Students never learn which of the likelihoods they built predicts best, although NB12 hands them the tool. Because `pm.LogNormal` and `pm.ExGaussian` are defined on `y` itself, NB7/NB8/NB9 fits could go into `azs.compare` directly (no Jacobian needed; the book's Jacobian is only for fitting `log(y)` as the outcome). Also unmade: NB9 found nearly symmetric scatter (tail ≈ 7 ms), NB12 found heavy two-sided tails (`nu` ≈ 2.6), partly from unusually *fast* days (332 day 7, 308 day 5) that a one-sided exponential tail cannot produce. That one sentence explains both results.

**Options.** Add one comparison section (or a short closing question) to NB12 that includes NB7/NB9's models; and/or add a question linking NB9's result to NB12's.

### P7. NB3's message and psense numbers pull in opposite directions [03.Q1–Q3]

**Context.** NB3 replaces NB2's `Normal(0, 1)` slope prior with `StudentT(7, 0, 1)`. Posterior `b1` 8.16 (NB2: 2.29, NB1: 11.33). §5.4: conflict still flagged; heavier tails made the prior "less brittle". But prior sensitivity *rose* (`b1` 0.393 vs 0.367; `b0` 0.335 vs 0.191). The book's lesson from the same prior is the robustness one: posterior mean 9.2, "similar to what we had originally obtained". The Python port gets 8.08 (95% ETI 2.9–13), essentially NB3's value, so the difference from the book is brms-vs-PyMC, not a notebook error; with 8 rather than 9 against 11, NB3's more cautious "not fully" is defensible.

**Why it matters.** A student comparing tables sees "worse" numbers under a prior described as better. The notebook needs either the book's framing (tails let the data win, as the posterior shows) or one sentence on why power-scaling stays high when the posterior sits in the prior's tail. The Normal-vs-t density plot (x from −6 to 6, linear density) hides the tails where the priors differ and where the posterior lands.

**Options.** Decide the headline; add a one-line explanation of the psense values; replot densities on a log axis or wider x-range; optionally close with a three-row NB1/NB2/NB3 `b1` comparison.

### P8. NB2 never shows what the conflict does to the estimates [02.Q3, 02.Q5]

**Context.** NB2 has no interpretation section. Under the tight slope prior, `b1` = 2.29 (NB1: 11.33), `b0` rises 268 → 300 ms and `sd_y` 51 → 55 ms to compensate; psense flags all three.

**Why it matters.** That compromise is *the* mechanism of prior–data conflict and explains both the failed PPC and why unchanged priors get flagged. The book uses exactly this example (its text reports `b1` 3.8; the Python port reports 2.3, `Intercept` 300, `sigma` 55 — NB2's numbers).

**Option.** One short question comparing the summary with NB1's.

### P9. NB4: partial pooling named but never shown [04.Q2, 04.Q3]

**Context.** NB4 §6.9 defines partial pooling in a given answer; nothing demonstrates it. `sd_y` falls from 51 (NB1) to 30 ms but is not interpreted (now mentioned in passing in fix F4).

**Why it matters.** The book shows pooling with a plot of separate per-person estimates vs multilevel estimates (Fig. 17.7). Without a display it is a vocabulary item. The `sd_y` drop is the most direct evidence that residual variation was hiding between-person variation.

**Options.** Add a small shrinkage display (e.g. each participant's day-0 observation or per-participant OLS intercept vs posterior `b0` mean, with `mu_b0` marked), and one question on `sd_y`.

### P10. Residual-scale prior when a hierarchy is added [04.Q1, 07.Q1]

**Context.** NB4 keeps NB1's `sd_y ~ Exponential(scale=50)` and adds `sd_b0 ~ Exponential(scale=25)` with no rationale. The book splits NB1's 50 into 25 + 25 (within- and between-person); the Python port instead uses 50 for both `sigma` and the subject SD. NB4's 50 + 25 matches neither. The R source lists "shall the prior on sigma change now that we add more terms?" as a discussion point. NB5, NB7 (log scale: keeps 1/3, book 1/6; `sd_b1` 0.05, book 0.1), NB12 follow NB4.

**Why it matters.** Small numerically (the data dominate), but it's a named teaching point in the source and the current "suppose we use 25" gives students no reasoning to imitate.

**Options.** Adopt the split with one question on why; or keep and give a reason for 25. Either way, propagate consistently.

### P11. The 150 ms baseline prior on the log scale [06.Q1]

**Context.** NB6 elicits `b0 ~ Normal(5, 0.55)` by matching the 2.5/97.5% points 50 and 450 ms on the log scale — the book's own derivation. The center is the geometric midpoint, ~150 ms; the notebook says the prior predictive's most probable RTs are "implausibly fast… below every observed reaction time", and proceeds. NB7 and NB8 inherit the prior and repeat the caveat. The book switches to `normal(5.5, 0.55)` for its distributional model.

**Why it matters.** The asymmetry is a good lesson once. Carrying a prior the notebook itself calls implausible into two more notebooks adds caveats and noise to their prior-predictive discussions.

**Options.** (a) Keep in NB6 as the lesson, then re-center on log(250) ≈ 5.5 and carry *that* into NB7–8 (a revision step students watch happen). (b) Keep everywhere as is.

### P12. NB8 centers a prior on a posterior from the same data [08.Q1, 08.Q4]

**Context.** NB8 §1.8 centers the typical log residual scale on NB7's fitted `sd_y` (≈ 0.08); §1.9 defends the double use ("only the order of magnitude"). NB8 has no sensitivity check. NB9 elicits the analogous prior in milliseconds without using earlier fits.

**Why it matters.** It is the only data-informed prior in the course, contradicting the workflow the course teaches; a sensitivity check is exactly what would justify it and is missing.

**Options.** Re-elicit from subject knowledge ("day-to-day variation of a few percent to ~20%", which gives nearly the same prior); or keep as a deliberate discussion and add power-scaling.

### P13. Intercept–slope correlation (LKJ) omitted [05.Q2, 08.Q5]

**Context.** The book's varying-slope models use an LKJ prior on the intercept–slope correlation (a sizeable part of §17.2); the distributional models correlate all participant effects. Ours use independent hierarchies throughout NB5, NB7–12; NB5 §1.1 says so.

**Options.** Keep (README calls it a deliberate simplification). If kept, nothing to do beyond NB5's existing sentence. If not, NB5 is the place to add it.

### P14. NB5: light scaffolding, orphan plot, `b1` changes meaning [05.Q1, 05.Q3, 05.Q4]

**Context.** NB5 supplies the model, prior draws, fit, diagnostics, and PPC as `given`; students name variables and copy plot calls. `change_7` is plotted in the posterior (§4.11) but no question uses the plot. `b1` means "the shared slope" in NB4 and "a participant's slope" in NB5 (population value `mu_b1`); NB12 §1.5 explains this, NB5 doesn't.

**Options.** Confirm the load; add one question on the `change_7` forest plot or drop it; add one sentence on `b1`'s new meaning in §1.4.

### P15. How notebooks end [01.Q9, 03.Q5, 04.Q4, 05.Q5]

**Context.** NB1–3 and NB5 end on their last check with no summary; NB4 ends with "What limitation remains?" (parallel slopes → sets up NB5); NB6–12 end with a `## Summary` Q&A. The playbook (§3.10) records your instruction: summarize the notebook's own results, don't preview the next.

**Options.** (a) Add a short summary question to NB1–5 (NB4's §8 could become it). (b) Remove the summaries from NB6–12 for consistency with NB1–5. (c) Leave. Also decide whether NB4's §8 counts as "a result" or "a preview".

---

## Part 3 — Presentation and style

### S1. Answer length escalates from NB6 on [06.Q4, 09.Q5, 11.Q2]

**Context.** NB1–3 answers are one line to three sentences. From NB6 on, typical solutions run 4–8 sentences, often with cross-references to three or four earlier questions ("(Notebook 8, Question 1.5)"). Examples: NB6 §2.8/§2.9, NB9 §2.4/§3.2/§4.7, NB10 §2.4, NB11 §3.3 (a given-answer of ~250 words). Playbook §1.4 asks for "a verdict word plus 1–3 sentences".

**Why it matters.** Teaching load and self-work usability: in the self-work notebooks students must write these answers.

**Option.** A trimming pass on NB6–12 (no code changes), guided by your answers to P2/P4/S3.

### S2. Prior-predictive plots are dominated by a few extreme draws [06.Q2]

**Context.** The participant helper draws the mean as the point estimate (`AGENTS.md` rule). For skewed or heavy-tailed prior predictives (NB6–10), a single extreme draw makes the mean line spike or zigzag, and the shared y-axis stretches to 5,000 ms (NB7) or 10⁵¹ ms (NB10), flattening the bands.

**Why it matters.** Each notebook then spends a paragraph explaining the artifact (S3). The bands carry the message; the mean line obscures it.

**Options.** For prior-predictive calls only: fix a y-range (e.g. 0–1,000 ms) and/or omit or de-emphasize the mean line (not yet checked whether `azp.plot_lm` accepts `point_estimate=None`; hiding the `pe_line` visual is the fallback). A helper argument, used consistently. Code change → re-run NB1–10.

### S3. Run-specific "forensic" answers about individual prior draws [07.Q2, 08.Q3, 09.Q4, 10.Q5]

**Context.** NB7 §2.5–2.6 (spikes in participants 333 and 335), NB8 §2.7 (351, 371; "a single draw… 750–1,300 s"), NB9 §2.7 (333's zigzag; "sd about 145 s"), NB10 §2.4 (the same panel, because NB10 reuses NB9's random numbers). All correct for the committed run.

**Why it matters.** (a) Panels are unlabeled (S5), so "middle row, first" is how students find them; (b) any change upstream moves the spikes and makes the text wrong; (c) the underlying lesson takes a sentence. Much of it disappears if S2 is adopted.

### S4. Claims based on runs students can't see [08.Q2, 09.Q3, 12.Q3; NB10 §3.1, NB11 §2.1/§2.5]

**Context.** "With the default `target_accept`… occasionally reports a divergence" (NB8), "more than a dozen divergences… 0.95 usually still leaves a few" (NB9), "with Notebook 9's `target_accept=0.99`… samples even worse" (NB10), "in ten test runs… 40% of chains got stuck" (NB11), "in test runs with other random seeds, the largest k… ranged from…" (NB12).

**Why it matters.** Unverifiable statements in a notebook whose method is "check the output". Playbook §3.3 requires confirming divergences before raising `target_accept`; the confirmation isn't in the notebook.

**Options.** Show the evidence (e.g. a short default-settings fit reporting only the divergence count — costs runtime), or state it once as "in our testing" without specifics, or drop.

### S5. Participant panels and trace colours are unlabeled [01.Q6, 04.Q7]

**Context.** `plot_participants` (NB1–11) draws 18 untitled panels; answers from NB7 on refer to participants by ID and grid position. `plot_trace_dist(..., coords=…)` for three participants draws three unlabeled colours (NB4–10). NB12's LOO helper titles its panels, as does the Python port's per-subject plot ("subject 308", …).

**Option.** Add panel titles to `plot_participants` (as NB12 does) and a legend or per-participant rows to the trace plots. Code change → re-run.

### S6. Heading and title style [01.Q2, 02.Q1]

**Context.** NB1: `## 2. Prior predictive check — What does the model imply…?`; NB2/NB3 mix; NB4–12: `## 3. Prior predictive check`. Titles: NB2 and NB3 are questions, the rest noun phrases. The playbook made NB5's style the rule (§3.8) while also calling NB1–3 the more reliable style model (§3.11).

**Option.** Pick one; the change is markdown-only.

### S7. `mu` (NB1–3) vs `mu_y` (NB4–12) [01.Q3]

**Context.** The playbook's rename (§3.1) was applied to NB4–12 only; NB6, also a population model, uses `mu_y`.

**Option.** Rename in NB1–3 (code change → re-run NB1–3, check NB1's slide figure) or accept the break at the first hierarchical model.

### S8. NB2 asks for criteria after showing the plot [02.Q2]

**Context.** NB2 §2.2 plots, §2.3 recalls criteria (then a `given` cell restates them); same at §4.2/§4.3. NB1 states criteria first ("Before examining the plot…").

**Option.** Move the two plot cells after the criteria (markdown reorder, no re-run). Also decide whether the recall-then-restate pattern stays.

### S9. Order of sensitivity vs posterior predictive check [01.Q4]

**Context.** NB1: sensitivity (§6) then PPC (§7). NB2, NB3, NB6, NB7: PPC then sensitivity.

**Option.** Align NB1 with the others or vice versa. For NB1 this is a section swap; neither section's results depend on the other, so the outputs stay valid, though execution counts would be out of order until the next re-run.

### S10. Small code inconsistencies [01.Q5, 01.Q7, 07.Q4, 04.Q5, 04.Q8]

- `plot_population(dt, var, group)` vs `plot_participants(dt, group, var)` argument order.
- NB1's `plot_dist` calls omit `point_estimate="mean"` (default is mean; visual only).
- NB7 asks students to read HDIs off plots because the summary rounds to 2 decimals; `round_to=3` would avoid it.
- NB4 §7.3 (`coords`) belongs with §8.3, where `coords` is first used.
- NB4's 13 incremental model prints (now informative, F5) — keep all, or keep 3–4.

### S11. Tag-format variants [02.Q4, 04.Q6]

**Context.** Some `exercise-question`+`given-answer` cells contain the answer inline (NB4 §1.4, §3.1, §5.5, §6.9); NB2 §5.1 is a question heading tagged only `given`. NB1's form is a question cell plus a separate `given` cell. Self-work generation is unaffected.

**Option.** Normalize or leave.

### S12. Committed outputs with foreign paths and unexplained warnings [01.Q1, 07.Q3, 12.Q4]

**Context.** NB1's first cell shows a Windows `No module named pip` error; NB7's sampling shows an unexplained `RuntimeWarning: overflow`; NB7/NB12 warnings include agent scratch-directory paths. Clears on re-run in Colab (NB7's warning may recur).

---

## Part 4 — Infrastructure

### I1. Runtime of NB10 and NB11
Sampling cells take 339 s and 292 s in the recorded runs (NB9: 33 s; most others < 10 s). Plan for this in class or reduce draws for the failure demos.

### I2. `pandas==2.2.3` pin vs `AGENTS.md`
Every notebook pins pandas. `AGENTS.md` says not to freeze pandas unless fresh-Colab testing shows it is needed, and lists only PyMC/ArviZ as course-wide pins. Either document why pandas is pinned in `AGENTS.md`, or remove the pin (re-test in Colab).

### I3. Playbook and revision logs
`REVISION_PLAYBOOK.md` contradicts itself on heading style (§3.8 vs §3.11) and encodes decisions made by agents (e.g. naming, `target_accept` policy) that your answers here may override. Decide whether it and `sleep/revision_logs/` stay in the repository, and update the playbook with your decisions if it stays.

### I4. Re-execution after decisions
Most S-items and several P-items change code and require re-running notebooks. Re-running in a different environment changes posterior numbers slightly (documented in `known_issues_in_01-05.md`), so every quoted number in a re-run notebook must be re-checked against its new output, and cross-notebook quotations (e.g. NB9, NB11, NB12 quote NB5/NB9 values) re-checked too.
