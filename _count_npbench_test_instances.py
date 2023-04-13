import os


def main():
    n_instances = 0
    failed_instances = 0
    base_dir = 'results/04_npbench/run_1'
    for dirname in os.listdir(base_dir):
        if os.path.exists(f'{base_dir}/{dirname}/successes'):
            for _ in os.listdir(f'{base_dir}/{dirname}/successes'):
                n_instances += 1
        if os.path.exists(f'{base_dir}/{dirname}/fails'):
            for _ in os.listdir(f'{base_dir}/{dirname}/fails'):
                n_instances += 1
                failed_instances += 1
    print(f'Tested a total of {n_instances} instances.')
    print(f'{failed_instances} instances failed. Perform manual triage to identify bugs.')


if __name__ == '__main__':
    main()
