# Sleep notebooks review — pass 1: notebook by notebook

Scope: the 12 solved notebooks in `sleep/solved/` (and, where it matters, their self-work twins in `sleep/`), read top to bottom against `AGENTS.md`, `sleep/REVISION_PLAYBOOK.md`, `sleep/solved/README.md`, Chapter 17 of `Bayesian-Workflow.pdf`, and the online case-study source (`avehtari/Bayesian-Workflow`, `sleep_study/sleep_study.R`, which contains the distributional, ex-Gaussian, default-prior, flat-prior, and LOO sections that the printed chapter does not).

This is the raw, sequential record. Pass 2 (`2_review_consolidated.md`) merges cross-notebook issues; pass 3 (`3_review_decisions.md`) is the one to edit.

## Conventions used here

- **Fixed** — changed on branch `claude/sleep-notebooks-review-m0u2y9` (commit `3a48fa8`). Obvious errors or clear misalignments with a written convention. Listed so you can veto any of them.
- **Flag** — not changed; needs a decision. Tagged with a rough weight: **[high]** changes what students learn or can break a lesson; **[med]** noticeable quality/consistency issue; **[low]** polish.
- Section/question numbers are the notebook's own (`§2.4`). Cell numbers are 0-based indices in the solved notebook *before* the fixes.
- Authorship weight (from your note): NB1, NB4 = most authoritative; NB2, NB3 = reviewed; NB5 = barely reviewed; NB6–12 = agent-written.

## How the fixes were validated

- Text-only fixes: numbers checked against the committed outputs in the same notebook.
- `print(model)` → `print(model.str_repr())` (NB4, NB5): the new outputs were produced by executing the model-building cells under the pinned stack (`pymc==6.3.2` etc., Python 3.12, `uv sync`). The sampling cells were **not** re-run, so every posterior number in NB4/NB5 is unchanged. The NB4 §6.12 table output was recomputed from the unchanged summary values (6.26 and 3.59).
- Self-work notebooks: re-checked mechanically (every non-`solution` cell identical to solved except the badge; every `solution` cell a placeholder; no outputs). All notebooks pass `nbformat.validate`.
- Nothing was re-sampled. Outputs elsewhere are as committed.

---

## NB01 — Linear baseline (instructor-authored; most authoritative)

### Fixed

- **01.F1** §5.3 answer said "**257–283 ms**"; the committed summary gives a 90% HDI of 254.82–281.49. Now "**255–281 ms**". (Already listed in `revision_logs/_shared/known_issues_in_01-05.md`.)
- **01.F2** `### Data` → `## Data`. Every other notebook uses `## Data` (playbook §3.7). Side benefit: `AGENTS.md` names slide figures after the enclosing `##` section; the data figure is saved as `01_linear_baseline_data.svg`, which is now consistent with the rule (previously the enclosing `##` section was "Setup"). The figure file name and the slide reference (`Slides/slide_deck.typ:861`) are unchanged.
- **01.F3** The 15 setup cells (badge through plotting helpers) had no tags; tagged `given` (playbook §2: "an untagged cell is an error"). No effect on content; same change in the self-work copy.
- **01.F4** Code comment "orange mean line" → "C1 mean line (pink in the arviz-variat style)". Under `azp.style.use("arviz-variat")`, `C1` renders pink (visible in every participant plot; NB12 already calls it "pink").

### Flags

