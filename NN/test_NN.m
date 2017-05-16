%inference on ideal hardware
nn.activation_function = 'sigm';
[original, original_index, original_loss] = nntest(nn, test_x, test_y);

tic
%Different resolution
WL = [16 12 8 6];
FL = cell([1 4]);
FL{1} = [14 13 12 11 10];
FL{2} = [10 9 8 6 4 2 ];
FL{3} = [6 5 4 3 2 1];
FL{4} = [4 3 2 1];

result.acc_inference = FL;
result.loss_inference = FL;
result.WL = WL;
result.FL = FL;

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

% >>> Testing different bitwidths ...


%{
for N_wl = 1:size(WL,2)
    res.WL = WL(N_wl);
    for N_fl = 1:size(FL{N_wl},2)     
        res.FL = FL{N_wl}(N_fl);
        disp(['>>>Processing Fixed point bitwidth ( ' num2str(res.WL) ...
            ' ) with fraction length ( ' num2str(res.FL) ' )']);
        res.IL = res.WL - res.FL; 
        [er, bad, loss]=nntest(nn, test_x, test_y, res);
        result.acc_inference{N_wl}(N_fl) = er;
        result.loss_inference{N_wl}(N_fl) = loss;   
        disp(['>>>>>>Error rate is : ' num2str(er) '; Averaged Loss is : ' num2str(loss)]);
    end
end
%}

% >>> Testing different sigmoid implementations ...

nn.activation_function = 'sigm_hard';
N_sigms = [4 8];
for i=1:size(N_sigms,2)
    res.N_sigm = N_sigms(i);
    for N_wl = 1:size(WL,2)
        res.WL = WL(N_wl);
        for N_fl = 1:size(FL{N_wl},2)     
            res.FL = FL{N_wl}(N_fl);
            disp(['>>>Processing Fixed point bitwidth ( ' num2str(res.WL) ...
                ' ) with fraction length ( ' num2str(res.FL) ' )']);
            res.IL = res.WL - res.FL; 
            [er, bad, loss]=nntest(nn, test_x, test_y, res);
            result.acc_inference{N_wl}(i,N_fl) = er;
            result.loss_inference{N_wl}(i,N_fl) = loss;   
            disp(['>>>>>>Error rate is : ' num2str(er) '; Averaged Loss is : ' num2str(loss)]);
        end
    end
end
%}
toc


