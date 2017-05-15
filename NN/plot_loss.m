

linenum = size(result.acc_inference,2);
figure
for i = 1:1:linenum
    er_rate = result.acc_inference{i};
    x_il = WL - result.FL{i};
    plot(x_il,er_rate,'linewidth',2);
    xlabel('Integer bit num')
    ylabel('Misclarification rate')
    hold on
end
 
figure
for i = 1:1:linenum
    er_rate = result.loss_inference{i};
    x_il = WL - result.FL{i};
    plot(fraction,er_rate,'linewidth',2);
    xlabel('Integer bitnum')
    ylabel('Loss')
    hold on
end