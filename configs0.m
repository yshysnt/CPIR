% data path
configs.dataset_name='Gowalla';
% configs.dataset_name='Yelp';
configs.dataset_path = 'Gowalla_vldb/';
% configs.dataset_path = 'Yelp_vldb/';
% configs.dataset_path = 'Gowalla_vldb-users leq 1000-pois leq 1000/';
% configs.dataset_path = 'Yelp_vldb-users leq 1000-pois leq 1000/';
% configs.dataset_path = 'toy_dataset/';
configs.result_path = [configs.dataset_path,'R-apg_2obj-F[2]-lambda1=1,lambda2=0.3,lambda3=1,lambda4=0,lambda5=0.mat'];
% configs.result_path = [configs.dataset_path,'R-test.mat'];
configs.save_rating_matrix=true;
% preprocess parameters
configs.num_user_knn = 100;
configs.alpha_rel=0.18;
configs.num_item_knn=100;
configs.alpha_t = 1;
configs.user_n_clusters=20;
configs.poi_n_clusters=20;
configs.DR_dimension=10;
% toy dataset generation parameters
configs.toy.itemnum=20;
configs.toy.usernum=20;
configs.toy.n_clusters=3;
% train parameters
configs.lambda_1 = 1;
configs.lambda_2 = 0.3;
configs.lambda_3 = 1;
configs.lambda_4 = 0.1; 
configs.lambda_5 = 0;
configs.iterations = 8;
% APG paramters
configs.APG.max_iterations=50; 
configs.APG.eta=0.7;
configs.APG.tau_max=1e2;
configs.APG.t=1;
configs.APG.ls_max_iterations=10;
configs.APG.threshold=1e-6;
% display parameters
configs.verbose=2;
% test parameters
configs.topN=10;
