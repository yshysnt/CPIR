
# coding: utf-8

import pandas as pd
import numpy as np
import os
from collections import defaultdict
from numpy import linalg as LA
import time
from scipy.sparse import csr_matrix
from collections import Counter


data_path = '../raw_data/Gowalla_vldb/'
output_path="../processed_data/Gowalla_vldb"
dataset_name="Gowalla"

if not os.path.isdir(output_path):
    os.mkdir(output_path)

df_all = pd.read_csv(data_path + dataset_name+'_checkins.txt',sep='\t',names=['userid','placeid','datetime'])
print(df_all.shape)


userid_all_list = df_all['userid'].values
placeid_all_list = df_all['placeid'].values
datetime_all_list = df_all['datetime'].values
userid_uni_list = np.unique(userid_all_list)
placeid_uni_list = np.unique(placeid_all_list)
user_num = len(userid_uni_list)
place_num = len(placeid_uni_list)
print(user_num,place_num)


n_unique_user_place_pairs=len(set(zip(userid_all_list,placeid_all_list)))


df_train = pd.read_csv(data_path + dataset_name+'_train.txt',sep='\t',names=['userid','placeid','times'])
df_test = pd.read_csv(data_path + dataset_name+'_test.txt',sep='\t',names=['userid','placeid','times'])
df_tune = pd.read_csv(data_path + dataset_name+'_tune.txt',sep='\t',names=['userid','placeid','times'])
userid_test_list = df_test['userid'].values
placeid_test_list = df_test['placeid'].values
userid_train_list = df_train['userid'].values
placeid_train_list = df_train['placeid'].values
userid_tune_list = df_tune['userid'].values
placeid_tune_list = df_tune['placeid'].values




n_unique_user_place_pairs==len(df_train)+len(df_test)+len(df_tune)


time.gmtime(datetime_all_list[0])


R = np.zeros((user_num,place_num),dtype=int)
hours_vector = np.zeros((user_num,place_num,24),dtype=int)
# this time is in UTC, not local time!
for idx,datetime in enumerate(datetime_all_list):
    hours_vector[userid_all_list[idx],placeid_all_list[idx],time.gmtime(datetime).tm_hour]+=1
# remove test set and remove tune set
for idx,userid in enumerate(userid_test_list):
    hours_vector[userid,placeid_test_list[idx],:]=0
for idx,userid in enumerate(userid_tune_list):
    hours_vector[userid,placeid_tune_list[idx],:]=0
dict_idx_exist={} # userid -> visited places
dict_idx_day_exist={} # userid -> time features exist range
for userid in userid_uni_list:
    dict_idx_exist[userid]=[]
    dict_idx_day_exist[userid]=[]
for idx,userid in enumerate(userid_train_list):
    # map hours of each places to a unique set of indices, later used in csr format
    dict_idx_day_exist[userid].extend(range(placeid_train_list[idx]*24,(placeid_train_list[idx]+1)*24))
    dict_idx_exist[userid].append(placeid_train_list[idx])


# transform matrix
trans_matrix = np.ones((24,24))/2
for i in xrange(24):
    trans_matrix[i,i] = 1
    trans_matrix[i,(i-1)%24] = 0.75
    trans_matrix[i,(i+1)%24] = 0.75


user_length = user_num
place_length = place_num


indptr=[0]
indices=[]
data=[]
norm_user_vector=np.zeros((user_length,))
for user_idx in xrange(user_length):
    #user_vector[user_idx,:] = (np.dot(hours_vector[user_idx,:,:],trans_matrix)/trans_matrix.sum(axis=0).reshape(1,-1)).reshape(1,-1)
    temp_data= (np.dot(hours_vector[user_idx,dict_idx_exist[user_idx],:],trans_matrix)/trans_matrix.sum(axis=0).reshape(1,-1)).reshape(-1,)
    data.extend(temp_data.values)
    indices.extend(dict_idx_day_exist[user_idx])
    indptr.append(len(indices))
    norm_user_vector[user_idx] = LA.norm(temp_data)
user_vec_spr = csr_matrix((data,indices,indptr),shape=(user_length,place_num*24))



user_sim=np.zeros((user_length,user_length))
user_vec = user_vec_spr.toarray()
for user_idx in xrange(user_length):
    if user_idx %100 == 0:
        print(user_idx)
    idx_com = dict_idx_day_exist[user_idx]
    # only features at idx_com are not zero, improving speed
    user_sim[user_idx,user_idx:user_length] = np.dot(user_vec[user_idx,idx_com].reshape(1,-1),user_vec[user_idx:user_length,idx_com].T)/(norm_user_vector[user_idx]*norm_user_vector[user_idx:user_length].reshape(1,-1))
    user_sim[user_idx:user_length,user_idx] = user_sim[user_idx,user_idx:user_length]

np.savetxt(output_path+"user_similarity.txt",user_sim)

