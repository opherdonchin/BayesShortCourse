# Revision pattern report: sleep notebooks 1–5 (commits a50165c, 6be7ef1, 4fcfcfd, 078547f)

Evidence base: full source-only diffs for all 10 notebook pairs, the README diff, the current state of NB1–NB6 (both variants), cell metadata (tags) and outputs of the revised solved notebooks, a feature scan of NB6–NB12 solved, and the pinned library sources (arviz-base 1.3.0, arviz-plots 1.3.1, pymc 6.3.2 wheels) to check defaults. "NBk" means notebook k. "solved" means `sleep/solved/`, and "student" means `sleep/` (self-work).

---

## 0. Headline findings

1. **The notebooks became fine-grained Q&A worksheets.** The old notebooks had 4–5 `## k.m` "scientific question" headings with a few prose/code cells. The new ones have a two-level hierarchy: `## N. <workflow stage>` sections, each containing many `### N.M <question or task>` cells, and each question is followed by exactly one answer cell. Cell counts grew 3–10×. For example, NB1 went from 35 to 115 cells and NB4 from 32 to 189.
2. **The student notebooks are now generated mechanically from the solved notebooks.** The two variants have identical cell counts, identical cell order and identical cell tags. Every cell tagged `solution` is replaced by `- answer here` (markdown) or `# answer here` (code), and no other cell is changed. Only the Colab badge URL differs besides that. This is new: before, student notebooks were only question headings with no code or model at all.
3. **There is a new cell-tag scheme**: `section`, `exercise-question`, `exercise-question`+`given-answer`, `given`, `solution`. It exists nowhere else in the repo, and no generator script is committed.
4. **Model variables were renamed course-wide:**
   - `Reaction` → `y`
   - `intercept`/`slope`/`sigma` → `b0`/`b1`/`sd_y`
   - `mu` stays `mu` in NB1–3 but becomes `mu_y` in NB4–5
   - Hierarchical: `participant_intercept_z/_sd` (non-centered) → centered `mu_b0`/`sd_b0`/`b0[participant]`
   - Prior constants are stored in named Python variables (`mu_b0`, `sd_b0`, `mu_sd_y`, `mu_mu_b0`, `sd_sd_b0`, …).
   - `pm.Exponential(..., lam=…)` → `pm.Exponential(..., scale=…)`.
   - `target_accept` was removed everywhere.
