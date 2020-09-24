function [L,tau,loss]=APGLineSearch2Obj(Tr,Content,F,G,apg_mode,lsargs)
    if strcmp(apg_mode,"user")
        lambda_1=lsargs.lambda_1;
        lambda_3=lsargs.lambda_3;
        lambda_4=lsargs.lambda_4;
        eta=lsargs.eta;
        tau_max=lsargs.tau_max;
        tau=min(lsargs.tau_current*eta,tau_max);
    elseif strcmp(apg_mode,"poi")
        lambda_2=lsargs.lambda_2;
        lambda_3=lsargs.lambda_3;
        lambda_5=lsargs.lambda_5;
        eta=lsargs.eta;
        tau_max=lsargs.tau_max;
        tau=min(lsargs.tau_current*eta,tau_max);
    else
        assert(false);
    end
    if strcmp(apg_mode,"user")
        [f_sm_X_val,cache]=user_f_sm(Tr,F,G,lambda_1,lambda_3);
        f_sm_grad_val=user_f_sm_grad(Tr,F,G,lambda_1,lambda_3,cache);
    elseif strcmp(apg_mode,"poi")
        [f_sm_X_val,cache]=poi_f_sm(Tr,G,F,lambda_2,lambda_3);
        f_sm_grad_val=poi_f_sm_grad(Tr,G,F,lambda_2,lambda_3,cache);
    end
    
    f_sm_grad_frob_norm_square_val=sum(sum(f_sm_grad_val.^2));
    for it=1:lsargs.max_iterations
        if strcmp(apg_mode,"user")
            Z=F-(1/tau)*f_sm_grad_val;
        elseif strcmp(apg_mode,"poi")
            Z=G-(1/tau)*f_sm_grad_val;
        end
        if strcmp(apg_mode,"user")
            L_star=userProxOperator(Tr,Content,Z,lambda_4,tau);
        elseif strcmp(apg_mode,"poi")
            L_star=poiProxOperator(Tr,Content,Z,lambda_5,tau);
        end

        if strcmp(apg_mode,"user")
            f_sm_L_star_val=user_f_sm(Tr,L_star,G,lambda_1,lambda_3);
        elseif strcmp(apg_mode,"poi")
            f_sm_L_star_val=poi_f_sm(Tr,L_star,F,lambda_2,lambda_3);
        end            
        f_taylor_val=f_taylor(L_star,Z,f_sm_grad_frob_norm_square_val,f_sm_X_val,tau);
        if f_sm_L_star_val<=f_taylor_val
            break
        else
            tau=min(tau/eta,tau_max);
        end
    end
    
    L=L_star;
    if strcmp(apg_mode,"user")
        loss=f_sm_L_star_val+user_f_non(Tr,Content,L,lambda_4);
    elseif strcmp(apg_mode,"poi")
        loss=f_sm_L_star_val+poi_f_non(Tr,Content,L,lambda_5);
    end
end