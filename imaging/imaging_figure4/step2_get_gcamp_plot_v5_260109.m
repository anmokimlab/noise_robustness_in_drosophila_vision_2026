%editing from ver2 -----250211
%%%%%250529 hyosun edited ---- edit normalize method & response idx (ver_7) 
%Method 2----------------------
%%Calculate noise performance index in GCaMP imaging result
%%%%%%%%pattern play time : 1.44s

clear;
folder_data='/Users/hyosunkim/1_Analyze_data/noise/2photon/RandMotion/mat_files';
folder_save='final_results_v6_260428/';

%flickering bar r patid : [11:2:26]; 1-8   pat2=[12,19,13:18];

PATNAMES={'noise 0','flick noise 10','flick noise 20','flick noise 30','flick noise 40',...
    'flick noise 50','flick noise 60','flick noise 70','left flick noise 0','left flick noise 10',...
    'left flick noise 20'};

%%pattern name for Random motion noise
% PATNAMES={'noise 0','flick noise 10','flick noise 20','flick noise 30','flick noise 40',...
%     'flick noise 50','flick noise 60','flick noise 70','left flick noise 0','left flick noise 10',...
%     'left flick noise 20', 'random motion 10','random motion 20','random motion 30','random motion 40',...
%     'random motion 50','random motion 60','random motion 70','left random motion 10','left random motion 20'};

file_list=search_for_mat(folder_data);
for i=1:length(file_list)
    mat_file_names{1,i}=file_list(i).name;
end

tit={'Bar LC15','Bar LPLC2','Loom LC4','Loom LPLC2','Loom LC11', 'Spot LC11','Spot LPLC2'};
dt=1;


