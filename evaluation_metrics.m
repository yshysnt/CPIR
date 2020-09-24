function [MP,MR,MAP,nDCG]=evaluation_metrics(Tr,Te,prob,configs)
    addpath("./metrics");
    Ns=configs.topNs;
    [n_users,n_pois]=size(prob);
    precision=zeros(n_users,length(Ns));
    recall = zeros(n_users,length(Ns));
    average_precision=zeros(n_users,length(Ns));
    ndcg_user=zeros(n_users,length(Ns));
    Tr_R=Tr.R_count;
    Te_R=Te.R_count;
    user_count=0;
    for i =1:Tr.usernum
        idx_tr = find(Tr_R(i,:)>0);
        prob(i,idx_tr)=0;
        [~,idx_pre_all] = sort(prob(i,:),'descend');
        idx_te = find(Te_R(i,:)>0);
        idx_uni = setdiff(idx_te,intersect(idx_tr,idx_te));
        if ~isempty(idx_uni)
            relevance=ismember(idx_pre_all,idx_uni);
            ap_cs=0;
            dcg=0;
            for k=1:max(Ns)
                idx_pre=idx_pre_all(1:k);
                correct_predictions=intersect(idx_pre,idx_uni);
                prec=length(correct_predictions)/k;
                reca=length(correct_predictions)/length(idx_uni);
                ap_cs=ap_cs+prec;
                dcg=dcg+(relevance(k))/(log2(k+1));
                % weight=sum(relevance(1:k));
                % if weight>0
                %     all_precision(i,k)=ap_cs/weight;
                % else
                %     all_precision(i,k)=0;
                % end

                if ismember(k,Ns)
                    l=find(Ns==k);
                    l=l(1);
                    precision(i,l)=prec;
                    recall(i,l)=reca;
                    average_precision(i,l)=ap_cs/k;
                    idcg=0;
                    for m=1:sum(relevance(:))
                        idcg=idcg+1/log2(m+1);
                    end
                    if sum(relevance(:)>0)
                        ndcg_user(i,l)=dcg/idcg;
                    else
                        ndcg_user(i,l)=0;
                    end

                end

            end
            user_count = user_count+1;
        end

    end
    
    MP=sum(precision,1)/user_count;
    MR=sum(recall,1)/user_count;
    MAP=sum(average_precision,1)/user_count;
    nDCG=sum(ndcg_user,1)/user_count;
end
