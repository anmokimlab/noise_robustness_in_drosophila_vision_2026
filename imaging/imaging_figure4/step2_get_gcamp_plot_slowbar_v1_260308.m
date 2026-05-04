%editing from ver2 -----250211
%%%%%250529 hyosun edited ---- edit normalize method & response idx (ver_7)
%Method 2----------------------
%%Calculate noise performance index in GCaMP imaging result
%%%%%%%%pattern play time : 1.44s

clear;
folder_data='/Users/hyosunkim/1_Analyze_data/noise/2photon/RandMotion/mat_files';
folder_save='final_results_v6_260428/';

%%pattern name for Random motion noise
PATNAMES={'noise  0','flick noise 10','flick noise 20','flick noise 30','flick noise 40',...
    'flick noise 50','flick noise 60','flick noise 70','left flick noise 0','left flick noise 10',...
    'left flick noise 20', 'random motion 10','random motion 20','random motion 30','random motion 40',...
    'random motion 50','random motion 60','random motion 70','left random motion 10','left random motion 20'};

file_list=search_for_mat(folder_data);
for i=1:length(file_list)
    mat_file_names{1,i}=file_list(i).name;
end

tit={'f2b slow Bar LC15','b2f slow Bar LC15','f2b slowbar LPLC2','b2f slowbar LPLC2'};
dt=1;

