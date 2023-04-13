#!/bin/bash

echo "========================================================================="
echo "= Running Workflow 02                                                   ="
echo "========================================================================="
echo "This workflow runs the case study for extracting a test out of an"
echo "application designed for a distributed setting. The script extracts"
echo "a test case for a (parallel) loop optimization in the distributed"
echo "Sampled Dense-Dense Matrix Multiplication (SDDMM) performed by a vanilla"
echo "graph attention neural network. This results in a test case that can be "
echo "run on a single node thanks to the cutout procedure."
echo "========================================================================="

echo "Extracting cutout..."
python -m fuzzyflow.cli.cutout_extractor \
    -p case_studies/02_graph_attention/vanilla_attention_inference_simplified.sdfg \
    -x case_studies/02_graph_attention/transformation.json \
    -o results/02_graph_attention

echo ""
echo ""
echo "Generating C++ for cutouts before and after transforming..."
python -m dace.cli.sdfgcc results/02_graph_attention/pre.sdfg &> \
    /dev/null
python -m dace.cli.sdfgcc results/02_graph_attention/post.sdfg &> \
    /dev/null

echo ""
echo ""
echo "========================================================================="
echo "= Summary                                                               ="
echo "========================================================================="
echo "The cutouts have been generated and you can find them in the following"
echo "locations:"
echo "- SDFG version of the cutout before transforming:" 
echo "    results/02_graph_attention/pre.sdfg"
echo "- SDFG version of the cutout after transforming:" 
echo "    results/02_graph_attention/post.sdfg"
echo "- C++ code of the cutout before transforming:" 
echo "    .dacecache/vanilla_dace_loop_cutout_cutout/src/cpu/vanilla_dace_loop_cutout_cutout.cpp"
echo "- C++ code of the cutout after transforming:" 
echo "    .dacecache/vanilla_dace_loop_cutout_cutout_transformed/src/cpu/vanilla_dace_loop_cutout_cutout_transformed.cpp"
echo "========================================================================="
echo ""
echo ""

echo "Done."
