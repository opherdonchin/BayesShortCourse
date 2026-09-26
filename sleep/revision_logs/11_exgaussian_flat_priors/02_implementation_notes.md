# Implementation notes: notebook 11 — Flat population-level priors

Author: implementation agent (Step 2 of `sleep/REVISION_PLAYBOOK.md`).

**This notebook is a deliberate failure demonstration.** Nothing was tuned, reparameterized,
or re-seeded to make the model sample. The plan's settings (`target_accept=0.97`,
`tune=2500`, matching the pre-revision draft's code) are used unchanged, and the failed
diagnostics are the lesson.

## Execution status

The repository copy of the solved notebook is **unexecuted**: outputs are empty and execution
counts are null, leaving the committed run to Step 3a, as for NB10. Every number and plot reading
in the answers comes from executions of the notebook's own code in the pinned venv
(`scratchpad/nbenv`: `pymc==6.3.2`, `arviz-base==1.3.0`, `arviz-stats==1.3.2`,
`arviz-plots==1.3.1`, Python 3.12, kernel `nbenv`, real `DATA_URL`):

- Two `jupyter nbconvert --execute` runs of earlier drafts (`exec_copy1`, `exec_copy2`) and one
  run of the **final** file (`exec_final.ipynb`, exit 0, 0 cell errors). The final repository
  file's 12 code cells are byte-identical to `exec_final.ipynb`'s. Later edits touched markdown
  only.
