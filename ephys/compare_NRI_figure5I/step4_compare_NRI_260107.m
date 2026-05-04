%compare_AUC
clear;
folder_data= '/Users/hyosunkim/1_Analyze_data/noise/v2_compare_AUC/result_v5';
folder_save= 'figure/';
%flickering bar r patid : [11:2:26]; 1-8   pat2=[12,19,13:18];

file_list=search_for_mat(folder_data);
for i=1:length(file_list)
    mat_file_names{1,i}=file_list(i).name;
end
auc_all=[]; g_name_all=[];

for mat_file_idx=1:6
    % load(mat_file_names{mat_file_idx},"auc");
    if mat_file_idx == 1
        load(mat_file_names{mat_file_idx},"auc3");
        auc_all = [auc3(4,:)'; auc3(1,:)'; auc3(3,:)'; auc3(2,:)']; % bar/spot/loom/grating
        g_name=[repmat({'gratingWBA'},length(auc3),1); repmat({'barWBA'},length(auc3),1);...
            repmat({'loomWBA'},length(auc3),1);repmat({'spotWBA'},length(auc3),1)];
    elseif mat_file_idx == 2
        load(mat_file_names{mat_file_idx},"auc3");
        %LC15bar/LPLC2bar/LC4loom/LPLC2loom/LC11loom/LC11spot/LPLC2spot
         %LC15bar/LPLC2bar/LPLC2spot/LC11spot/LC4loom/LPLC2loom/LC11Loom
        auc_all = [auc_all; auc3(2,1:11)';auc3(1,1:9)'; auc3(7,1:8)'; auc3(6,1:6)'; auc3(4,1:7)'; auc3(3,1:13)';auc3(5,1:6)']; 
        g_name=[g_name; repmat({'LPLC2Bar'},11,1);repmat({'LC15Bar'},9,1);repmat({'LPLC2Spot'},8,1);repmat({'LC11Spot'},6,1) ;...
            repmat({'LPLC2Loom'},7,1); repmat({'LC4Loom'},13,1);repmat({'LC11Loom'},6,1) ];
    elseif mat_file_idx == 3
         load(mat_file_names{mat_file_idx},"auc3");
        auc_all = [auc_all; auc3(2,:)'; auc3(1,:)']; %LC15ba/LPLC2bar/LC4loom/LPLC2loom
        g_name = [g_name; repmat({'HS Grating'},length(auc3),1); repmat({'HS Bar'},length(auc3),1)];
    elseif mat_file_idx == 5
        load(mat_file_names{mat_file_idx},"auc3");
        auc_all = [auc_all; auc3(1,:)']; % CSxTNT Slowbar
        g_name =[g_name; repmat({'SlowbarWBA'},length(auc3),1)];
    elseif mat_file_idx == 6
        load(mat_file_names{mat_file_idx},"auc3");
        auc_all = [auc_all; auc3{1}(2,:)'; auc3{2}(2,:)']; % LC15 SlowbarB2f/LPLC2B2f
        g_name =[g_name; repmat({'LC15 Slowbar'},length(auc3{1}),1);repmat({'LPLC2 Slowbar'},length(auc3{2}),1)];
    elseif mat_file_idx == 4
        load(mat_file_names{mat_file_idx},"auc3");
        auc_all = [auc_all; auc3(1,:)';auc3(2,:)';auc3(3,:)']; %bar/loom/spot
        g_name = [g_name; repmat({'DNp06 Bar'},length(auc3),1);repmat({'DNp06 Loom'},length(auc3),1);repmat({'DNp06 Spot'},length(auc3),1)];
    else
        load(mat_file_names{mat_file_idx},"auc3");
        %LC15bar/LPLC2bar/LC4loom/LPLC2loom/LC11spot/LPLC2spot/LC11loom
         %LC15bar/LPLC2bar/LPLC2spot/LC11spot/LC4loom/LPLC2loom/LC11Loom
        auc_all = [auc_all; auc3(2,1:11)';auc3(1,1:9)'; auc3(4,1:7)'; auc3(3,1:13)';]; 
        g_name=[g_name; repmat({'LPLC2fastBar'},11,1);repmat({'LC15fastBar'},9,1);...
            repmat({'LPLC2fastLoom'},7,1); repmat({'LC4fastLoom'},13,1)];
    end
    
end

%% compare ANOVA

[p,t,stats]=anova1(auc_all,g_name);  %/80*100
set(gcf,'Color','w');
% sgtitle([ ' Noise Performance (p=' num2str(p) ')']);
set(gca,'Box','off','TickDir','out','FontSize',12);
ylabel('AUC(a.u.)');

means=stats.means;
% std=stats.s;
% means=means/80*100;
ii=104*ones(1,size(means,2));

% for i=1:size(means,2)
%     text(i,ii(i),num2str(means(i))); hold on;
% end
% saveas(gcf,[folder_save 'v3_AUC2_ANOVA_NotchPlot_trapezoidal']);

MSE = t{2,4};


figure;
[c,m,h,gnames] = multcompare(stats);

for i=1:size(c,1)
    disp([ num2str(c(i,1)) ' with ' num2str(c(i,2)) ' pValue : ' num2str(c(i,6))]);
end

% saveas(gcf,[folder_save 'v2_Compare_AUC_ANOVA']);

%% For standard deviation

[means, sds, nums,nnn] = grpstats(auc_all, g_name);

%% heat map
figure(2);clf;
% xvalues={"Grating","Bar","Loom","Spot"};
% yvalues={"WBA","LPLC2","LC15","LC4","HS","DNp06"};
% cdata=[means(1:4); nan,means(5),means(7),nan; nan, means(6),nan,nan;... 
%     nan,nan,means(8),nan; means(9),means(10),nan,nan; nan,means(11:13)];

xvalues={"Grating","Bar","Loom","Spot","Slow-bar(4s)"};
yvalues={"WBA","LPLC2","LC11","LC15","LC4","HS","DNp06"};

cdata=[means(1:4)',means(17);...
    nan,means(5),means(9),means(7),means(19);...
    nan,nan,means(11),means(8),nan;...
    nan,means(6),nan,nan,means(18);...
    nan,nan,means(10),nan,nan;...
    means(12),means(13),nan,nan,nan;...
    nan,means(14:16)',nan];

heatmap(xvalues,yvalues,cdata);


% xvalues={"Grating","Bar(0.2s)","Loom","Spot","Slow-bar(4s)","Fast-bar(0.14)"};
% yvalues={"WBA","LPLC2","LC11","LC15","LC4","HS","DNp06"};
% 
% cdata=[means(1:4),means(17),nan;...
%     nan,means(5),means(9),means(7),means(19),means(20);...
%     nan,nan,means(11),means(8),nan,nan;...
%     nan,means(6),nan,nan,means(18),means(21);...
%     nan,nan,means(10),nan,nan,nan;...
%     means(12),means(13),nan,nan,nan,nan;...
%     nan,means(14:16),nan,nan];
% 
% heatmap(xvalues,yvalues,cdata);