
clear all;
folder_data='/Volumes/nisl/hyosun/1.Noise_Experiment/V4-10_TNT_re-analyze/results';

X = categorical({'0' '10' '20' '30' '40' '50' '60' '70' '100'});
X = reordercats(X,{'0' '10' '20' '30' '40' '50' '60' '70' '100'});

cd(folder_data);

file_list=search_for_mat(folder_data);
for i=1:length(file_list)
    mat_file_names{1,i}=file_list(i).name;
end

f1=figure(1); hold on;
set(gcf,'Color','w');
f2=figure(2); hold on;
set(gcf,'Color','w');

for mat_file_idx=1:7
    
    load(mat_file_names{mat_file_idx},'mean_peak','single_norm');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%% compare peak amplitude %%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for panel_idx=1:4
        hold on;
        %%%%%%%%%%%%% plot the peak amplitude %%%%%%%%%%%%%%%%%
        cm=colororder("gem");

        sem=std(mean_peak{panel_idx},[],2,'omitnan')/sqrt(size(mean_peak{panel_idx},2));
        
        figure(1);
        haxes(panel_idx)=subplot(1,4,panel_idx);
        if sum(ismember([1,3:2:7],mat_file_idx))==1
            plot((1:9)-.03*mat_file_idx, mean(mean_peak{panel_idx},2,'omitnan'),'o-','Color',cm(mat_file_idx,:),'MarkerFaceColor',cm(mat_file_idx,:),'MarkerSize',2); 
            hold all;
        else
            plot((1:9)-.03*mat_file_idx, mean(mean_peak{panel_idx},2,'omitnan'),'o--','Color',cm(mat_file_idx+1,:),'MarkerSize',2);
        end
        set(gca,'XTick',1:9,'XTickLabel',{'0' '10' '20' '30' '40' '50' '60' '70' '100'});
        set(gca,'Box','off','TickDir','out');
        xlabel('noise level (%)'); ylabel('WBA response (deg)');
%% plot the normalized peak amplitude -- Figure 7A
        %%%%%%%%%%%%% plot the normalized peak amplitude %%%%%%%%%%%%%%%%%
        norm_sem=std(single_norm{panel_idx},[],2,'omitnan')/sqrt(size(mean_peak{panel_idx},2));
        
        figure(2);
        haxes(panel_idx)=subplot(1,4,panel_idx);
         if sum(ismember([1,3:2:7],mat_file_idx))==1
             plot((1:9)-.03*mat_file_idx, mean(single_norm{panel_idx},2,'omitnan'),'+-','Color',cm(mat_file_idx,:),'MarkerFaceColor',cm(mat_file_idx,:));
         else
             plot((1:9)-.03*mat_file_idx, mean(single_norm{panel_idx},2,'omitnan'),'+--','Color',cm(mat_file_idx+1,:));
         end
        axis tight;
        set(gca,'XTick',1:9,'XTickLabel',{'0' '10' '20' '30' '40' '50' '60' '70' '100'});
        set(gca,'Box','off','TickDir','out');
        xlabel('noise level (%)'); ylabel('Normalized WBA response (deg)');

        switch panel_idx
            case 1
                title('Bar');
                f1;ylim([-5 25]);
            case 2
                title('Spot');
                f1;ylim([-5 18]);
            case 3
                title('Loom');
                f1;ylim([-5 20]);
            case 4
                title('Grtng');
                f1;ylim([-5 20]);
        end
        f2;ylim([-0.1 1.2]);
    end

    clear wba_flyavg;
    clear mean_peak;
    clear wba_single_fly;

end

saveas(f1,['v3_compare_peak_of_silenced']);
saveas(f2,['v3_compare_normalized_peak_of silenced']); 

% end





