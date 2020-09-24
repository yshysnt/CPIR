function [val]=item_f_sm_grad(Tr,G,F,lambda_2,lambda_3,cache)
    if nargin==6
        val=lambda_2*cache.B+lambda_3*(G-F)+(G-Tr.R_bool);
    elseif nargin==5
        val=lambda_2*G*Tr.L_poi+lambda_3*(G-F)+(G-Tr.R_bool);
    else
        assert(false)
    end
end