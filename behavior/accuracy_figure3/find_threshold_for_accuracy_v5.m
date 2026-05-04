% find threshold for accuracy
clear;
pattern_name=["bar 0%" "bar 10%" "bar 20%" "bar 30%" "bar 40%"...
    "bar 50%" "bar 60%" "bar 70%" "spot up 0%" "spot up 10%"...
    "spot up 20%" "spot up 30%" "spot up 40%" "spot up 50%" "spot up 60%"...
    "spot up 70%" "looming 0%" "looming 10%" "looming 20%" "looming 30%" "looming 40%"...
    "looming 50%" "looming 60%" "looming 70%" "grating 0%" "grating 10%"...
    "grating 20%" "grating 30%" "grating 40%" "grating 50%" "grating 60%"...
    "grating 70%" "noise 100%"];

j=1;
figure(1);set(gcf,'Color','w','DefaultAxesColorOrder','remove');
figure(2);set(gcf,'Color','w','DefaultAxesColorOrder','remove');

% load analyzed mat flies from "step2_get_single_WBA.m"
load("quantified_peak_wba_HCSxTNT_.mat");

%% get wba data of trials from single flies
peak_single_fly=vertcat(mean_peak{1}(1:8,:),-mean_peak{2}(1:8,:),-mean_peak{3}(1:8,:),mean_peak{4}(1:8,:));

% get noise 100 trials
for n=1:size(mean_single_peak,2)
    i=1;
    for trial = 1:size(mean_single_peak{1,n},2)
        if not(mean_single_peak{1,n}(9,trial)==0)
            noise100{1,n}(i)=mean_single_peak{1,n}(9,trial); %for barspot patterns
            noise100{2,n}(i)=mean_single_peak{3,n}(9,trial); %for loomgrating patterns
            i=i+1;
        end
    end
end

%%
% For bar spot patterns
figure(1); 
for n=1:size(mean_single_peak,2)
    subplot(5,9,n);
    bins_bs=min(noise100{1,n}):max(noise100{1,n});
    histogram(noise100{1,n},length(bins_bs),'Normalization','pdf');hold on;

    % calculate the average and std
    mu_noise_bs(n) = mean(noise100{1,n});
    sigma_noise_bs(n) = std(noise100{1,n});

    % Two-tailed threshold (mu +- 2*sigma) for N-th flies
    upper_th_bs(n) = mu_noise_bs(n) + 2*sigma_noise_bs(n);
    lower_th_bs(n) = mu_noise_bs(n) - 2*sigma_noise_bs(n);

    rectangle('Position',[upper_th_bs(n) 0 0 0.2],'EdgeColor','b');
    rectangle('Position',[lower_th_bs(n) 0 0 0.2],'EdgeColor','b');
    set(gca,'Box','off','TickDir','out');
    title(['The threshold ' num2str(upper_th_bs(n)) ' and ' ...
        num2str(lower_th_bs(n))]);
end

% For loom grating patterns
figure(2); 
for n=1:size(mean_single_peak,2)
    subplot(5,9,n);
    bins_lg=min(noise100{2,n}):max(noise100{2,n});
    histogram(noise100{2,n},length(bins_lg),'Normalization','pdf');hold on;

    % calculate the average and std
    mu_noise_lg(n) = mean(noise100{2,n});
    sigma_noise_lg(n) = std(noise100{2,n});

    % Two-tailed threshold (mu +- 2*sigma) for N-th flies
    upper_th_lg(n) = mu_noise_lg(n) + 2*sigma_noise_lg(n);
    lower_th_lg(n) = mu_noise_lg(n) - 2*sigma_noise_lg(n);

    rectangle('Position',[upper_th_lg(n) 0 0 0.2],'EdgeColor','b');
    rectangle('Position',[lower_th_lg(n) 0 0 0.2],'EdgeColor','b');
    set(gca,'Box','off','TickDir','out');
    title(['The threshold ' num2str(upper_th_lg(n)) ' and ' ...
        num2str(lower_th_lg(n))]);
end


%% accuracy -- Figure3C
figure(3);clf;set(gcf,'Color','w');
pat_grp_idx={[1:8], [9:16], [17:24], [25:32]};

for p=1:size(peak_single_fly,1)
    for n=1:size(peak_single_fly,2)
        if sum(ismember(1:8,p))==1 && peak_single_fly(p,n) > upper_th_bs(n)  %bar
            accuracy(p,n)=1;
        elseif sum(ismember(9:16,p))==1 && peak_single_fly(p,n) < lower_th_bs(n) %spot
            accuracy(p,n)=1;
        elseif sum(ismember(17:24,p))==1 && peak_single_fly(p,n) < lower_th_lg(n) %loom
            accuracy(p,n)=1;
        elseif sum(ismember(25:32,p))==1 && peak_single_fly(p,n) > upper_th_lg(n) %grating
            accuracy(p,n)=1;
        else
            accuracy(p,n)=0;
        end
    end
end

tit={'bar','spot','loom','grating'};
c='bmrg';
for pat=1:4
    subplot(1,4,pat);
    errorbar((1:8)+0.1,mean(accuracy(pat_grp_idx{pat},:),2),...
        1.96*std(accuracy(pat_grp_idx{pat},:),[],2)/sqrt(size(accuracy,2)),'Color',[.7, .7, .7]); hold all;
    plot((1:8)+0.1,mean(accuracy(pat_grp_idx{pat},:),2),'Color',c(pat),'Marker','o','MarkerFaceColor',c(pat));
    title(tit{pat});
    set(gca,'Box','off','Tickdir','out');
    xticks([1:8]); ylim([-0.2 1.2])
    set(gca,'XTickLabel',{0,10,20,30,40,50,60,70});
    xlabel('noise level');
    ylabel('accuracy');
end

save('threshold', 'threshold');


