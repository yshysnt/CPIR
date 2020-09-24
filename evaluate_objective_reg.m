function [val]=evaluate_objective_reg(Tr,Content,R,configs)
    val=f_sm(Tr,R,configs.lambda_1,configs.lambda_2,configs.lambda_3);
    val=val+f_non(Tr,Content,R,configs.lambda_4);

end