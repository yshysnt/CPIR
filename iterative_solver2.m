function [R] = iterative_solver2(Tr,Te,Content,configs)
[n_users,n_pois]=size(Tr.R_bool);
F=Tr.R_bool;
G=Tr.R_bool;
evaluate(0,Tr,Te,G,configs);
for k=1:configs.iterations
    F=(configs.lambda_1*Tr.L_user+configs.lambda_3*eye(n_users))\(configs.lambda_3*Tr.R_bool-configs.lambda_2*G*Tr.L_poi);
    G=(configs.lambda_3*Tr.R_bool-configs.lambda_1*Tr.L_user*F)/(configs.lambda_2*Tr.L_poi+configs.lambda_3*eye(n_pois));
    evaluate(k,Tr,Te,G,configs);
end
R=F;
end
function evaluate(iter,Tr,Te,R,configs)
    obj=evaluate_objective(Tr,R,configs);
    train_err=evaluate_train(Tr,R);
    [test_ap,test_ar]=evaluate_test(Tr,Te,R,configs);
    fprintf("iterative_solver(lizx): iteration %d, objective_fn=%.4f, train_err=%.3e, test_ap=%.4f, test_ar=%.4f\n",iter,obj,train_err,test_ap,test_ar);
end

