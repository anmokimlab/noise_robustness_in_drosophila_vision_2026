% analyze NRI of ResNet
clear; %grat,loom,bar,spot L/R

file_list=search_for_mat();


for idx=1:5%size(file_list,1) %0,10,20,30,70
    load(file_list(idx).name);
    merged_acc{idx}=accuracy;
    merged_acc_per_pat{idx}=accuracy_per_pattern;
    
    % Calculate NRI
    for pattern_idx=1:size(merged_acc_per_pat{idx},2)
        % calculate with mean value
        auc3(idx,pattern_idx)=mean(merged_acc_per_pat{idx}(2:8,pattern_idx),'omitnan')*100;
    end
end

%% plot NRI
figure; clf;set(gcf,'color','w');hold all;

for idx=1:size(file_list,1)/2
    plot(auc3(idx,:));
end
title('NRI of each pattern acrros training range', 'FontWeight', 'bold', 'FontSize', 15);
xlabel('Pattern');
ylabel('NRI');
% xlim([-5 75]); ylim([0 100]);
xticks(1:1:4);
xticklabels({'Grating','Loom','Bar','Spot'});
set(gca,'TickDir','out');
legend('0%noise','0-10%noise','0-20%noise','0-30%noise','0-70%noise','Box','off');

%% plot NRI
figure; clf;set(gcf,'color','w');hold all;

bar(auc3);

title('NRI of each pattern across training range', 'FontWeight', 'bold', 'FontSize', 15);
xlabel('Pattern');
ylabel('NRI');
% xlim([-5 75]); ylim([0 100]);
xticks(1:1:5);
set(gca,'TickDir','out');
xticklabels({'0%noise','0-10%noise','0-20%noise','0-30%noise','0-70%noise'});
legend('Grating','Loom','Bar','Spot','Box','off','Location','northwest');

%% plot_grating FigureS2F
figure; clf;set(gcf,'color','w');hold all;
for i=1:5
    plot(merged_acc_per_pat{i}(:,4),'.-');
end

legend({'0%noise','0-10%noise','0-20%noise','0-30%noise','0-70%noise'},'location','southwest');
xlabel('Noise level (%)');
set(gca,'tickdir','out','xtick',[1:8],'xticklabel',0:10:70);
ylabel('Accuracy (%)');
set(gca,'tickdir','out','box','off');
title('Spot across training range');