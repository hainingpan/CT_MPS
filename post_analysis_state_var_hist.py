# This script is used to compute histogram true state variance as in the paper, 
# the clear distinction is that , it does not take the "trajector-average" of state fluctuation, which is consistent with the paper. Also to save the disk space, it automatically take out the "steady state" from L^2 to 2L^2

import sys
dir_path='../control_transition'
sys.path.append(dir_path)
# import matplotlib.pyplot as plt

from tqdm import tqdm
from plot_utils import *

# L=12
def run(L):
    params_list=[
    ({'nu':0,'de':1,},
    {
    # 'p_ctrl':[.47,.49,.51,.53],
    'p_ctrl':[.4,.45,.5,.55,.6],
    # 'p_ctrl':[0.4,0.45,0.47,0.49,0.5,0.51,0.53,0.55,0.6],
    'p_proj':np.linspace(0.0,0.0,1),
    'sC':np.arange(0,500),
    'sm':np.arange(500),
    'L':[L,]
    }
    ),
    ]
    ob="DW"
    # ob="O"
    ob1=ob+'1'
    ob2=ob+'2'

    err=1e-5
    for fixed_params,vary_params in params_list:
        data_MPS_0_T_DW_dict=generate_params(
            fixed_params=fixed_params,
            vary_params=vary_params,
            fn_template='MPS_({nu},{de})_L{L}_pctrl{p_ctrl:.3f}_pproj{p_proj:.3f}_sC{sC}_sm{sm}_x01_DW_T.json',
            # fn_template='MPS_({nu},{de})_L{L}_pctrl{p_ctrl:.3f}_pproj{p_proj:.3f}_sC{sC}_sm{sm}_O_T.json',
            fn_dir_template='/MPS_0-1_C_m_x01_T',
            input_params_template='',
            load_data=load_zip_json,
            filename=None,
            filelist=None,
            load=True,
            data_dict={'fn':set()},
            # zip_fn='/home/jake/Data/MPS_0-1_C_m_x01_T.zip'  
            # zip_fn='./MPS_0-1_C_m_x01_T.zip'  
            zip_fn=f'/p/work/hpan/CT_MPS/MPS_0-1_C_m_x01_T_L{L}.zip'  
            # zip_fn=f'/p/work/hpan/CT_MPS/MPS_0-1_C_m_O_T_L{L}.zip'  
            # zip_fn=f'./MPS_0-1_MIPT_T_L{L}.zip'  
        )
    df_MPS_0_T_DW=convert_pd(data_MPS_0_T_DW_dict,names=['Metrics','sm','sC','p_ctrl','L','p_proj',])

    def state_var(df, L,p_ctrl,sC,p_proj=0):
        data=df['observations'].xs(sC,level='sC').xs(p_ctrl,level='p_ctrl').xs(L,level='L').xs(p_proj,level='p_proj')
        data_ob1=np.stack(data.xs(ob1,level='Metrics'))
        data_ob2=np.stack(data.xs(ob2,level='Metrics'))
        return (data_ob2-data_ob1**2)

        
    state_var_dict={}
    for p in tqdm(params_list[0][1]['p_ctrl']):
        for L in params_list[0][1]['L']:
            print(p,L)
            state_var_list = []
            for sC in range((params_list[0][1]['sC']).shape[0]):
                try:
                    state_var_=state_var(df_MPS_0_T_DW,L=L,p_ctrl=p,sC=sC)
                    state_var_list.append(state_var_)
                except Exception as e:
                    print(f"Error at p_ctrl={p}, L={L}, sC={sC}: {e}")
            state_var_dict[p,L]=np.array(state_var_list)
            
    # with open(f'state_var_hist_C_m_T_L{L}.pickle','wb') as f:
    # with open(f'state_var_hist_C_m_T_O_L{L}.pickle','wb') as f:
    with open(f'state_var_hist_{ob}_L{L}.pickle','wb') as f:
        pickle.dump(state_var_dict,f)

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--L', type=int, required=True, help='System size parameter')
    args = parser.parse_args()
    run(args.L)