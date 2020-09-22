
# coding: utf-8

# computes the similarity of different places


import pandas as pd
import numpy as np
import os
from collections import defaultdict
from numpy import linalg as LA
import time



data_path = '../raw_data/Gowalla_vldb/'
output_path="../processed_data/Gowalla_vldb/"
dataset_name="Gowalla"

if not os.path.isdir(output_path):
    os.makedir(output_path)
df_all = pd.read_csv(data_path + dataset_name+'_checkins.txt',sep='\t',names=['userid','placeid','datetime'])
print(df_all.shape)



userid_all_list = df_all['userid'].get_values()
placeid_all_list = df_all['placeid'].get_values()
datetime_all_list = df_all['datetime'].get_values()


df_train = pd.read_csv(data_path + dataset_name+'_train.txt',sep='\t',names=['userid','placeid','times'])
df_test = pd.read_csv(data_path + dataset_name+'_test.txt',sep='\t',names=['userid','placeid','times'])
df_tune = pd.read_csv(data_path + dataset_name+'_tune.txt',sep='\t',names=['userid','placeid','times'])
userid_test_list = df_test['userid'].get_values()
placeid_test_list = df_test['placeid'].get_values()
userid_train_list = df_train['userid'].get_values()
placeid_train_list = df_train['placeid'].get_values()
userid_tune_list = df_tune['userid'].get_values()
placeid_tune_list = df_tune['placeid'].get_values()



sizedata_file = data_path + dataset_name+'_data_size.txt'
sizedata = np.loadtxt(sizedata_file,dtype=int)
print(sizedata)
user_length =  sizedata[0]
place_length = sizedata[1]



df_coos = pd.read_csv(data_path + dataset_name+'_poi_coos.txt',sep='\t',names=['placeid','lat','lon'])
placeid_occs_list = df_coos['placeid'].get_values()
lat_list = df_coos['lat'].get_values()
lon_list = df_coos['lon'].get_values()
lat_lng_vector = np.zeros((place_length,2))
for idx,placeid in enumerate(placeid_occs_list):
    lat_lng_vector[placeid,:] = [lat_list[idx],lon_list[idx]]




R_train = np.zeros((user_length,place_length))
for idx,userid in enumerate(userid_train_list):
    R_train[userid,placeid_train_list[idx]]=1




hours_vector = np.zeros((place_length,24))
for idx,datetime in enumerate(datetime_all_list):
    hours_vector[placeid_all_list[idx],time.gmtime(datetime_all_list[idx]).tm_hour]+=R_train[userid_all_list[idx],placeid_all_list[idx]]
for idx in xrange(place_length):
    if not LA.norm(hours_vector[idx,:])==0:
        hours_vector[idx,:]=hours_vector[idx,:]/LA.norm(hours_vector[idx,:])




trans_matrix = np.zeros((24,24))
for i in xrange(24):
    trans_matrix[i,i] = 1
    trans_matrix[i,(i-1)%24] = 0.5
    trans_matrix[i,(i+1)%24] = 0.5
hours_acco_matrix = np.dot(hours_vector,trans_matrix)
for idx in xrange(place_length):
    if not LA.norm(hours_acco_matrix[idx,:])==0:
        hours_acco_matrix[idx,:]=hours_acco_matrix[idx,:]/LA.norm(hours_acco_matrix[idx,:])




hours_similarity = np.dot(hours_acco_matrix,hours_acco_matrix.T)




geo_similarity = np.zeros((place_length,place_length))
for i in range(place_length-1):
    length_cal = place_length - i -1
    geo_similarity[i,i+1:place_length] = np.exp(-LA.norm(lat_lng_vector[i+1:place_length,:]-np.ones((length_cal,2))*lat_lng_vector[i,:],axis=1)*100)
    geo_similarity[i+1:place_length,i] = geo_similarity[i,i+1:place_length]




nn_num = 5000
nn_matrix = np.argsort(-geo_similarity)[:,:nn_num]


wf = open(output_path+dataset_name+'_train_GNN.txt','w')
wf_weight = open(output_path+dataset_name+'_train_GNN_weight.txt','w')
wf_tweight = open(output_path+dataset_name+'_train_TNN_weight.txt','w')
for idx in range(place_length):
    str_w = str(idx+1)
    str_w_wei = ''
    str_w_twei = ''
    for placeid in nn_matrix[idx,:]:
        str_w += ' ' + str(placeid+1)
        str_w_wei += str(geo_similarity[idx,placeid]) + ' '
        str_w_twei += str(hours_similarity[idx,placeid]) + ' '
    str_w += '\n'
    str_w_wei += '\n'
    str_w_twei += '\n'
    wf.write(str_w)
    wf_weight.write(str_w_wei)
    wf_tweight.write(str_w_twei)
wf.close()
wf_weight.close()
wf_tweight.close()