for mat_file_idx=[10,11]

    load(mat_file_names{mat_file_idx});
    load(mat_file_names{mat_file_idx+2});
    PATDUR=4*ones(1,size(seg_idx,1));
    t = seg_idx{1}*10^-4;

    concat_mean_gcamp={};

    for i=1:size(mean_gcamp_tr_all,1)
        %flickering
        for j=1:10 %0-40 percent
            concat_mean_gcamp{i,j}=mean_gcamp_tr_all{i,j};
        end
        for j=11:18 %randmotion 10-40 percent
            concat_mean_gcamp{i,j+6}=mean_gcamp_tr_all{i,j};
        end

        for j=1:6 %50-70 percent
            concat_mean_gcamp{i,j+10}=mean_gcamp_tr_all_2{i,j+2};
            concat_mean_gcamp{i,j+24}=mean_gcamp_tr_all_2{i,j+8};
        end
    end

    for i=1:18
        seg_idx{i,1}=seg_idx{i,1};
        seg_idx{i+18,1}=seg_idx_2{i,1};
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%% for response index %%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for n=1:size(concat_mean_gcamp,1)
        for pat_idx=1:size(concat_mean_gcamp,2)
            baseline_idx=(seg_idx{pat_idx}>1.3*10^4 & seg_idx{pat_idx}<1.5*10^4); %-5000/0
            % for f2b bar
            switch mat_file_idx
                case 10
                    response_idx=(seg_idx{pat_idx}>4.5*10^4 & seg_idx{pat_idx}<=4.7*10^4);  %PATDUR(pat_idx)
                    % for b2f bar
                    response_idx2=(seg_idx{pat_idx}>3.4*10^4 & seg_idx{pat_idx}<=3.6*10^4);  %PATDUR(pat_idx)
                    % for latency index
                case 11
                    response_idx=(seg_idx{pat_idx}>1.8*10^4 & seg_idx{pat_idx}<=2*10^4);  %PATDUR(pat_idx)
                    % for b2f bar
                    response_idx2=(seg_idx{pat_idx}>1.8*10^4 & seg_idx{pat_idx}<=2*10^4);  %PATDUR(pat_idx)
            end
            % for latency index
            response_idx_lat=(seg_idx{pat_idx}>1.5*10^4 & seg_idx{pat_idx}<=6*10^4);
            based_gcamp{n,pat_idx}=concat_mean_gcamp{n,pat_idx}(1,:)-mean(concat_mean_gcamp{n,pat_idx}(1,baseline_idx),2); %/based_gcamp
            %%%%%%%%% delf/f %%%%%%%%%
            del_gcamp{mat_file_idx-9,pat_idx}(n,:)=based_gcamp{n,pat_idx}(1,:)/mean(concat_mean_gcamp{n,pat_idx}(1,baseline_idx),2);
            gcamp_amplitude{mat_file_idx-9}(n,pat_idx)=mean(del_gcamp{mat_file_idx-9,pat_idx}(n,response_idx),2);
            gcamp_amplitude{mat_file_idx-9}(n,size(concat_mean_gcamp,2)+1)=mean(del_gcamp{mat_file_idx-9,pat_idx}(n,baseline_idx),2);
        end
    end

    %%
    % f2b bar : [1:2:16]; b2f bar : [2:2:16];
    figure(mat_file_idx);
    tr=[];
    
    subplot(1,2,1);
    rectangle('Position',[1.5 -0.2 4 1.5],'FaceColor',ones(1,3)*0.8,'EdgeColor',ones(1,3)*0.8); hold all;

    for i=1:2:16 % f2b_flickering noise
        subplot(1,2,1);
        tr=cell2mat(based_gcamp(:,i));
        avg_tr=mean(tr,1);
        p1(i)=plot(t,avg_tr,'LineWidth',1.5);
        axis tight;
        title('f2b flickering noise');

        xlim([-2 7]);
        ylim([-0.2 1.2])
        ylabel('delF'); xlabel('time(s)')

        set(gca,'Box','off','TickDir','out');
    end
    legend([p1(1:2:16)],{'0% noise','10%noise','20','30','40','50','60','70'},'Box','off');

    subplot(1,2,2);
    rectangle('Position',[1.5 -0.2 4 1.5],'FaceColor',ones(1,3)*0.8,'EdgeColor',ones(1,3)*0.8); hold all;

    for i=[2:2:16] % b2f flickering noise
        subplot(1,2,2);
        tr=cell2mat(based_gcamp(:,i));
        avg_tr=mean(tr,1);
        p1(i)=plot(t,avg_tr,'LineWidth',1.5);
        axis tight;
        axis tight;
        title('b2f Flickering noise');
        xlim([-2 7]); ylim([-0.2 1.2])
        ylabel('delF'); xlabel('time(s)')
        set(gca,'Box','off','TickDir','out');
    end


    %%
    idx0= {[1:2:16,31],[2:2:16,31],[1,17:2:29,31],[2,18:2:30,31]};
    % for random motion : [1,17:2:29]/ [2,18:2:30] 
    mat_file_idx=mat_file_idx-9;
    
    avg_gcamp{mat_file_idx}=mean(gcamp_amplitude{mat_file_idx},1,'omitnan');
    
    %baseline-response
    % avg_gcamp{mat_file_idx}(1,end+1)=mean(concat_mean_gcamp{n,1}(1,baseline_idx),2);

    %%%%%%%%%%%%%%%%%%% normalized amplitude %%%%%%%%%%%%%%%%%%
    % normalize the response to min / max
    % for f=1:4 %f2b/b2f
    %     mean_min_gcamp{mat_file_idx,f} = min(avg_gcamp{mat_file_idx}(idx0{f}));
    %     mean_norm{mat_file_idx,f} = (avg_gcamp{mat_file_idx}(idx0{f}) - mean_min_gcamp{mat_file_idx,f}) / (mean_max_gcamp{mat_file_idx,f} - mean_min_gcamp{mat_file_idx,f});
    % 
    %     for n=1:size(gcamp_amplitude{mat_file_idx},1)
    %         single_norm{mat_file_idx,f}(n,:) = (gcamp_amplitude{mat_file_idx}(n,idx0{f}) - mean_min_gcamp{mat_file_idx,f}) / (mean_max_gcamp{mat_file_idx,f} - mean_min_gcamp{mat_file_idx,f});
    %     end
    % end

    %normalize the response to max
     for f=1:4 %f2b/b2f
        mean_max_gcamp{mat_file_idx,f} = max(avg_gcamp{mat_file_idx}(idx0{f}));
        mean_norm{mat_file_idx,f} = avg_gcamp{mat_file_idx}(idx0{f}) / mean_max_gcamp{mat_file_idx,f} ;
        
        for n=1:size(gcamp_amplitude{mat_file_idx},1)
            single_norm{mat_file_idx,f}(n,:) = gcamp_amplitude{mat_file_idx}(n,idx0{f}) / mean_max_gcamp{mat_file_idx,f};
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

    % xtick={'0','10','20','30','40','50','60','70','Blank'};
    % x=1:9;
    % 
    % %%%%%%%%%%%%%%%% Flickering Noise %%%%%%%%%%%%%%%%%%%%%%%%%
    % f2=figure(2);set(gcf,'Color','w'); hold on;
    % subplot(4,2,mat_file_idx);sgtitle('Flickering Noise')
    % rectangle('Position',[1.44 -20 0.2 60 ],'FaceColor',[0.8 0.8 0.8],'EdgeColor',[0.8 0.8 0.8]);
    % 
    % for pat_idx= idx{mat_file_idx} %[1,12:18]
    %     plot(seg_idx{i}*dt/10000,mean(del_gcamp{mat_file_idx,pat_idx}),'LineWidth',1.5); hold on;
    % end
    % colormap turbo;
    % xlim([1.4 2]); ylim([-0.1 0.6]);
    % set(gca,'Box','off','TickDir','out','FontSize',12);
    % 
    % switch mat_file_idx
    %     case 1
    %         title('LC15 Bar'); z=1; %legend(xtick,'Box','off');
    %     case 2
    %         title('LPLC2 Bar'); z=2; %legend(xtick);
    %     case 3
    %         title('LC4 Loom'); z=1; %legend(xtick);
    %     case 4
    %         title('LPLC2 Loom'); z=2; %legend(xtick);
    %     case 5
    %         title('LC11 Loom'); z=3;
    %     case 6
    %         title('LC11 Spot'); legend(xtick,'Box','off'); z=1;
    %     case 7
    %         title('LPLC2 Loom');z=2;
    % end
    % 
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%%%%%%%%%%%%%%%%%%% RandomMotion %%%%%%%%%%%%%%%%%%%%%
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % if mat_file_idx < 5
    %     f3=figure(3); subplot(2,2,mat_file_idx); sgtitle('Random Motion noise');
    %     rectangle('Position',[1.44 -20 0.2 60 ],'FaceColor',[0.8 0.8 0.8],'EdgeColor',[0.8 0.8 0.8]);hold all;
    %     for pat_idx=[1,12:18]
    %         plot(seg_idx{i}*dt/10000,mean(del_gcamp{mat_file_idx,pat_idx}),'LineWidth',1.5); hold on;
    %     end
    %     colormap turbo;
    %     xlim([1.2 3]); ylim([-0.1 0.6]);
    %     set(gca,'Box','off','TickDir','out','FontSize',12);
    % 
    %     switch mat_file_idx
    %         case 1
    %             title('LC15 Bar'); legend(xtick,'Box','off');
    %         case 2
    %             title('LPLC2 Bar'); %legend(xtick);
    %         case 3
    %             title('LC4 Loom'); %legend(xtick);
    %         case 4
    %             title('LPLC2 Loom'); %legend(xtick);
    %     end
    % end


    %% Plot peak amplitude (normalized) LPLC2 / LC15 slow bar
    % f2b f=1 / b2f f=2 / f2b(random motion) f=3 / b2f (random motion) f=4 

    % cm='byby';
    % % f4=figure(4); set(gcf,'Color','w'); hold all;
    % if f == 1 || f == 2  % LC15 f2b / LPLC2 f2b
    %     f4=figure(4); set(gcf,'Color','w'); hold all;
    %     subplot(1,2,f);xticks(1:9); xticklabels(xtick);
    %     xlabel('noise (%)'); ylabel('avg delF/F');title('bar');
    %     legend('LC15','LPLC2');
    % 
    % elseif f == 3 || mat_file_idx == 4 % LC11 spot / LPLC2 spot
    %     subplot(1,3,3); xticks(1:9); xticklabels(xtick);
    %     xlabel('noise (%)'); ylabel('avg delF/F');title('spot');
    %     legend('LC11','LPLC2');
    % else
    %     subplot(1,3,2);xticks(1:9); xticklabels(xtick);
    %     xlabel('noise (%)'); ylabel('avg delF/F');title('loom');
    %     legend('LC4','LPLC2','LC11');
    % end
    % errorbar(avg_gcamp{mat_file_idx}(idx{mat_file_idx}), std(gcamp_amplitude{mat_file_idx}(:,idx{mat_file_idx}),1)/sqrt(size(gcamp_amplitude{mat_file_idx}(:,idx{mat_file_idx}),1))*1.96,'Color',ones(1,3)*0.8);
    % plot(avg_gcamp{mat_file_idx}(idx{mat_file_idx}),'Color',cm(mat_file_idx),'Marker','o','MarkerFaceColor',cm(mat_file_idx));
    % set(gca,'Box','off','TickDir','out','FontSize',12);
    % 
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%%%%%%%%%%%%%%%%%%% RandomMotion %%%%%%%%%%%%%%%%%%%%%
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % f5=figure(5); set(gcf,'Color','w'); hold on;
    % if mat_file_idx < 5
    %     %for bar / loom before normalize randmotion
    %     if mat_file_idx == 1 || mat_file_idx == 2  %LC15 bar / LPLC2 bar
    %         subplot(1,2,1);xticks(1:8); xticklabels(xtick);
    %         xlabel('noise (%)'); ylabel('avg delF/F');title('bar');
    %         legend('LC15','LPLC2');
    %     elseif mat_file_idx == 3 || mat_file_idx == 4  %LC4 loom / LPLC2 loom
    %         subplot(1,2,2);xticks(1:8); xticklabels(xtick);
    %         xlabel('noise (%)'); ylabel('avg delF/F');title('loom');
    %         legend('LC4','LPLC2');
    %     end
    %     errorbar(avg_gcamp{mat_file_idx}(1,12:19), std(gcamp_amplitude{mat_file_idx}(:,12:19),1)/sqrt(size(gcamp_amplitude{mat_file_idx}(:,10:17),1))*1.96,'Color',ones(1,3)*0.8);
    %     plot(avg_gcamp{mat_file_idx}(1,12:19),'Color',cm(mat_file_idx),'Marker','o','MarkerFaceColor',cm(mat_file_idx));
    %     set(gca,'Box','off','TickDir','out','FontSize',12);
    % end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%% normalized avg amplitude %%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % single_norm{mat_file_idx}(n,1:9)
    %mean_norm{mat_file_idx,f}/ single_norm{mat_file_idx,f}(n,:)
    cm='by';
    xtick={'0','10','20','30','40','50','60','70','Blank'};
    f6=figure(6); set(gcf,'Color','w'); hold all;
    f7=figure(7); set(gcf,'Color','w'); hold all;

    for f=1:4
        %for bar / loom normalize flickering
        if f == 1 || f == 2  %LC15 bar / LPLC2 bar
            figure(6);
            subplot(1,2,f);xticks(1:9); xticklabels(xtick); hold on;
            xlabel('noise (%)'); ylabel('avg delF/F');title('bar');
            switch f
                case 1
                    legend('f2b LC15','f2b LPLC2');
                    title('front to back slow bar');
                case 2
                    legend('b2f LC15','b2f LPLC2');
                    title('back to front slow bar');
            end

            errorbar((1:9)+.2*mat_file_idx, mean_norm{mat_file_idx,f}, std(single_norm{mat_file_idx,f}(:,1:9),1)/sqrt(size(single_norm{mat_file_idx,f}(:,1:9),1))*1.96, 'Color',ones(1,3)*0.8);
            plot((1:9)+.2*mat_file_idx, mean_norm{mat_file_idx,f},'Color',cm(mat_file_idx),'Marker','o','MarkerFaceColor',cm(mat_file_idx));

            set(gca,'Box','off','TickDir','out','FontSize',12);
            ylim([-.2 1.4]); sgtitle('Flickering slow bar')

        elseif f == 3 || f == 4
            figure(7);
            subplot(1,2,f-2); xticks(1:9); xticklabels(xtick); hold on;
            xlabel('noise (%)'); ylabel('avg delF/F');
            switch f
                case 3
                    legend('f2b LC15','f2b LPLC2');
                    title('front to back slow bar');
                case 4
                    legend('b2f LC15','b2f LPLC2');
                    title('back to front slow bar');
            end

            errorbar((1:9)+.2*(mat_file_idx-2), mean_norm{mat_file_idx,f}, std(single_norm{mat_file_idx,f}(:,1:9),1)/sqrt(size(single_norm{mat_file_idx,f}(:,1:9),1))*1.96, 'Color',ones(1,3)*0.8);
            plot((1:9)+.2*(mat_file_idx-2), mean_norm{mat_file_idx,f},'Color',cm(mat_file_idx),'Marker','o','MarkerFaceColor',cm(mat_file_idx));

            set(gca,'Box','off','TickDir','out','FontSize',12);
            ylim([-.2 1.4]);sgtitle('Motion slow bar')
        end
 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%% calculating p-value %%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%% flickering %%%%%%%%%%%%%%%%%%%%%%%%%%
        j=1;
        for k=1:8
            locat=mean_norm{mat_file_idx,f}+.3;
            [h p2{mat_file_idx}(k)]=ttest(single_norm{mat_file_idx,f}(:,9),single_norm{mat_file_idx,f}(:,k));
            text(j,locat(k),num2str(p2{mat_file_idx}(k)),'Color',cm(mat_file_idx));
            j=j+1;
        end
        %%%%%%%%%%%%%%% between neurons %%%%%%%%%%%%%%%%%%%%%%%
        % j=1;
        % if mat_file_idx == 2 
        %     mat_file_idx2 = mat_file_idx-1;
        %     for k=1:8
        %         locat=mean_norm{mat_file_idx,f}+.2;
        %         [h p3{mat_file_idx}(k)]=ttest2(single_norm{mat_file_idx,f}(:,k),single_norm{mat_file_idx-1,f}(:,k));
        %         text(j,locat(k),num2str(p3{mat_file_idx}(k)),'Color','k');
        %         j=j+1;
        %     end
        % end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%% RandomMotion %%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % f7=figure(7);set(gcf,'Color','w');
        % %for bar / loom normalize randmotion
        % if mat_file_idx < 5
        %     if mat_file_idx == 1 || mat_file_idx == 2  %LC15 bar / LPLC2 bar
        %         subplot(1,2,1);xticks(1:8); xticklabels(xtick); hold on;
        %         xlabel('noise (%)'); ylabel('avg delF/F (%)');title('bar');
        %     elseif mat_file_idx == 3 || mat_file_idx == 4 %LC4 / LPLC2 Loom
        %         subplot(1,2,2);xticks(1:8); xticklabels(xtick); hold on;
        %         xlabel('noise (%)'); ylabel('avg delF/F (%)');title('loom');
        %     end
        %     errorbar(x-.2*mat_file_idx, mean_norm(mat_file_idx,10:18), std(single_norm{mat_file_idx}(:,10:18),1)/sqrt(size(single_norm{mat_file_idx}(:,10:18),1))*1.96,'Color',ones(1,3)*0.8);
        %     plot(x-.2*mat_file_idx,mean_norm(mat_file_idx,10:18),'Color',cm(mat_file_idx),'Marker','o','MarkerFaceColor',cm(mat_file_idx));
        % 
        %     set(gca,'Box','off','TickDir','out','FontSize',12);
        %     ylim([-.2 1.4]);
        %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %     %%%%%%%%%%%%%%%% calculating p-value %%%%%%%%%%%%%%%%%%%
        %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %     %%%%%%%%%%%%% Random Motion %%%%%%%%%%%%
        %     for k=10:16
        %         locat=mean(mean_norm(mat_file_idx,k))+.3;
        %         [h p2{mat_file_idx}(k)]=ttest(single_norm{mat_file_idx}(:,17),single_norm{mat_file_idx}(:,k));
        %         text(k-11.1,locat,num2str(p2{mat_file_idx}(k)),'Color',cm(mat_file_idx));
        % 
        %     end
        % end
        
    end


    %% latency --- Figure S4C, S4F
    % t=seg_idx{1}*dt/10000;
    % % color='bgrg';
    % for p=1:size(del_gcamp,2)
    %     for n=1:size(del_gcamp{mat_file_idx,p},1)
    %         max_peak_single{mat_file_idx}(p,n)=max(del_gcamp{mat_file_idx,p}(n,response_idx));
    %         max_peak_idx{mat_file_idx}(p,n)=find(del_gcamp{mat_file_idx,p}(n,response_idx)==max_peak_single{mat_file_idx}(p,n),1)+find(seg_idx{pat_idx}>1.7*10^4,1);  %-1;
    %         max_peak_sec{mat_file_idx}(p,n)=t(max_peak_idx{mat_file_idx}(p,n));
    %         half_peak{mat_file_idx}(p,n)=max_peak_single{mat_file_idx}(p,n)*0.5;
    %         if max_peak_single{mat_file_idx}(p,n)<=0
    %             lat_idx50{mat_file_idx}(p,n)=nan;
    %             lat_idx50_sec{mat_file_idx}(p,n)=nan;
    %         else
    %             if isempty(find(del_gcamp{mat_file_idx,p}(n,response_idx_lat)>half_peak{mat_file_idx}(p,n),1,'first'))
    %                 lat_idx50{mat_file_idx}(p,n)=nan;
    %                 lat_idx50_sec{mat_file_idx}(p,n)=nan;
    %             else
    %                 lat_idx50{mat_file_idx}(p,n)=find(del_gcamp{mat_file_idx,p}(n,response_idx_lat)>half_peak{mat_file_idx}(p,n),1,'first')+find(seg_idx{pat_idx}>1.5*10^4,1);   %1.5-1.8
    %                 lat_idx50_sec{mat_file_idx}(p,n)=t(lat_idx50{mat_file_idx}(p,n));
    %             end
    %         end
    %         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     end
    %     sem(mat_file_idx,p)=std(lat_idx50_sec{mat_file_idx}(p,:),[],2,'omitnan')/sqrt(size(lat_idx50_sec{mat_file_idx},2))*1.96;
    %     mean_lat_50(mat_file_idx,p)=mean(lat_idx50_sec{mat_file_idx}(p,:),2,'omitnan');
    %     mean_lat_peak(mat_file_idx,p)=mean(max_peak_sec{mat_file_idx}(p,:),2,'omitnan');
    % end
    % 
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%%%%%%%%%%%%%%%%%%% RandomMotion %%%%%%%%%%%%%%%%%%%%%
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % %%%%%%%%%%%%%%%%% compare filckering and random motion %%%%%%%%%%
    % 
    % f8=figure(8); sgtitle('compare flickering and random motion');
    % hold on; set(gcf,'Color','w','DefaultAxesColorOrder','remove');haxes=[];
    % % cm='byry';
    % if mat_file_idx <5
    % 
    %     if mat_file_idx==1
    %         subplot(2,2,1); %LC15 bar
    %         title('LC15 bar');hold on;
    %     elseif mat_file_idx==2
    %         subplot(2,2,2); %LPLC2 bar
    %         title('LPLC2 bar');hold on;
    %     elseif mat_file_idx==3
    %         subplot(2,2,3); % LC4 Loom
    %         title('LC4 loom');hold on;
    %     else
    %         subplot(2,2,4); %LPLC2 Loom
    %         title('LPLC2 loom'); hold on;
    %     end
    % 
    %     errorbar((1:8)+0.05*mat_file_idx, mean_lat_50(mat_file_idx,1:8), sem(mat_file_idx,1:8),'Color',ones(1,3)*0.8); hold on;
    %     errorbar((1:8)-0.05*mat_file_idx, mean_lat_50(mat_file_idx,[1,12:18]), sem(mat_file_idx,1:8),'Color',ones(1,3)*0.8); hold on;
    % 
    %     plot((1:8)+0.05*mat_file_idx, mean_lat_50(mat_file_idx,1:8),'Color','b','Marker','o','MarkerFaceColor','b');
    %     plot((1:8)-0.05*mat_file_idx, mean_lat_50(mat_file_idx,[1,12:18]),'Color','r','Marker','o','MarkerFaceColor','r');
    % 
    % 
    %     %%%%%%%%%%%%%%%%%%%% p-value %%%%%%%%%%%%%%%%%%%%%%%
    %     j=[1,12:18];
    %     for k=1:8
    %         locat=mean_lat_50(mat_file_idx,k)+0.05;
    %         [h pp(k)]=ttest(lat_idx50_sec{mat_file_idx}(k,:),lat_idx50_sec{mat_file_idx}(j(k),:));
    % 
    %         text(k-0.2,locat,num2str(pp(k)),'Color','k');
    %     end
    %     set(gca,'Box','off','TickDir','out') %'YLim',[-0.05 0.6]);
    %     xticks([1:8]);
    %     set(gca,'XTickLabel',PATNAMES);
    %     xtickangle(45);
    %     xlabel('Pattern id');
    %     ylim([1.5 1.75]);
    %     % legend('flickering','random motion');
    % end
    % 
    % 
    % 
    % %%%%%%%%%%%%%%%%%%%compare neurons with flickering patterns%%%%%%%%%%%%%%%%%%%%%%%
    % 
    % f9=figure(9);sgtitle('compare neurons with flickering');
    % hold on; set(gcf,'Color','w','DefaultAxesColorOrder','remove'); haxes=[];
    % if mat_file_idx==1||mat_file_idx==2
    %     subplot(1,3,1);
    %     legend('LC15','LPLC2');
    % elseif mat_file_idx==6||mat_file_idx==7
    %     subplot(1,3,3);
    %     legend('LC11','LPLC2');
    % else
    %     subplot(1,3,2);
    %     legend('LC4','LPLC2','LC11');
    % end
    % errorbar((1:8)+0.05*z, mean_lat_50(mat_file_idx,idx{mat_file_idx}), sem(mat_file_idx,idx{mat_file_idx}),'Color',ones(1,3)*0.8);hold on;
    % plot((1:8)+0.05*z, mean_lat_50(mat_file_idx,idx{mat_file_idx}),'Color',cm(mat_file_idx),'Marker','o','MarkerFaceColor',cm(mat_file_idx));
    % j=1;
    % for k=idx{mat_file_idx}
    %     locat=mean_lat_50(mat_file_idx,k)+0.05;
    %     [h pp(k)]=ttest(lat_idx50_sec{mat_file_idx}(k,:),lat_idx50_sec{mat_file_idx}(2,:));
    % 
    %     text(j,locat,num2str(pp(k)),'Color',cm(mat_file_idx));
    %     j=j+1;
    % end
    % set(gca,'Box','off','TickDir','out') %'YLim',[-0.05 0.6]);
    % xticks([1:8]);
    % set(gca,'XTickLabel',PATNAMES);
    % xtickangle(45);
    % xlabel('Pattern id');
    % ylim([1.5 1.75]);

    %% Compare the normalized response for Flickering and Random motion -- Figure S6B-E
    % f10=figure(10); set(gcf,'Color','w'); sgtitle('compareing peak amplitude flicker and random motion');
    % 
    % if mat_file_idx <5
    %     subplot(2,2,mat_file_idx);
    %     xticks(1:8);xticklabels(xtick); hold on;
    %     xlabel('noise (%)'); ylabel('avg delF/F');
    % 
    %     switch mat_file_idx
    %         case 1
    %             title('LC15 Bar'); %legend('flickering','random Motion');
    %         case 2
    %             title('LPLC2 Bar'); %legend(xtick);
    %         case 3
    %             title('LC4 Loom'); %legend(xtick);
    %         case 4
    %             title('LPLC2 Loom'); %legend(xtick);
    %     end
    %     x=1:8;
    % 
    %     errorbar(x-.15, mean_norm(mat_file_idx,idx{mat_file_idx}), std(single_norm{mat_file_idx}(:,idx{mat_file_idx}),1)/sqrt(size(single_norm{mat_file_idx}(:,idx{mat_file_idx}),1))*1.96, 'Color',ones(1,3)*0.8);
    %     errorbar(x+.15, mean_norm(mat_file_idx,10:17), std(single_norm{mat_file_idx}(:,10:17),1)/sqrt(size(single_norm{mat_file_idx}(:,10:17),1))*1.96, 'Color',ones(1,3)*0.8);
    % 
    %     plot(x-.15,mean_norm(mat_file_idx,1:8),'Color','b','Marker','o','MarkerFaceColor','b');
    %     plot(x+.15,mean_norm(mat_file_idx,10:17),'Color','r','Marker','o','MarkerFaceColor','r');
    %     set(gca,'Box','off','TickDir','out','FontSize',12);
    %     ylim([-0.5 1.5]);
    %     %
    %     % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     % %%%%%%%%%%%%%%% calculating p-value %%%%%%%%%%%%%%%%%%%
    %     % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 
    %     % %%%%%%% flickering vs randMotion %%%%%%%%%%%%
    %     for k=2:8
    %         locat=mean(mean_norm(mat_file_idx,k))+.10;
    %         [h p(k)]=ttest(single_norm{mat_file_idx}(:,k),single_norm{mat_file_idx}(:,k+9));
    %         if (p(k)<0.001)
    %             text(k-0.1,locat+.5,'***');
    %         elseif (p(k)<0.01)
    %             text(k-0.1,locat+.5,'**');
    %         elseif p(k)<0.05
    %             text(k-0.1,locat+.5,'*');
    %         end
    %         text(k,locat,num2str(p(k)));
    %     end
    %     %
    %     % %%%%%%%%%%%%%flickering%%%%%%%%%%%%
    %     for k=1:8
    %         locat=mean(mean_norm(mat_file_idx,k))+.30;
    %         [h p(k)]=ttest(single_norm{mat_file_idx}(:,8),single_norm{mat_file_idx}(:,k));
    %         % if (p(k)<0.001)
    %         %     text(k-0.1,locat+5.5,'***','Color','b');
    %         % elseif (p(k)<0.01)
    %         %     text(k-0.1,locat+5.5,'**','Color','b');
    %         % elseif p(k)<0.05
    %         %     text(k-0.1,locat+5.5,'*','Color','b');
    %         % end
    %         text(k,locat,num2str(p(k)),'Color','b');
    %     end
    % 
    %     %%%%%%%%%%%%%Random Motion%%%%%%%%%%%%
    %     for k=10:17
    %         locat=mean(mean_norm(mat_file_idx,k))-.10;
    %         [h p(k)]=ttest(single_norm{mat_file_idx}(:,17),single_norm{mat_file_idx}(:,k));
    %         % if (p(k)<0.001)
    %         %     text(k-11.1,locat+2,'***','Color','r');
    %         % elseif (p(k)<0.01)
    %         %     text(k-11.1,locat+2,'**','Color','r');
    %         % elseif p(k)<0.05
    %         %     text(k-11.1,locat+2,'*','Color','r');
    %         % end
    %         text(k-11.1,locat,num2str(p(k)),'Color','r');
    %     end
    % 
    % end
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

