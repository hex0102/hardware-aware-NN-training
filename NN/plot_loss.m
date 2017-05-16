

linenum = size(result.acc_inference,2);
%figure

subplot(1,2,1)
for i = 1:1:linenum
    er_rate = result.acc_inference{i};
    x_il = WL(i) - result.FL{i};
    plot(x_il,er_rate,'linewidth',2);
    xlabel('Integer bitwidth')
    ylabel('Misclarification rate')
    hold on;
end
set(gca,'FontSize', 18);
legend('WL:16','WL:12','WL:8','WL:6');
grid on;


subplot(1,2,2)
for i = 1:1:linenum
    er_rate = result.loss_inference{i};
    x_il = WL(i) - result.FL{i};
    plot(x_il,er_rate,'linewidth',2);
    xlabel('Integer bitwidth')
    ylabel('Loss')
    hold on;
end
set(gca,'FontSize', 18);
legend('WL:16','WL:12','WL:8','WL:6');
grid on;