# Sleep notebooks — review decisions

**How to use this file.** Each item ends with a `Decision:` line. Replace `_` with a letter from the options, your own instruction, or `skip`. Leave anything you don't want to decide yet as `_`. Upload the edited file back to the conversation and I'll implement it.

- IDs match `2_review_consolidated.md` (full context) and, through it, `1_review_by_notebook.md` (per-notebook detail).
- ⚠ **re-run** = the change touches code, so the notebook must be re-executed and every quoted number re-checked.
- "Book" = Chapter 17 of `Bayesian-Workflow.pdf`, plus the online case-study code for NB8–11 (not in the printed chapter).

Already done on this branch (commit `3a48fa8`): 14 mechanical fixes, listed in the appendix with a keep/revert line each.

---

## Tier 1 — Shape of the NB9–NB12 arc (decide first; other items depend on these)

### P1 · NB10's "naive" priors are the book's own priors · NB10
**Issue.** NB10 calls `Normal(0, 5)` on `log sd_y` and `log nu`, and `Exponential(scale=5)` on `sd_log_sd_y`, "the kind of prior written by default rather than by thinking". These are exactly the priors the book uses for its *informed* ex-Gaussian model, which brms fits fine. The book's "default priors" section teaches the opposite of NB10: defaults barely matter except for the tail. File name (`default_priors`) and title ("Priors that ignore the log link") also disagree.
**Options.**
- A. Keep the content; reframe honestly ("the book uses these priors in brms; here is what they imply in ms, and what happens in PyMC"); retitle/rename to match.
- B. Rebuild as the book's lesson: fit with Bambi's default priors and show they barely matter except for `nu`.
- C. Drop NB10 (its lesson is also in NB6 §1 and NB8 §1.7; see P5).

**Recommend.** A, unless P5 leads you to C.
**Decision:** _

### P2 · NB10's sampling failure depends on PyMC internals · NB10
**Issue.** §4.5 explains the failed fit through PyMC 6.3.2's switch to a Gaussian formula when `nu < 0.05·sd_y`. The prior-predictive failure (§2) is robust; the sampling failure and its explanation could change with any PyMC release, and the explanation is far below the course's level.
**Options.**
- A. Keep §2; cut §3–4 to the one durable lesson: zero divergences is not a clean bill of health (max tree depth, R-hat, ESS still fail).
- B. Keep as is.

**Recommend.** A.
**Decision:** _

