# This script can run P(sigma^2=0), <sigma^2>, and <(sigma^2)^2> - <sigma^2>^2

import sys
dir_path='../control_transition'
sys.path.append(dir_path)
# import matplotlib.pyplot as plt

from tqdm import tqdm
# from plot_utils import *
import numpy as np
import rqc
import pickle



def run(L, ob):
    # ob="DW"
    # ob="O"
    ob1=ob+'1'
    ob2=ob+'2'

    zip_fn = {
    'O':f'MPS_0-1_C_m_O_T_L{L}.zip',
    'DW':f'MPS_0-1_C_m_x01_T_L{L}.zip'
    }
    params_list=[
    ({'nu':0,'de':1,},
    {
    'p_ctrl':[0.4,0.5,0.6],
    'p_proj':np.linspace(0.0,0.0,1),
    'sC':np.arange(0,500),
    'sm':np.arange(500),
    'L':[L]
    }
    ),
    ]
    x01 = '' if ob=='O' else 'x01_'
    for fixed_params,vary_params in params_list:
        data_MPS_0_T_DW_dict=rqc.generate_params(
            fixed_params=fixed_params,
            vary_params=vary_params,
            fn_template='MPS_({nu},{de})_L{L}_pctrl{p_ctrl:.3f}_pproj{p_proj:.3f}_sC{sC}_sm{sm}_'+x01+ob+'_T.json',
            fn_dir_template='/MPS_0-1_C_m_x01_T',
            input_params_template='',
            load_data=rqc.load_zip_json,
            filename=None,
            filelist=None,
            load=True,
            data_dict={'fn':set()},
            # zip_fn=f'/p/work/hpan/CT_MPS/MPS_0-1_C_m_x01_T_L{L}.zip'  
            zip_fn = '/p/work/hpan/CT_MPS/'+zip_fn[ob]
        )
    df_MPS_0_T=rqc.convert_pd(data_MPS_0_T_DW_dict,names=['Metrics','sm','sC','p_ctrl','L','p_proj',])

    
    def process_each_traj(df,L,p_ctrl,sC,p_proj=0, threshold=1e-8):
        # data_ob1.shape = (num_trajectories, num_timepoints), "first moment of ob"
        # data_ob2.shape = (num_trajectories, num_timepoints), "second moment of ob"
        # traj_var = E_traj[<ob>^2] - (E_traj[<ob>])^2
        # state_var = E_traj[<ob^2>] - E_traj[<ob>]^2
        # shot_var = E_traj[<ob^2>] - (E_traj[<ob>])^2
        data = df['observations'].xs(sC,level='sC').xs(p_ctrl,level='p_ctrl').xs(p_proj,level='p_proj').xs(L,level='L')
        data_ob1=np.stack(data.xs(ob1,level='Metrics'))
        data_ob2=np.stack(data.xs(ob2,level='Metrics'))
        sigma_mc=data_ob1.var(axis=0)
        traj_var = sigma_mc
        state_var = data_ob2-data_ob1**2
        traj_weight = (traj_var<threshold).astype(float)
        state_weight = (state_var<threshold).sum(axis=0)
        num_state = state_var.shape[0]
        return num_state, traj_weight, state_weight, traj_var, state_var
        
    traj_weight_list = {}
    state_weight_list = {}
    traj_mean_list = {}
    state_mean_list = {}
    traj_var_list = {}
    state_var_list = {}
    for p in tqdm(params_list[0][1]['p_ctrl']):
        for L in params_list[0][1]['L']:
            print(p,L)
            num_state=0
            num_traj=0
            traj_weight_sum=0
            state_weight_sum=0
            traj_mean_sum=0
            state_mean_sum=0
            traj_sq_sum=0
            state_sq_sum=0
            for sC in range(params_list[0][1]['sC'].shape[0]):
                try:
                    num_state_, traj_weight, state_weight, traj_var, state_var = process_each_traj(df_MPS_0_T,L=L,p_ctrl=p,sC=sC,p_proj=0)
                    num_traj +=1
                    traj_weight_sum +=traj_weight
                    state_weight_sum +=state_weight
                    traj_mean_sum += traj_var
                    state_mean_sum += state_var.sum(axis=0)
                    traj_sq_sum += (traj_var**2)
                    state_sq_sum += (state_var**2).sum(axis=0)
                    num_state += num_state_
                except:
                    pass
            traj_weight_list[(p,L)]=traj_weight_sum/num_traj
            state_weight_list[(p,L)]=state_weight_sum/num_state
            traj_mean_list[(p,L)]=traj_mean_sum/num_traj
            state_mean_list[(p,L)]=state_mean_sum/num_state
            traj_var_list[(p,L)] = traj_sq_sum/num_traj - (traj_mean_sum/num_traj)**2
            state_var_list[(p,L)] = state_sq_sum/num_state - (state_mean_sum/num_state)**2


    with open(f'traj_state_var_{ob}_L{L}.pickle','wb') as f:
        pickle.dump({
            'traj_weight': traj_weight_list, 
            'state_weight': state_weight_list,
            'traj_mean': traj_mean_list,
            'state_mean': state_mean_list,
            'traj_var': traj_var_list,
            'state_var': state_var_list,
            },f)
    # return traj_weight_list, state_weight_list

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--L', type=int, required=True, help='System size parameter')
    parser.add_argument('--ob', type=str, required=True, help='Observable, DW or O')
    args = parser.parse_args()


    run(args.L, args.ob)