- **01.Q1 [low]** The committed `%pip install` output contains `D:\Repositories\BayesShortCourse\tmp\colabenv\Scripts\python.exe: No module named pip` — an artifact of a local Windows run, not Colab. Harmless, but a student opening the solved notebook sees an error message in the first code cell. Clears on the next re-run.
- **01.Q2 [med]** Section headings use "Stage — question?" (`## 2. Prior predictive check — What does the model imply before seeing the outcomes?`). NB4–12 use short noun phrases (`## 3. Prior predictive check`), which the playbook (§3.8) made the rule, apparently without noticing that NB1 — the authoritative notebook — does the opposite. NB2/NB3 mix both styles. Needs one course-wide decision.
- **01.Q3 [med]** Naming: NB1–3 call the linear predictor `mu`; NB4–12 call it `mu_y` (including NB6, which is also a population-level model). Playbook §3.1 prescribes `mu_y` everywhere, but NB1–3 were never renamed. Renaming NB1–3 is a code change (re-execution of three notebooks, and NB1's slide figure is unaffected).
- **01.Q4 [low]** Workflow order: NB1 does prior sensitivity (§6) *before* the posterior predictive check (§7); NB2 does PPC (§4) before sensitivity (§5); NB3 likewise PPC before sensitivity; NB6/NB7 also PPC before sensitivity. `AGENTS.md`'s workflow list has PPC at step 7 and does not list sensitivity. NB1 is the odd one out.
- **01.Q5 [low]** Helper signatures are inconsistent: `plot_population(dt, var, group="posterior")` vs `plot_participants(dt, group, var)`. Students calling both (NB1, NB6) must remember different argument orders.
- **01.Q6 [med]** Participant panels have no participant labels (the same helper is used in NB1–11). This is minor in NB1 but becomes a real problem later, where answers refer to "participant 333's panel (middle row, first)" and students must count panels against a sorted ID list they never see printed alongside the plot. NB12's helper does title its panels (`"title": True`), so the fix is known.
- **01.Q7 [low]** NB1 calls `azp.plot_dist` without `point_estimate=`; NB4+ pass `point_estimate="mean"`. The default is already `mean` (`arviz_base.rcParams["stats.point_estimate"]`), so the plots are the same; it is only a visible inconsistency in the code students copy.
- **01.Q8 [low]** Book comparison, FYI: the chapter uses `normal(200, 100)` for the *uncentered* intercept and `normal(250, 100)` for the *centered* one (day 3.5), explicitly arguing that day 0 should be lower. NB1 puts `Normal(250, 100)` on the day-0 intercept. Immaterial to the posterior; only worth knowing if students read the chapter alongside.
- **01.Q9 [med]** NB1 has no closing summary; NB6–12 all end with a `## Summary` section. See the cross-notebook item on closing sections (NB4 closes with a forward-looking "What limitation remains?").

---

## NB02 — Informative (tight) slope prior (reviewed)

### Fixed

- **02.F1** `plot_population` was defined but never called (the README says it should be defined "only in notebooks that call it"; the playbook names NB2 as the example not to repeat). Removed the helper and its heading; reworded the helper intro ("There are two…") to match.
- **02.F2** Setup cells tagged `given` (as 01.F3); colour comment as 01.F4.

### Flags

- **02.Q1 [low]** The title is a question ("Can the workflow reveal an inappropriate prior?"); NB1 and NB4–12 titles are noun phrases ("Linear baseline", "Varying intercepts"). NB3's title is also a question.
- **02.Q2 [med]** Criteria are asked for *after* the plot: §2.2 plots the prior predictive, §2.3 asks for the criteria; §4.2 plots the PPC, §4.3 asks for the criteria. NB1 (§2.4, "Before examining the plot…") and the playbook (§1.2, "State criteria before checking them") put criteria first. Swapping is a markdown-only reorder. Related known issue: each recall question (`solution`) is immediately followed by a `given` cell restating the same criteria, so in the self-work notebook the blank sits directly above its own answer.
- **02.Q3 [high]** No interpretation of the posterior. The notebook's point is prior–data conflict, but it never shows *what the conflict does to the estimates*: `b1` = 2.29 (NB1: 11.33), `b0` rises from 268 to 300 ms and `sd_y` from 51 to 55 ms to compensate. That compromise is the mechanism behind the failed PPC and the psense flags on all three parameters, and it is the book's own illustration (book: posterior mean 3.8 under `normal(0, 1)`). One short question comparing the summary with NB1's would carry it.
- **02.Q4 [low]** §5.1 is a `### ` question-style heading tagged only `given`. Elsewhere this pattern is `exercise-question` + `given-answer` followed by a `given` cell. No effect on the generated self-work notebook.
- **02.Q5 [low]** §5.4's answer says conflict is flagged but not that `b0` and `sd_y` are flagged too; that the conflict in one prior propagates to parameters whose priors were unchanged is a teachable point (and connects to 02.Q3).

---

## NB03 — Heavy-tailed slope prior (reviewed)

### Fixed

- **03.F1** Cell 13 was an `exercise-question` with no `###` heading ("Where is the difference between the two priors most important?"), sitting after the given plot. Folded into §1.2's prompt and deleted; §1.2 is now question → given plot → solution, matching the scheme. Same change in the self-work copy.

### Flags

- **03.Q1 [high]** What is the lesson? The notebook concludes (§5.4) that the heavy-tailed prior "did not eliminate the prior–data conflict". But the psense numbers are *higher* than NB2's (`b1` prior sensitivity 0.393 vs 0.367; `b0` 0.335 vs 0.191), which a student will read as "worse", while the text says the prior became "less brittle". The book draws a different lesson from the same prior (`t_7(0, 1)`): the posterior (mean 9.2) is "similar to what we had originally obtained", i.e. the tails let the data win. NB3's posterior (`b1` 8.16, 90% HDI 4.26–12.10) is closer to NB1's 11.33 than to NB2's 2.29. Needs a decision on the intended message, and probably one sentence explaining why power-scaling sensitivity stays high when the posterior sits in the prior's tail (scaling the prior changes the tail weight a lot, so the posterior moves).
- **03.Q2 [med]** The Normal-vs-t density plot spans −6 to 6 ms/day on a linear density axis, so the tails — where the priors differ and where the posterior ends up (~8) — are invisible. A log-density axis, or an x-range to ~15 with NB1/NB3 posterior means marked, would show the point the notebook is making.
- **03.Q3 [med]** §4 answers are qualitative ("much better job"). A three-row comparison (`b1` posterior under NB1/NB2/NB3 priors) would make the NB1–3 arc concrete and could serve as NB3's closing.
- **03.Q4 [low]** The Data cell omits NB1/NB2's sentence about the intercept being a prior on baseline RT; heading uses "prior–data" (en dash) where NB2 uses "prior-data".
- **03.Q5 [low]** No closing summary (see 01.Q9).

---

## NB04 — Varying intercept (instructor-authored; most authoritative, "not well proofread")

### Fixed

- **04.F1** `print(model)` was called 13 times and §2.1 taught it as "the textual representation" of the model; in PyMC 6.3.2 it prints only `<pymc.model.core.Model object at 0x…>`. Replaced with `print(model.str_repr())` and regenerated those outputs, which now show the model growing node by node (e.g. `b0 ~ Normal(mu_b0, sd_b0)`). §2.1's answer now reads "`print(model.str_repr())`. (Plain `print(model)` shows only the object's memory address.)" Note: the first print (empty model) outputs a blank line.
- **04.F2** §6.12 hard-coded NB1's slope HDI as 7.94–14.07; NB1's output is 8.20–14.46. Question text and code updated; the width table output is now 6.26 vs 3.59 (was 6.13 vs 3.59).
- **04.F3** Hedged answers replaced with actual results:
  - §5.4 "Yes, provided the executed notebook shows…" → "Yes. There are no divergences, every R-hat is 1.00, every bulk and tail ESS is above 2,000, and the traces show well-mixed chains." (min bulk ESS 2,022 for `b1`.)
  - §5.10 "Yes, provided…" → "Yes. For participants 308, 337, and 372, R-hat is 1.00, every bulk and tail ESS is above 3,000, and the traces mix well." (trace plot inspected.)
  - §6.13 "In the executed notebook, compare…" → names the varying-intercept model, quotes 3.6 vs 6.3 ms/day, and adds one sentence of explanation grounded in the output (`sd_y` fell from about 51 to about 30 ms). **The explanatory sentence is new content — veto if unwanted.**