for neuron_idx=1:2
    for f=1:4
        for n=1:1:size(single_norm{neuron_idx,f},1)
            % calculate with area under curve
            auc2{neuron_idx}(f,n)=sum(single_norm{neuron_idx,f}(n,2:8))*10;
        end
    end
end

for neuron_idx=1:2
    for f=1:4
        for n=1:1:size(single_norm{neuron_idx,f},1)
            % calculate with mean value
            auc3{neuron_idx}(f,n)=mean(single_norm{neuron_idx,f}(n,2:8))*100;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% random motion %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for neuron_idx=1:4
%     for n=1:1:size(single_norm{neuron_idx},1)
%         % calculate with area under curve
%         auc4(neuron_idx,n)=sum(single_norm{neuron_idx}(n,10:17))*10;
%     end
% end
% 
% for neuron_idx=1:4
%     for n=1:1:size(single_norm{neuron_idx},1)
%         % calculate with mean value
%         auc5(neuron_idx,n)=mean(single_norm{neuron_idx}(n,10:17))*100;
%     end
% end


%%

%%%%%%%%%%%%%%%%%%% compare ANOVA %%%%%%%%%%%%%%%%%%%%%%%%%%%%
g_LC15bar_f2b= repmat({'LC15barF2b'},size(single_norm{1},1),1);
% g_LPLC2bar_f2b= repmat({'LPLC2barF2b'},size(single_norm{2},1),1);

