function [val,cache]=user_f_sm(Tr,F,G,lambda_1,lambda_3)
    a=tic;
    A=Tr.L_user_full*F;
    val=0;
    val=val+lambda_1*F(:)'*A(:);
    val=val+lambda_3*sum(sum((F-G).^2));
    val=1/2*val;
    t=toc(a);
    cache.A=A;
    % fprintf("\t\tuser_f_sm: %.4f\n",t);
end