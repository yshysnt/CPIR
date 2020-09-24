function [R]=APG_solver_2obj(Tr,Te,Content,configs)
    F=Tr.R_bool;
    G=Tr.R_bool;
    main_evaluate(0,"user",Tr,Te,Content,F,configs);
    for iter=1:configs.iterations
        fprintf("main iteration: %d, user step\n",iter);
        F=APG_iteration(iter,Tr,F,G,Content,configs,"user");
        main_evaluate(iter,"user",Tr,Te,Content,F,configs);
        fprintf("main iteration: %d, poi step\n",iter);
        G=APG_iteration(iter,Tr,F,G,Content,configs,"poi");
        main_evaluate(iter,"poi",Tr,Te,Content,G,configs);
    end
    R=F;
end
function [res]=APG_iteration(iteration,Tr,F,G,Content,configs,apg_mode)
    % initialize t (update step parameter) with configs
    t_prev=configs.APG.t;
    % initialize tau (taylor parameter) with configs
    tau_current=configs.APG.tau_max;
    if strcmp(apg_mode,"user")
        L=G;
        L_prev=G;
    elseif strcmp(apg_mode,"poi")
        L=F;
        L_prev=F;
    end
    obj_prev=0;
    % evaluate
    data.tau_current=tau_current;
    data.t=t_prev;
    data.delta_obj=nan;
    tic;
    if strcmp(apg_mode,"user")
        obj=user_f_non(Tr,Content,L,configs.lambda_4);
        obj=obj+user_f_sm(Tr,L,G,configs.lambda_1,configs.lambda_3);
    elseif strcmp(apg_mode,"poi")
        obj=poi_f_sm(Tr,L,F,configs.lambda_2,configs.lambda_3);
        obj=obj+poi_f_non(Tr,Content,L,configs.lambda_5);
    end
    data.obj=obj;
    data.apg_iteration_time=toc;
    apg_evaluate(iteration,apg_mode,0,data);

    for it=1:configs.APG.max_iterations
        % update t
        t= (1+ sqrt(1 + 4*((t_prev)^2)))/2;
        % update R with step paremter t
        X=L+((t_prev-1)/t)*(L-L_prev);
        t_prev=t;
        L_prev=L;
        % line search: returns new R, new tau and new error
        lsargs=struct();
        lsargs.tau_current=tau_current;
        lsargs.tau_max=configs.APG.tau_max;
        lsargs.eta=configs.APG.eta;
        lsargs.max_iterations=configs.APG.ls_max_iterations;
        if strcmp(apg_mode,"user")
            lsargs.lambda_1=configs.lambda_1;
            lsargs.lambda_3=configs.lambda_3;
            lsargs.lambda_4=configs.lambda_4;   
        elseif strcmp(apg_mode,"poi")         
            lsargs.lambda_2=configs.lambda_2;
            lsargs.lambda_3=configs.lambda_3;
            lsargs.lambda_5=configs.lambda_5;    
        end         
        t0=tic;
        if strcmp(apg_mode,"user")
            [L,tau_current,obj]=APGLineSearch2Obj(Tr,Content,X,G,apg_mode,lsargs);
        elseif strcmp(apg_mode,"poi")
            [L,tau_current,obj]=APGLineSearch2Obj(Tr,Content,F,X,apg_mode,lsargs);
        end
        delta_obj=abs(obj-obj_prev)/abs(obj_prev);
        obj_prev=obj;
        %evaluate
        data.tau_current=tau_current;
        
        data.t=t;
        data.delta_obj=delta_obj;
        data.obj=obj;
        data.apg_iteration_time=toc(t0);
        apg_evaluate(iteration,apg_mode,it,data);
        if delta_obj<configs.APG.threshold
            break;
        end
    end
    res=L;
end

function main_evaluate(iteration,step,Tr,Te,Content,R,configs)
    train_err=evaluate_train(Tr,R);
    [test_ap,test_ar]=evaluate_test(Tr,Te,full(R),configs);
    fprintf("APG_solver_2obj: iteration=%d, step=%s, train_err=%.4e, test_ap=%.4f, test_ar=%.4f\n",...
    iteration,step,train_err,test_ap,test_ar);
end

function apg_evaluate(main_iteration,step,apg_iteration,data)
    tau_current=data.tau_current;
    t=data.t;
    obj=data.obj;
    delta_obj=data.delta_obj;
    apg_iteration_time=data.apg_iteration_time;
    fprintf("\tAPG_iteration: main_iteration=%d, step=%s, apg_iteration=%d, objective_fn=%.4f, delta_objective_fn=%.4f, apg_iteration_time=%.2f, tau_current=%.4f, t=%.4f\n",...
    main_iteration,step,apg_iteration,obj,delta_obj,apg_iteration_time,tau_current,t);
end