g_LC15bar_b2f= repmat({'LC15barB2f'},size(single_norm{1},1),1);
g_LPLC2bar_b2f= repmat({'LPLC2barB2f'},size(single_norm{2},1),1);


c = [auc3{1}(1,1:size(single_norm{1},1))'; auc3{1}(2,1:size(single_norm{1},1))';auc3{2}(2,1:size(single_norm{2},1))'];
g1 = [g_LC15bar_f2b; g_LC15bar_b2f; g_LPLC2bar_b2f];


[p4,t1,stats]=anova1(c,g1);
set(gcf,'Color','w');
sgtitle(['Noise Performance Index (p=' num2str(p4) ')']);
set(gca,'Box','off','TickDir','out','FontSize',12);
ii=100*ones(1,3);
means2=stats.means;

for i=1:3
    text(i,ii(i),num2str(stats.means(i))); hold on;
end
ylim([-10 160])
saveas(gcf,[folder_save 'AUC2_ANOVA_NotchPlot']);

figure;
[c,m,h,gnames] = multcompare(stats);
%
for i=1:size(c,1)
    disp([ num2str(c(i,1)) ' with ' num2str(c(i,2)) ' pValue : ' num2str(c(i,6))]);
end


save([folder_save 'quantified_slowbar_gcamp_260428'], 't','avg_gcamp','g1','c','auc2','auc3','single_norm','mean_norm','means2');

