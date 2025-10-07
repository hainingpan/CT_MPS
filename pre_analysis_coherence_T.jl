import sys
# dir_path='../control_transition'
# sys.path.append(dir_path)
# import matplotlib.pyplot as plt
import rqc
import numpy as np
from tqdm import tqdm

L=10

params_list=[
({'nu':0,'de':1,'mb':120,'t':1},
{
# 'p_ctrl':[0.35],
'p_ctrl':[0.5],
# 'p_ctrl':[.47,.49,.51,.53],
# 'p_ctrl':[.4,.45,.5,.55,.6],
# 'p_ctrl':[0.4,0.45,0.47,0.49,0.5,0.51,0.53,0.55,0.6],
# 'p_ctrl':np.linspace(0,1,21),
# 'p_ctrl':np.linspace(0,1,21)[:8],
# 'p_ctrl':np.arange(.65,0.86,0.05),
# 'p_ctrl':[0.45,0.47,0.49,0.51,0.53,0.55],
'p_proj':[0,],
's':np.arange(0,2000),
'L':[L],
}
),
]

for fixed_params,vary_params in params_list:
    data_MPS_0_T_dict=rqc.generate_params(
        fixed_params=fixed_params,
        vary_params=vary_params,
        fn_template='MPS_({nu},{de})_L{L}_pctrl{p_ctrl:.3f}_pproj{p_proj:.3f}_mb{mb}_t{t}_s{s}_coherence_T.json',
        fn_dir_template=f'/p/work/hpan/CT_MPS/MPS_0-1_coherence_T_L{L}',
        input_params_template='{L},{p_ctrl:.3f},{p_proj:.3f},{mb},{s},{t} ',
        load_data=rqc.load_json,
        filename=f'params_CT_MPS_0_coherence_T_L{L}_series.txt',
        filelist = None,
        load=False,
        data_dict=None,
    )

with open(f'params_CT_MPS_0_coherence_T_L{L}_series.txt','r') as f:
    # lines=f.readlines()
    linewidth=92
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

with open(f'params_CT_MPS_0_coherence_T_L{L}_series.txt','w') as f:
    f.write('\n'.join(total_string))
