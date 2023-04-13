# Computational Artifact for FuzzyFlow
This repository contains everythin necessary to reproduce the results reported
in the paper **"FuzzyFlow: Leveraging Dataflow To Find and Squash Program
Optimization Bugs"**.

The artifact can be run containerized with all necessary dependencies and
environment setup through a provided Docker image.
You can find setup instructions and a guide on how to reproduce results in the
sections [Setup](#setup) and [Reproducing Results](#reproducing-results) below.
The experiment workflows themselves are described in
[Experiment Workflows](#experiment-workflows).

## Experiment Workflows
### Workflow 1 (Paper Section 6.1)
This workflow reproduces the case study 'Minimizing Input Configurations'.
In this case study we test a series of loop vectorization optimizations
(built-in optimizations in the DaCe framework) on the encoder layer from the
natural language model (Transformer) BERT. The input parameters used in the
paper are as follows:
- N = 1024
- B = 8
- H = 16
- SM = 512
- emb = 4096
- P = 64

We report the following insights in the paper:
1. The full application takes **12.1 seconds to run** with the listed input
parameters while accelerating BLAS operations with Intel MKL (median over 10 runs).
2. For a specific instance of the loop vectorization optimization, FuzzyFlow is
able to **reduce the input configuration by 75%**.
3. With the extracted and minimized cutout, AFL++ is able to run an average of
**43.7 fuzzing trials per second** (tps).
4. Considering the original application runtime of 12.1 seconds, which would lead
to 0.083 tps, this corresponds to around **528 times faster testing**.

A single Bash script in the provided artifact can be used to reproduce each of
these reported numbers. The script first runs the full application 10 times and
reports the median runtime (1). The script then extracts and minimizes a cutout
for the reported vectorization optimization, reporting the input configuration
size before and after minimization together with a number indicating by how many
percent the configuration was reduced (2). Finally, the script uses AFL++ to
fuzz the extracted cutout and reports the number of fuzzing trials per second
achieved (3 and 4).

### Workflow 2 (Paper Section 6.2)
This workflow reproduces the case study 'From Multi-Node to Single-Node'. In
this case study, we demonstrate how using the cutout extraction method employed by
FuzzyFlow, testing program transformations in a distributed, multi-node setting,
the resulting test cases can effectively reduce tests to single-node problems,
eliminating the need for multiple nodes and communication. Specifically, we
extract a test case for an optimization of the Sampled Dense-Dense Matrix
Multiplication (SDDMM) performed by forward propagation in a vanilla attention
graph neural network, designed to run in a distributed setting using MPI. Since
the optimization does not make any changes to MPI communication calls, the
resulting test case can be run without communication on a single rank/node.

A Bash script in the provided artifact automatically extracts a test case for
the discussed optimization and generates the corresponding C++ code. This can
be used to verify that the generated C++ code does not contain any MPI
communication and may be run on a single node, as shown in the (simplified)
code from Figure 6 in the paper.

### Workflow 3 (Paper Section 6.3)
This workflow reproduces the case study 'NPBench'. In this case study we use a
set of micro-benchmarks (52) from the benchmark suite [NPBench](https://github.com/spcl/npbench)
to test all of the built-in optimizations that the DaCe framework can apply to
those programs. Some types of transformations that require special hardware like
FPGAs were omitted. We use FuzzyFlow to test a total of **3,280 transformation instances**
on the entire benchmark set. We report **6 transformations** from the DaCe
framework that contain bugs according to the resulting failing test cases.

A Bash script in the provided artifact can be used to run FuzzyFlow on the
tested benchmarks and DaCe transformations. This generates all 3,280 resulting
test cases and tests them with differential fuzzing. All failing test cases are
reported and through performing a manual triage the 6 transformation bugs
reported in Table 2 of Section 6.3 can be found and reconstructed.

### Workflow 4 (Paper Section 6.4)
This workflow reproduces the case study 'Optimizing Weather Forecasts'. In this
case study we test 2 custom transformations and one built-in optimization from
the DaCe framework on a real-world application. The custom transformations were
taken from a group of engineers that were in the process of optimizing the cloud
microphysics scheme (CLOUDSC) of the European Centre for Medium-Range Weather
Forecasts' (ECMWF) Integrated Forecasting System (IFS). The engineers wrote
custom transformations to automatically extract GPU kernels and to perform loop
unrolling. We use FuzzyFlow to test each instance of these custom transformations
on the CLOUDSC application - specifically on different versions of CLOUDSC
taken from different stages of their optimization workflow. Similarly, we test
each instance of a built-in optimization from the DaCe framework that tries to
eliminiate intermediate writes on CLOUDSC.

We report the following insights in the paper:
1. 62 instances of the GPU kernel extraction transformation were tested,
**48 of which** changed program semantics.
2. Testing a single instance of a GPU kernel extraction transformation took only
**43 seconds**
3. Most semantics altering transformation instances of the GPU kernel extraction
were uncovered after only 1 or 2 fuzzing trials.
4. 19 instances of the loop unrolling transformation were tested, **one of which**
changed program semantics.
5. 136 instances of the built-in write elimination transformation were tested,
**one of which** changed program semantics.

A Bash script in the provided artifact can be used to run FuzzyFlow on CLOUDSC
for all three of the listed transformations, reproducing each of these insights.
The script first tests the GPU kernel extraction transformation on CLOUDSC,
extracting a minimal test case and demonstrating that finding a single bug only
takes 43 seconds (2). The script then tests each instance of the loop unrolling
transformation a version of CLOUDSC, demonstrating that from all tested 19
instances, the failing test case can be found (after manual triage) (4).
Finally, the script tests each instance of the write elimination transformation
on two versions of CLOUDSC. This demonstrates that all 136 instances are quickly
tested individually, each with a minimal test case. Out of all tested instances,
a few test cases fail testing and after performing triage, the bug can be
identified and reconstructed (5).

## Setup
To build and deploy the provided Docker image, run through the following steps:
1. Clonse the repository and navigate into it with your terminal. Ensure all
    submodules are cloned by running `git submodule update --init --recursive`.
2. Build the Docker image by running `docker build . -t fuzzyflow`.
3. Launch the image in an Docker container with an interactive shell using:
    `docker run --rm -it fuzzyflow`. (`--rm` removes the container again after
    exiting. If you wish for it to persist, omit this option.)

## Reproducing Results
The results in the paper may be reproduced by running the four provided
[experiment workflows](#experiment-workflows).
Each workflow can be launched through a single Bash script:
1. To run workflow 1, reproducing Paper Section 6.1, run `./run_workflow_01.sh`
inside the artifact's Docker container.
2. To run workflow 2, reproducing Paper Section 6.2, run `./run_workflow_02.sh`
inside the artifact's Docker container.
3. To run workflow 3, reproducing Paper Section 6.3, run `./run_workflow_03.sh`
inside the artifact's Docker container.
4. To run workflow 4, reproducing Paper Section 6.4, run `./run_workflow_04.sh`
inside the artifact's Docker container.
