import dace
from dace import SDFG
import numpy as np


def profile_bert(sdfg: SDFG, B: int, H: int, N: int, P: int, SM: int, EMB: int):
    x = np.random.rand(B, SM, N)

    attn_wq = np.ones((P, H, N))
    attn_wk = np.ones((P, H, N))
    attn_wv = np.ones((P, H, N))
    attn_wo = np.ones((P, H, N))
    attn_bk = np.ones((P, H, 1, 1))
    attn_bo = np.ones((N,))
    attn_bq = np.ones((P, H, 1, 1))
    attn_bv = np.ones((P, H, 1, 1))
    attn_dropout = np.full((B, SM, N), 0.5)

    norm1_scale = np.ones((N,))
    norm1_bias = np.zeros((N,))
    norm2_scale = np.ones((N,))
    norm2_bias = np.zeros((N,))

    linear1_w = np.ones((EMB, N))
    linear1_b = np.zeros((EMB,))
    linear1_dropout = np.full((B, SM, EMB), 0.5)
    linear2_w = np.ones((N, EMB))
    linear2_b = np.zeros((N,))
    ff_dropout = np.full((B, SM, N), 0.5)

    with dace.config.temporary_config():
        dace.Config.set(
            'library', 'blas', 'default_implementation', value='MKL'
        )
        dace.Config.set('optimizer', 'autooptimize', value=False)
        dace.Config.set('optimizer', 'automatic_simplification', value=False)
        dace.Config.set('debugprint', value=False)
        with dace.profile(repetitions=10):
            _ = sdfg(x=x,
                    attn_wq=attn_wq,
                    attn_wk=attn_wk,
                    attn_wv=attn_wv,
                    attn_wo=attn_wo,
                    attn_bk=attn_bk,
                    attn_bo=attn_bo,
                    attn_bq=attn_bq,
                    attn_bv=attn_bv,
                    attn_dropout=attn_dropout,
                    norm1_scale=norm1_scale,
                    norm1_bias=norm1_bias,
                    norm2_scale=norm2_scale,
                    norm2_bias=norm2_bias,
                    linear1_w=linear1_w,
                    linear1_b=linear1_b,
                    linear1_dropout=linear1_dropout,
                    linear2_w=linear2_w,
                    linear2_b=linear2_b,
                    ff_dropout=ff_dropout,
                    attn_scale=1.0,
                    B=B,
                    H=H,
                    N=N,
                    SM=SM,
                    P=P,
                    emb=EMB)


def run_bert(sdfg: SDFG, B: int, H: int, N: int, P: int, SM: int, EMB: int):
    x = np.random.rand(B, SM, N)

    attn_wq = np.ones((P, H, N))
    attn_wk = np.ones((P, H, N))
    attn_wv = np.ones((P, H, N))
    attn_wo = np.ones((P, H, N))
    attn_bk = np.ones((P, H, 1, 1))
    attn_bo = np.ones((N,))
    attn_bq = np.ones((P, H, 1, 1))
    attn_bv = np.ones((P, H, 1, 1))
    attn_dropout = np.full((B, SM, N), 0.5)

    norm1_scale = np.ones((N,))
    norm1_bias = np.zeros((N,))
    norm2_scale = np.ones((N,))
    norm2_bias = np.zeros((N,))

    linear1_w = np.ones((EMB, N))
    linear1_b = np.zeros((EMB,))
    linear1_dropout = np.full((B, SM, EMB), 0.5)
    linear2_w = np.ones((N, EMB))
    linear2_b = np.zeros((N,))
    ff_dropout = np.full((B, SM, N), 0.5)

    _ = sdfg(x=x,
             attn_wq=attn_wq,
             attn_wk=attn_wk,
             attn_wv=attn_wv,
             attn_wo=attn_wo,
             attn_bk=attn_bk,
             attn_bo=attn_bo,
             attn_bq=attn_bq,
             attn_bv=attn_bv,
             attn_dropout=attn_dropout,
             norm1_scale=norm1_scale,
             norm1_bias=norm1_bias,
             norm2_scale=norm2_scale,
             norm2_bias=norm2_bias,
             linear1_w=linear1_w,
             linear1_b=linear1_b,
             linear1_dropout=linear1_dropout,
             linear2_w=linear2_w,
             linear2_b=linear2_b,
             ff_dropout=ff_dropout,
             attn_scale=1.0,
             B=B,
             H=H,
             N=N,
             SM=SM,
             P=P,
             emb=EMB)

        
if __name__ == '__main__':
    orig_sdfg = dace.SDFG.from_file(
        'case_studies/01_bert/vectorization/specialized_sdfg.sdfg'
    )

    B = 8
    H = 16
    N = 1024
    P = 64
    SM = 512
    EMB = 4096

    profile_bert(orig_sdfg, B, H, N, P, SM, EMB)
