function [Tr,Te,Content,configs,R]=main2(solver)
    assert((nargin==1) && ismember(solver,{'cvx','apg','syl','apg_2obj','apg_1obj','iterative_2obj','iterative_1obj'}) );
    run('configs0.m')
    configs
    if exist(configs.result_path,'file')
        assert(false);
    end
    feature('numcores');
    [Tr,Te,Content]=preprocess(configs);
    if strcmp(solver,'cvx')
        R=cvx_solver(Tr,Te,Content,configs);
    elseif strcmp(solver,'syl')
        R=sylvester_solver(Tr,Te,Content,configs);
    elseif strcmp(solver,'apg_1obj')
        R=APG_solver_1obj(Tr,Te,Content,configs);
    elseif strcmp(solver,'apg_2obj')
        R=APG_solver_2obj(Tr,Te,Content,configs);
    elseif strcmp(solver,'iterative_1obj')
        R=iterative_solver_1obj(Tr,Te,Tr.R_bool,Content,configs);
    elseif strcmp(solver,'iterative_2obj')
        R=iterative_solver_2obj(Tr,Te,Tr.R_bool,Content,configs);
    else
        assert(false);
    end
    
    if configs.save_rating_matrix
        fprintf("Saving optimized rating matrix...\n");
        save(configs.result_path,'R','configs','-v7.3');
    end
end