- Literal-script runs (`lit11.py`, which `exec`s the notebook's model cell) for seeds,
  settings, and the cache experiment below.

**Important for Step 3a: the run is reproducible only once PyTensor's compiled code is
cached.**
- PyTensor 3 here uses the Numba backend (`~/.pytensor/numba`, `fastmath` enabled).
- Every run that loaded this model's compiled functions from the cache gave **bit-identical**
  results. There were five: two nbconvert drafts, the final nbconvert run, one literal rerun, and
  one literal run with a separate, freshly warmed cache directory. The result was 1,488
  divergences with chain 3 stuck.
- **The first run after the model's functions are compiled gives a different path**, with the
  same code, seed and machine:
  - my first literal run, compiled against a cache that already held related functions from an
    exploratory model, gave 1,932 divergences and no stuck chain;
  - a run with a completely fresh cache directory (`PYTENSOR_FLAGS=base_compiledir=...`) gave
    1,003 divergences and two stuck chains;
  - a second run on that fresh cache then gave 1,488 again.
- I did not identify which compiled function differs between in-process compilation and
  cache loading.
- I checked that `PYTHONHASHSEED` does not matter: the compiled logp/gradient gave an identical
  bit fingerprint at 200 points under five hash seeds (`hashtest.py`).
- **Consequence:** in this container, whose cache is warm, Step 3a should reproduce the
  1,488-divergence run that the answers describe.
  - If Step 3a runs where the cache is cold, execute twice and keep the second run, or rewrite
    the answers (see the claims table).
  - On Colab, a student's first run is effectively a random draw from the distribution of
    outcomes in the seed table below. The notebook's question and `given` texts are written to
    work for either outcome.

## What was written

- **`sleep/solved/11_exgaussian_flat_priors.ipynb`:** 49 cells (37 markdown, 12 code), all
  tagged:
  - 4 `section`;
  - 19 `given`;
  - 12 `exercise-question`, each followed by exactly one `solution` (10 markdown, 2 code);
  - 2 `exercise-question` + `given-answer`: 2.5 (stuck chains) and 3.3 (the arithmetic wall).
- **Built by** `scratchpad/nb11/build_nb11.py`, NB10's builder pattern:
  - stable hashed ids (`sleep11-<key>`);
  - top-level metadata taken from the pre-revision file, which had no `widgets`;
  - `json.dump(..., indent=1, ensure_ascii=False, sort_keys=True)` plus a trailing newline.
    `sort_keys` matches nbformat's own writer, which avoids churn when Step 3a executes the file.
- **`sleep/11_exgaussian_flat_priors.ipynb`:** derived mechanically by
  `derive_and_verify_nb11.py`, NB10's script with the file names changed:
  - `solution` cells become `- answer here` or `# answer here`;
  - the badge points to `sleep/11_...`;
  - outputs are cleared and execution counts are null;
  - there is no `metadata.execution` and no `metadata.widgets`.
- **Verified by script** (`derive_and_verify_nb11.py`, `check_nb11.py`):
  - exactly 13 cells differ: 12 `solution` cells and the badge;
  - the two files have identical ids, types, tags and order;
  - both pass `nbformat.validate`, ids are unique, and both files end in a trailing newline;
  - Q→A adjacency holds, questions are `###` headings and sections are `##` headings;
  - every in-notebook "Question N.M" reference resolves;
  - math uses only `$`/`$$`;
  - no `sample_prior_predictive` call appears in code;
  - none of these appear: `print(model`, `lam=`, `kind="kde"`, `plot_population`,
    `population_mu`, `_z`, `residual_scale`, `sigma_intercept`, `nu_intercept`,
    `intercept_sd`, "Notebook 11/12", "next notebook", "later notebook";
  - "Reaction" appears only in the axis label and `observed=sleep["Reaction"]`;
  - notebooks cited: 1, 9, 10.

### Section structure

| Section | Content (Q = student answers, G = given) |
|---|---|
| Title, Setup, Data, Plotting helper | G. NB10's cells verbatim, with a new intro. Its title, "Flat population-level priors", glosses the README's "(or common-effect)". The intro says the priors are "chosen for you as a deliberate demonstration… the model is fitted to be diagnosed, not to be used". No forward pointer. |
| 1. Removing prior information | 1.1 model math, and a table of the four changed priors against NB09's (G) · 1.2 what `pm.Flat` claims; improper (Q) · 1.3 reverse elicitation: a flat prior on log ν gives every factor of ten equal weight, so infinitely more weight below 1 ms (Q) · 1.4 the supplied model, NB09's code with four `pm.Flat` lines and NB09's priors in comments (G) · 1.5 why there is no prior predictive check (Q) |
| 2. Fit and diagnose the model | 2.1 sampling at 0.97/2500 (G) · 2.2 divergences, share at maximum tree depth, step size, summary, trace (G) · 2.3 participant screen, NB09's three-number table (G) · 2.4 criteria verdict (Q) · 2.5 why a chain can sit far away from the others (given-answer), plus a given chain-means table |
| 3. Read the failed fit | 3.1 where the draws of `log_nu` lie (Q) · 3.2 why nothing stops `log_nu`: an improper posterior (Q) · 3.3 the arithmetic wall at about −372.5, where the divergences come from, and the contrast with NB10 (given-answer) · 3.4 summary of the non-stuck chains via `coords={"chain": [...]}` (Q code) · 3.5 what R-hat/ESS can and cannot detect; dropping a chain repairs nothing (Q) · 3.6 posterior predictive plot (Q code) · 3.7 would the PPC have revealed the problem? (Q) · 3.8 which results look like NB09's, and can they be reported? (Q) |
| 4. Summary | 4.1 retrospective only (Q). No reference to any later notebook. |

## What the failure actually looked like

### The notebook's run (warm cache, `RANDOM_SEED`, 0.97/2500; five identical runs)

**Headline:**
- 1,488 divergences, per chain 563 / 451 / 474 / 0;
- 25.2% of draws at the maximum tree depth, per chain 0 / 0.1% / 0.7% / **100%**;
- average step size 0.0059, per chain 0.0056 / 0.0090 / 0.0083 / **0.00064**;
- sampling took 299 s (final nbconvert run) and up to 381 s under concurrent load.

**Warnings printed:** divergences; "Chain 3 reached the maximum tree depth"; R-hat above 1.01;
ESS per chain below 100.

**Population summary** (all four chains):

| | mean | 90% HDI | ess_bulk | ess_tail | r_hat |
|---|---|---|---|---|---|
| mu_b0 | 262.23 | 241.20, 280.15 | 8.78 | 17.22 | 1.38 |
| sd_b0 | 33.17 | 21.71, 44.25 | 19.47 | 18.75 | 1.14 |
| mu_b1 | 10.72 | 6.66, 14.54 | 15.07 | 19.59 | 1.20 |
| sd_b1 | 7.93 | 5.12, 10.46 | 25.55 | 86.94 | 1.13 |
| mu_log_sd_y | 0.88 | −5.00, 3.01 | 6.90 | 6.12 | 1.58 |
| sd_log_sd_y | 0.47 | 0.00, 0.77 | 6.81 | 4.95 | 1.59 |
| log_nu | −139.82 | −320.11, 3.73 | 7.19 | 11.37 | 1.53 |

**Participant screen:** largest R-hat 1.60, smallest bulk ESS 6.80, smallest tail ESS 4.59.

**Chain means:**

| chain | mu_b0 | mu_b1 | mu_log_sd_y | log_nu |
|---|---|---|---|---|
| 0 | 266.79 | 11.54 | 2.84 | −190.09 |
| 1 | 267.50 | 11.60 | 2.84 | −192.88 |
| 2 | 267.24 | 11.29 | 2.82 | −179.74 |
| 3 | 247.39 | 8.44 | −5.00 | 3.44 |

Chain 3 is stuck in the region where the Gaussian part has vanished:
- `sd_y` ≈ 0.0067 ms for every participant, and `sd_log_sd_y` ≈ 0.005;
- ν ≈ 31 ms;
- 0 divergences, 100% of draws at the maximum tree depth, step size 0.00064.

**Non-stuck chains only** (3.4's code, `coords={"chain": [0, 1, 2]}`):

| | mean | 90% HDI | ess_bulk | ess_tail | r_hat |
|---|---|---|---|---|---|
| mu_b0 | 267.18 | 252.35, 281.24 | 1111 | 1026 | 1.0 |
| mu_b1 | 11.48 | 8.27, 14.55 | 1256 | 1194 | 1.0 |
| mu_log_sd_y | 2.83 | 2.57, 3.11 | 1332 | 1345 | 1.0 |
| sd_log_sd_y | 0.63 | 0.43, 0.82 | 1028 | 1342 | 1.0 |
| log_nu | −187.57 | −345.59, −14.46 | 550 | 571 | 1.0 |

Participant-level values for chains 0–2 (scratch): max R-hat 1.01, min ESS 545 bulk / 426 tail.
The `log_nu` draws of chains 0–2 run from −371.98 to 1.14.

### Seeds, settings and attribution (`scratchpad/nb11/`, 4 chains × 1,000 draws, 2 jobs)

**Literal notebook code at 0.97/2500** ("stuck" = a chain that settled in the vanished-Gaussian
region):

| Run | Divergences | Stuck chains | Max-depth share |
|---|---|---|---|
| `RANDOM_SEED`, first compile (cache held related functions) | 1,932 | 0 | 0.1% |
| `RANDOM_SEED`, fresh cache directory, first compile | 1,003 | 2 | 50.0% |
| `RANDOM_SEED`, warm cache (×5, identical) | **1,488** | **1** | 25.2% |
| seed 1 | 1,432 | 1 | 25.0% |
| seed 2 | 1,703 | 3 | 42.7% |
| seed 3 | 962 | 2 | 50.1% |
| seed 4 | 1,000 | 2 | 50.0% |
| seed 5 | 2,028 | 2 | 23.9% |
| seed 6 | 1,573 | 1 | 25.0% |
| seed 7 | 1,194 | 2 | 43.3% |

- These are 10 distinct runs, counting the identical warm runs once: 16 of 40 chains got stuck
  (40%), and 9 of the 10 runs had at least one stuck chain. This is the basis for 2.5.
- The only run with no stuck chain was the first compile, and it is the basis for 2.5's
  "almost 2,000 divergences, but every population-level R-hat was 1.00":
  - 1,932 divergences;
  - every population R-hat 1.00, and participant maximum 1.01;
  - smallest ESS about 545;
  - `log_nu` −187.62 ± 107.58, HDI [−372.54, −37.83];
  - 172 s.
- In every run, **every non-stuck chain** let `log_nu` spread uniformly down to about −372 and
  diverged on about 45–56% of its draws.
- Stuck chains:
  - have `log_nu` ≈ 3.4–5.1 (ν ≈ 30–160 ms) and `mu_log_sd_y` from −4 to −17;
  - have `mu_b0` from −1 to 247 ms and `mu_b1` from 8 to 46;
  - take tiny steps (0.0002–0.0009), and usually hit the maximum tree depth;
  - usually have 0 divergences, but some have many: seed 2's stuck chains had 192, 123 and 940;
    seed 5's had 37 and 1,000. These are NB09's observation-wall divergences.

**Other settings** (literal code, `RANDOM_SEED`):

| Settings | Divergences | Stuck chains | Max-depth share | Time |
|---|---|---|---|---|
| PyMC default (0.8), tune 1500 | **2,804** | 0 | 0% | 16 s |
| NB09's 0.99, tune 1500 | 508 | **3** | 72.0% | 679 s |

These two runs are the basis for 2.1: defaults gave "even more divergences", and NB09's setting
"left three of the four chains stuck".

**Attribution variants** (`model11.py`, whose variable order differs from the notebook's, so
their paths are not the notebook's):

| Variant | Divergences | Stuck | Result |
|---|---|---|---|
| all four flat (exploratory) | 1,410 | 1 | same failure |
| **nuflat** (only `log_nu` flat; NB09's other priors) | 1,842 | **0** | all 4 chains wander to about −372; mean structure NB09-like (`mu_b1` about 11.3) |
| **meanflat** (flat `mu_b0`/`mu_b1`/`mu_log_sd_y`; NB09's `log_nu` prior), 4 seeds | 2 / 1 / 5 / 3 | 0 / 0 / 1 / 0 | otherwise NB09's fit: `log_nu` about 2.0 (ν about 7.5 ms), `mu_b1` 11.4 [8.15, 14.71] |
| flat, **smooth exact density** (erfcx) | 292 | 2 (+1 at max depth) | fails differently (below) |

What this establishes:
1. **The flat prior on `log_nu` alone causes the divergence failure** (nuflat).
2. **The flat priors on `mu_b0`/`mu_b1`/`mu_log_sd_y` alone can trap a chain** (meanflat: 1 of
   16 chains), but rarely. With all four flat, and every chain starting with ν ≈ 1 ms, it
   happens to about 40% of chains.
3. With only the three mean-level flat priors, the non-stuck chains reproduce NB09's fit. The
   data determine those parameters well. This supports 4.1's "the data determine the mean
   structure well".

## Mechanism (probes, `scratchpad/nb11/`)

1. **The posterior is improper in `log_nu`** (`probe11.py`, `wall11.py`).
   - The joint log density is **exactly constant** for `log_nu` below every participant's
     switch point, and its `log_nu` gradient is exactly 0. For example, it is −755.8310 at a
     least-squares point for every `log_nu` from −2 to −745.
   - At nine posterior draws it was constant to 6 decimals (e.g. −793.006826), with switch
     points between −1.6 and 1.6.
   - In PyMC 6.3.2, `ExGaussian.logp` uses `log_normal` when `nu <= 0.05*sigma`, and
     `check_parameters(nu > 0)` gives −inf only once ν underflows to 0 (`log_nu` < −745.2).
   - Mathematically, even an exact density only *approaches* the Gaussian as ν→0. A flat prior
     over an infinite half-line therefore has infinite mass in any implementation.
2. **The lower edge is the gradient becoming NaN at `log_nu` ≈ −372.55.**
   - In the sampler's own compiled function (`model.logp_dlogp_function`), the `log_nu`
     gradient first becomes non-finite between −372.55 and −372.6 at three different posterior
     draws.
   - That is exactly where ν² underflows to 0: e^−372.5 squared is 5e−324, the smallest
     subnormal, and e^−372.6 squared is 0.
   - The same happens for a bare `pm.logp(pm.ExGaussian.dist(...))`: at −372.6 the log density
     is finite but d/d`log_nu` is NaN, while d/d`mu` and d/d`sigma` stay finite.
   - The gradient graph contains `True_div` nodes by powers of ν. 3.3 says "divides by that
     square, and once it is zero, the calculation produces NaN". That is the course-level
     version; the NaN arises when the switch's zero upstream gradient meets an infinite term.
   - **Caveat:** a separately compiled `model.compile_dlogp` graph goes NaN earlier, at −354.9
     (= −ln(DBL_MAX)/2, an overflow of 1/ν²). The sampler does not use that function, and every
     run's draws reach −372.
3. **The divergences are that wall.** In the notebook's run (chains 0–2):
   - 99.87% of divergent draws have `max_energy_error = inf`; the 2 finite ones are about
     1,100. The first-compile run gives 99.7%.
   - P(divergent | `log_nu` in [−400, −300)) is 0.77, against 0.35–0.40 above −100. In the
     first-compile run it was 0.81 against about 0.30.
   - Divergent transitions build shorter trees: 399 steps on average, against 740.
4. **The draws are uniform between the wall and the data's edge.**
   - Notebook run, chains 0–2: pooled `log_nu` mean −187.6, sd 106.7, against −185.4 and
     107.7 for a uniform over the draws' range. The first-compile run gives −187.6 and 107.6,
     against −185.5 and 108.0.
   - Draw counts in 50-unit bins are roughly equal.
   - Successive draws differ by 71–75 units on average (mean |Δ|; 67–72 in the first-compile
     run), because adapt_diag scales `log_nu`'s steps to its spread. This is the basis for 3.3's
     "learns how widely each parameter ranges and scales its steps".
   - **This also explains the pre-revision draft's result.** Its `nu_intercept` was
     −181.77 ± 107.41, HDI [−332.85, −0.30], on a different machine and with a non-centered
     parameterization, which is the same uniform-to-the-wall distribution.
   - In the notebook's run, 99.67% of the non-stuck draws lie below every participant's switch
     point, so the model is literally evaluated as Gaussian there. This is the basis for 3.7's
     and 3.8's "effectively a Gaussian model". Switch points across these draws range from −2.04
     to 2.1, which is why 3.2 says "below about −3".
5. **The stuck chains sit in a second improper direction** (`probe_stuck.py`).
   - At a stuck draw, shifting `mu_log_sd_y` and every `log_sd_y` down together leaves the joint
     log density **exactly** unchanged: −859.924 from shift −50 to +1, and −1013.931 from −50 to
     +3 at another run's stuck draw.
   - It changes only once `sd_y` approaches the smallest trajectory-to-observation gap, which
     is 0.0–0.05 ms.
   - Once every trajectory lies below all of a participant's observations, the likelihood is
     the pure-exponential one, and the flat `mu_log_sd_y` leaves this direction unbounded.
   - NB09's `Normal(log 30, 0.5)` puts −5 about 17 SD out.
   - The sampler barely moves there because the observations act as walls (NB09 3.2).
   - Every chain starts at the Flat support point 0 ± 1 jitter (checked with `init_nuts`):
     trajectories ≈ 0 ms, `sd_y` ≈ 1 ms, ν ≈ 1 ms. That is a start from which falling into this
     region is easy.
   - **Caution:** a stuck chain's `lp` can be *higher* than the others'. The notebook's chain 3
     has −722.8 against −784, because the centered funnel's density grows as
     `sd_log_sd_y`→0.005. `lp` therefore says nothing about posterior mass, and the notebook
     makes no such claim.
6. **A smooth implementation does not escape** (`fit11.py flat_smooth`, `model11.py`:
   `smooth_exgauss_logp`).
   - This is an erfcx-based exact density, checked to reduce to the Normal density
     analytically.
   - Its log density is also flat for small ν.
   - Its gradient becomes round-off garbage below about −13: −26 at −14.3, −1.1e5 at −20,
     −1.4e14 at −30. That is a spurious numerical wall.
   - Its chains therefore stop near −14.6, with 292 finite-energy divergences, and 3 of 4
     chains end up at the maximum tree depth (2 in the vanished-Gaussian region).
   - So the edge's *location* is implementation-specific, but some edge of the arithmetic
     always stops the drift. The notebook does not mention this run; 3.3 says only that the
     edge is "the limit of the arithmetic, not anything in the model or the data".
7. **The PPC's lopsided bands come from the stuck chain** (scratch re-draw).
   - 50% HDIs with and without chain 3: participant 332 on day 7 is [253, 344] against
     [313, 396]; participant 308 on day 4 is [281, 360] against [340, 403].
   - Chain 3's trajectories lie below the observations, so its predictive mass sits low.

### How this compares with NB10's failure

**NB10** (Normal(0, 5) on `log_nu`):
- a **proper** posterior, confined to about [−16, 3];
- that range overlaps the switch jumps;
- step size 0.0025, 99.9% at the maximum tree depth, **0 divergences**, R-hat up to 1.04.

**NB11** (flat):
- an **improper** posterior;
- non-stuck chains spread over hundreds of units, with larger steps (0.0056–0.0090) and almost
  no maximum-depth draws;
- about half their draws diverge at the ν² = 0 wall;
- chains that fall into the second improper direction (vanished Gaussian part) are stuck,
  with R-hat about 1.6.

3.3 explains the difference at course level and ends on the shared cause: "a prior that puts its
weight where the data carry no information".

## Deviations from the plan and judgment calls (flagged)

1. **A stuck-chain question (2.5, `given-answer`) and a chain-means cell were added.**
   - The plan anticipated only the `log_nu` failure. The executed run has a stuck chain, and
     9 of 10 test runs did too, so a student will almost certainly meet one.
   - Leaving it unexplained would make the diagnostics section unreadable. The mechanism is the
     same lesson (missing prior information), in the other part of the likelihood, so I explain
     it rather than treating it as noise.
   - **Reviewer check:** is 2.5 at the right level and length?
2. **The solved answers describe the reproducible warm-cache run**, which has chain 3 stuck.
   - The question and `given` texts are outcome-neutral:
     - 2.4 asks for a criteria verdict;
     - 3.1 asks about "the chains that did not get stuck";
     - 3.4 tells the student to pick non-stuck chains from the chain-means table;
     - 3.5 asks whether leaving out "a stuck chain" repairs the fit.
   - 2.1 warns that "even the overall picture can differ in one respect".
3. **A new student code task (3.4):** summarize only the non-stuck chains with `coords`.
   - It turns the arviz-diagnostics skill's point, "dropping bad chains cannot certify a
     repair", into a visible result: R-hat 1.00 and ESS ≥ 550 for a distribution that does not
     exist.
   - The solution code hard-codes `[0, 1, 2]`, as NB10's 3.6 hard-codes participant `"332"`.
   - **If Step 3a's run has different stuck chains, change the list.**
4. **A posterior predictive check is included (3.6–3.7), which NB10 omitted.**
   - The plan lists "posterior plots, PPC". NB10's 4.3 says a failed fit is "neither reported
     nor used for predictions".
   - To stay consistent, 3.6 says the predictions "will not be used, as in Notebook 10", and
     asks a different question: would the check have raised an alarm had the diagnostics been
     skipped?
   - The answer, "no clear alarm, and it cannot tell 10^−5 ms from 10^−150 ms tails, for the
     same reason the data cannot", is a lesson NB10 did not have.
5. **`mean_rt` dropped** (as in NB10): no question uses it. The plan's "everything else
   identical" listed it; 1.4 says it is left out.
6. **No `plot_dist` of `log_nu` or `nu`.** The trace plot already shows each chain's `log_nu`
   density and rug, and a separate plot would be redundant (AGENTS.md: one figure per question).
   No prior–posterior plot is possible, because there are no prior draws.
7. **Mechanism depth (plan's open question).**
   - 3.2 (student) derives impropriety from NB09 4.4 and NB10 4.5. 3.3 (`given-answer`) explains
     the NaN wall, the step scaling, and the contrast with NB10.
   - New terms, each defined inline: "improper" (1.2, 3.2), "not a number (NaN)", and "the
     smallest positive number it can store". "Slope of the log posterior density" reuses NB10
     3.3's revised definition.
   - **Reviewer check:** the level of 3.3. A shorter fallback would keep only its first
     paragraph and last sentence.
8. **Sampler settings.** I used 0.97/2500 as planned and confirmed it against the pre-revision
   code. The default and 0.99 runs are reported in 2.1 as evidence that settings are not the
   cause; 3.3 explains why no step size avoids the wall.
9. **Title** "Flat population-level priors". The course says "population-level" throughout;
   the intro glosses "(or common-effect)" to match the README.
10. **The `given` text (2.1, 2.5) quotes scratch statistics** (test-run counts, the 0.99 and
    default runs), as NB10's 3.1 did. They are stated as test-run facts, not as this run's
    output.
11. **Summary (4.1)** is retrospective and quotes this run's numbers. It frames the result as
    "two parts of the likelihood, each of which the data cannot tell from nothing", which is
    the notebook's synthesis of 3.2 and 2.5.

## For Step 3a: every claim and its basis

"Final run" means `exec_final.ipynb`: the final file's code, nbconvert, warm cache, identical to
four other warm runs. "Scratch" means scripts in `scratchpad/nb11/`.

**If Step 3a reproduces the final run** (expected in this container): 1,488 divergences, 25.2%,
0.0059, and the chain-means table with chain 3 at −5.00 / 3.44. Then every row below holds as
written.

**If it does not:**
- if there is **no stuck chain**, rewrite 2.4, 3.1, 3.4–3.5, 3.7–3.8 and 4.1 (the first-compile
  run's numbers above show what that outcome looks like: R-hat 1.00 everywhere);
- if **different chains are stuck**, update 3.4's `coords` and the chain numbers in 3.1, 3.5,
  3.8 and 4.1.

| # | Cell | Claim | Basis | Action if Step 3a differs |
|---|---|---|---|---|
| 1 | 1.2 A | Normal(250, 100) holds about 95% in 50–450 ms; a flat density has infinite area | Analytic | None |
| 2 | 1.3 A | Each factor of ten is 2.3 wide on the log scale; infinitely many factors below 1 ms | Analytic | None |
| 3 | 1.5 A | `pm.sample_prior_predictive` stops with "Cannot sample from flat variable" | Scratch: `NotImplementedError: Cannot sample from flat variable`, for the model and for `pm.draw(pm.Flat.dist())` | None (version-specific wording, PyMC 6.3.2) |
| 4 | 2.1 G | Default settings: more divergences; 0.99 leaves three of four chains stuck; "several minutes" | Scratch: 2,804 divergences at 0.8/1500; 0.99/1500 had 3 stuck chains and took 679 s; 172–381 s at 0.97 | Re-run once if desired (outside the notebook's output, like NB10 3.1) |
| 5 | 2.4 A | 1,488 of 4,000; warnings for chain 3's tree depth, R-hat and ESS; R-hat about 1.6; ESS below 10; one chain apart (lower `mu_b0`/`mu_b1` densities; `mu_log_sd_y` near −5 vs 2.8; `sd_log_sd_y` near 0; `log_nu` near 3); others' `log_nu` sweeps about −370 to 0 | Final run's output and trace figure (viewed) | Rewrite if different |
| 6 | 2.5 G | Flat parameters start near 0 (0 ms, about 1 ms, about 1 ms); stuck region description; "tens to hundreds of ms"; "thousandths of a ms or less"; the data cannot tell the Gaussian part from none; walls; 10 test runs, about 40% stuck, 9 of 10 with at least one; the one run without had about 2,000 divergences and every population R-hat 1.00 | `init_nuts` check; seed table; `probe_stuck.py` | Holds regardless of Step 3a's outcome. If a new run is added, the tally changes slightly. |
| 7 | 3.1 A | Chains 0–2 spread almost evenly over about −372…0; rug is a solid bar, density invisible beside chain 3's peak; e^−372 ≈ 10^−162 ms; upper end about 1 ms; "the data rule out long tails"; chain 3 near 3.4 ≈ 30 ms | Final run's chain means and figure; uniformity analysis (`post11.py`); e^3.44 = 31.2 | Chain numbers |
| 8 | 3.2 A | Likelihood exactly constant below the switches, "below about −3"; improper | `probe11.py`/`wall11.py`; switch points span −2.04…2.1 across the notebook run's non-stuck draws; analytic | None |
| 9 | 3.3 G | Slope exactly 0; smallest positive about 5e−324; at −372.5 ν ≈ 1e−162 ms and ν² → 0; NaN; divergence; step scaling; "no step size avoids that edge"; NB10: about 20 units, tiny steps, max depth, 0 divergences; here larger steps, almost no max depth, about half diverge (non-stuck chains) | Mechanism points 1–4; the 0.99 run's non-stuck chain still had 508 divergences in 1,000 draws; NB10's committed output | None expected. **Level is a reviewer check** (deviation 7). |
| 10 | 3.4 code | `coords={"chain": [0, 1, 2]}` | Final run's chain means | Change the list if the stuck chains differ |
| 11 | 3.5 A | Subset R-hat 1.00; smallest bulk/tail ESS about 550/570 (`log_nu`); all 1,488 divergences in chains 0–2, half their draws; dropping a chain repairs nothing | Final run's 3.4 output (549.65 / 571.22); per-chain divergences 563/451/474/0 | Rewrite if different |
| 12 | 3.7 A | Bands follow trajectories and scatter as in NB09; clearest exception 332's day-4 point; stuck chain pulls 50% bands down, lopsided for 308 and 332; tails of 1e−5 and 1e−150 ms predict the same | Final run's figure (viewed and cropped); scratch HDI comparison (mechanism point 7); NB09 5.5's committed text names 332 day 4 | **Look at the figure** if the run differs |
| 13 | 3.8 A | Subset `mu_b1` about 8.3–14.6, `mu_log_sd_y` about 2.8, `mu_b0` about 267, which is about 7 above NB09's 260 because ν vanished; NB09's `mu_b0` + ν ≈ 259.9 + 7.4 = 267.3; chain 3's `mu_b1` about 8.4, tail about 30 ms | Final run's subset summary and chain means; NB09's committed summary | Numbers |
| 14 | 4.1 A | Restates rows 1–13: 1,488 of 3,000 draws in three chains; R-hat about 1.6; "Notebook 9's priors for `log_nu` and `mu_log_sd_y` ruled out both regions" | As above; NB09's priors put log ν < −2 about 8 SD and `mu_log_sd_y` = −5 about 17 SD from their centers | Numbers |

## Notes for the orchestrator (not stated in the notebook)

- **Reproducibility.** The cold-versus-warm cache effect is new to this sequence. NB10's runs
  may have been all warm, or less chaotic.
  - With the Numba backend, the first execution after compilation can follow a different path
    than every later one.
  - For failure notebooks whose answers quote run-specific numbers, execute twice and keep the
    second run.
  - This may deserve a playbook note.
- **README.** `solved/README.md` describes NB11 as "deliberately flat common-effect priors,
  with the same hierarchical priors as notebook 9", which remains accurate. The playbook says
  README changes are for repository-wide conventions, so I did not edit it.
- **Colab.** Sampling takes about 5 minutes on 2 cores, and 2.1 warns of "several minutes". A
  stuck chain is likely on Colab. 2.5, the chain-means cell and the neutral question wording
  prepare students for it.

## Scratch files (`scratchpad/nb11/`)

- **Builders and checks:**
  - `build_nb11.py`, assembled from `_part_head.py`, `_part_title.py`, `_part_setup.py`,
    `_part_body_s1.py`, `_part_body_s234.py` and `_part_tail.py`;
  - `derive_and_verify_nb11.py`, `check_nb11.py`, `dump_exec.py`.
- **Model and fits:**
  - `model11.py` (variants `flat`, `nuflat`, `meanflat`, `nb09`, `flat_smooth`);
  - `fit11.py`, `fit_*.log`, `idata_*.pkl`.
- **Literal runs:**
  - `lit11.py` and `nb_model_cell.py`, the notebook's model cell verbatim;
  - `lit11_*.log`, `lit11_*.pkl`, `lit11_first_run.pkl` (the 1,932 first compile);
  - `cold_warm.sh`, `ptcold/`, `hashtest.py`.
- **Mechanism:** `probe11.py`, `wall11.py`, `probe_stuck.py`, `post11.py`.
- **Executed copies:**
  - `exec_copy1.ipynb` and `exec_copy2.ipynb` (drafts), and `exec_final.ipynb` (final code);
  - `exec_cell23_0.png` (trace), `exec_cell41_3.png` (PPC), `crop308.png`, `crop332.png`;
  - `nbconvert*.log`.
