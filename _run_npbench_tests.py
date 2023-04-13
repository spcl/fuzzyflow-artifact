import os
import re
from dace.sdfg import SDFG
from dace.transformation.optimizer import SDFGOptimizer
import traceback

import fuzzyflow as ff


IGNORE_LIST = [
    'ElementWise*', # Not an actual transformation, only pattern detection.
    'FPGA*', # Requires special hardware.
    'MPI*', # Turns programs into distributed programs.
    'GPU*', # Requires special hardware.
    'ReductionNOperation', # Not an actual transformation, only pattern detection.
    'OuterProductOperation', # Not an actual transformation, only pattern detection.
    'CopyToDevice', # Requires special hardware.
    'LoopDetection', # Not an actual transformation, only pattern detection.
    'StreamingComposition', # Requires special hardware.
]

GRAPH_IGNORE_LIST = [
    'channel_flow.sdfg', # Causes exceptions in pattern matching (DaCe issue).
    'conv2d_bias.sdfg', # Causes exceptions in pattern matching (DaCe issue).
    'jacobi_1d.sdfg', # Program hangs.
    'scattering_self_energies.sdfg', # Out of memory exception in program.
    'seidel_2d.sdfg', # Out of memory exception in program.
]

prefix = 'run_1'

last_pattern = None
last_graph = None
exception_nr = 0

def main():
    ignore_regex = re.compile(
        '^' + '$|^'.join(IGNORE_LIST).replace('*', '\w*') + '$'
    )

    for graph_name in os.listdir('case_studies/03_npbench/graphs'):
        if graph_name in GRAPH_IGNORE_LIST:
            continue
        print('Moving on to', graph_name)
        try:
            sdfg = SDFG.from_file(f'case_studies/03_npbench/graphs/{graph_name}')
            optimizer = SDFGOptimizer(sdfg)
            pattern_matches = optimizer.get_pattern_matches()
            i = 0
            for pattern in pattern_matches:
                if ignore_regex.search(pattern.__class__.__name__):
                    continue

                if pattern.__class__.__name__ == 'NestSDFG' and i == 0:
                    # NestSDFG's first match is the entire SDFG. That is not
                    # interesting and does not lead to a test case that is any
                    # different than the original program. Skip it.
                    i += 1
                    continue

                last_pattern = pattern
                last_graph = graph_name

                print(f'Verifying {pattern.__class__.__name__} on {graph_name}')
                out_dir = os.path.join(
                    'results', '04_npbench', prefix,
                    graph_name.split('.')[0], 'fails',
                    pattern.__class__.__name__ + '_' + str(i)
                )
                success_dir = os.path.join(
                    'results', '04_npbench', prefix,
                    graph_name.split('.')[0], 'successes',
                    pattern.__class__.__name__ + '_' + str(i)
                )
                verifier = ff.TransformationVerifier(
                    pattern, sdfg, output_dir=out_dir, success_dir=success_dir,
                    status=ff.StatusLevel.BAR_ONLY
                )
                valid, dt = verifier.verify(
                    n_samples=1, minimize_input=False, use_alibi_nodes=False,
                    maximum_data_dim=64
                )
                print('Valid:', valid)
                print('Time:', dt * 1e-9, 's')
                if not valid:
                    print('Instance invalid!')

                i += 1
        except Exception as e:
            print('-' * 80)
            print('Exception occurred!')
            print(last_pattern)
            print(last_graph)
            print('-' * 80)
            with open(
                'exception_' + str(graph_name) + '_' + '.txt', 'w'
            ) as f:
                f.writelines([
                    str(e),
                    str(last_pattern),
                    str(last_graph),
                    '',
                ])
                traceback.print_tb(e.__traceback__, file=f)


if __name__ == '__main__':
    main()
