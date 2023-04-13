#!/bin/bash

echo "========================================================================="
echo "= Running Workflow 01                                                   ="
echo "========================================================================="
echo "This workflow runs the case study for reducing the input configuration"
echo "space of a cutout obtained for a vectorization transformation on the"
echo "BERT encoder layer."
echo "========================================================================="

echo "Obtaining baseline runtime for program, profiling with 10 repetitions..."
res_orig=$(python _run_bert_random_data.py)
filtered_orig=$(echo "$res_orig" | grep "encoder")
read -ra res_arr_orig <<< "$filtered_orig"
rt_orig_s=$(bc -l <<< "${res_arr_orig[-2]}/1000")
tps_orig=$(bc -l <<< "1/${rt_orig_s}")

echo ""
echo ""
echo "Extracting cutout with and without minimization..."
reduction_output=$(python -m fuzzyflow.cli.cutout_extractor \
    -p case_studies/01_bert/vectorization/specialized_sdfg.sdfg \
    -x case_studies/01_bert/vectorization/transformation.json \
    -o results/01_bert/vectorization \
    --maxd 64 \
    --noreduce-reduce-diff)
ignored=$(python -m fuzzyflow.cli.cutout_extractor \
    -p case_studies/01_bert/vectorization/unspecialized_sdfg.sdfg \
    -x case_studies/01_bert/vectorization/transformation.json \
    -o results/01_bert/vectorization2 \
    --maxd 64)

echo ""
echo ""
echo "Generating C++ for cutout..."
python -m dace.cli.sdfgcc results/01_bert/vectorization2/pre.sdfg &> \
    /dev/null
python -m dace.cli.sdfgcc results/01_bert/vectorization2/post.sdfg &> \
    /dev/null

echo ""
echo ""
echo "Preparing AFL++ fuzzing..."
cp fuzzyflow/fuzzyflow/harness_generator/depickle.py results/01_bert/vectorization2/depickle.py
cd results/01_bert/vectorization2
python depickle.py
pre_name="encoder_cutout_cutout"
post_name="encoder_cutout_cutout_transformed"
rm -rf afl_seeds
rm -rf afl_finds
afl-g++-fast -O3 -fopenmp -DWITH_CUDA harness.cpp \
    /app/.dacecache/${pre_name}/src/cpu/${pre_name}.cpp \
    /app/.dacecache/${post_name}/src/cpu/${post_name}.cpp \
    -I/app/.dacecache/${pre_name}/include/ \
    -I/app/.dacecache/${post_name}/include/ \
    -I/app/dace/dace/runtime/include/ \
    -I/usr/local/cuda/include \
    -L/usr/local/cuda/lib64/ -lcudart \
    -L/app/.dacecache/${post_name}/build/ -l${post_name} \
    -Wl,-rpath=/app/.dacecache/${post_name}/build/ \
    -o harness
mkdir -p afl_seeds
mkdir -p afl_finds
cp ../vectorization/noreduce/harness.dat afl_seeds/harness.dat

echo ""
echo ""
echo "Fuzzing extracted cutout with AFL++ for 10 seconds..."
afl-fuzz -i afl_seeds -o afl_finds -t 10000 -V 10 -M fuzzer0 -- ./harness @@ out1.dat out2.dat

echo ""
echo ""
echo "========================================================================="
echo "= Summary                                                               ="
echo "========================================================================="
echo "Median runtime of full, original program: ${rt_orig_s}s"
echo "Allows for ${tps_orig} trials per second with the full program"

echo "$reduction_output"
echo "AFL++ trials per second: see above ('exec speed')"
echo "========================================================================="
echo ""
echo ""

echo "Done."