### Flags

- **04.Q1 [med]** Priors when adding a level. `sd_y` keeps NB1's `Exponential(scale=50)` and the new `sd_b0` gets `Exponential(scale=25)` with no rationale ("Suppose we use… 25"). The book deliberately *splits* NB1's 50 into 25 + 25 (`sigma` and `tau_0` both `exponential(1/25)`), and the online source lists "shall the prior on sigma change now that we add more terms?" as a discussion point. NB5, NB7, NB12 inherit the same choice. Either adopt the split (with one question on why) or state the reason for 25.
- **04.Q2 [high]** Partial pooling is defined (§6.9, given-answer) but never shown. The book's Figure 17.7 shows it by plotting separate per-person estimates against the multilevel ones. A minimal version here: participant sample means at day 0 (or per-participant OLS intercepts) vs posterior `b0` means, showing shrinkage toward `mu_b0`. Without it, "partial pooling" is a vocabulary item.
- **04.Q3 [med]** `sd_y` drops from 51 (NB1) to 30 ms — the key numeric consequence of the hierarchy — and is plotted (§6.6) but not interpreted. (Now mentioned in passing in the §6.13 fix.) A dedicated question would teach "residual variance was hiding between-person variance".
- **04.Q4 [med]** §8 "What limitation remains?" ends the notebook by setting up NB5 (parallel lines). The playbook (§3.10) records your instruction that notebooks should close by summarizing their own results, not previewing the next. This is arguably a result (the model's own limitation), so it may be fine — your call, and whichever way it goes should be applied consistently.
- **04.Q5 [low]** §7.3 asks which argument selects participants (`coords`) right before §7.4, which doesn't use it; `coords` is first used in §8.3. Move §7.3 into §8.
- **04.Q6 [low]** Tag-format variant: §1.4, §3.1, §5.5, §6.9 are `exercise-question` + `given-answer` with the answer inside the same cell; NB1's form is question cell + separate `given` cell. No effect on self-work generation.
- **04.Q7 [low]** `azp.plot_trace_dist(..., coords=…)` for three participants draws three colours with no legend, so students cannot tell which participant is which (same in NB5, NB7–10).
- **04.Q8 [low]** 189 cells. The playbook justifies this as the first hierarchical model; noting only that the 13 incremental `print`s are a large share of it. Now that they print something useful, they may be worth keeping — or cutting to three or four.

---

## NB05 — Varying intercept and slope (barely reviewed)

### Fixed

- **05.F1** Stale numbers: §4.3 `mu_b1` HDI "7.94–14.71" → "8.07–14.62"; §4.6 `sd_b1` HDI "4.74–10.06" → "4.61–9.96"; §3.3 "ESS … comfortably above 2,800" → "2,700" (`sd_b1` tail ESS is 2,718).
- **05.F2** `print(model)` → `print(model.str_repr())` (as 04.F1).
- **05.F3** §7.4's last sentence previewed NB6 ("Notebook 6 can investigate…"). Removed per the closing-section instruction (playbook §3.10). The rest of the answer is unchanged.

### Flags

- **05.Q1 [med]** Scaffolding: the model, prior draws, fit, diagnostics, and PPC are all `given`; student work is naming variables and copying `plot_dist`/`plot_forest` calls. That is the stated NB5-style ("read a model"), but the result is a light notebook for the first model that has everything the chapter's multilevel section is about. Confirm the load is what you want.
- **05.Q2 [med]** No intercept–slope correlation (book: LKJ prior, a large part of §17.2 and a discussion point in the source). The README calls this a deliberate simplification. Either keep and say *once* in the notebook why (done in §1.1), or add the correlation. Affects NB5, NB7–12.
- **05.Q3 [med]** `change_7` is introduced (§1.11 asks its units) and forest-plotted in the prior (§2.2) and posterior (§4.11), but no question interprets the posterior plot. `AGENTS.md`: every Deterministic should answer a stated question. Add a one-line question (e.g. "Which participants' 90% HDI for the 7-day change excludes zero?") or drop the posterior plot.
- **05.Q4 [low]** `b1` changes meaning between NB4 (shared slope) and NB5 (participant slopes; `mu_b1` is the population value). NB12 §1.5 explains this later; a one-sentence note in NB5 §1.4 would help at first encounter.
- **05.Q5 [low]** No closing summary (see 01.Q9).
- **05.Q6 [info]** Verified against the plot: §2.5's claim that 90% prior-predictive bands reach below zero late in the week is correct (several panels). NB6 builds its motivation on this.

---

## NB06 — Lognormal regression (agent-written)

### Flags

- **06.Q1 [high]** The log-scale baseline prior `b0 ~ Normal(5, 0.55)` (book's own choice, by quantile-matching 50–450 ms) centers the median at ~150 ms. The notebook says so candidly: prior predictive 50% bands "below about 150 ms on every day, below every observed reaction time: the prior's most probable reaction times are implausibly fast" (§2.8), then proceeds. The same prior is carried into NB7 and NB8, whose prior-predictive answers repeat the caveat. The book itself switches to `normal(5.5, 0.55)` for its distributional model. Options: keep (it is the book's teaching example of quantile matching's asymmetry), or re-elicit around log(250) ≈ 5.5 once the problem is seen, and carry that forward — which would shorten NB7/NB8 prior discussions.
- **06.Q2 [med]** Prior-predictive plots show a mean line that is dragged far above the 50% band by a few extreme draws (§2.9 needs a full paragraph to explain it; NB7 §2.5–2.6, NB8 §2.7, NB9 §2.7, NB10 §2.4 each spend a paragraph or more on spikes in specific panels). `AGENTS.md` requires the mean as point estimate, so the lever is display: e.g. clip the y-axis for prior-predictive plots, or omit the point estimate line on prior-predictive panels. Cross-notebook decision.
- **06.Q3 [med]** §5.6 compares the pooled ECDF with NB5's (hierarchical Gaussian), and has to explain the comparison isn't like-for-like. The like-for-like model is NB1 (population Gaussian), which has no ECDF check.
- **06.Q4 [med]** Answer length and density: many solution cells are 4–8 sentences with multi-step reasoning (§2.8, §2.9, §4.1). Playbook §1.4 asks for "a name, a bold term, or a verdict word plus 1–3 sentences". This pattern intensifies through NB12 (cross-notebook item).
- **06.Q5 [info]** Numbers checked against output: e^20 ≈ 5×10^8 ✓; age of universe ≈ 4×10^20 ms ✓; mean/median gap 1.5% at `sd_y`≈0.17 ✓; `b1` HDI 0.03–0.05 ✓.

---

## NB07 — Hierarchical lognormal (agent-written)

### Flags

- **07.Q1 [low]** Hyperpriors vs book: `sd_b1 ~ Exponential(scale=0.05)` (book `exponential(10)`, mean 0.1); `sd_y` keeps NB6's scale 1/3 (book halves it to 1/6 when adding the hierarchy, as in the Gaussian case). Internally consistent with NB4/NB5's choice not to split (04.Q1).
- **07.Q2 [med]** §2.5–§2.6 spend two long answers on two spikes in specific prior-predictive panels (participants 333 and 335), explaining which draw caused each. The explanation is correct for this run, but (a) the panels are unlabeled (01.Q6), (b) a re-run in Colab may move the spikes to other panels, and (c) the teaching point (heavy right tail of compounded multiplicative priors) takes one sentence.
- **07.Q3 [low]** The sampling output contains a `RuntimeWarning: overflow encountered in dot` (with an agent scratch path) that is never mentioned. Students will see it. Either say one sentence about it or accept.
- **07.Q4 [low]** §4.2 and §4.4 ask students to read HDIs off the plot "because the summary rounds to two decimals". Simpler: `round_to=3` in the summary (a code change → re-run).
- **07.Q5 [info]** Uses `prior_var_names` to power-scale only top-level priors, with a good explanation of why (§6.1). New relative to NB1–3/NB6; appropriate for a hierarchical model.

---

## NB08 — Distributional lognormal (agent-written)

### Flags

- **08.Q1 [high]** §1.8–§1.9 center the prior for the typical log residual scale on NB7's *posterior* estimate from the same data (`log(0.08)`), then defend it ("only the order of magnitude… it uses the same observations twice"). This is the one place in the course where the prior is taken from a fit to the same data. NB9 does the same job properly (elicited in milliseconds). Options: re-elicit from subject-matter reasoning (e.g. "day-to-day variation of a few to ~20%"), which gives essentially the same numbers without the double use; or keep as a deliberate discussion of data-informed priors.
- **08.Q2 [med]** `target_accept=0.9` with the claim that the default "occasionally reports a divergence". The notebook doesn't show this; students cannot verify it. Playbook §3.3 permits a higher `target_accept` only "after confirming default settings actually produce divergences, and explain the need in a Q&A". The Q&A is there; the evidence isn't. (Same pattern in NB9–11.)
- **08.Q3 [med]** §2.7 is a forensic answer about two single-day spikes (participants 351 and 371), including that a single draw would need to be "roughly 750–1,300 s long". High reading load, fragile to re-runs (see 07.Q2).
- **08.Q4 [low]** No prior-sensitivity check, although NB6 and NB7 have one and this notebook's new prior is the data-informed one (08.Q1) — the case where power-scaling is most informative.
- **08.Q5 [info]** The book's version (model 6) correlates the residual-scale effects with the mean-structure effects (`|S|`); ours are independent, consistent with 05.Q2.

---

## NB09 — Ex-Gaussian distributional (agent-written)

### Fixed (README, relevant here)

- **09.F1** `sleep/solved/README.md` said "`pm.ExGaussian(mu, sigma, nu)` matches the book's parameterization directly". It doesn't: brms's `exgaussian()` (used in the online case study) is parameterized by the **mean** of the whole distribution, while PyMC's `mu` is the Gaussian location (mean = `mu + nu`). The README now says this and notes the consequence (the book's mean-structure priors describe expected RT; ours describe the Gaussian location). NB9's own text ("PyMC's `pm.ExGaussian(mu, sigma, nu)` uses exactly this parameterization", referring to its own `g + e` description) is correct and unchanged.

### Flags

- **09.Q1 [high]** The tail is barely identified. Posterior `nu` ≈ 7 ms (90% HDI 3.7–11) against a prior median of 50 ms; §4.4 itself says the lower end is set by the prior. So the "ex-Gaussian" model is, in effect, NB8's distributional model with a Gaussian likelihood. That matters because NB10 and NB11 are built entirely on this weakly identified parameter. The book's corresponding point (online source, model 8): priors "barely matter… except for the skewness parameter". NB9 is the natural place to show that with power-scaling on `nu`, and it has no sensitivity section.
- **09.Q2 [med]** §4.5's insight — each observation is a session *average*, so single-trial RT skew is averaged away — is the scientific reason the tail is short. It only appears after the fit. Stating it when eliciting the 50 ms tail prior (§1.12) would make the prior and the result coherent rather than surprising.
- **09.Q3 [med]** `target_accept=0.99`; claims that the default gives "more than a dozen divergences", 0.95 "a few", and another seed "occasionally a single divergence" are not shown (08.Q2).
- **09.Q4 [med]** §2.7 forensic on participant 333's zigzag ("Gaussian standard deviation about 145 s") — same pattern as 07.Q2/08.Q3.
- **09.Q5 [low]** Answers average 4–6 sentences with cross-references to 3–4 earlier questions (06.Q4).
- **09.Q6 [info]** Numbers checked: prior mean of `nu` ≈ 50·e^{0.75²/2} ≈ 66 (text "about 64", from draws) ✓; `mu_b1` 8.0–14.6 ✓; `mu_b0` ≈ 260 = NB5's 268 − ~8 ✓.

---

## NB10 — "Priors that ignore the log link" / `exgaussian_default_priors` (agent-written)

### Fixed

- **10.F1** The self-work notebook's Colab badge pointed to `sleep/solved/10_exgaussian_default_priors.ipynb` (students opening it from Colab would get the solutions). Now points to `sleep/10_…`.

### Flags

- **10.Q1 [high]** The three "naive" priors are exactly the book's own priors for its *informed* ex-Gaussian model. Online source, `prior7`: `normal(0, 5)` on the sigma intercept (log link), `normal(0, 5)` on `beta` (log link), `exponential(0.2)` (mean 5) on the SD of the sigma effects. NB10's table: `mu_log_sd_y ~ Normal(0, 5)`, `log_nu ~ Normal(0, 5)`, `sd_log_sd_y ~ Exponential(scale=5)` — identical. The book fits that model successfully with brms (`init = 0`). NB10 presents these priors as "the kind of prior written by default rather than by thinking". Independently of that, the book's "default priors" section (model 8) teaches the *opposite* lesson from NB10: brms defaults are "sensible(ish)" and results "barely matter… except for the skewness parameter". The README says NB10 reuses priors "that made an earlier draft of notebook 9 fail". So the notebook's framing, title/filename mismatch, and relation to the source all need a decision.
- **10.Q2 [high]** The sampling failure is PyMC-implementation-specific. §4.5 explains it by PyMC 6.3.2's switch to the plain Gaussian log-density when `nu < 0.05·sigma`, producing small jumps that shrink the step size. The prior-predictive failure (§2) is robust and version-independent; the sampling failure is not, and its explanation is deep implementation detail. A future PyMC release could change the behavior and silently invalidate §3–§4.
- **10.Q3 [med]** Overlap: "a prior on the log scale that looks vague is extreme on the natural scale" is already NB6 §1 (priors on the wrong scale) and NB8 §1.7 (zero on the log scale is not neutral). NB10 is the third treatment.
- **10.Q4 [med]** Runtime: the sampling cell took 339 s (5–6 min). In a live class that is dead time unless planned for.
- **10.Q5 [med]** §2.4 depends on NB10 drawing *the same random numbers* as NB9 ("the same panel that zigzagged… in Notebook 9", "15 times larger here, about 34"). Correct now, fragile to any change in either notebook.
- **10.Q6 [info]** §3.4's lesson — zero divergences is not a clean bill of health; max-tree-depth, R-hat and ESS still fail — is valuable and not taught elsewhere.

---

## NB11 — Flat population-level priors (agent-written)

### Flags

- **11.Q1 [high]** Reproducibility: the text hard-codes one run's specifics — chain 3 stuck, 1,488 divergences, `log_nu` swept to −372, chain means — and §3.4's solution selects chains `[0, 1, 2]` by index. The notebook itself reports that in ten test runs 40% of chains got stuck and one run had none; the README says the behavior depends on PyTensor/Numba cache state. The README also tells instructors to re-run in Colab before lecturing — which will very likely make the text wrong. Needs either robust wording (describe what to look for, not which chain) or an explicit "your numbers will differ" framing with a data-driven chain selection.
- **11.Q2 [high]** Teaching load: the explanation of the failure goes through improper posteriors (appropriate), then floating-point underflow (`5×10⁻³²⁴`, NaN at `log ν ≈ −372.6`), mass-matrix adaptation, and "walls" in the likelihood. The core lesson — a flat prior on a parameter the data cannot bound gives an improper posterior; no prior predictive check is possible; R-hat/ESS on "good" chains don't rescue it — could be made with a fraction of this.
- **11.Q3 [med]** Flat priors are put on four parameters including `mu_b0` and `mu_b1`, which the data identify well; the failure comes from `log_nu` (and, in the stuck chain, `mu_log_sd_y`). A flat prior only on the tail parameter would isolate the lesson. (The book flattens everything, including the SDs.)
- **11.Q4 [med]** Runtime ~5 min (292 s).
- **11.Q5 [info]** §1.5 (no prior predictive check is possible under a flat prior) and §3.7 (a PPC cannot detect a nonexistent posterior) are strong, compact lessons worth keeping whatever else changes.

---

## NB12 — Robust Student-t and PSIS-LOO (agent-written)

### Flags

- **12.Q1 [high]** The course never compares likelihood families predictively. NB6–9 introduce lognormal and ex-Gaussian likelihoods; NB12 compares only Gaussian vs Student-t. The book compares normal vs lognormal (lognormal better by 10.6 ± 4.1) and log-t vs t (with a Jacobian). Because `pm.LogNormal` is defined on `y` directly, NB7's model could be added to `azs.compare` with no Jacobian adjustment; so could NB8/NB9's. Decide whether NB12 (or a closing note) should answer "which of the likelihoods we tried predicts best?"
- **12.Q2 [med]** A connection left unmade: NB9 found the within-participant scatter nearly symmetric (tail ≈ 7 ms), while NB12 finds heavy *two-sided* tails (`nu` ≈ 2.6), driven partly by unusually *fast* days (332 day 7, 308 day 5). An ex-Gaussian tail is one-sided and cannot produce those; that explains both results. One question would tie the likelihood arc together.
- **12.Q3 [med]** §4.5 and §4.8 cite "test runs of this notebook with other random seeds" and refits "in test runs" that students cannot see. Either show them or drop them.
- **12.Q4 [low]** Committed outputs include `UserWarning` text with agent scratch-directory paths (`/tmp/claude-0/…/nbenv/…`). Cosmetic; clears on re-run.
- **12.Q5 [low]** The LOO interval plot uses equal-tailed intervals (stated in §2.3). Only a note: it is the one departure from the 90% HDI convention, and it is explained.
- **12.Q6 [info]** Results agree closely with the book: `nu` 2.62 (book 2.63), `student_t_slope` vs `gaussian_slope` ΔELPD −38.0 ± 12.9 (book −38.7 ± 12.5), varying-slope gain larger under Student-t (book: 44.8 vs 15.3; ours 45.8 vs 16.0).

---

## Cross-notebook observations recorded during the pass

(Each is consolidated with context in pass 2.)

- Section-heading and title style (01.Q2, 02.Q1).
- `mu` vs `mu_y` (01.Q3).
- Unlabeled participant panels; unlabeled trace colours (01.Q6, 04.Q7).
- Prior-predictive mean-line spikes and the long forensic answers they generate (06.Q2, 07.Q2, 08.Q3, 09.Q4, 10.Q5).
- Answer length/verbosity escalating from NB6 to NB12 (06.Q4, 09.Q5, 11.Q2).
- Claims based on runs students cannot see (08.Q2, 09.Q3, 12.Q3; also NB10 §3.1 and NB11 §2.1).
- Closing sections: none in NB1–3, NB5; forward-looking in NB4; `## Summary` in NB6–12 (01.Q9, 04.Q4).
- Prior choices diverging from the book when levels are added (04.Q1, 07.Q1) and the 150 ms baseline prior (06.Q1).
- LKJ/correlation omitted (05.Q2, 08.Q5).
- Weakly identified ex-Gaussian tail underpinning NB9–11 (09.Q1, 10.Q1, 11.Q3).
- Runtime of NB10/NB11 (~5 min each).
- Environment: every notebook pins `pandas==2.2.3`. `AGENTS.md` says not to freeze pandas "unless fresh-Colab testing shows that an additional constraint is necessary", and lists only the PyMC/ArviZ pins as course-wide. If the pandas pin is needed, `AGENTS.md` should say so; if not, it should go.
- Stale committed outputs with non-Colab paths/warnings (01.Q1, 07.Q3, 12.Q4).
- `REVISION_PLAYBOOK.md` §3.8 made NB5's heading style the rule over NB1's; §3.11 says NB1–3 are the more reliable style models. These two statements pull in opposite directions for headings.
