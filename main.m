function [Tr,Te,Content,configs,R]=main(varargin)
    p=inputParser;
    p.CaseSensitive=true;
    validSolvers={'cvx','apg','syl','apg_2obj','apg_1obj','iterative_2obj','iterative_1obj'};
    validScalarPosNum=@(x) isnumeric(x) && isscalar(x) && x>=0;
    addRequired(p,'solver',@(x) ismember(x,validSolvers));
    addRequired(p,'dataset_name',@ischar)
    addRequired(p,'dataset_path',@ischar)
    addRequired(p,'rating_matrix_file',@ischar)
    addRequired(p,'lambda_1',validScalarPosNum)
    addRequired(p,'lambda_2',validScalarPosNum)
    addRequired(p,'lambda_3',validScalarPosNum)
    addRequired(p,'lambda_4',validScalarPosNum)
    addRequired(p,'lambda_5',validScalarPosNum)
    addOptional(p,'dry_run',false,@islogical)
    run('configs0.m')
    parse(p,varargin{:})
    solver=p.Results.solver;
    configs.dataset_name=p.Results.dataset_name;
    configs.dataset_path=p.Results.dataset_path;
    configs.result_path=p.Results.rating_matrix_file;
    configs.lambda_1=p.Results.lambda_1;
    configs.lambda_2=p.Results.lambda_2;
    configs.lambda_3=p.Results.lambda_3;
    configs.lambda_4=p.Results.lambda_4;
    configs.lambda_5=p.Results.lambda_5;

    % print out settings
    fprintf('hostname: %s\n',getComputerName);
    fprintf('solver: %s\n',solver);
    configs
    feature('numcores');

    if exist(configs.result_path,'file')
        assert(false);
    end

    if p.Results.dry_run
        return
    end

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


