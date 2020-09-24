function [R]=sylvester_solver(Tr,Te,Content,configs)
lambda_1=configs.lambda_1;
lambda_2=configs.lambda_2;
lambda_3=configs.lambda_3;
[n_users,n_pois]=size(Tr.R_bool);
evaluate(false,Tr,Te,Tr.R_bool,configs);
A=(lambda_1*full(Tr.L_user)+lambda_3*eye(n_users));
B=lambda_2*full(Tr.L_poi);
C=lambda_3*full(Tr.R_bool);
R=sylvester(A,B,C);
evaluate(true,Tr,Te,R,configs);
end

function evaluate(trained,Tr,Te,R,configs)
    obj=evaluate_objective_noreg(Tr,R,Tr.R_bool,configs);
    train_err=evaluate_train(Tr,R);
    [test_ap,test_ar]=evaluate_test(Tr,Te,R,configs);
    fprintf("sylvester_solver: trained=%d, objective_fn=%.4f, train_err=%.3e, test_ap=%.4f, test_ar=%.4f\n",trained,obj,train_err,test_ap,test_ar);
end