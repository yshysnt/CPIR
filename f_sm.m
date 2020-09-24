function [val,cache]=f_sm(Tr,X,lambda_1,lambda_2,lambda_3)
    tic;
    val=0;
    A=Tr.L_user_full*X;
    % for k=1:size(A,2)
    %     val=val+lambda_1*X(:,k)'*A(:,k);
    % end
    val=val+lambda_1*X(:)'*A(:);
    B=X*Tr.L_poi_full;
    % for k=1:size(B,1)
    %     val=val+lambda_2*B(k,:)*X(k,:)';
    % end
    val=val+lambda_2*B(:)'*X(:);
    val=val+lambda_3*sum(sum((X-Tr.R_bool).^2));
    val=1/2*val;
    cache.A=A;
    cache.B=B;
    t=toc;
    % fprintf("f_sm: %.4f\n",t);
end