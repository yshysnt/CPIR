
# coding: utf-8



import pandas as pd
import numpy as np
import os
from collections import defaultdict
from numpy import linalg as LA
import time


def save_mat_file(df,data_path,filename):
    values = df.values
    values[:,0] = values[:,0] + 1
    values[:,1] = values[:,1] + 1
    np.savetxt(data_path+filename,values,fmt='%d')
    


data_path = '../raw_data/Gowalla_vldb/'
output_path="../processed_data/Gowalla_vldb/"
dataset_name="Gowalla"

if not os.path.isdir(output_path):
    os.mkdir(output_path)

df_train = pd.read_csv(data_path + dataset_name+'_train.txt',sep='\t',names=['userid','placeid','times'],dtype=int)
df_test = pd.read_csv(data_path + dataset_name+'_test.txt',sep='\t',names=['userid','placeid','times'],dtype=int)
df_tune = pd.read_csv(data_path + dataset_name+'_tune.txt',sep='\t',names=['userid','placeid','times'],dtype=int)
save_mat_file(df_train,output_path , dataset_name+'_train_mat.txt')
save_mat_file(df_test,output_path , dataset_name+'_test_mat.txt')
save_mat_file(df_tune,output_path , dataset_name+'_tune_mat.txt')

