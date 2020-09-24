function [L_star]=ProxOperator(Tr,Content,Z,lambda_4,tau)
    if lambda_4~=0
        L_star=zeros(size(Z));
        n_clusters=length(unique(Content.user_cidx));
        [~,n_pois]=size(Tr.R_bool);
        for g=1:n_clusters
            g_idx=find(Content.user_cidx==g);
            omega_g=sqrt(length(g_idx));
            threshold=lambda_4*omega_g/tau;
            for p=1:n_pois
                Z_sub=Z(g_idx,p);
                Z_sub_norm=norm(Z_sub,2);
                if Z_sub_norm>threshold
                    L_star(g_idx,p)=(Z_sub_norm-threshold)/Z_sub_norm*Z_sub;
                else
                    L_star(g_idx,p)=zeros(size(Z_sub));
                end
            end
        end     
    else
        L_star=Z;
    end
end