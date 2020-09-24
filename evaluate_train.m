function [err]=evaluate_train(Tr,R)
    err=full(mean(mean(((Tr.R_bool-R).^2) .*Tr.R_bool)));
end