for mat_file_idx=1:7 

    load(mat_file_names{mat_file_idx});
    PATDUR=4*ones(1,size(seg_idx,1));
    t = seg_idx{1}*10^-3;
   
    for pat_idx=1:size(mean_gcamp_tr_all,2)
        for n=1:size(mean_gcamp_tr_all,1)
            tr=cell2mat(mean_gcamp_tr_all(:,pat_idx));
            baseline_idx=(seg_idx{pat_idx}>1.3*10^4 & seg_idx{pat_idx}<1.5*10^4); %-5000/0
            response_idx=(seg_idx{pat_idx}>1.65*10^4 & seg_idx{pat_idx}<=1.85*10^4);  %PATDUR(pat_idx)
            response_idx_lat=(seg_idx{pat_idx}>1.5*10^4 & seg_idx{pat_idx}<=2*10^4);
            based_gcamp{n,pat_idx}=mean_gcamp_tr_all{n,pat_idx}(1,:)-mean(mean_gcamp_tr_all{n,pat_idx}(1,baseline_idx),2); %/based_gcamp
            %%%%%%%%% delf/f %%%%%%%%%
            del_gcamp{mat_file_idx,pat_idx}(n,:)=based_gcamp{n,pat_idx}(1,:)/mean(mean_gcamp_tr_all{n,pat_idx}(1,baseline_idx),2);
            gcamp_amplitude{mat_file_idx}(n,pat_idx)=mean(del_gcamp{mat_file_idx,pat_idx}(n,response_idx),2);
        end
        %%%%%%%%%%% ignore data error %%%%%%%%%%%%%%%%
        if mat_file_idx==1
            % del_gcamp{mat_file_idx,pat_idx}(10,:)=[];
            % gcamp_amplitude{mat_file_idx}(10,:)=[];
        elseif mat_file_idx==3
            del_gcamp{mat_file_idx,pat_idx}(11,:)=[];
            % gcamp_amplitude{mat_file_idx}(11,:)=[];
        end
    end
    %%%%%%%%%%% ignore data error %%%%%%%%%%%%%%%%
    if mat_file_idx==1
        gcamp_amplitude{mat_file_idx}(10,:)=[];
    elseif mat_file_idx==3
        gcamp_amplitude{mat_file_idx}(11,:)=[];
    end

    idx0= {[1:9],[1:9],[1:9],[1:9],[12,14,16:22],[2,4,6:11,22],[2,4,6:11,22]};
    idx= {[1:8],[1:8],[1:8],[1:8],[12,14,16:21],[2,4,6:11],[2,4,6:11]};
    
    avg_gcamp{mat_file_idx,:}=mean(gcamp_amplitude{mat_file_idx},1,'omitnan');

    %%%%%%%%%%%%%%%%%%% normalized amplitude %%%%%%%%%%%%%%%%%%
    % normalize the response to min / max
    mean_min_gcamp{mat_file_idx} = min(avg_gcamp{mat_file_idx}(idx0{mat_file_idx}));
    mean_max_gcamp{mat_file_idx} = max(avg_gcamp{mat_file_idx}(idx0{mat_file_idx}));
    
    if mat_file_idx == 5 || mat_file_idx == 6 || mat_file_idx ==7 
        for n=1:size(gcamp_amplitude{mat_file_idx},1)
            mean_norm(mat_file_idx,1:9) = (avg_gcamp{mat_file_idx}(idx0{mat_file_idx}) - mean_min_gcamp{mat_file_idx}) / (mean_max_gcamp{mat_file_idx} - mean_min_gcamp{mat_file_idx});
            single_norm{mat_file_idx}(n,1:9) = (gcamp_amplitude{mat_file_idx}(n,idx0{mat_file_idx}) - mean_min_gcamp{mat_file_idx}) / (mean_max_gcamp{mat_file_idx} - mean_min_gcamp{mat_file_idx});
        end
    else
        for n=1:size(gcamp_amplitude{mat_file_idx},1)
            mean_min_rand{mat_file_idx} = min(avg_gcamp{mat_file_idx}([1,12:18,9]));
            mean_max_rand{mat_file_idx} = max(avg_gcamp{mat_file_idx}([1,12:18,9]));

            mean_norm(mat_file_idx,1:9) = (avg_gcamp{mat_file_idx}(idx0{mat_file_idx}) - mean_min_gcamp{mat_file_idx}) / (mean_max_gcamp{mat_file_idx} - mean_min_gcamp{mat_file_idx});
            mean_norm(mat_file_idx,10:18) = (avg_gcamp{mat_file_idx}([1,12:18,9]) - mean_min_rand{mat_file_idx}) / (mean_max_rand{mat_file_idx} - mean_min_rand{mat_file_idx});

            single_norm{mat_file_idx}(n,1:9) = (gcamp_amplitude{mat_file_idx}(n,idx0{mat_file_idx}) - mean_min_gcamp{mat_file_idx}) / (mean_max_gcamp{mat_file_idx} - mean_min_gcamp{mat_file_idx});
            single_norm{mat_file_idx}(n,10:18) = (gcamp_amplitude{mat_file_idx}(n,[1,12:18,9]) - mean_min_rand{mat_file_idx}) / (mean_max_rand{mat_file_idx} - mean_min_rand{mat_file_idx});

        end
    end


    %% plot population traces -- Figure 3C
    
    % f1=figure(1); clf; set(gcf,'Color','w'); hold on;
    % sgtitle([tit{mat_file_idx} 'flies trials amplitude']);
    % cm=repmat(linspace(0.2, 0.7, size(mean_gcamp_tr_all,1))', 1, 3);
    % 
    % cm=cm(randperm(end),:);
    % set(gcf,'Color','w','defaultAxesColorOrder',cm);
    % %
    % for pat_idx=1:11 %20 for random motion noise
    %     subplot(4,5,pat_idx); title(PATNAMES{pat_idx});hold on;
    %     rectangle('Position',[1.44 -20 0.2 60 ],'FaceColor',[0.8 0.8 0.8],'EdgeColor',[0.8 0.8 0.8]);hold on;
    %     for n=1:size(del_gcamp{mat_file_idx,pat_idx},1) %size(all_gcamp_amplitude{mat_file_idx},1) %size(mean_gcamp_tr_all,1) %size(all_gcamp_amplitude{mat_file_idx},1)
    %         plot(seg_idx{i}*dt/10000,del_gcamp{mat_file_idx,pat_idx}(n,:));hold on;
    %         xlabel('time(s)'); ylabel('delF/F');
    %         % del_gcamp2{pat_idx}(n,:)=cell2mat(del_gcamp{mat_file_idx,pat_idx}(n,:));
    %         del_gcamp2{pat_idx}(n,:)=del_gcamp{mat_file_idx,pat_idx}(n,:);
    %     end
    % 
    %     plot(seg_idx{i}*dt/10000,mean(del_gcamp2{pat_idx}),'r','LineWidth',1.5);
    %     xlim([1.2 3]); ylim([-0.1 0.6]);
    %     set(gca,'Box','off','TickDir','out','FontSize',12);
    % 
    % end

    % % savefig(f1,['v2_final_plot_gcamp/' tit{mat_file_idx} 'final_flies_trials']);

    %% Plot population traces across noise levels -- Figure 3D, 3F, S4A, S4D

    xtick={'0','10','20','30','40','50','60','70'};
    x=1:9;

    %%%%%%%%%%%%%%%% Flickering Noise %%%%%%%%%%%%%%%%%%%%%%%%%
    f2=figure(2);set(gcf,'Color','w'); hold on; 
    subplot(4,2,mat_file_idx);sgtitle('Flickering Noise')
    rectangle('Position',[1.44 -20 0.2 60 ],'FaceColor',[0.8 0.8 0.8],'EdgeColor',[0.8 0.8 0.8]);
    
    for pat_idx= idx{mat_file_idx} %[1,12:18]
        plot(seg_idx{pat_idx}*dt/10000,mean(del_gcamp{mat_file_idx,pat_idx}),'LineWidth',1.5); hold on;
    end
    colormap turbo;
    xlim([1.4 2]); ylim([-0.1 0.6]);
    set(gca,'Box','off','TickDir','out','FontSize',12);
    
    switch mat_file_idx
        case 1
            title('LC15 Bar'); z=1; %legend(xtick,'Box','off'); 
        case 2
            title('LPLC2 Bar'); z=2; %legend(xtick);
        case 3
            title('LC4 Loom'); z=1; %legend(xtick);
        case 4
            title('LPLC2 Loom'); z=2; %legend(xtick);
        case 5
            title('LC11 Loom'); z=3;
        case 6
            title('LC11 Spot'); legend(xtick,'Box','off'); z=1;
        case 7
            title('LPLC2 Loom');z=2;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%% RandomMotion %%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if mat_file_idx < 5
        f3=figure(3); subplot(2,2,mat_file_idx); sgtitle('Random Motion noise');
        rectangle('Position',[1.44 -20 0.2 60 ],'FaceColor',[0.8 0.8 0.8],'EdgeColor',[0.8 0.8 0.8]);hold all;
        for pat_idx=[1,12:18]
            plot(seg_idx{pat_idx}*dt/10000,mean(del_gcamp{mat_file_idx,pat_idx}),'LineWidth',1.5); hold on;
        end
        colormap turbo;
        xlim([1.2 3]); ylim([-0.1 0.6]);
        set(gca,'Box','off','TickDir','out','FontSize',12);

        switch mat_file_idx
            case 1
                title('LC15 Bar'); legend(xtick,'Box','off');
            case 2
                title('LPLC2 Bar'); %legend(xtick);
            case 3
                title('LC4 Loom'); %legend(xtick);
            case 4
                title('LPLC2 Loom'); %legend(xtick);
        end
    end


    %% Plot peak amplitude (normalized) LPLC2 LC4 loom/ LC15 LPLC2 bar
    % Flickering 1:9 / RandomMotion 10:18

    cm='bgrgmmg';
    f4=figure(4); set(gcf,'Color','w'); hold all;
    
    if mat_file_idx == 1 || mat_file_idx == 2  % LC15 bar / LPLC2 bar
        subplot(1,3,1);xticks(1:9); xticklabels(xtick); 
        xlabel('noise (%)'); ylabel('avg delF/F');title('bar');
        legend('LC15','LPLC2');

    elseif mat_file_idx == 6 || mat_file_idx == 7 % LC11 spot / LPLC2 spot
        subplot(1,3,3); xticks(1:9); xticklabels(xtick); 
        xlabel('noise (%)'); ylabel('avg delF/F');title('spot');
        legend('LC11','LPLC2');
    else
        subplot(1,3,2);xticks(1:9); xticklabels(xtick); 
        xlabel('noise (%)'); ylabel('avg delF/F');title('loom');
        legend('LC4','LPLC2','LC11');
    end
    errorbar(avg_gcamp{mat_file_idx}(idx{mat_file_idx}), std(gcamp_amplitude{mat_file_idx}(:,idx{mat_file_idx}),1)/sqrt(size(gcamp_amplitude{mat_file_idx}(:,idx{mat_file_idx}),1))*1.96,'Color',ones(1,3)*0.8);
    plot(avg_gcamp{mat_file_idx}(idx{mat_file_idx}),'Color',cm(mat_file_idx),'Marker','o','MarkerFaceColor',cm(mat_file_idx));
    set(gca,'Box','off','TickDir','out','FontSize',12);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%% RandomMotion %%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    f5=figure(5); set(gcf,'Color','w'); hold on;
    if mat_file_idx < 5
        %for bar / loom before normalize randmotion
        if mat_file_idx == 1 || mat_file_idx == 2  %LC15 bar / LPLC2 bar
            subplot(1,2,1);xticks(1:8); xticklabels(xtick); 
            xlabel('noise (%)'); ylabel('avg delF/F');title('bar');
            legend('LC15','LPLC2');
        elseif mat_file_idx == 3 || mat_file_idx == 4  %LC4 loom / LPLC2 loom
            subplot(1,2,2);xticks(1:8); xticklabels(xtick); 
            xlabel('noise (%)'); ylabel('avg delF/F');title('loom');
            legend('LC4','LPLC2');
        end
        errorbar(avg_gcamp{mat_file_idx}(1,12:19), std(gcamp_amplitude{mat_file_idx}(:,12:19),1)/sqrt(size(gcamp_amplitude{mat_file_idx}(:,10:17),1))*1.96,'Color',ones(1,3)*0.8);
        plot(avg_gcamp{mat_file_idx}(1,12:19),'Color',cm(mat_file_idx),'Marker','o','MarkerFaceColor',cm(mat_file_idx));
        set(gca,'Box','off','TickDir','out','FontSize',12);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%% normalized avg amplitude %%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% single_norm{mat_file_idx}(n,1:9)
    f6=figure(6); set(gcf,'Color','w');
    %for bar / loom normalize flickering
    if mat_file_idx == 1 || mat_file_idx == 2  %LC15 bar / LPLC2 bar
        subplot(1,3,1);xticks(1:8); xticklabels(xtick); hold on;
        xlabel('noise (%)'); ylabel('avg delF/F');title('bar');
        legend('LC15','LPLC2');
    elseif mat_file_idx == 6 || mat_file_idx == 7
        subplot(1,3,3); xticks(1:8); xticklabels(xtick); hold on;
        xlabel('noise (%)'); ylabel('avg delF/F');title('spot');
        legend('LC11','LPLC2');
    else
        subplot(1,3,2);xticks(1:8); xticklabels(xtick); hold on;
        xlabel('noise (%)'); ylabel('avg delF/F');title('loom');
        legend('LC4','LPLC2','LC11');
    end
    errorbar(x+.2*z, mean_norm(mat_file_idx,1:9), std(single_norm{mat_file_idx}(:,1:9),1)/sqrt(size(single_norm{mat_file_idx}(:,1:9),1))*1.96, 'Color',ones(1,3)*0.8);
    plot(x+.2*z, mean_norm(mat_file_idx,1:9),'Color',cm(mat_file_idx),'Marker','o','MarkerFaceColor',cm(mat_file_idx));

    set(gca,'Box','off','TickDir','out','FontSize',12);
    ylim([-.2 1.4]);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%% calculating p-value %%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%% flickering %%%%%%%%%%%%%%%%%%%%%%%%%%
    j=1;
    for k=1:8
        locat=mean(mean_norm(mat_file_idx,k))+.3;
        [h p1{mat_file_idx}(k)]=ttest(single_norm{mat_file_idx}(:,9),single_norm{mat_file_idx}(:,k));
        text(j,locat,num2str(p1{mat_file_idx}(k)),'Color',cm(mat_file_idx));
        j=j+1;
    end
    %%%%%%%%%%%%%%% between neurons %%%%%%%%%%%%%%%%%%%%%%%
    j=1;
    if mat_file_idx == 2 || mat_file_idx == 7 || mat_file_idx == 4
        mat_file_idx2 = mat_file_idx-1;
        for k=1:8
            locat=mean(mean_norm(mat_file_idx,k))+.2;
            [h p1{mat_file_idx}(k)]=ttest2(single_norm{mat_file_idx}(:,k),single_norm{mat_file_idx-1}(:,k));
            text(j,locat,num2str(p1{mat_file_idx}(k)),'Color','k');
            j=j+1;
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%% RandomMotion %%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    f7=figure(7);set(gcf,'Color','w');
    %for bar / loom normalize randmotion
    if mat_file_idx < 5
        if mat_file_idx == 1 || mat_file_idx == 2  %LC15 bar / LPLC2 bar
            subplot(1,2,1);xticks(1:8); xticklabels(xtick); hold on;
            xlabel('noise (%)'); ylabel('avg delF/F (%)');title('bar');
        elseif mat_file_idx == 3 || mat_file_idx == 4 %LC4 / LPLC2 Loom
            subplot(1,2,2);xticks(1:8); xticklabels(xtick); hold on;
            xlabel('noise (%)'); ylabel('avg delF/F (%)');title('loom');
        end
        errorbar(x-.2*mat_file_idx, mean_norm(mat_file_idx,10:18), std(single_norm{mat_file_idx}(:,10:18),1)/sqrt(size(single_norm{mat_file_idx}(:,10:18),1))*1.96,'Color',ones(1,3)*0.8);
        plot(x-.2*mat_file_idx,mean_norm(mat_file_idx,10:18),'Color',cm(mat_file_idx),'Marker','o','MarkerFaceColor',cm(mat_file_idx));

        set(gca,'Box','off','TickDir','out','FontSize',12);
        ylim([-.2 1.4]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%% calculating p-value %%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%% Random Motion %%%%%%%%%%%%
        for k=10:16
            locat=mean(mean_norm(mat_file_idx,k))+.3;
            [h p2{mat_file_idx}(k)]=ttest(single_norm{mat_file_idx}(:,17),single_norm{mat_file_idx}(:,k));
            text(k-11.1,locat,num2str(p2{mat_file_idx}(k)),'Color',cm(mat_file_idx));

        end
    end


    %% latency --- Figure S4C, S4F
    t=seg_idx{1}*dt/10000;
    % color='bgrg';
        for p=1:size(del_gcamp,2)
            for n=1:size(del_gcamp{mat_file_idx,p},1)
                max_peak_single{mat_file_idx}(p,n)=max(del_gcamp{mat_file_idx,p}(n,response_idx));
                max_peak_idx{mat_file_idx}(p,n)=find(del_gcamp{mat_file_idx,p}(n,response_idx)==max_peak_single{mat_file_idx}(p,n),1)+find(seg_idx{pat_idx}>1.7*10^4,1);  %-1;
                max_peak_sec{mat_file_idx}(p,n)=t(max_peak_idx{mat_file_idx}(p,n));
                half_peak{mat_file_idx}(p,n)=max_peak_single{mat_file_idx}(p,n)*0.5;
                if max_peak_single{mat_file_idx}(p,n)<=0
                    lat_idx50{mat_file_idx}(p,n)=nan;
                    lat_idx50_sec{mat_file_idx}(p,n)=nan;
                else
                    if isempty(find(del_gcamp{mat_file_idx,p}(n,response_idx_lat)>half_peak{mat_file_idx}(p,n),1,'first'))
                        lat_idx50{mat_file_idx}(p,n)=nan;
                        lat_idx50_sec{mat_file_idx}(p,n)=nan;
                    else
                        lat_idx50{mat_file_idx}(p,n)=find(del_gcamp{mat_file_idx,p}(n,response_idx_lat)>half_peak{mat_file_idx}(p,n),1,'first')+find(seg_idx{pat_idx}>1.5*10^4,1);   %1.5-1.8
                        lat_idx50_sec{mat_file_idx}(p,n)=t(lat_idx50{mat_file_idx}(p,n));
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
            sem(mat_file_idx,p)=std(lat_idx50_sec{mat_file_idx}(p,:),[],2,'omitnan')/sqrt(size(lat_idx50_sec{mat_file_idx},2))*1.96;
            mean_lat_50(mat_file_idx,p)=mean(lat_idx50_sec{mat_file_idx}(p,:),2,'omitnan');
            mean_lat_peak(mat_file_idx,p)=mean(max_peak_sec{mat_file_idx}(p,:),2,'omitnan');
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%% RandomMotion %%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%% compare filckering and random motion %%%%%%%%%%

    f8=figure(8); sgtitle('compare flickering and random motion');
    hold on; set(gcf,'Color','w','DefaultAxesColorOrder','remove');haxes=[];
    % cm='byry';
    if mat_file_idx <5

        if mat_file_idx==1
            subplot(2,2,1); %LC15 bar
            title('LC15 bar');hold on;
        elseif mat_file_idx==2
            subplot(2,2,2); %LPLC2 bar
            title('LPLC2 bar');hold on;
        elseif mat_file_idx==3
            subplot(2,2,3); % LC4 Loom
            title('LC4 loom');hold on;
        else
            subplot(2,2,4); %LPLC2 Loom
            title('LPLC2 loom'); hold on;
        end

        errorbar((1:8)+0.05*mat_file_idx, mean_lat_50(mat_file_idx,1:8), sem(mat_file_idx,1:8),'Color',ones(1,3)*0.8); hold on;
        errorbar((1:8)-0.05*mat_file_idx, mean_lat_50(mat_file_idx,[1,12:18]), sem(mat_file_idx,1:8),'Color',ones(1,3)*0.8); hold on;

        plot((1:8)+0.05*mat_file_idx, mean_lat_50(mat_file_idx,1:8),'Color','b','Marker','o','MarkerFaceColor','b');
        plot((1:8)-0.05*mat_file_idx, mean_lat_50(mat_file_idx,[1,12:18]),'Color','r','Marker','o','MarkerFaceColor','r');


        %%%%%%%%%%%%%%%%%%%% p-value %%%%%%%%%%%%%%%%%%%%%%%
        j=[1,12:18];
        for k=1:8
            locat=mean_lat_50(mat_file_idx,k)+0.05;
            [h pp(k)]=ttest(lat_idx50_sec{mat_file_idx}(k,:),lat_idx50_sec{mat_file_idx}(j(k),:));

            text(k-0.2,locat,num2str(pp(k)),'Color','k');
        end
        set(gca,'Box','off','TickDir','out') %'YLim',[-0.05 0.6]);
        xticks([1:8]);
        set(gca,'XTickLabel',PATNAMES);
        xtickangle(45);
        xlabel('Pattern id');
        ylim([1.5 1.75]);
    % legend('flickering','random motion');
    end



    %%%%%%%%%%%%%%%%%%%compare neurons with flickering patterns%%%%%%%%%%%%%%%%%%%%%%%

    f9=figure(9);sgtitle('compare neurons with flickering');
    hold on; set(gcf,'Color','w','DefaultAxesColorOrder','remove'); haxes=[];
    if mat_file_idx==1||mat_file_idx==2
        subplot(1,3,1);
        legend('LC15','LPLC2');
    elseif mat_file_idx==6||mat_file_idx==7
        subplot(1,3,3);
        legend('LC11','LPLC2');
    else
        subplot(1,3,2);
        legend('LC4','LPLC2','LC11');
    end
    errorbar((1:8)+0.05*z, mean_lat_50(mat_file_idx,idx{mat_file_idx}), sem(mat_file_idx,idx{mat_file_idx}),'Color',ones(1,3)*0.8);hold on;
    plot((1:8)+0.05*z, mean_lat_50(mat_file_idx,idx{mat_file_idx}),'Color',cm(mat_file_idx),'Marker','o','MarkerFaceColor',cm(mat_file_idx));
    j=1;
    for k=idx{mat_file_idx}
        locat=mean_lat_50(mat_file_idx,k)+0.05;
        [h pp(k)]=ttest(lat_idx50_sec{mat_file_idx}(k,:),lat_idx50_sec{mat_file_idx}(2,:));

        text(j,locat,num2str(pp(k)),'Color',cm(mat_file_idx));
        j=j+1;
    end
    set(gca,'Box','off','TickDir','out') %'YLim',[-0.05 0.6]);
    xticks([1:8]);
    set(gca,'XTickLabel',PATNAMES);
    xtickangle(45);
    xlabel('Pattern id');
    ylim([1.5 1.75]);

    %% Compare the normalized response for Flickering and Random motion -- Figure S6B-E
    f10=figure(10); set(gcf,'Color','w'); sgtitle('compareing peak amplitude flicker and random motion');

    if mat_file_idx <5
        subplot(2,2,mat_file_idx);
        xticks(1:8);xticklabels(xtick); hold on;
        xlabel('noise (%)'); ylabel('avg delF/F');

        switch mat_file_idx
            case 1
                title('LC15 Bar'); %legend('flickering','random Motion');
            case 2
                title('LPLC2 Bar'); %legend(xtick);
            case 3
                title('LC4 Loom'); %legend(xtick);
            case 4
                title('LPLC2 Loom'); %legend(xtick);
        end
        x=1:8;

        errorbar(x-.15, mean_norm(mat_file_idx,idx{mat_file_idx}), std(single_norm{mat_file_idx}(:,idx{mat_file_idx}),1)/sqrt(size(single_norm{mat_file_idx}(:,idx{mat_file_idx}),1))*1.96, 'Color',ones(1,3)*0.8);
        errorbar(x+.15, mean_norm(mat_file_idx,10:17), std(single_norm{mat_file_idx}(:,10:17),1)/sqrt(size(single_norm{mat_file_idx}(:,10:17),1))*1.96, 'Color',ones(1,3)*0.8);

        plot(x-.15,mean_norm(mat_file_idx,1:8),'Color','b','Marker','o','MarkerFaceColor','b');
        plot(x+.15,mean_norm(mat_file_idx,10:17),'Color','r','Marker','o','MarkerFaceColor','r');
        set(gca,'Box','off','TickDir','out','FontSize',12);
        ylim([-0.5 1.5]);
        %
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % %%%%%%%%%%%%%%% calculating p-value %%%%%%%%%%%%%%%%%%%
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % %%%%%%% flickering vs randMotion %%%%%%%%%%%%
        for k=2:8
            locat=mean(mean_norm(mat_file_idx,k))+.10;
            [h p(k)]=ttest(single_norm{mat_file_idx}(:,k),single_norm{mat_file_idx}(:,k+9));
            if (p(k)<0.001)
                text(k-0.1,locat+.5,'***');
            elseif (p(k)<0.01)
                text(k-0.1,locat+.5,'**');
            elseif p(k)<0.05
                text(k-0.1,locat+.5,'*');
            end
            text(k,locat,num2str(p(k)));
        end
        %
        % %%%%%%%%%%%%%flickering%%%%%%%%%%%%
        for k=1:8
            locat=mean(mean_norm(mat_file_idx,k))+.30;
            [h p(k)]=ttest(single_norm{mat_file_idx}(:,8),single_norm{mat_file_idx}(:,k));
            % if (p(k)<0.001)
            %     text(k-0.1,locat+5.5,'***','Color','b');
            % elseif (p(k)<0.01)
            %     text(k-0.1,locat+5.5,'**','Color','b');
            % elseif p(k)<0.05
            %     text(k-0.1,locat+5.5,'*','Color','b');
            % end
            text(k,locat,num2str(p(k)),'Color','b');
        end

        %%%%%%%%%%%%%Random Motion%%%%%%%%%%%%
        for k=10:17
            locat=mean(mean_norm(mat_file_idx,k))-.10;
            [h p(k)]=ttest(single_norm{mat_file_idx}(:,17),single_norm{mat_file_idx}(:,k));
            % if (p(k)<0.001)
            %     text(k-11.1,locat+2,'***','Color','r');
            % elseif (p(k)<0.01)
            %     text(k-11.1,locat+2,'**','Color','r');
            % elseif p(k)<0.05
            %     text(k-11.1,locat+2,'*','Color','r');
            % end
            text(k-11.1,locat,num2str(p(k)),'Color','r');
        end

    end
