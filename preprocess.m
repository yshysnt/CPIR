
% lizx: vldb means to use the dataset from vldb review
% lizx: use all vldb version
% This algorithm is to solve the fowllowing function
% \min_F tr(F^\top\Theta^UF)+tr(F\Theta^PF^\top)+\|F-Y\|^2_F
function [Tr,Te,Content]=preprocess(configs)
cachefile=[configs.processed_dataset_path,configs.dataset_name,'_preprocess_cache.mat'];
if exist(cachefile,'file')
    fprintf('loading preprocess cache file found at %s...\n',cachefile);
    load(cachefile,'-mat');
    fprintf('finish loading\n');
    Tr.L_user_full=full(Tr.L_user);
    Tr.L_poi_full=full(Tr.L_poi);
else
    if strcmp(configs.raw_dataset_path,'toy_dataset/')
        Tr.itemnum=configs.toy.itemnum;
        Tr.usernum=configs.toy.usernum;
        configs.n_clusters=configs.toy.n_clusters;

        Tr.R_count=randi([-3,5],Tr.usernum,Tr.itemnum); 
        Tr.R_count(Tr.R_count<0)=0;
        Tr.R_bool=Tr.R_count;
        Tr.R_bool(Tr.R_bool>=1)=1;
        Te.R_count=randi(5,Tr.usernum,Tr.itemnum);
        Te.R_count(Te.R_count<0)=0;

        Content.poi_coos=[];
        Content.user_cidx=randi(configs.n_clusters,1,Tr.usernum);

        rand_poi=rand(Tr.itemnum,Tr.itemnum);
        Kn_poi=(rand_poi+rand_poi')/2;
        D=1./sqrt(sum(Kn_poi,2));
        D=diag(D);
        S=D*Kn_poi*D;
        L_poi=speye(Tr.itemnum)-S;
        Tr.Kn_poi=Kn_poi;
        Tr.L_poi=L_poi;

        rand_user=rand(Tr.usernum,Tr.usernum);
        Kn_user=(rand_user+rand_user')/2;
        D=1./sqrt(sum(Kn_user,2));
        D=diag(D);
        S=D*Kn_user*D;
        L_user=eye(Tr.usernum)-S;
        Tr.Kn_user=Kn_user;
        Tr.L_user=L_user;
        save(cachefile,'Tr','Te','Content','-v7.3');
        fprintf('saving finished.\n');

    else
    %----------------------------------load data files------------------------------------------%
    fprintf('preprocess cache not found, building from scratch...\n');
    raw_mat_file=[configs.processed_dataset_path,configs.dataset_name,'_preprocess_raw.mat'];
    if exist(raw_mat_file,"file")
        fprintf("loading raw data from mat file...\n");
        load(raw_mat_file,'-mat');
    else
        fprintf('loading raw data...\n');
        trainingfile=[configs.processed_dataset_path, configs.dataset_name, '_train_mat.txt'];
        testingfile=[configs.processed_dataset_path, configs.dataset_name, '_test_mat.txt'];
        relationfile = [configs.raw_dataset_path, configs.dataset_name, '_social_relations.txt'];
        pidNNfile=[configs.processed_dataset_path, configs.dataset_name, '_train_GNN.txt'];  
        % lizx: produced by user_similarity_TG.ipynb
        % lizx: produced by vldb_user_gt_sim.ipynb
        usersimfile=[configs.processed_dataset_path,  'user_similarity.txt'];
        weightGNNfile=[configs.processed_dataset_path, configs.dataset_name, '_train_GNN_weight.txt'];
        weightTNNfile=[configs.processed_dataset_path, configs.dataset_name, '_train_TNN_weight.txt'];
        sizefile=[configs.raw_dataset_path, configs.dataset_name, '_data_size.txt'];  
        poi_coos_file=[configs.raw_dataset_path,configs.dataset_name,'_poi_coos.txt'];
        trainingdata=dlmread(trainingfile);
        relationdata=dlmread(relationfile);
        user_sim = dlmread(usersimfile); 
        testingdata=dlmread(testingfile);
        pidNN=dlmread(pidNNfile);
        weightGNN = dlmread(weightGNNfile);
        weightTNN = dlmread(weightTNNfile);
        sizedata=dlmread(sizefile);
        Content.poi_coos=dlmread(poi_coos_file);
        Tr.users = trainingdata(:,1); 
        Tr.items = trainingdata(:,2); 
        Tr.times = trainingdata(:,3);
        Tr.usernum=sizedata(1);
        Tr.itemnum=sizedata(2);
        relationdata = relationdata + 1;
        % symmetric graph
        relation_sim = sparse([relationdata(:,1);relationdata(:,2)],[relationdata(:,2);relationdata(:,1)],ones(length(relationdata(:,1))*2,1),Tr.usernum,Tr.usernum);
        Te.users = testingdata(:,1); Te.items = testingdata(:,2); Te.times = testingdata(:,3);

        % train rating matrix
        Tr_R = sparse(Tr.users,Tr.items,Tr.times,Tr.usernum,Tr.itemnum);
        Tr.R_count=Tr_R;
        R=sparse(Tr.users,Tr.items,ones(size(Tr.times)),Tr.usernum,Tr.itemnum);
        Tr.R_bool=R;
        % test rating matrix
        Te_R = sparse(Te.users,Te.items,Te.times,Tr.usernum,Tr.itemnum);
        Te.R_count=Te_R;
        save(raw_mat_file,'Tr','Te','pidNN','weightGNN','weightTNN','relation_sim','user_sim','-v7.3');
    end
    


    %----------------------------------Laplacian POI------------------------------------------%
    fprintf("build laplacian matrix...\n")
    Corr_G=[]; Corr_T=[]; [m, n]=size(pidNN);
    Corr_nei = [];
    for i = 1 : m
        %geoSim=L2_distance(POICoords(geoNN_InX(i, 1), 2:3)', POICoords(geoNN_InX(i, 2: geoNN_Num+1), 2:3)'); % may need some modification
        %geoSim=exp(-10*geoSim);
        gtGSim=weightGNN(i,1:configs.num_item_knn);
        gtTSim=weightTNN(i,1:configs.num_item_knn);
    %     gtSim_nei = weightNN(i,1:num_nei);
    %     temp=[ones(num_item_knn, 1)*pidNN(i, 1), pidNN(i, 2: (num_item_knn+1))', gtSim'/sum(gtSim)];
        temp_G=[ones(configs.num_item_knn, 1)*pidNN(i, 1), pidNN(i, 2: (configs.num_item_knn+1))', gtGSim'];
        temp_T=[ones(configs.num_item_knn, 1)*pidNN(i, 1), pidNN(i, 2: (configs.num_item_knn+1))', gtTSim'];
    %     temp_nei = [ones(num_nei, 1)*pidNN(i, 1), pidNN(i, 2: (num_nei+1))', gtSim_nei'/sum(gtSim_nei)];
        Corr_G=[Corr_G; temp_G];
        Corr_T=[Corr_T; temp_T];
    %     Corr_nei =[Corr_nei; temp_nei];
    end
    % Kn_nei = sparse(Corr_nei(:,1),Corr_nei(:,2),Corr_nei(:,3),m,m);
    Kn_poi_T=sparse(Corr_T(:, 1), Corr_T(:, 2), Corr_T(:, 3), m, m);    
    Kn_poi_G=sparse(Corr_G(:, 1), Corr_G(:, 2), Corr_G(:, 3), m, m);    
    Kn_poi = (configs.alpha_t + Kn_poi_T).*Kn_poi_G/(1+configs.alpha_t);

    Kn_poi=(Kn_poi+Kn_poi')/2;
    % add self-loop, may affect normalized laplacian but not unnormalized laplacian
    D=1./sqrt(sum(Kn_poi,2));
    D=sparse(diag(D));
    S=D*sparse(Kn_poi)*D;
    L_poi = speye(size(Kn_poi)) - S;
    Tr.Kn_poi=Kn_poi;
    Tr.L_poi=L_poi;
    % % % R = R*(geo_alpha*eye(Tr.itemnum)+(1-geo_alpha)*Kn_nei);

    %----------------------------------Laplacian User------------------------------------------%
    Kn_user = zeros(size(user_sim));
    user_sim_com = user_sim.*(configs.alpha_rel + relation_sim);
    for i =1:Tr.usernum
        [~,idx]=sort(user_sim_com(i,:),'descend');
        Kn_user(i,idx(1:configs.num_user_knn+1))=user_sim_com(i,idx(1:configs.num_user_knn+1));
    end
    Kn_user=(Kn_user+Kn_user')/2;
    Kn_user=sparse(Kn_user);
    D=1./sqrt(sum(Kn_user,2));
    D=sparse(diag(D));
    S=D*sparse(Kn_user)*D;
    L_user = speye(Tr.usernum) - S;
    Tr.Kn_user=Kn_user;
    Tr.L_user=L_user;


    %===================================Spectral Clustering================================%
    fprintf("start spectral clustering...\n");
    D_poi=sum(Tr.Kn_poi,2);                                                                                                                                                                                                                                                      
    L_poi_unnormalized=full(diag(D_poi)-Tr.Kn_poi);                                                                                                                                                                                                                              
    [V_poi,Lambda_poi]=eig(L_poi_unnormalized);                                                                                                                                                                                                                                  
    Lambda_poi=diag(Lambda_poi);                                                                                                                                                                                                                                                 
    [~,I]=sort(Lambda_poi);                                                                                                                                                                                                                                                      
    V_poi_sorted=V_poi(:,I);
    poi_dr_features=V_poi_sorted(:,1:configs.DR_dimension);

    D_user=sum(Tr.Kn_user,2);                                                                                                                                                                                                                                                      
    L_user_unnormalized=full(diag(D_user)-Tr.Kn_user);                                                                                                                                                                                                                              
    [V_user,Lambda_user]=eig(L_user_unnormalized);                                                                                                                                                                                                                                  
    Lambda_user=diag(Lambda_user);                                                                                                                                                                                                                                                 
    [~,I]=sort(Lambda_user);                                                                                                                                                                                                                                                      
    V_user_sorted=V_user(:,I);
    user_dr_features=V_user_sorted(:,1:configs.DR_dimension);


    %======================================================================================%

    fprintf("start kmeans...\n");
    assert(all(size(user_dr_features)==[Tr.usernum,configs.DR_dimension]));
    assert(all(size(poi_dr_features)==[Tr.itemnum,configs.DR_dimension]));
    Content.user_cidx=kmeans(user_dr_features,configs.user_n_clusters,'MaxIter',1000);
    Content.poi_cidx=kmeans(poi_dr_features,configs.poi_n_clusters,'MaxIter',1000);

    Tr.R_ncount=Tr.R_count;
    for u=1:Tr.usernum
        idx=Tr.R_ncount(u,:)>0;
        Tr.R_ncount(u,idx)=1+Tr.R_ncount(u,idx)/max(Tr.R_ncount(u,idx));
    end

    fprintf('preprocessing finished, saving to cache file...\n');
    save(cachefile,'Tr','Te','Content','-v7.3');
    fprintf('saving finished.\n');
    Tr.L_user_full=full(Tr.L_user);
    Tr.L_poi_full=full(Tr.L_poi);
    end
end

end





