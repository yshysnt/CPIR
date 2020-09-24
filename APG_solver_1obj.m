function [R]=APG_solver_1obj(Tr,Te,Content,configs)

t_prev=configs.APG.t;
tau_current=configs.APG.tau_max;
% initialize R
L=Tr.R_bool;
L_prev=Tr.R_bool;
loss_prev=0;
evaluate(0,Tr,Te,Content,L,configs,tau_current,t_prev);

for it=1:configs.APG.max_iterations
    % update t
    t= (1+ sqrt(1 + 4*((t_prev)^2)))/2;
    % update R with step paremter t
    X=L+((t_prev-1)/t)*(L-L_prev);
    t_prev=t;
    L_prev=L;
    % line search: returns new R, new tau and new error
    lsargs.tau_current=tau_current;
    lsargs.tau_max=configs.APG.tau_max;
    lsargs.eta=configs.APG.eta;
    lsargs.max_iterations=configs.APG.ls_max_iterations;
    lsargs.lambda_1=configs.lambda_1;
    lsargs.lambda_2=configs.lambda_2;
    lsargs.lambda_3=configs.lambda_3;
    lsargs.lambda_4=configs.lambda_4;

    t0=tic;
    [L,tau_current,loss]=APGLineSearch(Tr,Content,X,lsargs);
    ls_time=toc(t0);
    delta_loss=abs(loss-loss_prev)/abs(loss_prev);
    loss_prev=loss;
    evaluate(it,Tr,Te,Content,L,configs,tau_current,t,loss,delta_loss,ls_time);
    if delta_loss<configs.APG.threshold
        break;
    end
end
R=L;
end

function [L,tau,loss]=APGLineSearch(Tr,Content,X,lsargs)
    lambda_1=lsargs.lambda_1;
    lambda_2=lsargs.lambda_2;
    lambda_3=lsargs.lambda_3;
    lambda_4=lsargs.lambda_4;
    eta=lsargs.eta;
    tau_max=lsargs.tau_max;
    tau=min(lsargs.tau_current*eta,tau_max);
    [f_sm_X_val,cache]=f_sm(Tr,X,lambda_1,lambda_2,lambda_3);
    f_sm_grad_val=f_sm_grad(Tr,X,lambda_1,lambda_2,lambda_3,cache);
    f_sm_grad_frob_norm_square_val=sum(sum(f_sm_grad_val.^2));
    for it=1:lsargs.max_iterations
        Z=X-(1/tau)*f_sm_grad_val;
        L_star=ProxOperator(Tr,Content,Z,lambda_4,tau);
        f_sm_L_star_val=f_sm(Tr,L_star,lambda_1,lambda_2,lambda_3);
        f_taylor_val=f_taylor(L_star,Z,f_sm_grad_frob_norm_square_val,f_sm_X_val,tau);
        if f_sm_L_star_val<=f_taylor_val
            break
        else
            tau=min(tau/eta,tau_max);
        end
    end
    L=L_star;
    loss=f_sm_L_star_val+f_non(Tr,Content,L,lambda_4);
end

function [val]=f_sm1(Tr,X,lambda_1,lambda_2,lambda_3)
    val=1/2*(lambda_1*trace(X'*Tr.L_user*X)+...
    lambda_2*trace(X*Tr.L_poi*X')+...
    lambda_3*sum(sum((X-Tr.R_bool).^2)));
end



function evaluate(iteration,Tr,Te,Content,R,configs,tau_current,t,loss,delta_loss,ls_time)
    % TODO: to be changed
    tic;
    if nargin==8
        obj=evaluate_objective_reg(Tr,Content,R,configs);
    elseif nargin==11
        obj=loss;
    else
        assert(false);
    end
    evaluate_time=toc;
    train_err=evaluate_train(Tr,R);
    R_full=full(R);
    [test_ap,test_ar]=evaluate_test(Tr,Te,R_full,configs);
    if nargin==11   
        fprintf("APG_solver_1obj: iteration=%d, objective_fn=%.4f,"+...
        "train_err=%.3e, test_ap=%.4f, test_ar=%.4f, tau_current=%.4f,"+...
         "t=%.4f, delta_loss=%.4f,ls_time=%.1f,evaluate_time=%.1f\n",iteration,obj,train_err,test_ap,test_ar,tau_current,t,delta_loss,ls_time,evaluate_time);
    elseif nargin==8
        fprintf("APG_solver_1obj: iteration=%d, objective_fn=%.4f,"+...
        "train_err=%.3e, test_ap=%.4f, test_ar=%.4f, tau_current=%.4f,"+...
         "t=%.4f\n",iteration,obj,train_err,test_ap,test_ar,tau_current,t); 
    else 
        assert(false);
    end
end