end
%% save figures

% savefig(f2,[folder_save 'population_avg_trace_flickering']);
% savefig(f3,[folder_save 'population_avg_trace_randomMotion']);
% savefig(f4,[folder_save 'mean_peak_flickering']);
% savefig(f5,[folder_save 'mean_peak_randomMotion']);
savefig(f6,[folder_save 'normalized_mean_peak_flickering']);
savefig(f7,[folder_save 'normalized_mean_peak_randomMotion']);

% savefig(f8,[folder_save 'Latency_gcamp_compare_flickerRandom']);
% savefig(f9,[folder_save 'Latency_gcamp_compare_neuron_flicker']);

savefig(f10,[folder_save 'comparing_mean_peak_flickier_randomMotion']);


  %% AUC(area under curve) - trapezoidal rule of integration(contain all non-significant) -- Figure 3H

  %%%%%%%%%%%%%%%%%%%% flickering %%%%%%%%%%%%%%%%%%%%

    for neuron_idx=1:7
        for n=1:1:size(single_norm{neuron_idx},1) 
            % calculate with area under curve
            auc2(neuron_idx,n)=sum(single_norm{neuron_idx}(n,2:8),'omitnan')*10;
        end
    end

    for neuron_idx=1:7
        for n=1:1:size(single_norm{neuron_idx},1) 
            % calculate with mean value
            auc3(neuron_idx,n)=mean(single_norm{neuron_idx}(n,2:8),'omitnan')*100;
        end
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% random motion %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for neuron_idx=1:4
        for n=1:1:size(single_norm{neuron_idx},1)
            % calculate with area under curve
            auc4(neuron_idx,n)=sum(single_norm{neuron_idx}(n,11:17),'omitnan')*10;
        end
    end

    for neuron_idx=1:4
        for n=1:1:size(single_norm{neuron_idx},1)
            % calculate with mean value
            auc5(neuron_idx,n)=mean(single_norm{neuron_idx}(n,11:17),'omitnan')*100;
        end
    end


