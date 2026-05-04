figure(1);clf;
set(gcf,'Color','w');

%%%%%%%%%%% plot the normalized mean peak %%%%%%%%%%%%%%%%%

pat_grp_idx={[1:8], [9:16], [17:24], [25:32]};

c='bmrg';
for panel_idx=1:4
    subplot(2,2,panel_idx);

    switch panel_idx
        case 1
            title('Bar');
            xlabel('noise level (%)');ylabel('Normalized WBA response (deg)');
        case 2
            title('Spot');
        case 3
            title('Loom');
        case 4
            title('Grating');
    end
    hold on;

    errorbar((1:8)+0.3,mean(accuracy_flies(pat_grp_idx{panel_idx},:),2),...
        1.96*std(accuracy_flies(pat_grp_idx{panel_idx},:),[],2)/sqrt(size(accuracy_flies,2)),'Color',[.7, .7, .7]); hold all;
    p1=plot((1:8)+0.3,mean(accuracy_flies(pat_grp_idx{panel_idx},:),2),'Color','k','Marker','o','MarkerFaceColor','k');
    
    errorbar(1:8, avg_avg_acc(panel_idx,1:8), sem(panel_idx,1:8),'Color',ones(1,3)*0.8);hold on;
    p2=plot(avg_avg_acc(panel_idx,1:8),'Color',c(panel_idx),'Marker','o','MarkerFaceColor',c(panel_idx));

    %%%%%%%%%%%%%%%%%%%% caculate p-value %%%%%%%%%%%%%%%%%%%%%%%%%

    % for i=1:8
    %     locat=mean(avg_avg_acc(panel_idx,i),2)+.1;
    %     [h p{panel_idx}(i)]=ttest2(avg_acc{panel_idx,i}(1,:),accuracy_flies(pat_grp_idx{panel_idx}(i),:));
    %     if(p{panel_idx}(i)<0.001)
    %         text(i, locat, '***');
    %     elseif(p{panel_idx}(i)<0.01)
    %         text(i, locat, '**');
    %     elseif(p{panel_idx}(i)<0.05)
    %         text(i, locat, '*');
    %     end
    % end
    
    set(gca,'Box','off','Tickdir','out','FontSize',12);
    xlabel('Noise level (%)');
    ylabel('Accuracy');
    ylim([-.1 1.2]);
    set(gca,'XTick',1:9,'XTickLabel',{'0' '10' '20' '30' '40' '50' '60' '70'});
end

legend([p1, p2],{'Drosophila', 'human'});


%% compare the latency

% figure(2);clf;
% set(gcf,'Color','w');
% 
% %%%%%%%%%%% plot the normalized mean peak %%%%%%%%%%%%%%%%%
% 
% pat_grp_idx={[1:8], [9:16], [17:24], [25:32]};
% 
% c='bmrg';
% for panel_idx=1:4
%     subplot(2,2,panel_idx);
% 
%     switch panel_idx
%         case 1
%             title('Bar');
%             xlabel('noise level (%)');ylabel('Normalized WBA response (deg)');
%         case 2
%             title('Spot');
%         case 3
%             title('Loom');
%         case 4
%             title('Grating');
%     end
%     hold on;
% 
%     errorbar((1:8)+0.3, mean_lat_50(panel_idx,1:8)-1.5, sem(panel_idx,1:8),'Color',ones(1,3)*0.8);hold on;
%     p1=plot((1:8)+0.3, mean_lat_50(panel_idx,1:8)-1.5,'Color','k','Marker','o','MarkerFaceColor','k');hold on;
% 
%     errorbar(1:8, avg_avg_lat(panel_idx,1:8), sem_lat(panel_idx,1:8),'Color',ones(1,3)*0.8);hold on;
%     p2=plot(avg_avg_lat(panel_idx,1:8),'Color','b','Marker','o','MarkerFaceColor','b');
% 
%     % %%%%%%%%%%%%%%%%%%%% caculate p-value %%%%%%%%%%%%%%%%%%%%%%%%%
%     % 
%     % for i=1:8
%     %     locat=mean(avg_avg_lat(panel_idx,i),2)+.1;
%     %     [h p{panel_idx}(i)]=ttest2(avg_acc{panel_idx,i}(1,:),accuracy_flies(pat_grp_idx{panel_idx}(i),:));
%     %     if(p{panel_idx}(i)<0.001)
%     %         text(i, locat, '***');
%     %     elseif(p{panel_idx}(i)<0.01)
%     %         text(i, locat, '**');
%     %     elseif(p{panel_idx}(i)<0.05)
%     %         text(i, locat, '*');
%     %     end
%     % end
% 
%     set(gca,'Box','off','Tickdir','out','FontSize',12);
%     xlabel('Noise level (%)');
%     ylabel('latency');
%     ylim([0 1.2]);
%     set(gca,'XTick',1:9,'XTickLabel',{'0' '10' '20' '30' '40' '50' '60' '70'});
% end
% 
% legend([p1, p2],{'Drosophila', 'human'});





%% compare the mean of accuracy

for panel_idx=1:4 %bar/spot/loom/grating
    mean_human(panel_idx)=mean(avg_avg_acc(panel_idx,1:8));
    mean_fly(panel_idx)=mean(mean(accuracy_flies(pat_grp_idx{panel_idx},:),2));
    sem2_human(panel_idx,:)=1.96*std(avg_avg_acc(panel_idx,1:8))/sqrt(size(avg_acc{panel_idx,1},2));
    sem2_fly(panel_idx,:)=1.96*std(mean(accuracy_flies(pat_grp_idx{panel_idx},:),2))/sqrt(size(accuracy_flies,2));
end

%% Compare the mean of accuracy --Figure 3D
figure;

subplot(2,1,1);
errorbar([(1:4)-.15;(1:4)+.15],[mean_fly;mean_human],[sem2_fly'; sem2_human'],'k','LineStyle','none','Marker','+'); hold all;
% plot(1:4,[mean_fly;mean_human],'Marker','+','LineStyle','none');
for panel_idx=1:4 
    scatter(panel_idx-.15,mean(accuracy_flies(pat_grp_idx{panel_idx},:),2),'g');hold all;
    scatter(panel_idx+.15,avg_avg_acc(panel_idx,1:8),'b')
end
legend('','','','',"fly","human","box","off");
set(gca,'Box','off','Tickdir','out','FontSize',12);
set(gca,'XTick',1:4,'XTickLabel',{'bar' 'spot' 'loom' 'grating'});
ylabel('mean of accuracy');

subplot(2,1,2);
bar(1:4,mean_human-mean_fly);
set(gca,'XTick',1:4,'XTickLabel',{'bar' 'spot' 'loom' 'grating'});
ylabel('difference in mean of accuracy');
set(gca,'Box','off','Tickdir','out','FontSize',12);
