function [val]=user_f_sm_grad(Tr,F,G,lambda_1,lambda_3,cache)
    if nargin==6
        val=lambda_1*cache.A+lambda_3*(F-G);
    elseif nargin==5
        val=lambda_1*Tr.L_user_full*F+lambda_3*(F-G);
    else
        assert(false);
    end
end