%%

%%%%%%%%%%%%%%%%%%% compare ANOVA %%%%%%%%%%%%%%%%%%%%%%%%%%%%
g_LC15bar= repmat({'LC15bar'},size(single_norm{1},1),1);
g_LPLC2bar= repmat({'LPLC2bar'},size(single_norm{2},1),1);
g_LC4loom= repmat({'LC4loom'},size(single_norm{3},1),1);
g_LPLC2loom= repmat({'LPLC2loom'},size(single_norm{4},1),1);
g_LC11loom= repmat({'LC11loom'},size(single_norm{5},1),1);
g_LC11spot= repmat({'LC11spot'},size(single_norm{6},1),1);
g_LPLC2spot= repmat({'LPLC2spot'},size(single_norm{7},1),1);

g_LC15bar_Rd= repmat({'LC15barRandom'},size(single_norm{1},1),1);
g_LPLC2bar_Rd= repmat({'LPLC2barRandom'},size(single_norm{2},1),1);
g_LC4loom_Rd= repmat({'LC4loomRandom'},size(single_norm{3},1),1);
g_LPLC2loom_Rd= repmat({'LPLC2loomRandom'},size(single_norm{4},1),1);

% c = [auc3(2,1:size(single_norm{2},1))' ; auc3(1,1:size(single_norm{1},1))';...
%     auc3(4,1:size(single_norm{4},1))' ; auc3(3,1:size(single_norm{3},1))'; auc3(3,1:size(single_norm{5},1))';...
%     auc3(6,1:size(single_norm{7},1))' ; auc3(5,1:size(single_norm{6},1))'];
% g1 = [ g_LPLC2bar; g_LC15bar ; g_LPLC2loom; g_LC4loom ; g_LC11loom; g_LPLC2spot; g_LC11spot ];