### P3 · The ex-Gaussian tail is barely identified · NB9 (NB10, NB11)
**Issue.** Posterior `nu` ≈ 7 ms (90% HDI 3.7–11) vs prior median 50 ms; its lower end is set by the prior. The reason — each data point is a session *average*, so single-trial skew is averaged away — appears only after the fit (§4.5). NB9 has no sensitivity check, although this is the one parameter where the prior matters (the book's point too). NB10–11 fail because of this parameter.
**Options** (combinable).
- A. Add power-scaling on `nu` to NB9. ⚠ re-run
- B. Move the "session averages" point into the tail-prior question (§1.12).
- C. In NB11, make only the tail prior flat (currently `mu_b0`, `mu_b1`, `mu_log_sd_y` are flat too), so the failure has one visible source. ⚠ re-run

**Recommend.** A + B; C if NB11 stays.
**Decision:** _

### P4 · NB11 text is tied to one run, and very heavy · NB11
**Issue.** The text hard-codes chain 3 as stuck, 1,488 divergences, `log_nu` stopping at −372 from floating-point underflow; §3.4's solution selects chains `[0, 1, 2]` by index. The notebook itself says 40% of chains got stuck across ten test runs, and the README tells instructors to re-run in Colab first — which will likely make the text wrong. The underflow/NaN/step-size explanation is far beyond a short course. Worth keeping whatever happens: §1.5 (no prior predictive check is possible with a flat prior) and §3.7 (a PPC can't reveal that the posterior doesn't exist).
**Options.**
- A. Rewrite generically (describe what to look for, select chains by a computed criterion); cut floating-point detail to one sentence.
- B. Keep as an optional/advanced notebook with a "your run will differ" banner.
- C. Drop NB11; move §1.5 and §3.7 into NB10 or NB9.

**Recommend.** A (or C if P5 shortens the arc).
**Decision:** _

### P5 · Length of the NB6–NB11 arc · NB6–NB11
**Issue.** "A vague-looking log-scale prior is extreme on the natural scale" is taught three times (NB6 §1, NB8 §1.7, all of NB10). NB10 and NB11 each sample for ~5 minutes. Six notebooks after NB5 is long for a short course; the book covers NB10–11's content in two paragraphs.
**Options.**
- A. Keep all 12; mark NB10–11 as optional/self-study.
- B. Merge NB10 into NB9 as one "what if we hadn't translated the priors?" section; keep NB11 short (P4).
- C. Keep as is.

**Recommend.** Your call on the intended stopping point; A is the least work.
**Decision:** _

### P6 · The course never compares its likelihoods predictively · NB12 (NB7–9)
**Issue.** NB6–9 build lognormal and ex-Gaussian models; NB12 introduces LOO but compares only Gaussian vs Student-t. `pm.LogNormal` and `pm.ExGaussian` are defined on `y`, so NB7/NB8/NB9 fits can go into `azs.compare` directly (no Jacobian). Also unmade: NB9 found nearly symmetric scatter, NB12 found heavy *two-sided* tails driven partly by unusually *fast* days, which a one-sided exponential tail cannot produce — one sentence explains both.
**Options** (combinable).
- A. Add the NB7/NB9 models to NB12's comparison. ⚠ re-run (adds fitting time)
- B. Add one question linking NB9's short tail to NB12's `nu` ≈ 2.6.
- C. Leave.

**Recommend.** B at least; A if class time allows.
**Decision:** _

---

## Tier 2 — Content within notebooks

### P7 · NB3's headline vs its own numbers · NB3
**Issue.** The Student-t prior moves `b1` to 8.16 (NB2: 2.29; NB1: 11.33), yet prior sensitivity *rises* (b1 0.393 vs 0.367). Text: conflict remains, prior is "less brittle". Book, same prior: "similar to what we had originally obtained" — tails let the data win. The density plot (x from −6 to 6) hides the tails where the difference lies.
**Options** (combinable).
- A. Reframe the headline around robustness (as the book does), keeping the psense result.
- B. Add one sentence on why power-scaling stays high when the posterior sits in the prior's tail.
- C. Replot densities on a log axis or x-range to ~15, marking the posterior mean. ⚠ re-run
- D. Close with a three-row `b1` table (NB1/NB2/NB3).

**Recommend.** B + C + D; A is your pedagogical call.
**Decision:** _

### P8 · NB2 never shows what the conflict does to the estimates · NB2
**Issue.** Under the tight prior, `b1` = 2.29 (NB1 11.33), and `b0` (268 → 300 ms) and `sd_y` (51 → 55 ms) shift to compensate — the mechanism behind the failed PPC and why unchanged priors get flagged. Not discussed.
**Options.** A. Add one question comparing the summary with NB1's. B. Leave.
**Recommend.** A.
**Decision:** _

### P9 · NB4: partial pooling named but not shown · NB4
**Issue.** §6.9 defines partial pooling; nothing displays it. `sd_y` falling 51 → 30 ms is plotted but not interpreted.
**Options** (combinable).
- A. Add a small shrinkage plot: per-participant raw estimate vs posterior `b0` mean, `mu_b0` marked. ⚠ re-run
- B. Add one question on the `sd_y` drop.

**Recommend.** A + B.
**Decision:** _

### P11 · The ~150 ms baseline prior on the log scale · NB6–NB8
**Issue.** NB6's `b0 ~ Normal(5, 0.55)` (book's derivation) centers the median RT at ~150 ms; NB6 calls the prior predictive "implausibly fast" and proceeds. NB7–8 inherit it and repeat the caveat. The book later uses `Normal(5.5, 0.55)`.
**Options.**
- A. Keep in NB6 as the lesson; re-center on log 250 ≈ 5.5 from NB7 on, as a visible revision. ⚠ re-run NB7–8
- B. Keep everywhere.

**Recommend.** A.
**Decision:** _

### P12 · NB8 builds a prior from a fit to the same data · NB8
**Issue.** The typical residual-scale prior is centered on NB7's posterior `sd_y` ≈ 0.08, with a paragraph defending the double use. It's the only data-informed prior in the course; NB8 has no sensitivity check.
**Options.**
- A. Re-elicit from subject knowledge ("day-to-day variation of a few % to ~20%" — nearly the same numbers). ⚠ re-run (text mostly)
- B. Keep as a deliberate discussion and add power-scaling. ⚠ re-run

**Recommend.** A.
**Decision:** _

### P10 · Residual-scale prior when a level is added · NB4, NB5, NB7, NB12
**Issue.** NB4 keeps `sd_y ~ Exponential(scale=50)` and adds `sd_b0 ~ Exponential(scale=25)` with no rationale. The book splits 50 into 25 + 25 and flags "should the prior on sigma change?" as a discussion point. NB5/NB7/NB12 follow NB4.
**Options.**
- A. Adopt the split, with one question on why; propagate. ⚠ re-run NB4, 5, 7, 12
- B. Keep; add one sentence of rationale for 25.

**Recommend.** B (cheap). A if you want the teaching point.
**Decision:** _

