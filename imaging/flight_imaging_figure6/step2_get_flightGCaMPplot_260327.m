%step2-- flight state imaging in LPLC2
%260327 -- hyosun

clear;
folder_data='/Users/hyosunkim/1_Analyze_data/noise/2photon/flight/new';
folder_save='results/';

PATNAMES={'Loom_R_8p_noise_0'...
    'Loom_L_8p_noise_0'...
    'Loom_R_8p_noise_10'...
    'Loom_L_8p_noise_10'...
    'Loom_R_8p_noise_20'...
    'Loom_R_8p_noise_30'...
    'Loom_R_8p_noise_40'...
    'Loom_R_8p_noise_50'...
    'Loom_R_8p_noise_60'...
    'Loom_R_8p_noise_70'...
    'noise_100'};

file_list=search_for_mat(folder_data);
for i=1:length(file_list)
    mat_file_names{1,i}=file_list(i).name;
end

for mat_file_idx=1:size(file_list,1)
    load(mat_file_names{mat_file_idx});
    
    % classify the flight/non-flight states
    for p=1:size(analysedData,2)
        t{p}=analysedData{1,p};
        for trials=1:size(analysedData{2,p},1)
            flightGcamp{mat_file_idx,p}=analysedData{2,p}(metaData.flying_pat_tr{p}',:);
            nonFlightGcamp{mat_file_idx,p}=analysedData{2,p}(metaData.nonflying_pat_tr{p}',:);
        end
    end
end

%%
for p=1:size(analysedData,2)
    % set index
    baseline_idx=(t{1}>1.3 & t{1}<1.5);
    response_idx=(t{1}>1.65 & t{1}<=1.85);

    for n=1:size(flightGcamp,1)
        %analyze flight gcamp response
        for trials=1:size(flightGcamp{n,p},1)
            based_flight_gcamp{n,p}(trials,:)=flightGcamp{n,p}(trials,:)-mean(flightGcamp{n,p}(trials,baseline_idx),2);
            %%%%%%%%% delf/f %%%%%%%%%
            del_gcamp_flight{n,p}(trials,:)=based_flight_gcamp{n,p}(trials,:)/abs(mean(flightGcamp{n,p}(trials,baseline_idx)));
            mean_del_gcamp_flight{n,p}(trials)=mean(del_gcamp_flight{n,p}(trials,response_idx));

        end
        for trials=1:size(nonFlightGcamp{n,p},1)
            based_nonFlight_gcamp{n,p}(trials,:)=nonFlightGcamp{n,p}(trials,:)-mean(nonFlightGcamp{n,p}(trials,baseline_idx),2);
            del_gcamp_nonflight{n,p}(trials,:)=based_nonFlight_gcamp{n,p}(trials,:)/abs(mean(nonFlightGcamp{n,p}(trials,baseline_idx)));
            mean_del_gcamp_nonflight{n,p}(trials)=mean(del_gcamp_nonflight{n,p}(trials,response_idx));
        end
        mean_dgcamp_flight{p}(n,:)=mean(del_gcamp_flight{n,p},1);
        mean_dgcamp_nonflight{p}(n,:)=mean(del_gcamp_nonflight{n,p},1);
        amplitude_flight(n,p)=mean(mean_dgcamp_flight{p}(n,response_idx));
        amplitude_non_flight(n,p)=mean(mean_dgcamp_nonflight{p}(n,response_idx));
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% normalized avg amplitude %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for n=1:size(flightGcamp,1)
    max_gcamp_flight = max(mean(amplitude_flight(:,[1,3,5:11])));
    min_gcamp_flight = min(mean(amplitude_flight(:,[1,3,5:11])));
    max_gcamp_nonFlight = max(mean(amplitude_non_flight(:,[1,3,5:11])));
    min_gcamp_nonFlight = min(mean(amplitude_non_flight(:,[1,3,5:11])));
    single_norm_flight(n,1:9) = mean(amplitude_flight(n,[1,3,5:11]))/ max_gcamp_flight ;
    single_norm_nonFlight(n,1:9) = mean(amplitude_non_flight(n,[1,3,5:11]))/ max_gcamp_nonFlight ;
    norm_flight = mean(amplitude_flight(:,[1,3,5:11]))/max_gcamp_flight;
    norm_nonFlight = mean(amplitude_non_flight(:,[1,3,5:11]))/max_gcamp_nonFlight;

    single_norm_flight2(n,1:9) = (mean(amplitude_flight(n,[1,3,5:11]))-min_gcamp_flight) / (max_gcamp_flight - min_gcamp_flight) ;
    single_norm_nonFlight2(n,1:9) = (mean(amplitude_non_flight(n,[1,3,5:11]))-min_gcamp_nonFlight) / (max_gcamp_nonFlight -min_gcamp_nonFlight) ;
    norm_flight2 = (mean(amplitude_flight(:,[1,3,5:11]))-min_gcamp_flight) / (max_gcamp_flight-min_gcamp_flight);
    norm_nonFlight2 = (mean(amplitude_non_flight(:,[1,3,5:11]))-min_gcamp_nonFlight) /(max_gcamp_nonFlight - min_gcamp_nonFlight);
end

%% plot mean traces per flies
figure;set(gcf,'Color','w');
pat=[1,3,5:11]
xtick={'0','10','20','30','40','50','60','70','100'};

for n=1:size(flightGcamp,1)
    subplot(3,4,n);hold on;
    for p=1:size(pat,2)
        text(p,amplitude_non_flight(n,pat(p))-.1,num2str(size(del_gcamp_nonflight{n,pat(p)},1)),'Color','b');hold on;
        text(p,amplitude_flight(n,pat(p))+.1,num2str(size(del_gcamp_flight{n,pat(p)},1)),'Color','r');
        std_non_flight(p)=std(mean_del_gcamp_nonflight{n,pat(p)});
        std_flight(p)=std(mean_del_gcamp_flight{n,pat(p)});
    end

    errorbar(1:9,amplitude_non_flight(n,pat),std_non_flight/sqrt(size(flightGcamp,1))*1.96, 'Color',ones(1,3)*0.8);
    errorbar(1:9,amplitude_flight(n,pat),std_flight/sqrt(size(flightGcamp,1))*1.96, 'Color',ones(1,3)*0.8);

    %non-flight response 
    plot(1:9,amplitude_non_flight(n,pat),'Marker','.','MarkerSize',20,'Color','b');
    %flight response
    plot((1:9)+.2,amplitude_flight(n,pat),'Marker','.','MarkerSize',20,'Color','r');
    title([num2str(n) 'th fly']);
    ylim([-.2 1.3]);
    set(gca,'Box','off','TickDir','out','FontSize',12);
    xticks(1:9); xticklabels(xtick);
    
end
    ylabel('mean delF'); xlabel('noise (%)');


%% plot mean traces -- Figure 6C,6F
figure; set(gcf,'Color','w');

cm=colormap(turbo(11));
subplot(1,2,1);
rectangle('Position',[1.5 -.1 0.2 .7 ],'FaceColor',[0.8 0.8 0.8],'EdgeColor',[0.8 0.8 0.8]);hold all;
subplot(1,2,2);
rectangle('Position',[1.5 -.1 0.2 .7 ],'FaceColor',[0.8 0.8 0.8],'EdgeColor',[0.8 0.8 0.8]);hold all;
for p=1:size(pat,2)
    subplot(1,2,1); title('non-Flight');
    plot(t{1},mean(mean_dgcamp_nonflight{pat(p)},1),'color',cm(p,:));
    xlim([1.2 4]);
    set(gca,'Box','off','TickDir','out','FontSize',12);
    ylabel('delF/F'); xlabel('time (s)');

    subplot(1,2,2); title('Flight');
    plot(t{1},mean(mean_dgcamp_flight{pat(p)},1),'color',cm(p,:));
    xlim([1.2 4]);
    set(gca,'Box','off','TickDir','out','FontSize',12);
    ylabel('delF/F'); xlabel('time (s)');
    legend(xtick,'Box','off');
end

%% plot mean amplitude / normalized mean amplitude -- Figure 6E,6H
figure; set(gcf,'Color','w');

subplot(1,2,1); hold all;
%non-flight response
errorbar(1:9,mean(amplitude_non_flight(:,pat)), std(amplitude_non_flight(:,[1,3,5:11]),1)/sqrt(size(nonFlightGcamp{n,p},1))*1.96,'Color',ones(1,3)*0.8);
plot(1:9,mean(amplitude_non_flight(:,pat)),'Marker','.','MarkerSize',20);
%flight response
errorbar((1:9)+.2,mean(amplitude_flight(:,pat)), std(amplitude_flight(:,[1,3,5:11]),1)/sqrt(size(flightGcamp{n,p},1))*1.96,'Color',ones(1,3)*0.8);
plot((1:9)+.2,mean(amplitude_flight(:,pat)),'Marker','.','MarkerSize',20);

set(gca,'Box','off','TickDir','out','FontSize',12);
ylabel('mean delF'); xlabel('noise (%)');
xticks(1:9); xticklabels(xtick); 


%%%%%%%%%%%%%%% ttest %%%%%%%%%%%%%%%%%%%%%%%
for k=1:8
    locat=mean(amplitude_flight(:,pat(k)))+.05;
    [h p1(k)]=ttest(amplitude_non_flight(:,pat(k)),amplitude_flight(:,pat(k)));
    text(k,locat,num2str(p1(k)),'Color','k');
end

subplot(1,2,2); hold all;

%non-flight response
errorbar(norm_nonFlight, std(single_norm_nonFlight(:,1:9),1)/sqrt(size(nonFlightGcamp{n,p},1))*1.96,'Color',ones(1,3)*0.8);
plot(norm_nonFlight,'Marker','.','MarkerSize',20);
%flight response
errorbar((1:9)+.2,norm_flight, std(single_norm_flight(:,1:9),1)/sqrt(size(flightGcamp{n,p},1))*1.96,'Color',ones(1,3)*0.8);
plot((1:9)+.2,norm_flight,'Marker','.','MarkerSize',20);

set(gca,'Box','off','TickDir','out','FontSize',12);
ylabel('Normalized mean delF'); xlabel('noise (%)');
xticks(1:9); xticklabels(xtick); 

legend('','nonFlght','','Flight','Box','off');


%% Bar plot of mean amplitude -- Figure 6D,6G
figure; set(gcf,'Color','w');
hold on;
bar(1:9,[mean(amplitude_non_flight(:,pat));mean(amplitude_flight(:,pat))]);
errorbar([(1:9)-.13; (1:9)+.13],[mean(amplitude_non_flight(:,pat));mean(amplitude_flight(:,pat))], [std(amplitude_non_flight(:,[1,3,5:11]),1)/sqrt(size(nonFlightGcamp{n,p},1))*1.96 ;  std(amplitude_flight(:,[1,3,5:11]),1)/sqrt(size(flightGcamp{n,p},1))*1.96],'Color',ones(1,3)*0.8,'LineStyle','none');

% plot dot
for n=1:size(flightGcamp,1)
    for p=1:size(pat,2)
        h= plot([(p-.13);(p+.13)],[amplitude_non_flight(n,pat(p));amplitude_flight(n,pat(p))],'-o');hold on;
        h.MarkerFaceColor = h.Color;
    end
end

% scatter((1:9)-.13,amplitude_non_flight(:,pat),'k','filled','SizeData',30);
% scatter((1:9)+.13,amplitude_flight(:,pat),'r','filled','SizeData',30);
set(gca,'Box','off','TickDir','out','FontSize',12);
ylabel('mean delF'); xlabel('noise (%)');
xticks(1:9); xticklabels(xtick);