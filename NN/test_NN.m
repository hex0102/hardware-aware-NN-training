%inference on ideal hardware
[original, original_index, original_loss] = nntest(nn, test_x, test_y);

%Different resolution
WL = [16 12 8 6];
FL = cell([1 4]);
FL{1} = [14 12 10];
FL{2} = [10 8 4];
FL{3} = [6 4 2];
FL{4} = [4 2];

acc_inference = FL;
loss_inference = FL;
%{
    DEFAULT CONFIGURATIONS ABOUT HARDWARE NO-IDEAL
%}

res.WL = 16;
res.IL = 4;
res.FL = res.WL - res.IL; % <IL,FL>  doned
res.P_flip =   0; %1e-5;  %  probability of bit-flip  doned 
res.P_stuck0 = 0; %1e-4; % probability of stuck-at-0   doned
res.P_stuck1 = 0; %1e-5; % probability of stuck-at-1
res.N_sigm = 8; % sigmoid N piece-wise linear  

for N_wl = 1:size(WL,2)
    res.WL = WL(N_wl);
    for N_fl = 1:size(FL{N_wl},2)     
        res.FL = FL{N_wl}(N_fl);
        disp(['>>>Processing Fixed point bitwidth ( ' num2str(res.WL) ...
            ' ) with fraction length ( ' num2str(res.FL) ' )']);
        res.IL = res.WL - res.FL; 
        [er, bad, loss]=nntest(nn, test_x, test_y, res);
        acc_inference{N_wl}(N_fl) = er;
        loss_inference{N_wl}(N_fl) = loss;   
        disp(['>>>>>>Error rate is : ' num2str(er) '; Averaged Loss is : ' num2str(loss)]);
    end
end