c = [auc3(2,1:size(single_norm{2},1))' ; auc3(1,1:size(single_norm{1},1))';...
    auc3(4,1:size(single_norm{4},1))' ; auc3(3,1:size(single_norm{3},1))'; auc3(5,1:size(single_norm{5},1))';...
    auc3(7,1:size(single_norm{7},1))' ; auc3(6,1:size(single_norm{6},1))';...
    auc5(2,1:size(single_norm{2},1))' ; auc5(1,1:size(single_norm{1},1))'; auc5(4,1:size(single_norm{4},1))' ; auc5(3,1:size(single_norm{3},1))'];
g1 = [ g_LPLC2bar; g_LC15bar ; g_LPLC2loom; g_LC4loom ; g_LC11loom; g_LPLC2spot; g_LC11spot ;...
    g_LPLC2bar_Rd ; g_LC15bar_Rd;  g_LPLC2loom_Rd; g_LC4loom_Rd];


[p3,t1,stats]=anova1(c,g1);
set(gcf,'Color','w');
sgtitle(['Noise Performance Index (p=' num2str(p3) ')']);
set(gca,'Box','off','TickDir','out','FontSize',12);
ii=100*ones(1,6);
means2=stats.means;

for i=1:6
    text(i,ii(i),num2str(stats.means(i))); hold on;
