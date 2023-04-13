#!/bin/bash

echo "========================================================================="
echo "= Running Workflow 04                                                   ="
echo "========================================================================="
echo "This workflow runs the case study for testing custom transformations"
echo "on CLOUDSC. Three types of custom transformations are tested:"
echo "  - GPU kernel extraction:"
echo "      -> One instance of this transformation is tested, demonostrating"
echo "         that finding a single bug takes less than a minute."
echo "  - Loop unrolling:"
echo "      -> 19 instances of this transformation are tested. The workflow"
echo "         demonstrates that a number of failing cases are automatically"
echo "         identified, and after manual triage, one of them stands out"
echo "         as a bug."
echo "  - Write elimination:"
echo "      -> 136 instances are tested. The workflow automatically identifies"
echo "         a number of failing cases, and manual triage of the generated"
echo "         failing cases reveals a bug."
echo "========================================================================="

echo "Testing one instance of the GPU kernel extraction transformation..."
python -m fuzzyflow.cli.xfuzz \
    -p case_studies/04_cloudsc/gpu/cloudscexp2_parallel.sdfg \
    -x case_studies/04_cloudsc/gpu/transformation.json \
    -r 100 \
    --maxd 64 \
    -o results/04_cloudsc/gpu/failures \
    --success-dir results/04_cloudsc/gpu/successes \
    --data-constraints-file case_studies/04_cloudsc/data_constraints.json

echo ""
echo ""
echo "==========================================================="

echo "Testing all loop unrolling transformation instances..."
python -m fuzzyflow.cli.xfuzzall \
    -p case_studies/04_cloudsc/loop_unroll/cloudscexp2_optim_fused.sdfg \
    -t interstate.LoopUnroll \
    -o results/04_cloudsc/loop_unroll/failures \
    --success-dir results/04_cloudsc/loop_unroll/successes \
    --data-constraints-file case_studies/04_cloudsc/data_constraints.json \
    --maxd 64 \
    -r 100

echo ""
echo ""
echo "==========================================================="

echo "Testing all write elimination transformation instances..."
echo "Testing two different program versions"
echo "Testing version 1 (60 instances)..."
python -m fuzzyflow.cli.xfuzzall \
    -p case_studies/04_cloudsc/write_elimination/cloudscexp2_parallel_refined_fused.sdfg \
    -t dataflow.TaskletFusion \
    -o results/04_cloudsc/write_elimination/v1/failures \
    --success-dir results/04_cloudsc/write_elimination/v1/successes \
    --data-constraints-file case_studies/04_cloudsc/data_constraints.json \
    --maxd 64 \
    -r 100

echo ""
echo ""

echo "Testing version 2 (74 instances)..."

echo ""
echo ""

python -m fuzzyflow.cli.xfuzzall \
    -p case_studies/04_cloudsc/write_elimination/cloudscexp2_optim_fused.sdfg \
    -t dataflow.TaskletFusion \
    -o results/04_cloudsc/write_elimination/v2/failures \
    --success-dir results/04_cloudsc/write_elimination/v2/successes \
    --data-constraints-file case_studies/04_cloudsc/data_constraints.json \
    --maxd 64 \
    -r 100

echo ""
echo ""
echo "========================================================================="
echo "= Summary                                                               ="
echo "========================================================================="
echo "Failing test cases for all transformations have been placed in the"
echo "following locations:"
echo "  - GPU kernel extraction:"
echo "     results/04_cloudsc/gpu/failures"
echo "  - Loop unrolling:"
echo "     results/04_cloudsc/loop_unroll/failures"
echo "  - Write elimination:"
echo "     results/04_cloudsc/write_elimination/failures"
echo ""
echo "To identify false positives, you may need to perform triage on the"
echo "generated offending test cases."
echo "========================================================================="

echo "Done!"
