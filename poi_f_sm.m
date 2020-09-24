function [val,cache]=poi_f_sm(Tr,G,F,lambda_2,lambda_3)
    a=tic;
    B=G*Tr.L_poi_full;
    val=0;
    val=val+lambda_2*B(:)'*G(:);
    val=val+lambda_3*sum(sum((G-F).^2))+sum(sum((G-Tr.R_bool).^2));
    val=(1/2)*val;
    t=toc(a);
    cache.B=B;
    % fprintf("\t\tpoi_f_sm: %.4f\n",t);