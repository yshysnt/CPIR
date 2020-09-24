function [L_star]=poiProxOperator(Tr,Content,Z,lambda_5,tau)
    if lambda_5~=0
        L_star=zeros(size(Z));
        n_clusters=length(unique(Content.poi_cidx));
        [n_users,~]=size(Tr.R_bool);
        for h=1:n_clusters
            h_idx=find(Content.poi_cidx==h);
            rho_h=sqrt(length(h_idx));
            threshold=lambda_5*rho_h/tau;
            for u=1:n_users
                Z_sub=Z(u,h_idx);
                Z_sub_norm=norm(Z_sub,2);
                if Z_sub_norm>threshold
                    L_star(u,h_idx)=(Z_sub_norm-threshold)/Z_sub_norm*Z_sub;
                else
                    L_star(u,h_idx)=zeros(size(Z_sub));
                end
            end
        end
    else
        L_star=Z;
    end
end
