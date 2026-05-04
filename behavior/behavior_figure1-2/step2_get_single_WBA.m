%%%%%250529 hyosun edited ---- edit normalize method & response idx (ver_8)
%%%%%250520 hyosun edited ---- fix the avg peak idx & NPI calculating
%%%%% hyosun edited

clear all;
folder_data='/Users/hyosunkim/1_Analyze_data/noise/TNT_ver4';
folder_save='results/';

cd(folder_data);
file_list=search_for_mat(folder_data);
for i=1:length(file_list)
    mat_file_names{1,i}=file_list(i).name;
end

for mat_file_idx=1:length(file_list)/2
    
    % load mat files which we got from step 1
    load(mat_file_names{mat_file_idx*2-1});

    % combine the data for bar,spot and loom,grating
    if exist('experimental_data','var')
        exp_group_data_lg=experimental_data;
        clear experimental_data;
        load(mat_file_names{mat_file_idx*2});
        exp_group_data_bs=experimental_data;
        min_nSamples=min(size(exp_group_data_lg,3), size(exp_group_data_bs,3));
        exp_group_data=vertcat(exp_group_data_bs(1:32,:,1:min_nSamples),exp_group_data_lg(:,:,1:min_nSamples),exp_group_data_bs(33,:,1:min_nSamples));
    else
        exp_group_data_lg=exp_group_data;
        clear exp_group_data;
        load(mat_file_names{mat_file_idx*2});
        exp_group_data_bs=exp_group_data;
        min_nSamples=min(size(exp_group_data_lg,3), size(exp_group_data_bs,3));
        exp_group_data=vertcat(exp_group_data_bs(1:32,:,1:min_nSamples),exp_group_data_lg(:,:,1:min_nSamples),exp_group_data_bs(33,:,1:min_nSamples));
    end

    pattern_name=["bar 0%" "bar 10%" "bar 20%" "bar 30%" "bar 40%"...
        "bar 50%" "bar 60%" "bar 70%" "spot up 0%" "spot up 10%"...
        "spot up 20%" "spot up 30%" "spot up 40%" "spot up 50%" "spot up 60%"...
        "spot up 70%" "looming 0%" "looming 10%" "looming 20%" "looming 30%" "looming 40%"...
        "looming 50%" "looming 60%" "looming 70%" "grating 0%" "grating 10%"...
        "grating 20%" "grating 30%" "grating 40%" "grating 50%" "grating 60%"...
        "grating 70%" "noise 100%" "noise 100%"];

    tit=[mat_file_names{mat_file_idx*2-1}(1:10)];

    if size(exp_group_data,2)==4
        t=exp_group_data{1,1,1};
    else
        t=exp_group_data{1,2,1};
    end

    dt=t(2)-t(1);

    patterns=1;
    for  p=[1:2:64,65,66]
        % if noise 100 % , no need to combine
        if p == 65 || p==66
            for n=1:1:size(exp_group_data,3)

                %1:16=bar 17:32=spotup 33:48 =looming 49:64=grating 65,66=noise100
                if size(exp_group_data,2)==4
                    wba_single_fly_data = (exp_group_data{p,3,n}-exp_group_data{p,4,n});
                else
                    wba_single_fly_data = (exp_group_data{p,4,n}-exp_group_data{p,5,n});
                end
                wba_single_fly{patterns,n}=wba_single_fly_data/5*135;
            end
        else
            % combine the inverted response for the left pattern to the response for the right patterns
            for n=1:1:size(exp_group_data,3)
                if size(exp_group_data,2)==4
                    right_pat_wba_single_fly=(exp_group_data{p,3,n}-exp_group_data{p,4,n});
                    left_pat_wba_single_fly= (exp_group_data{p+1,4,n}-exp_group_data{p+1,3,n});
                    wba_single_fly_data=vertcat(right_pat_wba_single_fly,left_pat_wba_single_fly);
                else
                    right_pat_wba_single_fly=(exp_group_data{p,4,n}-exp_group_data{p,5,n});
                    left_pat_wba_single_fly= (exp_group_data{p+1,5,n}-exp_group_data{p+1,4,n});
                    wba_single_fly_data=vertcat(right_pat_wba_single_fly,left_pat_wba_single_fly);
                end

                if sum(~isnan(wba_single_fly_data(:,1))) < 5
                    wba_single_fly_data =nan(1,size(wba_single_fly_data,2));
                end

                if(p>=17 && p<=48) %anmo 2021.7.14.
                    %for spot and loom, invert the sign
                    wba_single_fly_data=-wba_single_fly_data;
                end
                wba_single_fly{patterns,n}=wba_single_fly_data/5*135;
            end
        end
        patterns=patterns+1;
    end

    % delete the wba error if wba decreased more than -15 deg
    for p=1:1:size(wba_single_fly,1)
        j=1;
        for n=1:size(wba_single_fly,2)
            if size(wba_single_fly{p,n},1)==1
                wba_flyavg{p,j}=wba_single_fly{p,n};
            else
                % calculate the average for the trials
                wba_flyavg{p,j}=mean(wba_single_fly{p,n},'omitnan');
            end
            j=j+1;
        end
    end

    t=1:length(wba_flyavg{1,1});
    if size(exp_group_data,2)==4
        t=t*dt-1;
    else
        t=t*dt-0.4;
    end

    for p=1:1:size(wba_flyavg,1)
        % calculate the average for flies (population average)
        wba_popavg{p}=mean(cell2mat(wba_flyavg(p,:)'),1,'omitnan');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%% index for response peak %%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    baseline_idx=find(t>1.3 & t<=1.5);
    response_idx=find(t>1.65 & t<=1.85);
    %index for latency
    response_idx_lat=find(t>1.5 & t<=1.8);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Single trial -- Figure 1C and 1D (Upper panel)
    
    %%%%%%%%%% noiseless bar, grating, loom, spot (Figure 1C)%%%%%%%%%%
    figure(1); clf;set(gca,'Box','off','Color','w');
    n=36;   %36th fly
    pat=[1,25,17,9]; % noiseless bar, grating, loom, spot (Figure 1C)

    for j=1:size(pat,2)
        subplot(1,5,j);
        % the range of pattern movement (1.5 - 1.6 sec)
        rectangle('Position',[1.5 -20 0.2 60 ],'FaceColor',[0.8 0.8 0.8],'EdgeColor',[0.8 0.8 0.8]);hold all;
        % 2nd trial
        for trial=2
            % baseline subtracted traces
            plot(t,wba_single_fly{pat(j),n}(trial,:)-mean(wba_single_fly{pat(j),n}(trial, baseline_idx)),'Color','b'); hold all;
            set(gca,'Box','off','TickDir','out','FontSize',12);
            xlim([1.4, 2]);
            ylim([-30 60]);
        end
        title(pattern_name(pat(j)));
    end

    %%%%%%%%%%% bar with 0,10,30,50,70 % noise (Figure 1D)%%%%%%%%%%
    figure(2); clf;set(gca,'Box','off','Color','w');
    n=36; %36th fly
    pat=[1,2,4:2:8]; %pattern index

    for j=1:size(pat,2)
        subplot(1,5,j);
        % the range of pattern movement (1.5 - 1.6 sec)
        rectangle('Position',[1.5 -20 0.2 60 ],'FaceColor',[0.8 0.8 0.8],'EdgeColor',[0.8 0.8 0.8]);hold all;
        % 10th trial
        for trial=10
            % baseline subtracted traces
            plot(t,wba_single_fly{pat(j),n}(trial,:)-mean(wba_single_fly{pat(j),n}(trial, baseline_idx)),'Color','b'); hold all;
            set(gca,'Box','off','TickDir','out','FontSize',12);
            xlim([1.4, 2]);
            ylim([-30 60]);
        end
        title(pattern_name(pat(j)));
    end

    %% Average of trials in single fly -- Figure 1C and 1D (middle panel)
    %%%%%%%%%%% noiseless bar, grating, loom, spot (Figure 1C)%%%%%%%%%%
    figure(3); clf;set(gca,'Box','off','Color','w');
    n=36;
    pat=[1,25,17,9]; 

    for j=1:size(pat,2)
        subplot(1,5,j);
        rectangle('Position',[1.5 -20 0.2 60 ],'FaceColor',[0.8 0.8 0.8],'EdgeColor',[0.8 0.8 0.8]);hold all;
        for trial=1:1:size(wba_single_fly{pat(j),n},1)
            cm_gray=repmat(linspace(0.4,0.8,size(wba_single_fly{pat(j),n},1))',[1 3]);
            % plot the baseline subtracted wing traces for each trials
            plot(t,wba_single_fly{pat(j),n}(trial,:)-mean(wba_single_fly{pat(j),n}(trial, baseline_idx)),'Color',cm_gray(trial,:,:)); hold all;
            set(gca,'Box','off','TickDir','out','FontSize',12);
            xlim([1.4, 2]);
            ylim([-30 60]);
        end
        % plot the baseline subtracted wing traces of mean trials (one fly)
        plot(t,wba_flyavg{pat(j),n}-mean(wba_flyavg{pat(j),n}(:, baseline_idx)),'r','LineWidth',1.5);
        title(pattern_name(pat(j)));
    end

    %%%%%%%%%%% bar with 0,10,30,50,70 % noise (Figure 1D) %%%%%%%%%%
    figure(4); clf;set(gca,'Box','off','Color','w');
    n=36;
    pat=[1,2,4:2:8]; % pattern index

    for j=1:size(pat,2)
        subplot(1,5,j);
        rectangle('Position',[1.5 -20 0.2 60 ],'FaceColor',[0.8 0.8 0.8],'EdgeColor',[0.8 0.8 0.8]);hold all;
        for trial=1:1:size(wba_single_fly{pat(j),n},1)
            cm_gray=repmat(linspace(0.4,0.8,size(wba_single_fly{pat(j),n},1))',[1 3]);
            % plot the baseline subtracted wing traces for each trials
            plot(t,wba_single_fly{pat(j),n}(trial,:)-mean(wba_single_fly{pat(j),n}(trial, baseline_idx)),'Color',cm_gray(trial,:,:)); hold all;
            set(gca,'Box','off','TickDir','out','FontSize',12);
            xlim([1.4, 2]);
            ylim([-30 60]);
        end
        % plot the baseline subtracted wing traces of mean trials (one fly)
        plot(t,wba_flyavg{pat(j),n}-mean(wba_flyavg{pat(j),n}(:, baseline_idx)),'r','LineWidth',1.5);
        title(pattern_name(pat(j)));
    end

    %% Flies wba traces (population) -- Figure 1C and 1D (Bottom panel)
    %%%%%%%%%% noiseless bar, grating, loom, spot (Figure 1C)%%%%%%%%%%
    figure(5); clf;set(gca,'Box','off','Color','w');
    pat=[1,25,17,9];

    for p=1:size(pat,2)
        subplot(1,5,p);
        rectangle('Position',[1.5 -20 0.2 60 ],'FaceColor',[0.8 0.8 0.8],'EdgeColor',[0.8 0.8 0.8]);hold all;
        for n=1:1:size(wba_flyavg,2)
            cm_gray=repmat(linspace(0.4,0.8,size(wba_flyavg,2))',[1 3]);
            % plot baseline subtracted wing traces of single flies
            plot(t,wba_flyavg{pat(p),n}-mean(wba_flyavg{pat(p),n}(:, baseline_idx)),'Color',cm_gray(n,:,:)); hold all;
            set(gca,'Box','off','TickDir','out','FontSize',12);
            xlim([1.4,2]);
            ylim([-20 50]);
        end
        % plot the population average traces
        plot(t,wba_popavg{pat(p)},'r','LineWidth',1.5);
        title(pattern_name(pat(p)));
    end

    %%%%%%%%%% bar with 0,10,30,50,70 % noise (Figure 1D) %%%%%%%%%%
    figure(6); clf;set(gca,'Box','off','Color','w');
    pat=[1,2,4:2:8]; 

    for p=1:size(pat,2)
        subplot(1,5,p);
        rectangle('Position',[1.5 -20 0.2 60 ],'FaceColor',[0.8 0.8 0.8],'EdgeColor',[0.8 0.8 0.8]);hold all;
        for n=1:1:size(wba_flyavg,2)
            cm_gray=repmat(linspace(0.4,0.8,size(wba_flyavg,2))',[1 3]);
            % plot baseline subtracted wing traces of single flies
            plot(t,wba_flyavg{pat(p),n}-mean(wba_flyavg{pat(p),n}(:, baseline_idx)),'Color',cm_gray(n,:,:)); hold all;
            set(gca,'Box','off','TickDir','out','FontSize',12);
            xlim([1.4,2]);
            ylim([-20 50]);
        end
        % plot the population average traces
        plot(t,wba_popavg{pat(p)},'r','LineWidth',1.5);
        title(pattern_name(pat(p)));
    end

    %% Population WBA traces across the noise levels -- Figure 1E
    figure(7);clf; set(gcf,'Color','w');

    num=num2str(size(wba_flyavg,2)); % number of flies

    colors=parula(8);

    for panel_idx=1:4
        haxes(panel_idx)=subplot(1,4,panel_idx);
        hold on;

        for p=[(1:8) + (panel_idx-1)*8]
            % baseline subtracted population traces
            wba_popavg{p}=wba_popavg{p}-mean(wba_popavg{p}(:, baseline_idx));
            % plot population wing traces across noise levels
            plot(t,wba_popavg{p},'Color',colors(mod(p-1,8)+1,:),'LineWidth',1); hold on;
            set(gca,'Box','off','TickDir','out','FontSize',12);
        end

        switch panel_idx
            case 1
                title( 'Bar ');
                xlabel('time(s)');
                ylabel('L-R WBA (°)');
            case 2
                title('Spot ');
            case 3
                title('Loom ');
            case 4
                title( 'Grtng ');
                legend({'0%', '10%', '20%','30%','40%','50%','60%','70%'},'Box','off','Location','northeastoutside','FontSize',12);hold all;
        end
        axis tight;
    end
    ylim2=cell2mat(get(haxes,'YLim'));
    ylim0=[min(ylim2(:,1)) max(ylim2(:,2))];
    set(haxes,'xlim',[1.4 4], 'ylim', ylim0);
    for i=1:4
        r=rectangle(haxes(i),'Position',[1.5 ylim0(1) 0.2 diff(ylim0)],'FaceColor',ones(1,3)*0.8,'EdgeColor',ones(1,3)*0.8);
        uistack(r,'bottom');
    end   
    
    %% delta WBA
    X = categorical({'0' '10' '20' '30' '40' '50' '60' '70' '100'});
    X = reordercats(X,{'0' '10' '20' '30' '40' '50' '60' '70' '100'});

    for p=1:1:size(wba_flyavg,1)
        for n=1:1:size(wba_flyavg,2)
            % delta WBA of single flies (to calculate the accuracy)
            for trial = 1: size(wba_single_fly{p,n},1)
                based_single_wba{p,n}(trial,:) = wba_single_fly{p,n}(trial,:)-mean(wba_single_fly{p,n}(trial, baseline_idx));
            end

            % baseline subtracted wing response
            zeroBased_WBA{p,n}=wba_flyavg{p,n}-mean(wba_flyavg{p,n}(:, baseline_idx),'omitnan');
        end
    end

    for pattern_idx=1:4
        if pattern_idx== 1 || pattern_idx== 2
            idx_here=[(1:8)+(pattern_idx-1)*8 size(zeroBased_WBA,1)];
        else
            idx_here=[(1:8)+(pattern_idx-1)*8 size(zeroBased_WBA,1)-1];
        end
        for n=1:1:size(wba_flyavg,2)
            for i=1:length(idx_here)
                for trial = 1: size(wba_single_fly{idx_here(i),n},1)
                    mean_single_peak{pattern_idx,n}(i,trial) = mean(based_single_wba{idx_here(i),n}(trial,response_idx),'omitnan');
                end
                % calculate the mean response in the response window(1.65-1.85 seconds)
                mean_peak{pattern_idx}(i,n)=mean(zeroBased_WBA{idx_here(i),n}(response_idx),'omitnan');
            end
        end
    end

    %%%%%%%%%%% plot the mean peak %%%%%%%%%%%%%%%%%
    figure(8);clf;
    set(gcf,'Color','w'); sgtitle([tit '(n=' num2str(size(mean_peak{pattern_idx},2)) ')']);
    c='bmrg';
    for pattern_idx=1:4
        switch pattern_idx
            case 1
                title(['Bar']);
                subplot(1,2,1);
                xlabel('noise level (%)');ylabel('Mean WBA response (deg)');
            case 2
                title( ['Spot']);
                subplot(1,2,2);
            case 3
                title( ['Loom']);
                subplot(1,2,2);
            case 4
                title( ['Grating']);
                subplot(1,2,1);
        end
        hold on;
        sem=std(mean_peak{pattern_idx},[],2)/sqrt(size(wba_flyavg,2))*1.96;
        errorbar(1:9, mean(mean_peak{pattern_idx},2,'omitnan'), sem,'Color',ones(1,3)*0.8);hold on;
        plot(mean(mean_peak{pattern_idx},2,'omitnan'),'Color',c(pattern_idx),'Marker','o','MarkerFaceColor',c(pattern_idx));

        %%%%%%%%%%%%%%%%%%%% caculate p-value %%%%%%%%%%%%%%%%%%%%%%%%%
        for i=1:8
            locat=mean(mean_peak{pattern_idx},2)+1;
            [h p]=ttest(mean_peak{pattern_idx}(i,:)-mean_peak{pattern_idx}(9,:));
            if(p<0.001)
                text(i, locat(i), '***');
            elseif(p<0.01)
                text(i, locat(i), '**');
            elseif(p<0.05)
                text(i, locat(i), '*');
            end
        end

        set(gca,'XTick',1:9,'XTickLabel',{'0' '10' '20' '30' '40' '50' '60' '70' '100'});
        set(gca,'Box','off','TickDir','out');

        axis tight;
        set(gca,'Box','off','TickDir','out','FontSize',12);

    end

    %% Normalized delta WBA -- Figure 2A
    for pattern_idx=1:4
        for n=1:size(wba_flyavg,2)
            mean_min{pattern_idx} = min(mean(mean_peak{pattern_idx},2,'omitnan'));
            mean_max{pattern_idx} = max(mean(mean_peak{pattern_idx},2,'omitnan'));

            mean_norm(pattern_idx,1:9) = (mean(mean_peak{pattern_idx},2,'omitnan') - mean_min{pattern_idx}) / (mean_max{pattern_idx} - mean_min{pattern_idx});
            single_norm{pattern_idx}(1:9,n) = (mean_peak{pattern_idx}(:,n) - mean_min{pattern_idx}) / (mean_max{pattern_idx} - mean_min{pattern_idx});
        end
    end

    %%%%%%%%%%% plot the normalized mean peak %%%%%%%%%%%%%%%%%
    figure(9);clf; set(gcf,'Color','w'); sgtitle([tit '(n=' num2str(size(mean_peak{pattern_idx},2)) ')']);

    c='bmrg';

    for pattern_idx=1:4
        switch pattern_idx
            case 1
                title('Bar');
                subplot(1,2,1);
                xlabel('noise level (%)');ylabel('Normalized WBA response (deg)');
                j=1;
            case 2
                title('Spot');
                subplot(1,2,2);
                j=1;
            case 3
                title('Loom');
                subplot(1,2,2);
                j=4;
            case 4
                title('Grating');
                subplot(1,2,1);
                j=4;
        end
        hold on;

        sem=std(single_norm{pattern_idx},[],2,'omitnan')/sqrt(size(wba_flyavg,2))*1.96;
        errorbar((1:9)+.05*j, mean_norm(pattern_idx,:), sem,'Color',ones(1,3)*0.8);hold on;
        plot((1:9)+.05*j, mean_norm(pattern_idx,:),'Color',c(pattern_idx),'Marker','o','MarkerFaceColor',c(pattern_idx));

        %%%%%%%%%%%%%%%%%%%% caculate p-value %%%%%%%%%%%%%%%%%%%%%%%%%
        for i=1:8
            locat=mean(single_norm{pattern_idx},2)+.1;
            [h p1{pattern_idx}(i)]=ttest(single_norm{pattern_idx}(i,:)-single_norm{pattern_idx}(9,:));
            if(p1{pattern_idx}(i)<0.001)
                text(i, locat(i), '***');
            elseif(p1{pattern_idx}(i)<0.01)
                text(i, locat(i), '**');
            elseif(p1{pattern_idx}(i)<0.05)
                text(i, locat(i), '*');
            end
        end

        set(gca,'XTick',1:9,'XTickLabel',{'0' '10' '20' '30' '40' '50' '60' '70' '100'});
        set(gca,'Box','off','TickDir','out');
        ylim([-0.2 1.2]);
        set(gca,'Box','off','TickDir','out','FontSize',12);
    end

    

    %% Calculate NRI - trapezoidal rule of integration(contain all non-significant) -- Figure 2C
    
    for pattern_idx=1:4
        for n=1:1:size(wba_flyavg,2) % n=[1:29,31,33:42]
            % calculate with mean value
            auc3(pattern_idx,n)=mean(single_norm{pattern_idx}(2:8,n),'omitnan')*100;
        end
    end

    %% compare NRI using ANOVA -- Figure 2C

    g_bar= repmat({'bar'},length(auc3),1);
    g_spot= repmat({'spot'},length(auc3),1);
    g_loom= repmat({'loom'},length(auc3),1);
    g_grat= repmat({'grating'},length(auc3),1);

    c = [auc3(4,:)' ; auc3(1,:)'; auc3(3,:)' ; auc3(2,:)'];
    g = [g_grat; g_bar ; g_loom ; g_spot];

    [p2,t1,stats]=anova1(c,g);
    set(gcf,'Color','w');
    sgtitle(['Noise Performance Index (p=' num2str(p2) ')']);
    set(gca,'Box','off','TickDir','out','FontSize',12);
    ylabel('AUC(a.u.)');

    ii=100*ones(1,4);
    means2=stats.means;
    for i=1:4
        text(i,ii(i),num2str(means2(i))); hold on;
    end
    ylim([-10 130]);
    
    figure;
    [c,m,h,gnames] = multcompare(stats);
    %
    for i=1:size(c,1)
        disp([ num2str(c(i,1)) ' with ' num2str(c(i,2)) ' pValue : ' num2str(c(i,6))]);
    end


    %% 50 % onset latency -- Figure 2B

    for idx_pat=1:4
        if idx_pat== 1 || idx_pat== 2  % if bar/spot stimuli
            idx_here=[(1:8)+(idx_pat-1)*8 size(zeroBased_WBA,1)];
        else
            idx_here=[(1:8)+(idx_pat-1)*8 size(zeroBased_WBA,1)-1];
        end
        for i=1:length(idx_here)
            for n=1:1:size(wba_flyavg,2)
                [max_peak_single{idx_pat}(i,n), max_peak_idx{idx_pat}(i,n)]=max(zeroBased_WBA{idx_here(i),n}(response_idx_lat));
                max_peak_sec{idx_pat}(i,n)=t(max_peak_idx{idx_pat}(i,n));
                half_peak{idx_pat}(i,n)=max_peak_single{idx_pat}(i,n)*0.5;
                if max_peak_single{idx_pat}(i,n)<=0
                    % ignore latency if the peak amplitude is negative
                    lat_idx50{idx_pat}(i,n)=nan;
                    lat_idx50_sec{idx_pat}(i,n)=nan;
                else
                    if isempty(find(zeroBased_WBA{idx_here(i),n}(response_idx_lat)>half_peak{idx_pat}(i,n),1,'first'))
                        % ignore latency if the 50% onset timing is empty
                        lat_idx50{idx_pat}(i,n)=nan;
                        lat_idx50_sec{idx_pat}(i,n)=nan;
                    else
                        response_amplitude_here{idx_pat}(i, n) = mean(zeroBased_WBA{idx_here(i),n}(response_idx));
                        if response_amplitude_here{idx_pat}(i, n)  < 3
                            % ignore latency if response is not large enough
                            lat_idx50{idx_pat}(i,n)=nan;
                            lat_idx50_sec{idx_pat}(i,n)=nan;
                        else
                            wingBeat_here = zeroBased_WBA{idx_here(i),n}(response_idx_lat) ;
                            threshold_here = half_peak{idx_pat}(i,n);
                            lat_idx50{idx_pat}(i,n)=find(wingBeat_here > threshold_here,1,'first')+response_idx_lat(1);   %1.5-1.8
                            lat_idx50_sec{idx_pat}(i,n)=t(lat_idx50{idx_pat}(i,n))-1.5;

                            if lat_idx50_sec{idx_pat}(i,n) < 0.05
                                % if the 50 percent latency is too short, ignore it
                                lat_idx50_sec{idx_pat}(i,n) = nan;
                                lat_idx50{idx_pat}(i,n) = nan;
                            end
                        end
                    end
                end
                sem(idx_pat,i)=std(lat_idx50_sec{idx_pat}(i,:),[],2,'omitnan')/sqrt(size(lat_idx50_sec{idx_pat},2))*1.96;
                mean_lat_50(idx_pat,i)=mean(lat_idx50_sec{idx_pat}(i,:),2,'omitnan');
                mean_lat_peak(idx_pat,i)=mean(max_peak_sec{idx_pat}(i,:),2,'omitnan');
            end
        end
    end

    %%%%%%%%%%%%% plot the 50 % onset latency %%%%%%%%%%%%
    figure;clf; set(gcf,'Color','w');
    cm='bmrg';

    for idx_pat=1:4
        if idx_pat==1 || idx_pat==4
            subplot(1,2,1);
        else
            subplot(1,2,2);
        end
        errorbar((1:9)+0.05*idx_pat, mean_lat_50(idx_pat,:), sem(idx_pat,:),'Color',ones(1,3)*0.8);hold on;
        plot((1:9)+0.05*idx_pat, mean_lat_50(idx_pat,:),'Color',cm(idx_pat),'Marker','o','MarkerFaceColor',cm(idx_pat));hold on;
    end

    %%%%%%%%%%%%%%%caculate p-value%%%%%%%%%%%%%%%%
    for idx=1:4
        for i=2:9
            locat=mean_lat_50(idx,i)-0.03;
            [h p]=ttest(lat_idx50_sec{idx}(i,:),lat_idx50_sec{idx}(1,:));
            if idx==1 || idx==4
                subplot(1,2,1);
                if(p<0.001)
                    text(i, locat, '***','Color',[cm(idx)]);
                elseif(p<0.01)
                    text(i, locat, '**','Color',[cm(idx)]);
                elseif(p<0.05)
                    text(i, locat, '*','Color',[cm(idx)]);
                end
                text(i,locat,num2str(p),'Color',cm(idx));
                set(gca,'XTick',1:9,'XTickLabel',{'0' '10' '20' '30' '40' '50' '60' '70' '100'});
                set(gca,'Box','off','TickDir','out');
                xlabel('noise level (%)');ylabel('Latency (s)');
                ylim([0.06 0.22]);
            else
                subplot(1,2,2);
                if(p<0.001)
                    text(i, locat, '***','Color',[cm(idx)]);
                elseif(p<0.01)
                    text(i, locat, '**','Color',[cm(idx)]);
                elseif(p<0.05)
                    text(i, locat, '*','Color',[cm(idx)]);
                end
                text(i,locat,num2str(p),'Color',cm(idx));
                set(gca,'XTick',1:9,'XTickLabel',{'0' '10' '20' '30' '40' '50' '60' '70' '100'});
                set(gca,'Box','off','TickDir','out');
                xlabel('noise level (%)');ylabel('Latency (s)');
                ylim([0.06 0.22]);
            end
        end
    end
    sgtitle(tit, 'interpreter', 'none');
    % saveas(gcf,[mat_file_names{mat_file_idx*2-1}(1:(end-4)) '_v5_latency_from_popavg']);

    save([folder_save 'v8_quantified_peak_wba_' tit '260428'], 't','wba_single_fly','wba_flyavg','wba_popavg', ...
    'mean_peak','single_norm','mean_norm', 'mean_lat_50', 'lat_idx50_sec','means2','auc2','auc3','mean_single_peak');

    %%
    cd ../


    clear;
    close all;

    folder_data='/Volumes/nisl/hyosun/1.Noise_Experiment/V4-10_TNT_re-analyze';
    folder_save='results/';
    cd(folder_data);
    file_list=search_for_mat(folder_data);
    for i=1:length(file_list)
        mat_file_names{1,i}=file_list(i).name;
    end

end



