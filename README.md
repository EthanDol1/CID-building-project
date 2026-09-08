# CID Building Mobility Model

Code and data for *Developing a data-informed indoor human mobility model on a network*.

This repository contains a first-order Markov model of student movement through the
Creativity and Innovation District (CID) Residence Hall at Virginia Tech, along with
the null models, analysis scripts, and data needed to reproduce the results in the
paper.

The building is represented as a network of **410 nodes** (rooms and spaces) joined by
**489 edges** (direct physical connections). Agents move between nodes according to a
Markov process whose transition probabilities are derived from **45 student time-use
diaries**. The day is split into six four-hour periods, each with its own transition
matrix; concatenating six simulated segments gives a full 24-hour trajectory at
15-minute resolution (96 time steps).

---

## Requirements

- **MATLAB R2025a or later**
- **Econometrics Toolbox** — `dtmc`, `simulate` (the Markov chain simulation)
- **Statistics and Machine Learning Toolbox** — `kruskalwallis`, `multcompare`

## Getting started

From MATLAB, with this folder as the current directory:

```matlab
setupPath
```

`setupPath` adds every folder the project needs to the MATLAB path for the current
session. It writes nothing to your MATLAB installation and does not persist, so run it
once per session. It also warns if any data file appears in more than one folder on the
path, since scripts load data files by bare name.

All generated `.mat` files are already included, so the analysis scripts can be run
directly without regenerating anything.

---

## Repository layout

```
setup/      scripts that build the model inputs, plus the .mat files they produce
models/     the four mobility models
models/lib/ shared functions used by the models and analyses
analysis/   scripts that produce the figures and statistics in the paper
data/       raw inputs (spreadsheets) and simulation output, one folder per model
results/    generated figures
```

## The four models

Each model is defined by whether it has access to the real building topology and
whether its transition probabilities come from the diary data.

| Model | Script | Topology | Transition probabilities |
|---|---|---|---|
| Full model | `models/fullModel.m` | true | diary-informed |
| Random topology | `models/randTopModel.m` | degree-preserving rewiring | diary-informed |
| Equal probability | `models/eqProbModel.m` | true | uniform over each node's edges |
| Random probability | `models/randProbModel.m` | true | uniform random weights, normalised per node |

The random topology and random probability models redraw their randomised component at
the start of every iteration, so a run samples across randomisations rather than
characterising one arbitrary draw.

Each model runs 200 iterations of a full day for all 594 residents and writes its
trajectory array to `data/<model>_data/`. The arrays are `96 x 594 x 200`: time steps
by residents by iterations, with entries giving the node number occupied.

---

## Pipeline

### 1. Build the model inputs (`setup/`)

Run in this order. Each writes a `.mat` file that later stages load. All outputs are
already committed, so this stage only needs re-running if the source data changes.

| Order | Script | Produces | Purpose |
|---|---|---|---|
| 1 | `makeBuildingData.m` | `CID_building.mat` | node list `V`, edge lists `E` / `E_num`, adjacency `A`, and `room_index` mapping each of the 594 residents to their room |
| 2 | `write_diaries.m` | `diaries.mat` | the 45 time-use diaries, and the same diaries partitioned into the six time-of-day windows |
| 3 | `diary_analysis.m` | `diary_data.mat` | self-loop probabilities and average entry counts per room type per period (Tables 3 and 5 in the paper) |
| 4 | `CID_master_list.m` | `master_list.mat` | `masterList`, the per-node table of room type and transition parameters |
| 5 | `CID_edge_dictionary.m` | `edgeDictionary.mat` | neighbour lookup per node |

`makeBuildingData.m` reads `data/CID_building.xlsx` via an absolute path set near the
top of the file. **Edit that path** before running it on another machine.

### 2. Run the models (`models/`)

Each model script is standalone and can be run on its own once stage 1 exists.

| Script | Approximate runtime |
|---|---|
| `eqProbModel.m` | under a minute |
| `randProbModel.m` | under a minute |
| `fullModel.m` | about a minute |
| `randTopModel.m` | about 30 minutes |

`randTopModel` is the slow one because it rebuilds transition matrices for every
iteration — the topology changes each time, so they cannot be cached across iterations
the way `fullModel` caches them.

Each model also contains a commented-out block that computes usage and collision
statistics (`useData`, `collisionData`). Enabling it is what produces the
`<model>_data.mat` files that `analysis/model_results.m` reads. **This block is far
slower than the simulation itself** — it compares all 594 × 593 / 2 resident pairs at
each of 96 time steps, for every iteration.

### 3. Analysis and figures (`analysis/`)

| Script | Produces |
|---|---|
| `shannon_entropy.m` | block entropy of trajectories, per model |
| `model_results.m` | usage and collision comparisons, Kruskal–Wallis tests, ranking distances |
| `survey_results.m` | survey response distributions and ratings |
| `diary_convergence.m` | convergence of diary-derived parameters as diaries accumulate |
| `gen_traj_FM.m`, `gen_traj_EP.m`, `gen_traj_RT.m` | example single-day trajectories |
| `randA_graph.m` | circle-layout plot of a randomised network |
| `leave_one_out.m` → `leave_one_out_analysis.m` | robustness check refitting the model with each diary held out (about 20 minutes) |

## Shared functions (`models/lib/`)

| Function | Purpose |
|---|---|
| `createTransitionMatrices.m` | the six time-of-day transition matrices for a given resident's room |
| `runSimulation.m` | simulates one full day by chaining the six periods; takes prebuilt `dtmc` objects |
| `createAdjacencyMatrix.m` | symmetric adjacency matrix from the node and edge lists |
| `randomizeA.m` | degree-preserving double edge swap randomisation |
| `kendallTauDistance.m` | ranking distance used to compare model output against survey rankings |

---

## Data

| Path | Contents |
|---|---|
| `data/CID_building.xlsx` | node and edge lists defining the building network |
| `data/BUILD_survey_data_public.xlsx` | 586 survey responses across four semesters |
| `data/<model>_data/*_data.mat` | trajectory arrays, `96 x 594 x 200` |
| `setup/*.mat` | model inputs produced by stage 1 |

Each model folder holds two files: `<prefix>_data.mat` with the trajectory array, and
`<model>_data.mat` with the aggregated `useData` and `collisionData` statistics that
`analysis/model_results.m` reads.

## Notes on reproducibility

- **No random seed is set.** Re-running any model produces different trajectories.
  Aggregate statistics are stable across runs, but individual trajectories and exact
  figure values will differ. Add `rng(<seed>)` at the top of a model script if you need
  bit-identical output.
- **Transition matrices are column-stochastic.** Column *i* holds the outgoing
  distribution of node *i*, so matrices are transposed at the `dtmc` call, which expects
  a row-stochastic matrix.
- The model treats each room as a single node regardless of physical size, and agents
  are goalless — both discussed as limitations in the paper.

## Citation

Dolin E, Baird TD, Kniola DJ, Pingel TJ, Tural E, Upthegrove T, Abaid N.
*Developing a data-informed indoor human mobility model on a network.*

Funded by NSF Grant #2149229.
