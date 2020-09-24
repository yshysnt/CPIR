function [val]=f_sm_grad(Tr,X,lambda_1,lambda_2,lambda_3,cache)
    if nargin==6
        val=lambda_1*cache.A+lambda_2*cache.B+lambda_3*(X-Tr.R_bool);
    elseif nargin==5
        val=lambda_1*Tr.L_user_full*X+lambda_2*X*Tr.L_poi_full+lambda_3*(X-Tr.R_bool);
    else
        assert(false);
    end
end