5. **Hierarchical models switched to centered parameterization**, and the `population_mu` Deterministic was dropped. A scientifically meaningful derived quantity was added in NB5 (`change_7 = 7 * b1`). The README's modeling note was updated for the parameterization. However, its claim that "hierarchical notebooks (4 onward) define `population_mu`/`mu`" is now **stale**, as is its question-numbering description.
6. **Criteria first, then check.** Every check is preceded by explicit criteria: prior predictive, sampling diagnostics, posterior predictive, and power-scaling. Criteria are established in NB1 and referenced ("criteria established in Notebook 1") or extended (NB4's criterion 4) later.
7. **Plot helpers were slimmed.** `plot_population` is removed wherever it is unused (NB3–5, but it survives unused in NB2). `plot_participants` gained `coords=None` in the hierarchical notebooks, and `y_obs="y"`.
8. **Several defects were introduced** that should not be propagated (details in §8):
   - `print(model)` in PyMC 6.3.2 prints only `<pymc.model.core.Model object at 0x…>`. NB4 calls it 13 times and teaches it as "the textual representation".
   - `azp.plot_dist`/`azp.plot_forest` calls in NB4–5 omit `ci_kind="hdi"`, so they draw 90% **ETIs** (the arviz-base default `ci_kind` is `"eti"`). This breaks the AGENTS.md 90%-HDI rule.
   - Stale numbers: NB1's answer says 257–283 ms but its output is 254.8–281.5. NB4 hard-codes NB1's slope HDI as (7.94, 14.07), but NB1's output is (8.20, 14.46).
   - NB4 has hedged answers of the form "Yes, provided the executed notebook shows…".
   - The student NB1 uses a wrong `FIG_DIR` path, `../../Slides` from `sleep/`.

---

## 1. Structural and organizational changes

### 1.1 Cell counts (before → after; student and solved are now identical)

| NB | student before | solved before | both after | md / code after |
|---|---|---|---|---|
| 01 | 20 | 35 | **115** | 91 / 24 |
| 02 | 17 | 32 | **61** | 42 / 19 |
| 03 | 17 | 34 | **52** | 36 / 16 |
| 04 | 18 | 32 | **189** | 146 / 43 |
| 05 | 17 | 33 | **98** | 78 / 20 |

Markdown volume in the solved notebooks went from about 520–575 words each to 1,015–2,321 words. Individual cells are short; the growth comes from the number of question/answer pairs.

### 1.2 Heading scheme

**Before**: after the setup, flat `##` headings numbered with the notebook number, each carrying a question in the body. Example from old NB1:
```
## 1.1 Prior implications
What reaction times and daily sleep-deprivation effects are plausible before seeing the data?
## 1.2 Population effect
## 1.3 Predictive adequacy
## 1.4 Prior sensitivity
## 1.5 Missing structure
```

**After**: numbering restarts at 1 in every notebook, with sections `## N.` and questions `### N.M`.
- NB1–3 use `## N. <Stage> — <Question?>`:
  - `## 1. Model — What model should we start with?`
  - `## 2. Prior predictive check — What does the model imply before seeing the outcomes?`
  - `## 3. Fit — What parameter values are compatible with the data?`
  - `## 4. Diagnose — Did posterior sampling work adequately?`
  - `## 5. Interpret — What have we learned from the fitted model?`
  - `## 6. Prior sensitivity — Would modest changes in the priors alter our conclusions?`
  - `## 7. Posterior predictive check — Can the fitted model reproduce the data?` (NB1)
  - `## 3. Fit and diagnose — Can the model sample reliably?` (NB2 and NB3 merge fit and diagnose)
- NB4–5 (later commits) drop the question suffix and use short imperative/noun phrases:
  - NB4: `## 1. Build a varying-intercept model`, `## 2. Examine the model`, `## 3. Prior predictive check`, `## 4. Fit the hierarchical model`, `## 5. Diagnose the fit`, `## 6. Examine the fitted hierarchy`, `## 7. Posterior predictive check`, `## 8. What limitation remains?`
  - NB5: `## 2. Check the prior implications`, `## 3. Fit and diagnose the model`, `## 6. Posterior predictive check — participant trajectories`, `## 7. Posterior predictive check — overall distribution`
  - NB2's first section also has no suffix: `## 1. Change the slope prior`.
- Question cells are `### N.M` followed by a question or an imperative task, optionally with a one- or two-sentence body:
  - Questions: `### 5.3 What baseline reaction times are credible?`
  - Tasks, which end with a period: `### 2.3 Generate prior predictive reaction times.`, `### 1.10 Add \`days\` to the model.`
  - NB4 and NB5 often use a bare heading with no body, e.g. `### 3.1 Sample from the posterior.`
  - NB3 once uses an unnumbered question line, `Where is the difference between the two priors most important?` (cell 13).
- Cross-references now use "Question 2.4", "Notebook 1" (capitalized), and "criteria established in Notebook 1".

### 1.3 Workflow order per notebook (after)

| NB | Order of sections |
|---|---|
| 1 | Model (incl. prior elicitation) → Prior predictive → Fit → Diagnose → Interpret (plot_dist of each param + `plot_population(mu)`) → Prior sensitivity → Posterior predictive |
| 2 | Change slope prior → Prior predictive → Fit+diagnose → Posterior predictive → Prior sensitivity |
| 3 | Change tail behavior (incl. prior density comparison plot) → Prior predictive → Fit+diagnose → Posterior predictive → Prior sensitivity |
| 4 | Build model incrementally → Examine model (`print(model)`, `model_to_graphviz`) → Prior predictive (param priors + observable) → Fit → Diagnose (population + participant subset) → Examine fitted hierarchy (`plot_dist`, `plot_forest`, HDI-width comparison) → Posterior predictive → What limitation remains (subset of `mu_y` trajectories) |
| 5 | Read supplied model (+graphviz) → Prior implications (param priors, `change_7` forest, observable) → Fit+diagnose (population + all-participant screen + subset) → Examine slope hierarchy → Expected trajectories (`mu_y`) → PPC trajectories → PPC overall distribution (ECDF) |

The common skeleton is **Model → Prior predictive → Fit → Diagnose → Interpret → Posterior predictive**, with prior sensitivity and a "limitation / next step" added where they serve the notebook's goal.
- In NB2 and NB3, prior sensitivity comes **after** the PPC and is explicitly motivated by it: "A posterior predictive failure tells us that the fitted model does not reproduce an important feature of the data, but it does not by itself identify which assumption is responsible."
- In NB1 it comes before the PPC.
- The old "Missing structure" / "Limits of prior tuning" / "Structural limitation" closing sections of NB1–3 were removed. The forward pointer survives as the final Q&A (NB1 7.6, NB3 4.2) or as a dedicated section (NB4 `## 8. What limitation remains?`).

### 1.4 Setup block

- **Title and intro** now link to the previous notebook and state the notebook's purpose. NB2 and NB3 titles became questions.
  - NB2 before: `# Sleep deprivation 2 — Informative slope prior`
  - NB2 after: `# Sleep deprivation 2 — Can the workflow reveal an inappropriate prior?` plus "In Notebook 1 we used a broad prior … The purpose of this notebook is to see whether the Bayesian workflow reveals that the new prior is inappropriate."
  - NB3: `# Sleep deprivation 3 — Can heavy tails make a skeptical prior more robust?`
  - NB4 and NB5 keep descriptive titles but rewrite the intro. NB5: "Notebook 4 introduced a hierarchical model in detail. Here the full model is supplied up front. The new task is to **read a hierarchical model**, run the familiar Bayesian workflow, and identify which posterior quantities answer particular questions."
  - The old student intros sometimes differed from the solved intros (NB6 still does). They are now identical.
- **Data prose is trimmed progressively.** NB1–2 keep all three paragraphs. NB3 and NB4 drop "The intercept prior is therefore a prior on baseline reaction time…". NB5 drops the whole "zero point is scientifically meaningful" paragraph.
- **Data heading.** NB1 changed `## Data` → `### Data`, so the data section now sits under `## Setup`. NB2–5 keep `## Data`. This is inconsistent (§8).
- **Imports.** `from matplotlib.lines import Line2D` and `from matplotlib.patches import Patch` were removed from the student notebooks, where they were unused leftovers. `compute_log_density` is imported only where power-scaling is used (NB1–3). `scipy.stats` is imported only in NB3.
- **Participant index.**
  - NB4 builds it as an exercise (1.3), with a `participant_to_idx` dict and `print`s.
  - NB5 moves it into the data-loading cell with sanity asserts:
    ```python
    participants = sorted(sleep["Subject"].unique(), key=int)
    participant_to_idx = {participant: i for i, participant in enumerate(participants)}
    participant_idx = sleep["Subject"].map(participant_to_idx).to_numpy()
    assert participant_idx.min() == 0
    assert participant_idx.max() == len(participants) - 1
    assert np.array_equal(np.asarray(participants)[participant_idx], sleep["Subject"].to_numpy())
    print(f"{len(participants)} participants, {len(sleep)} observations")
    ```
- **Plotting-helper block** (details in §4). In NB1–2 it is multi-cell (`### Plotting helpers` / `#### Format colors` / `#### plot_population` / `#### plot_participants`). In NB3–5 it is a single cell under `### Plotting helper` with a one-sentence description.
- **NB-specific extra data view (NB4 only).** `### A different look at the data` is a baseline-vs-day-7 scatter from `sleep.pivot(...)`, followed by "Participants who are relatively fast at baseline also tend to be relatively fast later in the experiment." It motivates varying intercepts without repeating the raw-trajectory plot, which the README restricts to NB1.

---

## 2. Content and pedagogical changes

### 2.1 Q&A granularity and answer style
- Each question cell is followed by exactly one answer cell.
- Answers are **short and declarative**: a bare API name (`` `pm.sample_prior_predictive`. ``), a bold key term ("The **prior predictive distribution**."), a variable name (`` `mu_b1`. ``), a bulleted classification (NB1 1.2), or 1–3 sentences with a bolded numeric result ("Approximately **8–14 ms/day** of slowing.").
- Interpretive answers begin with a verdict word and then justify it: "Broadly, yes.", "No. The main problem is the third criterion.", "Not convincingly.", "Not fully.", "Broadly, but with an important warning."
- NB1 teaches **conceptual vocabulary before API**. Pairs such as "What distribution …?" → "The prior predictive distribution" are followed by "What PyMC function …?" → `pm.sample_prior_predictive`, and then the code task. NB2 and NB3 drop the API-name questions and name the function in the task text instead ("Use `pm.sample_prior_predictive` to draw 500 samples…").
- **Prior elicitation is a worked calculation** from a stated plausible range. NB1 1.3: "almost all alert reaction times are between 50 and 450 ms. What Normal distribution would put approximately 95% of its probability between those two extremes?" → "The midpoint is 250 ms, and 50–450 ms is approximately $250 \pm 2(100)$ ms". The same pattern appears in NB1 1.5, NB2 1.2 (±2 ms/day → Normal(0, 1)) and NB4 1.14/1.19.
- **Model-role classification** (NB1 1.2): classify `days`, `y`, `b0`, `b1`, `sd_y`, `mu` as input data, observed outcome, unknown parameter, or deterministic calculation.
- The model is shown as display math **before** the code, one equation per `$$` block, with `\operatorname{Normal}` and `\mathrm{days}_i`. Notation:
  - Population model: `sd_y`, `b_0`, `b_1`, `\mu_i`.
  - Hierarchical models: `\mu_{y,i}`, `b_{0,s[i]}`, `b_{0,s} \sim \operatorname{Normal}(\mu_{b0}, sd_{b0})`, "Here `s[i]` identifies the participant who produced observation `i`."
  - The old notation (`\alpha`, `\beta`, `u_{0,s}`, `\tau_0`, `N(...)`, one-line `$$…$$`) was removed.

### 2.2 Criteria first, then check (repeated in every notebook)
- **Prior predictive.** NB1 2.4 establishes three criteria:
  > 1. Predicted reaction times should not routinely be physically impossible. 2. Reaction times near the beginning of the experiment should mostly occupy a broadly plausible range. 3. The model should allow substantial changes over the seven days without routinely generating absurd trajectories. The goal is broad plausibility, not tuning the priors to reproduce the observed data.

  NB2 asks students to recall these criteria (2.3) and then restates them in a `given` cell. NB3 references them. NB4 3.1 restates them and adds "4. it should allow meaningful differences among participant baselines without routinely producing implausibly large between-participant differences." NB4 3.5 adds per-hyperparameter criteria. NB5 2.1 adds slope-hierarchy criteria ("avoid making enormous seven-day changes routine").
- **Sampling.** NB1 4.1: "no divergences, $\hat R$ values no larger than about 1.01, bulk and tail effective sample sizes comfortably in the hundreds or more, and traces in which the chains mix together…". Later notebooks say "criteria established in Notebook 1". This replaced the old boilerplate cell "Do not interpret the fit until the sampler diagnostics are acceptable…", which appeared in every notebook.
- **Posterior predictive.** NB1 7.4 lists: participants' overall levels; changes across days; observation-to-observation variation; "Pay particular attention to discrepancies that persist across many observations from the same participant rather than isolated misses." NB4 7.1 restates these and names "the main new question" for the notebook.
- **Power-scaling.** NB1 6.6 gives the 0.05 screening threshold and the meaning of the diagnosis labels before the table is read.

### 2.3 Distinguishing uncertainty in the mean from predictive variation (AGENTS rule, now made explicit)
- NB1 5.10: "Is the uncertainty shown by the bands in this plot uncertainty about the mean or uncertainty about future data?" → "It is uncertainty about the **population-average mean reaction time** `mu`. It does not include the residual variability…"
- NB5 1.10: "What is the difference between `mu_y` and `y`?" NB5 6.2: "What is added when we move from `mu_y` to posterior predictive `y`?"
- NB5 splits the PPC into two sections, each answering a different question: participant trajectories, and the overall distribution ("We now pool all observations and ask a different question: does the Gaussian likelihood reproduce the overall distribution of reaction times?").

### 2.4 Scaffolding changes along the sequence (deliberate)
- **NB1**: students write everything, including prior constants, the model, sampling, diagnostics and every plot. Only the power-scaling bookkeeping (`compute_log_likelihood` + `compute_log_density`) is `given`.
- **NB2/NB3**: the unchanged prior constants are `given` ("The remaining prior constants are unchanged from Notebook 1 and are supplied."). Students write the model, sampling, checks and interpretation. NB3's density-comparison plot is `given`.
- **NB4**: a very granular, incremental model build. The empty model comes first, then one `with model:` block per node. Each node gets three questions: what the parameter represents, which dims it uses, and which distribution it has. Next come indexing (`b0[participant_idx_data]`), building the expression, and adding the Deterministic. This is the notebook's teaching goal (first hierarchical model), and 1.4 says so: "A PyMC model does not have to be written in one `with pm.Model():` block… This lets us inspect the model as it grows."
- **NB5**: the model, prior sampling, sampling, diagnostics and PPC code are all `given` (16 `given` markdown and 15 `given` code cells). Students answer interpretive questions and write only the posterior plots: `plot_dist`, `plot_forest`, `plot_participants(... "mu_y")`. Stated goal: "read a hierarchical model".

### 2.5 What was removed or trimmed, and why
- **Repeated explanatory boilerplate.** Examples: "Before fitting, ask what reaction times the priors make plausible. Each panel is one participant…", "Now generate new reaction times from the fitted model. The layout is the same…", and "The chapter uses power-scaling to ask…". These were replaced by criteria questions, or the explanation was moved once into NB1.
- **Outcome-announcing prose.** Old NB2 ended with "This is intentionally a prior experiment… compare the `slope` estimate here with notebook 1's…". Old NB5 ended with "reaction times are positive and right-skewed. The next branch asks whether a positive-only lognormal observation model is a useful alternative." These were replaced by questions whose answers come from the actual outputs.
- **Plots that did not serve the teaching goal.**
  - NB2 and NB3 dropped `plot_population(idata, "mu")`, and their `plot_population` definitions (NB2 keeps the definition, now unused).
  - NB1 dropped `azp.plot_psense_dist` and keeps only `psense_summary`. NB2 and NB3 keep the plot.
  - NB4 and NB5 dropped `plot_population(idata, "population_mu")`.
  - NB4 replaced the all-participant `plot_participants(idata, "posterior", "mu")` with a 6-participant subset in the "limitation" section, used to show parallel slopes.
- **Model machinery.** Non-centered `_z` variables, the `participant_intercept` Deterministic wrapper, the `population_mu` Deterministic, and `target_accept`.
- **The NB5 LKJ note** moved from a separate paragraph into the model description and was reworded ("does not estimate whether those two characteristics are correlated across participants").

### 2.6 Answers grounded in the executed outputs, and honest about nuance
- NB3 2.3: "Not convincingly. … The heavy tails make much larger slopes possible, but those slopes are rare and therefore do not dominate the 50% or 90% prior predictive intervals."
- NB5 2.5: "Broadly, but with an important warning. … its 90% bands reach below zero for some late-day predictions … We will proceed while retaining that limitation rather than treating the prior check as an unqualified pass."
- NB5 7.4 reverses the old narrative. Old: the Gaussian model fails on right skew, which motivates the lognormal model. New: "Broadly, yes. The observed ECDF lies close to the posterior-predictive ECDFs … This marginal check therefore does **not** show a decisive Gaussian failure. It also cannot establish that Gaussian residuals are correct conditionally within participants. Notebook 6 can investigate what changes when reaction times are modeled with positive support and multiplicative rather than additive variation." This **constrains NB6's framing** (see §7).
- NB2 3.4 and NB3 3.3 teach that clean sampling does not validate a model: "an inappropriate prior does not necessarily cause a sampling failure. We need the other parts of the workflow to evaluate the model itself."
- NB5 answers cite concrete output values ("every reported population-level R-hat is 1.00 … ESS values are all comfortably above 2,800", "participants 308, 337, and 372", "7.94–14.71 ms/day"), and these match the committed outputs. NB4's answers are hedged instead (§8).

### 2.7 Tone
The prose is concise, second-person-plural ("We will…"), and question-driven, following the AGENTS.md "Critiquing and improving teaching notebooks" section. New methods get a short `given` explanation introduced by a rhetorical question tagged `given-answer`. NB1 6.1: "We did not cover this method in the lecture, so here we will introduce it before using it." It is followed by a two-paragraph conceptual explanation of power-scaling ($p^\alpha$, importance reweighting).

---

## 3. Code and modeling changes

### 3.1 Renaming (substantive for students, mechanical for the math)

| Old | New (NB1–3) | New (NB4–5) |
|---|---|---|
| observed `"Reaction"` | `y = pm.Normal("y", …)` | same |
| `intercept` | `b0` | `mu_b0` (population center) and `b0` (per participant, `dims="participant"`) |
| `slope` | `b1` | NB4: scalar `b1`; NB5: `mu_b1`, `sd_b1`, `b1[participant]` |
| `sigma` | `sd_y` | `sd_y` |
| `mu` | `mu` | **`mu_y`** |
| `participant_intercept_sd` | — | `sd_b0` |
| `participant_intercept_z`, `participant_intercept` | — | removed (centered `b0`) |
| `population_mu` | — | **removed** |
| `pidx = pm.Data("participant_idx", …)` | — | NB4: `participant_idx_data`; NB5: `pidx` (inconsistent Python names; PyMC name is `"participant_idx"` in both) |

Before (old NB1):
```python
intercept = pm.Normal("intercept", mu=250, sigma=100)
slope = pm.Normal("slope", mu=0, sigma=20)
sigma = pm.Exponential("sigma", lam=0.02)
mu = pm.Deterministic("mu", intercept + slope * days, dims="obs_id")
pm.Normal("Reaction", mu=mu, sigma=sigma, observed=sleep["Reaction"].to_numpy(), dims="obs_id")
```
After (NB1):
```python
b0 = pm.Normal("b0", mu=mu_b0, sigma=sd_b0)
b1 = pm.Normal("b1", mu=mu_b1, sigma=sd_b1)
sd_y = pm.Exponential("sd_y", scale=mu_sd_y)
mu = pm.Deterministic("mu", b0 + b1 * days, dims="obs_id")
y = pm.Normal("y", mu=mu, sigma=sd_y, observed=sleep["Reaction"].to_numpy(), dims="obs_id")
```

### 3.2 Prior constants live in named variables
- Pattern: `mu_<param>`, `sd_<param>`, `nu_<param>` for priors. For hyperpriors: `mu_mu_b0`, `sd_mu_b0`, `sd_sd_b0`, `mu_mu_b1`, `sd_mu_b1`, `sd_sd_b1`.
- `mu_sd_y` is the prior mean of `sd_y`, and it is passed as `scale=`.
- NB5 groups these constants with comments ("# Hyperprior constants for the intercept hierarchy") above the `with pm.Model` block.
- `pm.Exponential` is always parameterized by `scale=` (the mean), matching how the prior is elicited ("expect its mean to be 50 ms").

### 3.3 Prior values harmonized across notebooks (a substantive statistical change)
- `sd_y` in NB4/NB5 went from `Exponential(lam=0.04)` (mean 25 ms) to `Exponential(scale=50)`. This matches NB1 and is taught as reuse: NB4 1.32, "What prior mean did we use for `sd_y` in Notebook 1?"
- `sd_b0` stays at scale 25 (old `lam=0.04`). `sd_b1` stays at scale 10 (old `lam=0.10`).
- NB4/NB5 `b1`/`mu_b1` keep Normal(0, 20), explicitly "the broad slope prior from Notebook 1".

### 3.4 Parameterization
The hierarchies in NB4 and NB5 changed from non-centered to **centered**.
- Before (NB5):
  ```python
  participant_intercept_z = pm.Normal("participant_intercept_z", 0, 1, dims="participant")
  participant_intercept = pm.Deterministic("participant_intercept", participant_intercept_sd * participant_intercept_z, dims="participant")
  ```
- After:
  ```python
  mu_b0 = pm.Normal("mu_b0", mu=mu_mu_b0, sigma=sd_mu_b0)
  sd_b0 = pm.Exponential("sd_b0", scale=sd_sd_b0)
  b0 = pm.Normal("b0", mu=mu_b0, sigma=sd_b0, dims="participant")
  ```

The choice is verified by diagnostics: 0 divergences, R-hat 1.00, and bulk/tail ESS in the thousands in both notebooks. NB5 3.3 concludes: "The centered hierarchy is computationally reliable for these data." The README now says centered vs non-centered is "chosen according to the notebook's teaching purpose and verified with sampling diagnostics rather than imposed as a course-wide rule."

### 3.5 Deterministics
- `population_mu` was removed in NB4 and NB5, so there is no "typical participant" curve.
- `mu`/`mu_y` stays as the per-observation expected value.
- NB5 added **`change_7 = pm.Deterministic("change_7", 7 * b1, dims="participant")`**, commented "Useful derived quantity: expected change across all seven days". It is asked about (1.11: "Give its units and interpretation"), plotted in the prior (`plot_forest(prior, group="prior", …)`), and plotted in the posterior. This applies the AGENTS "scientifically meaningful `pm.Deterministic`" rule.

### 3.6 Sampling
Every notebook now uses the same call:
```python
pm.sample(draws=1000, tune=1500, chains=4, random_seed=RANDOM_SEED)
```
`target_accept` (0.90/0.92/0.95) was removed everywhere. In NB1 the settings are a student task: "Use `pm.sample` to draw 1000 samples in each of 4 chains … with 1500 tuning samples."

### 3.7 Diagnostics
- **Population models (NB1–3):**
  - Divergence count: `int(idata["sample_stats"]["diverging"].sum().item())`.
  - `azs.summary(idata, var_names=[...], ci_prob=0.90, ci_kind="hdi", round_to=2)`, reformatted to one argument per line.
  - `azp.plot_trace_dist(idata, var_names=[...])`.
  - A "Did sampling succeed?" Q&A.
- **Hierarchical models (NB4–5) add:**
  - A population-level summary stored as `population_summary` (NB4 reuses it later for an HDI-width comparison) plus a trace plot.
  - A rhetorical question on why not to plot all participants (NB4 5.5).
  - The `coords` argument taught (NB4 5.6).
  - A representative subset `[participants[0], participants[len(participants)//2], participants[-1]]` passed as `coords=diagnostic_coords` to both `azs.summary` and `azp.plot_trace_dist`.
  - NB5 also adds an **all-participant screen**:
    ```python
    participant_diagnostics = azs.summary(idata, var_names=["b0", "b1"], kind="diagnostics", round_to=2)
    display(pd.DataFrame({"value": [participant_diagnostics["r_hat"].max(),
                                    participant_diagnostics["ess_bulk"].min(),
                                    participant_diagnostics["ess_tail"].min()]},
                         index=["largest R-hat", "smallest bulk ESS", "smallest tail ESS"]))
    ```

### 3.8 Prior predictive
- NB1–3: `pm.sample_prior_predictive(draws=500, var_names=["y"], random_seed=RANDOM_SEED)` followed by `plot_participants(prior, "prior_predictive", "y")`. The plotting is now a separate cell and a separate student task.
- NB4–5 also sample the parameters (`var_names=["mu_b0","sd_b0","b0","b1","sd_y","mu_y","y"]` in NB4) and plot **parameter-level priors** before the observable-scale check:
  ```python
  azp.plot_dist(prior, group="prior", var_names=["mu_b0", "sd_b0", "b1", "sd_y"], ci_prob=0.90, point_estimate="mean")
  azp.plot_forest(prior, group="prior", var_names=["change_7"], combined=True, ci_probs=(0.50, 0.90), figure_kwargs={"figsize": (7, 6)})
  ```
  Some sampled variables are never used: `b0` and `mu_y` in NB4; `b1` and `mu_y` in NB5.
- NB3 adds a supplied density comparison of Normal(0, 1) vs Student-t(7, 0, 1) using `scipy.stats`. The x-range was widened from ±4 to ±6 to show the tails.

### 3.9 Posterior interpretation
- NB1 uses one `azp.plot_dist(idata, var_names=["b0"], ci_prob=0.90, ci_kind="hdi")` per parameter, each followed by a "what range is credible?" question answered from the summary HDI. It then plots `plot_population(idata, "mu")` and asks the mean-vs-predictive question.
- NB4–5 use `azp.plot_dist(..., ci_prob=0.90, point_estimate="mean")` for scalars. **`ci_kind` is omitted, so these plots show 90% ETIs** (§8).
- NB4–5 use `azp.plot_forest(idata, var_names=["b0"|"b1"|"change_7"], combined=True, ci_probs=(0.50, 0.90), figure_kwargs={"figsize": (7, 6)})` for participant vectors, also without `ci_kind`.
- NB4 6.12 computes an HDI-width comparison against NB1 in a small DataFrame. The NB1 value is hard-coded.

### 3.10 Posterior predictive
- `pm.sample_posterior_predictive(idata, var_names=["y"], extend_inferencedata=True, random_seed=RANDOM_SEED)` followed by `plot_participants(idata, "posterior_predictive", "y")`, using the same grammar as the prior predictive check.
- NB5 changed the marginal check from `azp.plot_ppc_dist(..., kind="kde")` to **`kind="ecdf"`**, with a question on what adequate ECDF fit looks like.

### 3.11 Power-scaling
- The same bookkeeping cell is `given` in all three notebooks that use it:
  ```python
  with model:
      pm.compute_log_likelihood(idata)
      compute_log_density(idata, model=model, kind="prior", extend_inferencedata=True)
  ```
  NB2 passes a redundant `model=model` to `compute_log_likelihood`. NB3 splits the call across lines. The accompanying text is "The bookkeeping code is supplied." (NB3).
- `azs.psense_summary(idata, var_names=["b0","b1","sd_y"])` everywhere, plus `azp.plot_psense_dist(..., visuals={"dist": False})` in NB2 and NB3 only.

### 3.12 Model inspection (new in NB4–5)
- NB4 calls `print(model)` after every node, and 2.1/2.2 teach "`print(model)`" as the textual representation. In PyMC 6.3.2, `Model` defines no `__str__`. The committed outputs are literally `<pymc.model.core.Model object at 0x0000012B5C2CB6E0>`. The textual form is `model.str_repr()`, or `model` as the last expression of a cell (rich LaTeX via `_repr_latex_`). **This is a bug.**
- `pm.model_to_graphviz(model)` is used in NB4 2.4 and NB5 (given) and works (SVG output).

### 3.13 Mechanical formatting
- Multi-argument calls are reformatted to one argument per line with trailing commas: `azs.summary`, `pm.sample_prior_predictive`, `pm.sample_posterior_predictive`, `pd.MultiIndex.from_frame`.
- NB5's model body has section comments (`# Varying intercepts`, `# Varying slopes`, `# Likelihood`).

---

## 4. Plotting and figure changes

- **`y_obs="Reaction"` → `y_obs="y"`** in both helpers everywhere. This is required by the rename; students must name the observed RV `y`.
- **`plot_population`** (single panel, `plot_dim="obs_id"`) is kept only in NB1, which uses it once for `mu`. Its markdown was tidied to "Plot any model variable against days using `plot_lm`." and the docstring to "…with all raw observations." (dropping "144"). NB2 still defines it, unused, with the old docstring.
- **`plot_participants`**:
  - NB1–3 keep the signature `(dt, group, var)`. The NB3 docstring changed to "…with observed data."
  - NB4–5 use **`plot_participants(dt, group, var, coords=None)`** with `coords=coords` passed to `azp.plot_lm`, docstring "One panel per participant, optionally restricted with ArviZ coords."
  - NB4 uses it for `plot_participants(idata, "posterior", "mu_y", coords={"participant": participants[::3]})` to show parallel slopes.
  - The body is otherwise unchanged: `ci_prob=(0.50, 0.90)`, `ci_kind="hdi"`, `point_estimate="mean"`, `smooth=False`, `col_wrap=6`, `figsize=(11, 5.5)`, `sharex`/`sharey`, HDI legend, `supxlabel`/`supylabel`.
- **Helper cell layout**:
  - NB3–5 put `LM_VISUALS`, `PARTICIPANT_DAY` and `def plot_participants` in one `given` cell under `### Plotting helper`, with a one-line description. NB3: "We will use the same participant-level predictive plot as in the previous notebooks." NB4: "The participant plotting helper now accepts an optional `coords` argument…" NB5: "The participant plotting helper is supplied…"
  - NB1–2 keep the older four-cell layout.
  - The comment `# orange mean line, blue 50% and 90% HDI bands, black observed points.` survives only in NB1–2.
- **Figure saving**:
  - Only NB1 saves a slide figure: `save_slide_figure(fig, "data")`, which was already present in solved NB1. The revision **added the `FIG_DIR`/`save_slide_figure` block and the call to the student NB1** because it is a mechanical copy of solved.
  - The student copy keeps `FIG_DIR = Path("../../Slides/figures") if Path("../../Slides").is_dir() else Path("figures")`. That path is correct for `sleep/solved/` but wrong for `sleep/`, where it should be `../Slides`. Run from `sleep/`, it silently falls back to `sleep/figures/`.
  - No other notebook gained `save_slide_figure`, and no new SVGs were committed.
  - The slides reference only one sleep figure (`figures/01_linear_baseline_data.svg`, `Slides/slide_deck.typ:861`). Consistent with AGENTS ("Save only figures the slides use"), **NB6–12 need no `save_slide_figure` unless slides are added.**
  - NB1's data plot now sits under `### Data` inside `## Setup`, so by the AGENTS slug rule its section would be "setup", not "data". The file name was not changed.
- **Other figure changes**:
  - New in NB4: the baseline-vs-day-7 scatter.
  - New in NB4–5: `plot_forest` of participant vectors, and `plot_dist(group="prior")` for hyperparameters.
  - NB5: ECDF PPC instead of KDE.
  - NB3: prior density comparison (existed before, now `given`).

---

## 5. Student ("self-work") versus solved

### 5.1 Before the revision
- Student notebooks had the setup, data, helpers and **only the bare `## k.m` question headings**: no model, no code and no sub-questions. Solved notebooks had roughly twice as many cells.
- Student intros sometimes differed from the solved intros (still true in NB6: "Changing the likelihood changes the scale…" vs "Replace the Gaussian likelihood with a lognormal likelihood…").
- Student imports included unused `Line2D` and `Patch`.

### 5.2 After the revision
- **The student notebook is cell-for-cell identical to the solved one**: same count, order, types and tags. There are exactly two kinds of difference:
  1. Cell 0: the Colab badge URL (`…/sleep/solved/NN_….ipynb` → `…/sleep/NN_….ipynb`).
  2. Every cell tagged `solution` becomes `- answer here` (markdown) or `# answer here` (code). I verified that all `solution` cells, and only those, are replaced, in all 5 notebooks.
- **Outputs are all cleared** and `execution_count` is `None` in the student notebooks, as the student README intends. Solved notebooks are executed with strictly sequential execution counts (a clean top-to-bottom run).
- **Leftovers of the copy step**: the student notebooks still carry per-cell `metadata.execution` timestamps (e.g. 24 cells in NB1) and the notebook-level `metadata.widgets` state (10–16 KB) from the solved run. This is harmless but is metadata churn (AGENTS: avoid irrelevant metadata churn).
- The kernelspec display name varies: "bayes-short-course (3.12.12)" for NB1–3 and "Python 3" for NB4–5. The solved runs were done locally on Windows (object addresses such as `0x0000012B…`).

### 5.3 Cell-tag scheme (new; used for the student/solved split)

| Tag(s) | Used for | In student version |
|---|---|---|
| none | Setup/data/helper cells in NB1–2 only | kept |
| `given` | Setup/data/helper cells (NB3–5); supplied explanations, criteria lists and model statements; supplied code (prior constants, bookkeeping, and in NB5 the whole model and workflow). In NB5 even `### N.M` task headings whose code is supplied are `given` | kept |
| `section` | `## N. …` section headings | kept |
| `exercise-question` | `### N.M …` prompts (and NB3's one unnumbered prompt) | kept |
| `exercise-question` + `given-answer` | Prompts whose answer is supplied, either in the same cell (NB1 6.3, 6.6; NB4 5.5, 6.9) or in the next `given` cell (NB1 1.1 → model equations; NB1 2.4 → criteria; NB3 1.1, 5.1) | kept |
| `solution` | Answer cells (markdown or code) | replaced by placeholder |

Tag counts by notebook:

| NB | `exercise-question` | `solution` | `given` | `section` | `given-answer` | untagged |
|---|---|---|---|---|---|---|
| 1 | 41 | 25 md + 16 code | 5 | 7 | 6 | 15 |
| 5 | 30 | 25 md + 5 code | 31 | 7 | — | — |

The share of `given` cells grows along the sequence (see §2.4).

**"Recall, then reveal" pattern (NB2 2.3 and 4.3).** A recall question ("What criteria did we establish in Notebook 1…?") has a `solution` answer, immediately followed by a `given` cell that restates the full criteria. In the student version the reveal sits right below the `- answer here` placeholder. This looks intentional (recall, then consolidate), but the solved `solution` cell is then partly redundant.

---

## 6. README changes

- **Only one line changed** (in commit 078547f, `sleep/solved/README.md`, "Modeling notes"):
  - Before: "We use independent, **non-centered** hierarchical priors for participant intercepts and slopes instead…"
  - After: "We use independent hierarchical priors… **Centered or non-centered parameterizations are chosen according to the notebook's teaching purpose and verified with sampling diagnostics rather than imposed as a course-wide rule.**"

  This is a forward-looking convention for NB7–12, which are currently all non-centered (`_z` variables).
- `sleep/README.md` (student) was not changed. Its description ("the same setup, data loading, plotting helpers, and numbered scientific questions as `solved/`, with the model-building and analysis code left for students to fill in. Outputs are intentionally cleared") still holds. The exception is NB5, where the model code is supplied.
- **Stale README statements.** These predate the instructor's revisions (written in 9fda4cd) and now conflict with NB4–5:
  - "Each notebook is organized around numbered scientific questions (`1.1`, `1.2`, … in notebook 1; `2.1`, `2.2`, … in notebook 2)." Numbering now restarts per notebook: `## 1.`, `### 1.1`, … in every notebook.
  - "Hierarchical notebooks (4 onward) define two `pm.Deterministic`s for the mean structure: `population_mu`/`population_mean_rt` … and `mu`/`mean_rt`…" NB4–5 define only `mu_y` (plus `change_7`). There is no `population_mu`.
  - "Population-level trends … use `plot_population`. Both helpers are defined once per notebook in a 'Plotting helpers' cell." NB3–5 define only `plot_participants`, in a "Plotting helper" cell.
  - The "expected reaction time" rule ("Gaussian / Student-t: `mu`") conflicts with NB4–5's `mu_y`. The lognormal/ex-Gaussian rules (`mean_rt = exp(mu + sigma**2/2)`, `mean_rt = mu + nu`) remain the only guidance for NB6–11. They will need reconciling with the new naming (`sd_y`, `mu_y`, …).
  - "Prior sensitivity (power-scaling, notebooks 1, 2, 3, 6, 7)" is still consistent: NB4–5 have none.
  - "Validation status: All 12 notebooks were executed…" NB1–5 were re-executed after the revision; NB6–12 were not.

**Implication:** the README is a partially stale description of the target style. When NB6–12 are revised, the README's "Plotting grammar", hierarchical-Deterministic paragraph, "expected reaction time" list and numbering sentence should be updated in the same change.

---

## 7. Checklist for revising NB6–NB12

Tags: **[GLOBAL]** = repository-wide convention observed consistently in the later revisions (NB3–5, or all five). **[JUDGEMENT]** = applied case by case in NB1–5. **[NB-SPECIFIC]** = do not copy blindly.

### A. Setup and preamble
1. **[GLOBAL]** Rewrite the title and intro. Link to the previous notebook in one sentence, then state the notebook's purpose or question ("The purpose of this notebook is…", "The new task is to…"). Titles may be phrased as a question (NB2, NB3); NB4–5 kept descriptive titles.
2. **[GLOBAL]** Keep the `%pip` cell, imports and `RANDOM_SEED` unchanged, except:
   - remove unused imports (`Line2D`, `Patch` are still in student NB6–12);
   - import `compute_log_density` only where power-scaling is used;
   - import `scipy.stats` only if needed.
3. **[GLOBAL]** Trim the Data prose to the NB5 form (source + day recoding). Do not repeat the raw-trajectory plot (README). Keep `## Data`, as NB2–5 do; NB1's `### Data` is the outlier.
4. **[GLOBAL for hierarchical NB7–12]** Build `participants`, `participant_to_idx` and `participant_idx`, with the three `assert`s, in the data cell (NB5 pattern). In the print, use `len(participants)`.
5. **[GLOBAL]** Use one `### Plotting helper` cell (tagged `given`) containing `LM_VISUALS`, `PARTICIPANT_DAY` and `def plot_participants(dt, group, var, coords=None)` with `y_obs="y"` and `coords=coords`. Add one sentence describing it.
   - Define `plot_population` **only if the notebook calls it.** Old NB6–11 call `plot_population(idata, "mean_rt"/"population_mean_rt")`. Decide whether that plot serves the notebook's question; if it stays, update `y_obs="y"`.
6. **[GLOBAL]** Do not add `FIG_DIR`/`save_slide_figure` unless the slides use a figure from this notebook (currently none from NB6–12). If one is added to a student notebook in `sleep/`, use `../Slides/figures`, not `../../Slides/figures`.

### B. Section and question structure
7. **[GLOBAL]** Number sections `## 1.`, `## 2.`, … and questions `### 1.1`, `### 1.2`, … restarting in each notebook.
   - Section headings follow the workflow: model → prior predictive → fit → diagnose → interpret → posterior predictive, plus prior sensitivity and "what limitation remains?" where relevant.
   - **[JUDGEMENT]** on suffix style: NB1–3 used "`## N. Stage — Question?`" and NB4–5 use short phrases. Pick one and apply it consistently to NB6–12; NB5, the latest, favors short phrases.
8. **[GLOBAL]** Make every question its own `### N.M` markdown cell tagged `exercise-question`, with an optional one-to-two-sentence body. Put exactly one answer cell after it: markdown or code, tagged `solution`.
   - Phrase task prompts imperatively with a trailing period ("### 3.1 Fit the model.").
   - Phrase interpretive prompts as questions.
9. **[GLOBAL]** Put supplied material in cells tagged `given`: explanations, criteria lists, bookkeeping code, and in "read-the-model" notebooks the model and workflow code. A prompt whose answer is supplied is tagged `exercise-question` + `given-answer`, and new methods are introduced with a rhetorical `given-answer` question (NB1 6.1, NB3 5.1). Tag setup cells `given` too (the NB3–5 practice).
10. **[GLOBAL]** Keep answers short and declarative:
    - a backticked name or bold term;
    - a verdict word ("Yes.", "No.", "Broadly, yes.", "Not fully.") followed by one to three sentences of justification;
    - numeric ranges bolded with units ("**7.94–14.71 ms/day**").

### C. Model
11. **[GLOBAL]** Show the model as display math first, one relation per `$$…$$` block, using the new notation (`y_i`, `\mu_{y,i}`, `b_{0,s[i]}`, `sd_y`, `\operatorname{Normal}`, `\mathrm{days}_i`). Add "Here `s[i]` identifies the participant…" for hierarchical models.
12. **[GLOBAL]** Rename variables:
    - `Reaction`→`y`, `intercept`→`b0`, `slope`→`b1`, `sigma`→`sd_y`.
    - Hierarchies: `mu_b0`/`sd_b0`/`b0[participant]` and `mu_b1`/`sd_b1`/`b1[participant]`.
    - Remove `participant_*_sd`/`_z`/`participant_*` Deterministics.
    - Expected value: NB4–5 use `mu_y`. **[JUDGEMENT]** for lognormal and ex-Gaussian see §8 (Q1). The README's `mean_rt` rule still stands and must be reconciled.
    - Distributional notebooks (NB8–11) will need analogous names for residual-scale hierarchies. There is no precedent yet; follow the `mu_<x>`/`sd_<x>` pattern (e.g. `mu_log_sd_y`, `sd_log_sd_y`). This is a judgement call.
13. **[GLOBAL]** Store prior constants in named variables: `mu_<p>`/`sd_<p>`/`nu_<p>`, and `mu_mu_<p>`/`sd_mu_<p>`/`sd_sd_<p>` for hyperpriors. Group them with comments above the model block (NB5). Use `pm.Exponential(..., scale=…)`.
14. **[GLOBAL]** Where elicitation is part of the lesson, elicit priors as a worked calculation from a stated plausible range ("95% between A and B → Normal(mid, (B−A)/4)"). **[NB-SPECIFIC → NB6]**: this is exactly NB6's lesson (priors on the log scale). NB1's granular elicitation Q&A is the model to follow, with the range stated in ms and converted to the log scale.
15. **[GLOBAL]** Reuse earlier priors where the model component is unchanged, and say so ("retain the broad slope prior from Notebook 1"). Supply unchanged constants as `given` ("The remaining prior constants are unchanged … and are supplied."). Do not silently change prior values between notebooks. NB4–5 changed `sd_y` from scale 25 to 50 to match NB1.
16. **[GLOBAL, per README]** Prefer the centered hierarchy when it samples cleanly, and verify with diagnostics. Switch to non-centered only when diagnostics demand it, and then explain why in the notebook. NB7–12 are currently all non-centered; each needs re-testing.
17. **[GLOBAL]** Remove `population_mu`/`population_mean_rt` unless the notebook's question needs a "typical participant" curve. Add a scientifically meaningful Deterministic when it answers a stated question (NB5's `change_7`), and ask for its units and interpretation.
18. **[JUDGEMENT]** Choose the scaffolding level from the notebook's teaching goal:
    - NB1 style (students write everything) for a new core workflow.
    - NB4 style (incremental build, dims and indexing questions) for a new modeling construct.
    - NB5 style (model supplied as `given`, students interpret and plot) for "read a bigger model".
    - Likely fits: NB6 (new likelihood and log-scale priors) is closest to NB2/NB3 (change one component, students build); NB7 closest to NB5. For NB9–11, whose theme is priors, the prior-elicitation questions probably carry the student work. NB12 (LOO) should introduce `azs.loo`/`azs.compare` with a `given-answer` explanation, as NB1 does for power-scaling.
19. **[GLOBAL for hierarchical]** Include `pm.model_to_graphviz(model)`. For a textual representation, **do not use `print(model)`**; use `model.str_repr()` or a bare `model` as the last line (§8).

### D. Prior predictive
20. **[GLOBAL]** State the criteria before plotting: refer to NB1's three criteria and add notebook-specific criteria as a numbered item (NB4 criterion 4).
21. **[GLOBAL]** Use `pm.sample_prior_predictive(draws=500, var_names=[...], random_seed=RANDOM_SEED)`. For hierarchical or new-scale models, also plot parameter-level priors, with `ci_kind="hdi"` added (see item 29):
    - `azp.plot_dist(prior, group="prior", var_names=[...], ci_prob=0.90, point_estimate="mean")`
    - `azp.plot_forest(prior, group="prior", …)` for derived per-participant quantities
22. **[GLOBAL]** Show the observable-scale check with `plot_participants(prior, "prior_predictive", "y")`, as a separate cell and task, followed by a verdict Q&A grounded in the plot.
    - **[NB-SPECIFIC → NB6/NB10/NB11]**: old NB6 prints `finite_fraction` and a `log10` range for the bad-prior demonstration. Prefer a native prior predictive display of the failure where possible, and keep the numeric print only if the plot is unreadable (overflow to inf). Ask what the criteria say.

### E. Fit and diagnostics
23. **[GLOBAL]** Use `pm.sample(draws=1000, tune=1500, chains=4, random_seed=RANDOM_SEED)` with no `target_accept`. If a model genuinely needs it (the ex-Gaussian notebooks might), keep it and explain it in a Q&A. Remove it only after verifying zero divergences.
24. **[GLOBAL]** Count divergences, then run `azs.summary(... ci_prob=0.90, ci_kind="hdi", round_to=2)` on the population-level parameters, then `azp.plot_trace_dist`, then a Q&A "Do … meet the diagnostic criteria (Notebook 1)?". The answer must quote actual values.
25. **[GLOBAL for hierarchical]** Add an all-participant screen (`azs.summary(kind="diagnostics")` → largest R-hat / smallest ESS table) plus a first/middle/last participant subset via `coords` for summary and trace.
26. **[NB-SPECIFIC → NB11]**: NB11 is "Reading a failed fit". Its diagnostics section is the lesson; the NB5 all-pass pattern does not apply. The answers must describe the failure.

### F. Interpretation
27. **[GLOBAL]** For each scientifically meaningful scalar: ask which variable represents the quantity, plot it with `azp.plot_dist(..., ci_prob=0.90, ci_kind="hdi")`, then ask what range is credible (answer from the summary's 90% HDI with units).
28. **[GLOBAL for hierarchical]** Plot participant vectors with `azp.plot_forest(..., combined=True, ci_probs=(0.50, 0.90), ci_kind="hdi")`.
29. **[GLOBAL — fix]** Always pass `ci_kind="hdi"` to `plot_dist`/`plot_forest`. The arviz-base default is ETI with 0.89, and NB4–5 omit it. Backport the fix to NB4–5.
30. **[GLOBAL]** Ask the mean-vs-predictive question explicitly whenever an expected-value plot (`mu_y`/`mean_rt` via `plot_participants(idata, "posterior", …)` or `plot_population`) precedes a predictive plot.
    - **[NB-SPECIFIC → NB6–8]**: for the lognormal model the expected value is `exp(mu + sd_y**2/2)`, not the location `mu`. This is a natural question: "Which quantity is the expected reaction time in ms?" Also, the mean line can sit above the 50% band because of skew (old NB6 prose). Ask about it rather than state it.

### G. Posterior predictive and sensitivity
31. **[GLOBAL]** Restate the PPC criteria (level, change across days, residual variation; persistent vs isolated misses), naming "the main new question" for this notebook. Then run `pm.sample_posterior_predictive(... var_names=["y"], extend_inferencedata=True, random_seed=RANDOM_SEED)` and `plot_participants(idata, "posterior_predictive", "y")`, followed by a verdict Q&A.
32. **[GLOBAL]** For marginal-distribution checks use `azp.plot_ppc_dist(idata, var_names=["y"], kind="ecdf", figure_kwargs={"figsize": (7, 4)})` (NB5 switched from `kde`; NB6–11 still use `kde`). Add a `given` "What would indicate adequate fit…" cell and a verdict question.
33. **[GLOBAL where power-scaling is used, NB6–7 per README]**
    - A `given-answer` motivation question.
    - The `given` bookkeeping cell (`pm.compute_log_likelihood(idata)` + `compute_log_density(..., kind="prior", extend_inferencedata=True)`).
    - `azs.psense_summary` (+ `azp.plot_psense_dist(..., visuals={"dist": False})` if it adds information).
    - The 0.05 threshold reminder.
    - A verdict question on the `diagnosis` column.
34. **[GLOBAL]** End with the limitation that motivates the next notebook, as a Q&A (NB1 7.6, NB4 §8, NB5 7.4), not as a closing prose paragraph. **[NB-SPECIFIC → NB6]**: NB5's final answer says the Gaussian ECDF check does **not** show a decisive failure. It motivates NB6 by *positive support and multiplicative variation*: NB5's prior predictive reached below zero. NB6's intro must not claim that the Gaussian model failed on skew.

### H. Answers, outputs, and the student version
35. **[GLOBAL]** Write solved answers **after** executing, from the actual outputs. No hedges such as "provided the executed notebook shows…" (NB4). Do not hard-code another notebook's numbers unless they match that notebook's committed output; NB4's `(7.94, 14.07)` does not.
36. **[GLOBAL]** Execute the solved notebook top to bottom (sequential execution counts) and commit it with outputs.
37. **[GLOBAL]** Generate the student notebook from the solved one:
    - copy all cells and tags;
    - replace `solution` cells with `- answer here` / `# answer here`;
    - fix the Colab badge path;
    - clear outputs and execution counts;
    - ideally also strip `metadata.execution` and `metadata.widgets`, which the current students retain (§8).
38. **[GLOBAL]** In the same change as NB6–12, update `sleep/solved/README.md`: the numbering sentence, the plotting-grammar helper sentence, the hierarchical-Deterministic paragraph, the expected-value naming, and the validation status.

### Current state of NB6–12 (from a scan of the solved notebooks), to scope the work
Every one of them still has:
- `Reaction` as the observed RV;
- `intercept`/`slope`/`sigma` names;
- `target_accept`;
- `plot_population`;
- the old `## k.m` headings;
- no tags;
- student notebooks containing only headings.

Notebook-specific items:

| Item | Notebooks |
|---|---|
| non-centered `_z` | NB7–12 |
| `population_mu`/`population_mean_rt` | NB7–11 |
| `plot_ppc_dist(kind="kde")` | NB6–11 |
| psense | NB6–7 |
| LOO | NB10, NB12 |
| `plot_forest` | NB8 already |

---

## 8. Open questions, inconsistencies, and bugs

### Bugs to fix, and not to propagate
1. **`print(model)` is useless in PyMC 6.3.2.** The committed outputs in NB4 (13 calls) and NB5 are `<pymc.model.core.Model object at 0x…>`. NB4 2.1's answer, "`print(model)`", and 1.4's "This lets us inspect the model as it grows" are therefore wrong in practice. Use `model.str_repr()` (e.g. `print(model.str_repr())`) or put `model` as the last expression.
2. **ETI instead of HDI.** `azp.plot_dist`/`azp.plot_forest` in NB4 and NB5 omit `ci_kind` and use `ci_prob=0.90`/`ci_probs=(0.50, 0.90)`. arviz-base 1.3.0 defaults to `stats.ci_kind="eti"`. NB5 4.3 asks for "the 90% HDI from the posterior summary" while the plot shows an ETI. NB1 does pass `ci_kind="hdi"`.
3. **Stale numbers in solved answers.**
   - NB1 5.3 says "Approximately **257–283 ms**", but the committed summary shows `b0` HDI 254.82–281.49.
   - NB4 6.12 hard-codes "Notebook 1 gave a 90% HDI … approximately 7.94 to 14.07 ms/day". NB1's committed output is 8.20–14.46.
   - Both look like leftovers from a different run.
4. **Hedged solved answers in NB4:**
   - 5.4 "Yes, provided the executed notebook shows no divergences…"
   - 5.10 "Yes, provided their R-hat, ESS, and traces meet…"
   - 6.13 "In the executed notebook, compare the two displayed values directly."

   The outputs give definite answers: 0 divergences, R-hat 1.0, and NB4 width 3.68 < NB1 width 6.13. NB5 shows the intended concrete style.
5. **Student NB1 `FIG_DIR`** is `Path("../../Slides/figures")`, copied from solved. It is wrong for `sleep/` and falls back to creating `sleep/figures/`.
6. **Student notebooks carry solved-run metadata**: per-cell `metadata.execution` timestamps and `metadata.widgets` state. Harmless, but notebook churn per AGENTS.

### Inconsistencies between NB1–3 and NB4–5 (which is the target?)
7. **Expected-value name**: `mu` (NB1–3) vs `mu_y` (NB4–5). For the lognormal model, `mu`/`mu_y` would be the *log-scale location*, not the expected RT. A naming decision is needed before NB6 (e.g. `mu_log_y` for the location and `mean_y` or `mean_rt` for `exp(mu + sd_y**2/2)`). The README still says `mean_rt`.
8. **Section heading suffix style**: "`## N. Stage — Question?`" (NB1–3) vs short phrases (NB4–5). There is also a slug concern: AGENTS derives figure names from `##` headings, and long question-style headings would produce unwieldy slugs if a figure were ever saved from them.
9. **Plot-helper layout**: multi-cell with `plot_population` (NB1–2; NB2's `plot_population` is unused, with the old docstring "all 144 raw observations") vs a single cell with `plot_participants` only (NB3–5). NB1–3's `plot_participants` lacks `coords=None`; NB4–5's has it. Should the `coords` signature become universal? It is harmless in population models.
10. **Setup-cell tags**: untagged in NB1–2, `given` in NB3–5.
11. **Data heading**: `### Data` (NB1) vs `## Data` (NB2–5). NB1's slide figure is saved as section "data" even though its `##` section is now "Setup".
12. **Power-scaling details**:
    - `plot_psense_dist` is present in NB2/NB3 but removed in NB1.
    - `pm.compute_log_likelihood(idata, model=model)` (NB2) vs `pm.compute_log_likelihood(idata)` (NB1, NB3).
    - The position of prior sensitivity differs: before the PPC in NB1, after it in NB2/NB3 (the latter is motivated by the PPC failure).
13. **The pm.Data variable for the participant index** is `participant_idx_data` in NB4 and `pidx` in NB5.
14. **Unused sampled variables** in the prior predictive: `b0` and `mu_y` in NB4; `b1` and `mu_y` in NB5. This conflicts mildly with the AGENTS rule that every quantity should be used.
15. **NB4 ordering**: 7.3 asks which `plot_lm` argument selects participants, but `coords` is first used in 8.3. 7.4 plots all participants.
16. **NB5 3.4 heading** says "Inspect a small subset of participant effects", but the cell also runs an all-participant screen, which 3.5's answer relies on.
17. **"Recall then reveal"** (NB2 2.3/4.3): a `solution` answer is immediately followed by a `given` restatement. Is this intended for later notebooks? NB3 and NB4 instead just refer to or restate the criteria as `given`.

### Things that probably do not generalize
18. NB4's incremental one-node-per-cell model build, with dims and indexing questions, is specific to the first hierarchical notebook. NB5 explicitly reverts to a supplied model. Do not replicate NB4's 189-cell granularity for NB7–12.
19. NB4's baseline-vs-day-7 scatter and HDI-width comparison with NB1 are notebook-specific motivators.
20. NB3's Normal-vs-Student-t density plot (scipy) is specific to the prior-tails lesson. A similar prior density or prior predictive comparison may suit NB9–11 (prior-focused notebooks); PreliZ is not pinned for the sleep notebooks.
21. NB5's `change_7` is specific to the slope model. The generalizable rule is "add a Deterministic that answers a stated question, and ask for its units".

### Unresolved scope questions
22. Should `plot_population` survive at all? The README still describes it as part of the grammar, and old NB6–11 use it for `mean_rt`/`population_mean_rt`. NB1 is the only revised notebook that uses it (for `mu`).
23. Will removing `target_accept` and centering remain viable in NB7–12 (lognormal and ex-Gaussian hierarchies, distributional scale hierarchies)? The README delegates this to diagnostics per notebook, so expect some notebooks to stay non-centered, with an explanation.
24. Should the README's lists of "notebooks 1, 2, 3, 6, 7" (psense) and "notebooks 5, 7–12" (LKJ note) be kept as they are? They are consistent so far, but depend on the scope of the NB6–12 revisions.
