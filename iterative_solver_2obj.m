function [R] = iterative_solver_2obj(Tr,Te,target,Content,configs)
fprintf("Saving F[2] in current setting!\n");
F=target;  
G=target;
[n_users,n_pois]=size(target);
evaluate(0,Tr,Te,F,target,configs);
for iter=1:configs.iterations
    F=(configs.lambda_1*Tr.L_user+configs.lambda_3*eye(n_users))\(configs.lambda_3*G);
    G=(configs.lambda_3*F+target)/(configs.lambda_2*Tr.L_poi+(configs.lambda_3+1)*eye(n_pois));
%     G=(configs.lambda_3*F)/(configs.lambda_2*Tr.L_poi+configs.lambda_3*eye(n_pois));
    evaluate(iter,Tr,Te,F,target,configs);
end
R=F;  % change it back
end

function evaluate(iter,Tr,Te,R,target,configs)
    obj=evaluate_objective_noreg(Tr,R,target,configs);
    train_err=evaluate_train(Tr,R);
    [test_ap,test_ar]=evaluate_test(Tr,Te,R,configs);
    % iter,obj,train_err,test_ap,test_ar
    fprintf("iterative_solver_2obj: iteration %d, objective_fn=%.4f, train_err=%.3e, test_ap=%.4f, test_ar=%.4f\n",iter,obj,train_err,test_ap,test_ar);
end
