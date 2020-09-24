function [val]=f_non(Tr,Content,X,lambda_4)
    if lambda_4~=0
        [~,n_pois]=size(Tr.R_bool);
        n_clusters=length(unique(Content.user_cidx));
        val=0;
        for g=1:n_clusters
            g_idx=find(Content.user_cidx==g);
            omega_g=sqrt(length(g_idx));
            for p=1:n_pois
                subvec=X(g_idx,p);
                val=val+omega_g*norm(subvec,2);
            end
        end
        val=val*lambda_4;
    else
        val=0;
    end
end