### P14 · NB5 details · NB5
**Issue.** (1) Nearly all code is `given`; student work is naming and copying plot calls — confirm the load. (2) `change_7` is forest-plotted in the posterior (§4.11) but no question uses it. (3) `b1` meant "the shared slope" in NB4 and now means "a participant's slope"; not flagged until NB12.
**Options.** A. Leave (1); add a question on the `change_7` plot; add one sentence on `b1` in §1.4. B. Also move some code from `given` to `solution`.
**Recommend.** A.
**Decision:** _

### P15 · How notebooks end · all
**Issue.** NB1–3, NB5: no summary. NB4: "What limitation remains?" (sets up NB5). NB6–12: `## Summary` Q&A. Your recorded instruction: summarize the notebook's own results, don't preview.
**Options.**
- A. Add a short summary Q to NB1–5 (NB4's §8 can become it).
- B. Remove summaries from NB6–12.
- C. Leave.

**Recommend.** A. Also say whether NB4 §8 counts as a result (keep) or a preview (rewrite).
**Decision:** _

### P13 · No intercept–slope correlation (LKJ) · NB5, NB7–12
**Issue.** The book's varying-slope models include an LKJ correlation prior (a real part of §17.2). Ours use independent hierarchies; NB5 §1.1 says so; README calls it deliberate.
**Options.** A. Keep. B. Add to NB5 (and decide about later notebooks).
**Recommend.** A.
**Decision:** _

---

## Tier 3 — Presentation and style

### S2 + S3 · Prior-predictive plots dominated by single draws, and the answers that explain them · NB6–NB10
**Issue.** The mean line on skewed prior predictives spikes/zigzags from single extreme draws; shared y-axes stretch to 5,000 ms (NB7) or 10⁵¹ ms (NB10). Each notebook then spends a paragraph on specific panels (NB7 §2.5–2.6, NB8 §2.7, NB9 §2.7, NB10 §2.4), correct only for the committed random draws.
**Options.**
- A. For prior-predictive plots only: fixed y-range (e.g. 0–1,000 ms) and no/de-emphasized mean line; cut the forensic answers to one sentence each. ⚠ re-run NB1–10
- B. Keep plots; cut the forensic answers.
- C. Leave.

**Recommend.** A.
**Decision:** _

### S1 · Answer length from NB6 on · NB6–NB12
**Issue.** NB1–3 answers: one line to three sentences. NB6–12: typically 4–8 sentences with cross-references to earlier questions; some given-answers ~250 words. Playbook asks for "a verdict word plus 1–3 sentences"; students must write these in the self-work versions.
**Options.** A. Trimming pass on NB6–12 (text only), after Tier 1 decisions. B. Leave.
**Recommend.** A.
**Decision:** _

### S5 · Unlabeled participant panels and trace colours · NB1–NB11
**Issue.** 18 untitled panels; from NB7 on, answers locate participants as "middle row, first". Three-participant trace plots use three unlabeled colours. NB12's helper already titles panels.
**Options.** A. Add titles to `plot_participants`; label trace colours. ⚠ re-run NB1–11 (NB1's slide figure unaffected — it doesn't use the helper). B. Leave.
**Recommend.** A (can go with S2's re-run).
**Decision:** _

### S4 · Claims based on runs students can't see · NB8–NB12
**Issue.** E.g. "with the default `target_accept`… occasionally reports a divergence" (NB8), "more than a dozen divergences" (NB9), "in ten test runs…" (NB11), "in test runs with other seeds…" (NB12). Unverifiable; playbook requires confirming divergences before raising `target_accept`.
**Options.** A. Drop the specifics; state once "in our testing, default settings produced divergences". B. Show evidence (extra fits; adds runtime). C. Leave.
**Recommend.** A.
**Decision:** _

### S6 · Heading and title style · all
**Issue.** NB1: `## 2. Prior predictive check — What does the model imply…?`; NB4–12: `## 3. Prior predictive check`; NB2–3 mixed. NB2/NB3 titles are questions, others noun phrases. The playbook's rule (NB5 style) contradicts its own statement that NB1–3 are the style model.
**Options.** A. Short noun phrases everywhere (change NB1–3). B. "Stage — question?" everywhere (change NB2–12). C. Leave.
**Recommend.** A (fewer edits; markdown only).
**Decision:** _

### S7 · `mu` (NB1–3) vs `mu_y` (NB4–12) · NB1–3
**Options.** A. Rename to `mu_y` in NB1–3. ⚠ re-run NB1–3 B. Leave; the name changes at the first hierarchical model.
**Recommend.** A if NB1–3 are re-run for other reasons; otherwise B.
**Decision:** _

### S8 · NB2 asks for criteria after showing the plot · NB2
**Issue.** §2.2/§4.2 plot before §2.3/§4.3 recall the criteria; each recall is followed by a `given` cell restating it (in the self-work version the blank sits right above its answer).
**Options.** A. Move the plots after the criteria (no re-run). B. Also drop the restating `given` cells. C. Leave.
**Recommend.** A; B is your call.
**Decision:** _

### S9 · Sensitivity before or after the PPC · NB1
**Issue.** NB1 does sensitivity (§6) before PPC (§7); NB2, NB3, NB6, NB7 do PPC first.
**Options.** A. Swap NB1's sections (no re-run needed). B. Leave.
**Recommend.** A.
**Decision:** _

### S10 · Small code inconsistencies
- a. `plot_population(dt, var, group)` vs `plot_participants(dt, group, var)` — unify order. ⚠ re-run NB1, NB6
- b. NB1's `plot_dist` calls lack `point_estimate="mean"` (visually identical).
- c. NB7 §4.2/§4.4 read HDIs off plots because the summary rounds to 2 decimals → `round_to=3`. ⚠ re-run
- d. NB4 §7.3 (`coords`) → move next to §8.3 where it's used.
- e. NB4's 13 incremental model prints (now informative) → keep all, or keep 3–4.

**Decision (per letter, e.g. `a yes, b yes, c no, d yes, e keep all`):** _

### S11 · Tag-format variants · NB2, NB4
**Issue.** Some question cells contain their own answer (NB4 §1.4, §3.1, §5.5, §6.9); NB2 §5.1 is a question tagged only `given`. No effect on self-work generation.
**Options.** A. Normalize to NB1's form. B. Leave.
**Recommend.** B.
**Decision:** _

### S12 · Stale outputs with foreign paths or unexplained warnings · NB1, NB7, NB12
**Issue.** NB1's first cell shows a Windows `No module named pip` error; NB7 sampling shows an unexplained overflow warning; NB7/NB12 warnings contain agent scratch paths. Cleared by re-running.
**Options.** A. Clear by re-running when those notebooks are next re-run; add one sentence on NB7's warning if it recurs. B. Leave.
**Recommend.** A.
**Decision:** _

---

## Tier 4 — Infrastructure

### I1 · Runtime of NB10/NB11 (~5 min sampling each)
**Options.** A. Accept; note it in the notebooks/README. B. Reduce draws/tuning for the failure demos (diagnostics still fail). C. Moot if P5 drops them.
**Decision:** _

### I2 · `pandas==2.2.3` pinned in every notebook, against `AGENTS.md`
**Options.** A. Keep; add the reason to `AGENTS.md`. B. Remove; re-test in fresh Colab.
**Decision:** _

### I3 · `REVISION_PLAYBOOK.md` and `sleep/revision_logs/`
**Issue.** Agent-written process documents; the playbook contradicts itself on headings (§3.8 vs §3.11) and encodes choices your answers here may override.
**Options.** A. Keep; update the playbook with these decisions. B. Remove both from the repo (history keeps them). C. Leave.
**Decision:** _

### I4 · Re-execution policy
**Issue.** Items marked ⚠ require re-running. Re-running here changes posterior numbers slightly, so every quoted number must be re-checked, including cross-notebook quotes (NB9, NB11, NB12 quote NB5/NB9 values).
**Options.** A. I re-run affected notebooks here with the pinned stack and re-check all numbers; you do a final fresh-Colab run before teaching. B. Re-run only what's necessary; you re-run in Colab.
**Decision:** _

---

## Appendix — Fixes already made (keep or revert)

Write `revert` next to any you don't want. Details in `2_review_consolidated.md`, Part 1.

| ID | Change | Keep/revert |
|---|---|---|
| F1 | NB10 self-work Colab badge pointed at the solved notebook → fixed | keep |
| F2 | NB1 §5.3: 257–283 → 255–281 ms (matches output) | keep |
| F3 | NB4 §6.12: NB1 HDI 7.94–14.07 → 8.20–14.46; table 6.26 vs 3.59 | keep |
| F4 | NB4 §5.4, §5.10, §6.13: hedged answers → actual results (§6.13 gains one sentence on `sd_y` 51 → 30 ms) | keep |
| F5 | NB4/NB5: `print(model)` → `print(model.str_repr())`, outputs regenerated; NB4 §2.1 answer updated | keep |
| F6 | NB5 §3.3, §4.3, §4.6: stale ESS/HDI numbers corrected | keep |
| F7 | NB5 §7.4: removed sentence previewing NB6 | keep |
| F8 | NB1: `### Data` → `## Data` | keep |
| F9 | NB1/NB2: setup cells tagged `given` | keep |
| F10 | NB2: removed unused `plot_population` | keep |
| F11 | NB3: untitled question folded into §1.2 | keep |
| F12 | NB1–5 self-work: stripped execution/widget metadata | keep |
| F13 | "orange mean line" → `C1` (pink) in NB1/NB2 comments and README | keep |
| F14 | README: `pm.ExGaussian` `mu` = Gaussian location; brms `mu` = mean | keep |
