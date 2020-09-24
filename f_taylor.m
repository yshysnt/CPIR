function [val]=f_taylor(L,Z,f_sm_grad_frob_norm_square_val,f_sm_val,tau)
    val=(tau/2)*sum(sum((L-Z).^2))-(1/(2*tau))*f_sm_grad_frob_norm_square_val+f_sm_val;
end 