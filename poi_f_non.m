function [val]=poi_f_non(Tr,Content,G,lambda_5)
    if lambda_5~=0
        [n_users,~]=size(Tr.R_bool);
        n_clusters=length(unique(Content.poi_cidx));
        val=0;
        for h=1:n_clusters
            h_idx=find(Content.poi_cidx==h);
            rho_h=sqrt(length(h_idx));
            for u=1:n_users
                subvec=G(u,h_idx);
                val=val+rho_h*norm(subvec,2);
            end
        end
        val=val*lambda_5;
    else
        val=0;
    end
end