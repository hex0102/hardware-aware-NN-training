

linenum = size(result.acc_inference,2);
%figure

for i =1:linenum
    x_il = WL(i) - result.FL{i};
    subplot(2,2,i)
    title(['Word Length :' num2str(WL(i))]);
    for j=1:4
        loss = result.loss_inference{i}(j,:);
        plot(x_il,loss,'--','linewidth',2.5);
        xlim([2 12]);
        xlabel('Integer bitwidth')
        ylabel('Loss')
        hold on
    end
    legend('ideal','flip:0.001','flip:0.0001','flip:0.00001');
    %0.001 0.0001 0.00001
    grid on;
end


%{
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

%}




