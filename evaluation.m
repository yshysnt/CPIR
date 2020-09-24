function [ap,ar] = evaluation(Tr,Tr_R,prob,N,Te_R)
    precision=0;
    recall =0;
    
    cal_user = 0;
    for i =1:Tr.usernum
        idx_tr = find(Tr_R(i,:)>0);
        prob(i,idx_tr)=0;
        [~,idx_pre] = sort(prob(i,:),'descend');
        idx_pre=idx_pre(1:N);
        idx_te = find(Te_R(i,:)>0);
        idx_uni = setdiff(idx_te,intersect(idx_tr,idx_te));
        if length(idx_uni)>0
            precision = precision + length(intersect(idx_pre,idx_uni))/N;
            recall = recall + length(intersect(idx_pre,idx_uni))/length(idx_uni);
            cal_user = cal_user+1;
        end
    end
    ap=precision/cal_user;
    ar=recall/cal_user;

end