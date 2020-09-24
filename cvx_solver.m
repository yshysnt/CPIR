function [R]=cvx_solver(Tr,Te,Content,configs)
lambda_1=configs.lambda_1;
lambda_2=configs.lambda_2;
lambda_3=configs.lambda_3;
lambda_4=configs.lambda_4;
[n_users,n_pois]=size(Tr.R_bool);
evaluate(false,Tr,Te,Content,Tr.R_bool,configs);
[U_user,D_user]=eig(Tr.L_user);
[U_poi,D_poi]=eig(Tr.L_poi);
D_user(D_user<0)=0;
D_poi(D_poi<0)=0;
L_user_sqrt=U_user*sqrt(D_user)/(U_user);
L_poi_sqrt=U_poi*sqrt(D_poi)/(U_poi);

cvx_begin quiet;
    variable R(n_users,n_pois);
    expression loss;
    loss=1/2*(...
    lambda_1*sum(sum_square(L_user_sqrt*R))+...
    lambda_2*sum(sum_square(R*L_poi_sqrt))+...
    lambda_3*sum(sum_square(R-Tr.R_bool)));
    for k=1:configs.n_clusters
        for l=1:n_pois
            idx=find(Content.user_cidx==k);
            loss=loss+lambda_4*sqrt(length(idx))*norm(R(idx,l),2);
        end
    end
    minimize(loss);
    % lambda_1*square_pos(norm(L_user_sqrt*R,'fro'))+...
    % lambda_2*square_pos(norm(R*L_poi_sqrt,'fro'))+...
    % lambda_3*square_pos(norm(R-Tr.R_bool,'fro')))...
cvx_end;
evaluate(true,Tr,Te,Content,R,configs);
end
function evaluate(trained,Tr,Te,Content,R,configs)
    % TODO: to be changed
    obj=evaluate_objective_reg(Tr,Content,R,configs);
    train_err=evaluate_train(Tr,R);
    [test_ap,test_ar]=evaluate_test(Tr,Te,R,configs);
    fprintf("cvx_solver: trained=%d, objective_fn=%.4f, train_err=%.3e, test_ap=%.4f, test_ar=%.4f\n",trained,obj,train_err,test_ap,test_ar);
end