%%%%%250529 hyosun edited ---- edit normalize method & response idx (ver_8)
%%%%%250520 hyosun edited ---- fix the avg peak idx & NPI calculating
%%%%% hyosun edited

clear all;
folder_data='/Volumes/nisl/hyosun/1.Noise_Experiment/V11_new/matFiles';
folder_save='results_v3/';


cd(folder_data);
file_list=search_for_mat(folder_data);
for i=1:length(file_list)
    mat_file_names{1,i}=file_list(i).name;
end


for mat_file_idx= 1:size(mat_file_names)
    % load mat files which we got from step 1
    load(mat_file_names{mat_file_idx*2-1});

    % combine the data for bar,spot and loom,grating
    if exist('experimental_data','var')
        exp_group_data_lg=experimental_data;
        clear experimental_data;
        load(mat_file_names{mat_file_idx*2});
        exp_group_data_bs=experimental_data;
        min_nSamples=min(size(exp_group_data_lg,3), size(exp_group_data_bs,3));
        exp_group_data=vertcat(exp_group_data_bs(:,:,1:min_nSamples),exp_group_data_lg(:,:,1:min_nSamples));
    else
        exp_group_data_lg=exp_group_data;
        clear exp_group_data;
        load(mat_file_names{mat_file_idx*2});
        exp_group_data_bs=exp_group_data;
        min_nSamples=min(size(exp_group_data_lg,3), size(exp_group_data_bs,3));
        exp_group_data=vertcat(exp_group_data_bs(:,:,1:min_nSamples),exp_group_data_lg(:,:,1:min_nSamples));
    end

    pattern_name=["bar 0%" "bar 10%" "bar 20%" "bar 30%" "bar 40%"...
        "bar 50%" "bar 60%" "bar 70%" "bar 71.2%" "bar 72.4%" "bar 73.6%" "bar 74.8%" ...
        "spot up 0%" "spot up 10%" "spot up 20%" "spot up 30%" "spot up 40%" "spot up 50%" ...
        "spot up 60%" "spot up 70%" "spot up 71.2%" "spot up 72.4%" "spot up 73.6%" "spot up 74.8%" ...
        "looming 0%" "looming 10%" "looming 20%" "looming 30%" "looming 40%" "looming 50%" ...
        "looming 60%" "looming 70%" "looming 71.2%" "looming 72.4%" "looming 73.6%" "looming 74.8%" ...
        "grating 0%" "grating 10%" "grating 20%" "grating 30%" "grating 40%" "grating 50%" ...
        "grating 60%" "grating 70%" "grating 71.2%" "grating 72.4%" "grating 73.6%" "grating 74.8%"];

    tit=[mat_file_names{mat_file_idx*2-1}(1:10)];

    t=exp_group_data{1,1,1};
   
    dt=t(2)-t(1);

    patterns=1;
    for  p=1:2:size(exp_group_data,1)
        % combine the inverted response for the left pattern to the response for the right patterns
        for n=1:1:size(exp_group_data,3)
            right_pat_wba_single_fly=(exp_group_data{p,3,n}-exp_group_data{p,4,n});
            left_pat_wba_single_fly= (exp_group_data{p+1,4,n}-exp_group_data{p+1,3,n});
            wba_single_fly_data=vertcat(right_pat_wba_single_fly,left_pat_wba_single_fly);

            if sum(~isnan(wba_single_fly_data(:,1))) < 5
                wba_single_fly_data =nan(1,size(wba_single_fly_data,2));
            end

            if(p>=25 && p<=72) %anmo 2021.7.14.
                %for spot and loom, invert the sign
                wba_single_fly_data=-wba_single_fly_data;
            end
            wba_single_fly{patterns,n}=wba_single_fly_data/5*135;
        end

        patterns=patterns+1;
    end

    % delete the wba error if wba decreased more than -15 deg
    for p=1:1:size(wba_single_fly,1)
        j=1;
        for n=1:size(wba_single_fly,2)
            % for the
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
    t=t*dt-1.14;

    for p=1:1:size(wba_flyavg,1)
        % calculate the average for flies (population average)
        wba_popavg{p}=mean(cell2mat(wba_flyavg(p,:)'),1,'omitnan');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%% index for response peak %%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    baseline_idx=find(t>1.3 & t<=1.5);
    response_idx=find(t>1.7 & t<=1.9);
    %index for latency
    response_idx_lat=find(t>1.5 & t<=1.8);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Population WBA traces across the noise levels -- Figure S1A
    figure(1);clf; set(gcf,'Color','w');

    num=num2str(size(wba_flyavg,2)); % number of flies
    sgtitle([tit ' (n=' num ')']);

    colors=parula(12);

    for panel_idx=1:4
        haxes(panel_idx)=subplot(1,4,panel_idx);
        hold on;

        for p=[(1:12) + (panel_idx-1)*12]
            % baseline subtracted population traces
            wba_popavg{p}=wba_popavg{p}-mean(wba_popavg{p}(:, baseline_idx));
            % plot population wing traces across noise levels
            plot(t,wba_popavg{p},'Color',colors(mod(p-1,12)+1,:),'LineWidth',1); hold on;
            set(gca,'Box','off','TickDir','out','FontSize',12);
        end

        switch panel_idx
            case 1
                title( 'Bar ');
                xlabel('time(s)');
                ylabel('L-R WBA (°)');
            case 2
                title( 'Grtng ');
                legend({'0', '10', '20','30','40','50','60','70','71.2','72.4','73.6','74.8'},'Box','off','Location','northeastoutside','FontSize',12);hold all;
        end
        axis tight;
    end
    ylim2=cell2mat(get(haxes,'YLim'));
    ylim0=[min(ylim2(:,1)) max(ylim2(:,2))];
    set(haxes,'xlim',[1.3 2.5], 'ylim', ylim0);
    for i=1:4
        r=rectangle(haxes(i),'Position',[1.5 ylim0(1) 0.2 diff(ylim0)],'FaceColor',ones(1,3)*0.8,'EdgeColor',ones(1,3)*0.8);
        uistack(r,'bottom');
    end

    savefig(gcf,[folder_save mat_file_names{mat_file_idx*2-1}(1:10) '_avgTraces']);


    %% delta WBA
    X = categorical({'0', '10', '20','30','40','50','60','70','71.2','72.4','73.6','74.8'});
    X = reordercats(X,{'0', '10', '20','30','40','50','60','70','71.2','72.4','73.6','74.8'});

    for p=1:1:size(wba_flyavg,1)
        for n=1:1:size(wba_flyavg,2)
            % baseline subtracted wing response
            zeroBased_WBA{p,n}=wba_flyavg{p,n}-mean(wba_flyavg{p,n}(:, baseline_idx),'omitnan');
        end
    end

    for pattern_idx=1:4
        idx_here=[(1:12)+(pattern_idx-1)*12];
        
        for n=1:1:size(wba_flyavg,2)
            for i=1:length(idx_here)
                % calculate the mean response in the response window(1.65-1.85 seconds)
                mean_peak{pattern_idx}(i,n)=mean(zeroBased_WBA{idx_here(i),n}(response_idx),'omitnan');
            end
        end
    end

    %%%%%%%%%%% plot the mean peak %%%%%%%%%%%%%%%%%
    figure(5);clf;
    set(gcf,'Color','w'); sgtitle([tit '(n=' num2str(size(mean_peak{pattern_idx},2)) ')']);
    c='bmrg';
    for pattern_idx=1:2
        switch pattern_idx
            case 1
                subplot(1,2,1);
                xlabel('noise level (%)');ylabel('Mean WBA response (deg)');
                title(['Bar']);
                j=1;
            case 2
                subplot(1,2,2);
                title( ['Grating']);
                j=4;
        end
        hold on;
        sem=std(mean_peak{j},[],2)/sqrt(size(wba_flyavg,2))*1.96;
        errorbar(1:12, mean(mean_peak{j},2,'omitnan'), sem,'Color',ones(1,3)*0.8);hold on;
        plot(mean(mean_peak{j},2,'omitnan'),'Color',c(j),'Marker','o','MarkerFaceColor',c(j));

        %%%%%%%%%%%%%%%%%%%% caculate p-value %%%%%%%%%%%%%%%%%%%%%%%%%
        for i=1:11
            locat=mean(mean_peak{j},2)+1;
            [h p]=ttest(mean_peak{j}(i,:)-mean_peak{j}(12,:));
            if(p<0.001)
                text(i, locat(i), '***');
            elseif(p<0.01)
                text(i, locat(i), '**');
            elseif(p<0.05)
                text(i, locat(i), '*');
            end
        end

        set(gca,'XTick',1:12,'XTickLabel',X);
        set(gca,'Box','off','TickDir','out');

        axis tight;
        set(gca,'Box','off','TickDir','out','FontSize',12);

    end
    saveas(gcf,[folder_save mat_file_names{mat_file_idx*2-1}(1:10) '_meanWBA']);

    %% Normalized delta WBA -- Figure 2A and 2C
    for pattern_idx=1:2
        for n=1:size(wba_flyavg,2)
            mean_min{pattern_idx} = min(mean(mean_peak{pattern_idx},2,'omitnan'));
            mean_max{pattern_idx} = max(mean(mean_peak{pattern_idx},2,'omitnan'));

            mean_norm(pattern_idx,1:12) = (mean(mean_peak{pattern_idx},2,'omitnan') - mean_min{pattern_idx}) / (mean_max{pattern_idx} - mean_min{pattern_idx});
            single_norm{pattern_idx}(1:12,n) = (mean_peak{pattern_idx}(:,n) - mean_min{pattern_idx}) / (mean_max{pattern_idx} - mean_min{pattern_idx});
        end
    end

    %%%%%%%%%%% plot the normalized mean peak %%%%%%%%%%%%%%%%%
    figure(6);clf; set(gcf,'Color','w'); sgtitle([tit '(n=' num2str(size(mean_peak{pattern_idx},2)) ')']);

    c='bmrg';

    for pattern_idx=1:2
        switch pattern_idx
            case 1
                subplot(1,2,1);
                xlabel('noise level (%)');ylabel('Normalized WBA response (deg)');
                j=1;
                title('Bar');
            
            case 2
                subplot(1,2,2);
                j=4;
                title('Grating');
        end
        hold on;

        sem=std(single_norm{j},[],2)/sqrt(size(wba_flyavg,2))*1.96;
        errorbar((1:12), mean_norm(j,:), sem,'Color',ones(1,3)*0.8);hold on;
        plot((1:12), mean_norm(j,:),'Color',c(j),'Marker','o','MarkerFaceColor',c(pattern_idx));

        %%%%%%%%%%%%%%%%%%%% caculate p-value %%%%%%%%%%%%%%%%%%%%%%%%%
        for i=1:11
            locat=mean(single_norm{j},2)+.1;
            [h p1{j}(i)]=ttest(single_norm{j}(i,:)-single_norm{j}(12,:));
            if(p1{j}(i)<0.001)
                text(i, locat(i), '***');
            elseif(p1{j}(i)<0.01)
                text(i, locat(i), '**');
            elseif(p1{j}(i)<0.05)
                text(i, locat(i), '*');
            end
        end

        set(gca,'XTick',1:12,'XTickLabel',X);
        set(gca,'Box','off','TickDir','out');
        ylim([-0.2 1.3]);
        set(gca,'Box','off','TickDir','out','FontSize',12);
    end
    saveas(gcf,[folder_save mat_file_names{mat_file_idx*2-1}(1:10) '_Normlized_meanWBA']);


    %%
    cd ../


    clear;
    close all;

   folder_data='/Volumes/nisl/hyosun/1.Noise_Experiment/V11_new/matFiles';
   folder_save='results_v3/';
    cd(folder_data);
    file_list=search_for_mat(folder_data);
    for i=1:length(file_list)
        mat_file_names{1,i}=file_list(i).name;
    end

end