end
ylim([-10 160])
saveas(gcf,[folder_save 'AUC_ANOVA_NotchPlot']);

figure;
[c,m,h,gnames] = multcompare(stats);
%
for i=1:size(c,1)
    disp([ num2str(c(i,1)) ' with ' num2str(c(i,2)) ' pValue : ' num2str(c(i,6))]);
end


 save([folder_save 'quantified_gcamp_260428'], 't','avg_gcamp','g1','c','auc2','auc3','auc4','auc5','single_norm','mean_norm','means2');


 %%

 %%%%%%%%%%%%%%%%%%% compare ANOVA %%%%%%%%%%%%%%%%%%%%%%%%%%%%
g_LC11spot= repmat({'LC11spot'},size(single_norm{6},1),1);
g_LPLC2spot= repmat({'LPLC2spot'},size(single_norm{7},1),1);

c2 = [auc3(7,1:size(single_norm{7},1))' ; auc3(6,1:size(single_norm{6},1))'];
g2 = [g_LPLC2spot; g_LC11spot ];


[p3,t1,stats]=anova1(c2,g2);
set(gcf,'Color','w');
sgtitle(['Noise Performance Index (p=' num2str(p3) ')']);
set(gca,'Box','off','TickDir','out','FontSize',12);
ii=100*ones(1,6);
% means3=stats.means;

% for i=1:6
%     text(i,ii(i),num2str(stats.means(i))); hold on;
% end
ylim([-10 160])
saveas(gcf,'Spot_AUC2_ANOVA_NotchPlot');

figure;
[c,m,h,gnames] = multcompare(stats);
%
for i=1:size(c,1)
    disp([ num2str(c(i,1)) ' with ' num2str(c(i,2)) ' pValue : ' num2str(c(i,6))]);
end
