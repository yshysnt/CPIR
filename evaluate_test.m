function [ap,ar] = evaluate_test(Tr,Te,prob,configs)
    precision=0;
    recall =0;
    cal_user = 0;
    Tr_R=Tr.R_count;
    Te_R=Te.R_count;
    N=configs.topN;
    for i =1:Tr.usernum
        idx_tr = find(Tr_R(i,:)>0);
        prob(i,idx_tr)=-inf; % change back
        [~,idx_pre] = sort(prob(i,:),'descend');
        idx_pre=idx_pre(1:N);
        idx_te = find(Te_R(i,:)>0);
        idx_uni = setdiff(idx_te,intersect(idx_tr,idx_te));
    
        if ~isempty(idx_uni)
            precision = precision + length(intersect(idx_pre,idx_uni))/N;
            recall = recall + length(intersect(idx_pre,idx_uni))/length(idx_uni);
            cal_user = cal_user+1;
        end

            
    end
    
    ap=precision/cal_user;
    ar=recall/cal_user;

end
