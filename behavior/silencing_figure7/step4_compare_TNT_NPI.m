%%%%%%%compare Noise performance index of TNT flies

clear all;
folder_data='/Volumes/nisl/hyosun/1.Noise_Experiment/V4-10_TNT_re-analyze/results';
folder_save='ANOVA2/';

cd(folder_data);
file_list=search_for_mat(folder_data);
for i=1:length(file_list)
    mat_file_names{1,i}=file_list(i).name;
end

auc_all=[]; g_name_all=[];
for mat_file_idx=1:7
    load(mat_file_names{mat_file_idx},"auc3");
    auc_all=vertcat(auc_all,auc3');
    g_name=repmat({[mat_file_names{mat_file_idx}(21:end-4)]},length(auc3),1);
    g_name_all=vertcat(g_name_all,g_name);

end

%% compare Noise Robustness index using ANOVA1 --- Figure 7B
pat={'bar','spot','loom','grating'};

for pattern_idx=1:4
    [p,t,stats]=anova1(auc_all(:,pattern_idx),g_name_all);
    set(gcf,'Color','w');
    sgtitle([pat{pattern_idx} ' Noise Performance (p=' num2str(p) ')']);
    set(gca,'Box','off','TickDir','out','FontSize',12);
    ylabel('AUC(a.u.)');
    means=stats.means;

    ii=(mean(means)+80)*ones(1, 17);

    figure;

    
    [c,m,h,gnames] = multcompare(stats);
    
    for i=1:size(c,1)
        disp([ num2str(c(i,1)) ' with ' num2str(c(i,2)) ' pValue : ' num2str(c(i,6))]);
    end

end



