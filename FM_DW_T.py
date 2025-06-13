import gc
import sys
dir_path='../control_transition'
sys.path.append(dir_path)
# import matplotlib.pyplot as plt

from tqdm import tqdm
from plot_utils import *
# data_path='/home/jake/Data'
data_path='/mnt/e/Control_Transition/Bitstring'
L_list=np.arange(10,61,10)
# L_list=np.arange(50,61,10)
# L_list=[50]
# p_ctrl_list=np.round(np.arange(0.4,0.6,0.01),2)
p_ctrl_list=[0.5]
cl_variance_p_ctrl_dict={}
se_cl_variance_p_ctrl_dict={}

for L in L_list:
    for p_ctrl in p_ctrl_list:
        params_list=[({'nu':0,'de':1,},{'p_ctrl':[p_ctrl],'p_proj':np.linspace(0.0,0.0,1),'s':np.arange(10000),'L':[L]}),]

        for fixed_params,vary_params in params_list:
            data_MPS_0_DW_dict=generate_params(
                fixed_params=fixed_params,
                vary_params=vary_params,
                # fn_template='MPS_({nu},{de})_L{L}_pctrl{p_ctrl:.3f}_pproj{p_proj:.3f}_s{s}_DW.json',
                fn_template='MPS_({nu},{de})_L{L}_pctrl{p_ctrl:.3f}_pproj{p_proj:.3f}_s{s}_x01_DW.json',
                fn_dir_template='./MPS_0-1_DW_x01',
                # fn_dir_template='./MPS_0-1_DW_x12',
                # fn_dir_template='./MPS_0-1_DW_x00',
                input_params_template='',
                load_data=load_zip_json,
                filename=None,
                filelist=None,
                load=True,
                data_dict={'fn':set()},
                # zip_fn=os.path.join(data_path,'MPS_0-1_DW_all.zip')
                zip_fn=os.path.join(data_path,'MPS_0-1_DW_x01_all.zip')
            )
        df_MPS_0_DW=convert_pd(data_MPS_0_DW_dict,names=['Metrics','L','p_ctrl','p_proj','T'])




        # for idx,p_ctrl in tqdm(enumerate(p_ctrl_list)):
        for idx,p_ctrl in enumerate(params_list[0][1]['p_ctrl']):
            data1=df_MPS_0_DW.xs(level='Metrics',key='DW1').xs(level='p_ctrl',key=p_ctrl).xs(level='p_proj',key=0.00).xs(level='L',key=L).sort_index()['observations']
            t_list=data1.index
            sq_mean=data1.apply(lambda x : np.array(x)**2).apply(np.mean)
            mean_sq=data1.apply(np.mean).apply(lambda x : np.array(x)**2)
            y=sq_mean-mean_sq
            cl_variance_p_ctrl_dict[p_ctrl,L]=y
            print(len(data1))
            se_cl_variance_p_ctrl_dict[p_ctrl,L]=y*np.sqrt(2)/np.sqrt(len(data1))
        

        with open('cl_var_p_ctrl_x01.pickle','wb') as f:
            pickle.dump([cl_variance_p_ctrl_dict,se_cl_variance_p_ctrl_dict],f)

        del data_MPS_0_DW_dict, df_MPS_0_DW
        gc.collect()


