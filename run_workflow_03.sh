#!/bin/bash

echo "========================================================================="
echo "= Running Workflow 03                                                   ="
echo "========================================================================="
echo "This workflow runs the case study testing built-in DaCe transformations"
echo "on the NPBench benchmark suite."
echo "========================================================================="

echo "Running tests, this may take some time..."
rm -rf results/04_npbench/run_1
python _run_npbench_tests.py

echo ""
echo ""
echo "========================================================================="
echo "= Summary                                                               ="
echo "========================================================================="
python _count_npbench_test_instances.py
echo "========================================================================="
echo ""
echo ""

echo "Done."
