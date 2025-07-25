import sys
dir_path='../control_transition'
sys.path.append(dir_path)
# import matplotlib.pyplot as plt

from tqdm import tqdm
from plot_utils import *

L=14

params_list=[
({'nu':0,'de':1,},
{
# 'p_ctrl':[.47,.49,.51,.53],
'p_ctrl':[.4,.45,.5,.55,.6],
# 'p_ctrl':[0.4,0.45,0.47,0.49,0.5,0.51,0.53,0.55,0.6],
# 'p_ctrl':np.linspace(0,1,21),
# 'p_ctrl':np.linspace(0,1,21)[:8],
# 'p_ctrl':np.arange(.65,0.86,0.05),
# 'p_ctrl':[0.45,0.47,0.49,0.51,0.53,0.55],
'p_proj':[0,],
'sC':np.arange(0,500),
'sm':np.arange(500),
'L':[L]
# 'L':[40,]
}
),
]

for fixed_params,vary_params in params_list:
    data_MPS_0_T_dict=generate_params(
        fixed_params=fixed_params,
        vary_params=vary_params,
        fn_template='MPS_({nu},{de})_L{L}_pctrl{p_ctrl:.3f}_pproj{p_proj:.3f}_sC{sC}_sm{sm}_x01_DW_T.json',
        # fn_template='MPS_({nu},{de})_L{L}_pctrl{p_ctrl:.3f}_pproj{p_proj:.3f}_sC{sC}_sm{sm}_DW_T.json',
        # fn_template='MPS_({nu},{de})_L{L}_pctrl{p_ctrl:.3f}_pproj{p_proj:.3f}_sC{sC}_sm{sm}_O_T.json',
        # fn_template='MPS_({nu},{de})_L{L}_pctrl{p_ctrl:.3f}_pproj{p_proj:.3f}_sC{sC}_sm{sm}_x01_shots.json',
        # fn_template='MPS_({nu},{de})_L{L}_pctrl{p_ctrl:.3f}_pproj{p_proj:.3f}_sC{sC}_sm{sm}_x01_shots_T.json',
        # fn_template='MPS_({nu},{de})_L{L}_pctrl{p_ctrl:.3f}_pproj{p_proj:.3f}_sC{sC}_sm{sm}_x01_shots_bitstring_T.json',
        # fn_template='MPS_({nu},{de})_L{L}_pctrl{p_ctrl:.3f}_pproj{p_proj:.3f}_sC{sC}_sm{sm}_x01_evo.json',
        # fn_dir_template='./MPS_0-1_C_m_x00',
        fn_dir_template=f'/p/work/hpan/CT_MPS/MPS_0-1_C_m_x01_T_L{L}',
        # fn_dir_template=f'MPS_0-1_C_m_O_T_L{L}',
        # fn_dir_template=f'../CT_MPS/MPS_0-1_shots_T_L{L}',
        # fn_dir_template=f'../CT_MPS/MPS_0-1_shots_bitstring_T_L{L}',
        # fn_dir_template=f'../CT_MPS/MPS_0-1_evo_L{L}',
        # fn_dir_template='./MPS_0-1_C_m_x0',
        input_params_template='{p_ctrl:.3f},{p_proj:.3f},{L},{sC},{sm} ',
        load_data=load_json,
        filename=f'params_CT_MPS_0_C_m_T_L{L}_series.txt',
        # filelist=f'O_L{L}.txt',
        filelist=f'DW_L{L}.txt',
        load=False,
        data_dict=None,
        # data_dict_file='xj({nu},{de})_C_m.pickle', 
        # data_dict_file='xj({nu},{de})_C_m.json', 
    )

with open(f'params_CT_MPS_0_C_m_T_L{L}_series.txt','r') as f:
    # lines=f.readlines()
    linewidth=5000
    count=0
    total_string = []
    string = ''
    for line in f:
        string = string + ',' + line.strip()
        count+=1
        if count>=linewidth:
            count=0
            total_string.append(string[1:])
            string= ''
    # Add the remaining part if it exists
    if string:
        total_string.append(string[1:])

with open(f'params_CT_MPS_0_C_m_T_L{L}_series.txt','w') as f:
    f.write('\n'.join(total_string))
