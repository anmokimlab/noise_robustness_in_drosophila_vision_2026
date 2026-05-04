clear;

folder_save='result_v5/';

cell_type='DNp06(ss01047)';
% cell_type='HS(81G07)';

files=dir('*.mat');
for file_idx=1:length(files)-1
    load(files(file_idx).name,'seg_idx','mean_Vm_tr','dt','PATNAMES');
    mean_Vm_tr_all(file_idx,:)=mean_Vm_tr;
end

%% plot Vm sample traces ---- Figure 5C

t=seg_idx{1}*dt;

response_idx=find(t>1.58 & t<=1.7 ); %Dnp06
patname={'Bar','Loom','SpotUp'}; pat_num=3;
PATID=[7:24,25:28,29:2:40,41,42,43:2:54,55:64,73,74];


PATDUR=3*ones(size(PATID));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% index for response peak %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
baseline_idx=find(t>=1.3 & t<1.5); %2000ms/300ms
response_idx_lat=find(t>1.5 & t<=1.7);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

based_tr=cell(pat_num,19);

for f=1:pat_num
    
    if f==1
        sgtitle([patname{f} ' ' cell_type ' cell FlickRandomNoise ' ]); hold on;
        p=1:18;
        patnum(f)=size(p,2)+1;
    elseif f==2
        sgtitle([patname{f} ' ' cell_type ' cell FlickRandomNoise ' ]); hold on;
        % p=19:36; For DNP06
        p=19:36;
        patnum(f)=size(p,2)+1;
    else
        sgtitle([patname{f} ' ' cell_type ' cell FlickRandomNoise ' ]);hold on;
        p=37:48;
        patnum(f)=size(p,2);
    end
    figure(f);clf;
    for i=p  %17
        cm=repmat(linspace(0.2, 0.7, size(Vm_tr{i,:},1))', 1, 3);
        cm=cm(randperm(end),:);
        set(gcf,'Color','w','defaultAxesColorOrder',cm)
        haxes(i)=subplot(3,6,i-18*(f-1));  %3,6
        tr_single=cell2mat(Vm_tr(i,:))-1300;
        tr=cell2mat(mean_Vm_tr(:,i))-1300;
        rectangle('Position',[1.5 -7000 0.2 2500 ],'FaceColor',[0.8 0.8 0.8],'EdgeColor',[0.8 0.8 0.8]);hold on;
        % mean_tr=mean(tr,1);
        % based_tr{f,i-18*(f-1)}=tr-mean(tr(:,baseline_idx),2);
        % based_tr{f,i-18*(f-1)}=based_tr{f,i-18*(f-1)}+mean(mean_tr(:,baseline_idx),2);

        for trials=1:size(Vm_tr{i,:},1)
            subplot(3,6,i-18*(f-1)); plot(t,tr_single(trials,:),'Color',cm(trials,:));
        end
        plot(t,tr,'r','LineWidth',1.5);
        axis tight;
        title(PATNAMES{PATID(i)});
        
        xlim([1.3 1.8]);
        set(gca,'Box','off','TickDir','out');
    end
   
    % savefig(gcf,[folder_save patname{f} '_' cell_type '_cell FlickRandomNoise_' num2str(size(mean_Vm_tr_all,1)) '_avgTraces']);

end



%% plot Vm traces -- Figure 5D,F
%for DNP06 bar = (1:18) %loom = (19:36)  spot= (37:48)

cm=repmat(linspace(0.2, 0.7, size(mean_Vm_tr_all,1))', 1, 3);
cm=cm(randperm(end),:);
t=seg_idx{1}*dt;
if convertCharsToStrings(cell_type) == "HS(81G07)"
    response_idx=find(t>1.5 & t<=1.62 );
    patname={'Bar','Grating'}; pat_num=2;
    PATID=[7:24,25:43];
else
    response_idx=find(t>1.58 & t<=1.7 ); %Dnp06
    patname={'Bar','Loom','SpotUp'}; pat_num=3;
    PATID=[7:24,25:28,29:2:40,41,42,43:2:54,55:64,73,74];
end
PATDUR=3*ones(size(PATID));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% index for response peak %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
baseline_idx=find(t>=1.3 & t<1.5); %2000ms/300ms
response_idx_lat=find(t>1.5 & t<=1.7);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
based_tr=cell(pat_num,19);
for f=1:pat_num
    figure(f);clf;set(gcf,'Color','w','defaultAxesColorOrder',cm)
    if f==1
        sgtitle([patname{f} ' ' cell_type ' cell FlickRandomNoise ' num2str(size(mean_Vm_tr_all,1))]); hold on;
        p=1:18;
        patnum(f)=size(p,2)+1;
    elseif f==2
        sgtitle([patname{f} ' ' cell_type ' cell FlickRandomNoise ' num2str(size(mean_Vm_tr_all,1))]); hold on;
        % p=19:36; For DNP06
        p=19:36;
        patnum(f)=size(p,2)+1;
    else
        sgtitle([patname{f} ' ' cell_type ' cell FlickRandomNoise ' num2str(size(mean_Vm_tr_all,1))]);hold on;
        p=37:48;
        patnum(f)=size(p,2);
    end

    for i=p  %17
        haxes(i)=subplot(3,6,i-18*(f-1));  %3,6
        tr=cell2mat(mean_Vm_tr_all(:,i))-1300;
        rectangle('Position',[1.5 -7000 0.2 2500 ],'FaceColor',[0.8 0.8 0.8],'EdgeColor',[0.8 0.8 0.8]);hold on;
        mean_tr=mean(tr,1);
        based_tr{f,i-18*(f-1)}=tr-mean(tr(:,baseline_idx),2);
        based_tr{f,i-18*(f-1)}=based_tr{f,i-18*(f-1)}+mean(mean_tr(:,baseline_idx),2);

        for n=1:size(mean_Vm_tr_all,1)
            subplot(3,6,i-18*(f-1)); plot(t,based_tr{f,i-18*(f-1)}(n,:),'Color',cm(n,:));
        end
        plot(t,mean(based_tr{f,i-18*(f-1)},1),'r','LineWidth',1.5);
        axis tight;
        title(PATNAMES{PATID(i)});
        
        xlim([1.3 1.8]);
        set(gca,'Box','off','TickDir','out');
    end
    if convertCharsToStrings(cell_type) == "HS(81G07)"
        tr=cell2mat(mean_Vm_tr_all(:,37));
        mean_tr=mean(tr,1);
        based_tr{2,19}=tr-mean(tr(:,baseline_idx),2);
        based_tr{2,19}=based_tr{2,19}+mean(mean_tr(:,baseline_idx),2);
        based_tr{1,19}=based_tr{2,19};
    end

    if f==3
        based_tr{1,size(based_tr,2)}=based_tr{3,size(p,2)};
        based_tr{2,size(based_tr,2)}=based_tr{3,size(p,2)};
    end
    savefig(gcf,[folder_save patname{f} '_' cell_type '_cell FlickRandomNoise_' num2str(size(mean_Vm_tr_all,1)) '_avgTraces']);

end

%% Calculate mean amplitude of membrane potential

pat={[1,3,5:10,19],[1,11,13:18,19],[1,3,5:10,12]};

for f=1:pat_num %2/3
    for pattern_idx=1:patnum(f)
        for n=1:size(mean_Vm_tr_all,1) %number of flies
            based_Vm{f,pattern_idx}(n,:)=based_tr{f,pattern_idx}(n,:)-mean(based_tr{f,pattern_idx}(n,baseline_idx),2);
            amplitude{f,n}(pattern_idx)=mean(based_Vm{f,pattern_idx}(n,response_idx),2)*10^-2;
        end
    end

    for pattern_idx=1:patnum(f)
        for n=1:size(mean_Vm_tr_all,1)
            amplitude2{f,pattern_idx}(n)=amplitude{f,n}(pattern_idx);
            mean_amplitude(f,pattern_idx)=mean(amplitude2{f,pattern_idx},'omitnan');
            sem(f,pattern_idx)=std(amplitude2{f,pattern_idx},0,2)/sqrt(size(amplitude,2))*1.96;
        end
    end

    % normalize the response to min / max 
    for n=1:size(mean_Vm_tr_all,1)
        if f==1 || f==2
            mean_min_flick{f} = min(mean_amplitude(f,pat{1}));
            mean_min_rand{f} = min(mean_amplitude(f,pat{2}));
            mean_max_flick{f} = max(mean_amplitude(f,pat{1}));
            mean_max_rand{f} = max(mean_amplitude(f,pat{2}));

            mean_norm(f,1:9) = (mean_amplitude(f,pat{1}) - mean_min_flick{f}) / (mean_max_flick{f} - mean_min_flick{f});
            mean_norm(f,10:18) = (mean_amplitude(f,pat{2}) - mean_min_rand{f}) / (mean_max_rand{f} - mean_min_rand{f});

            single_norm{f}(n,1:9) = (amplitude{f,n}(pat{1}) - mean_min_flick{f}) / (mean_max_flick{f} - mean_min_flick{f});
            single_norm{f}(n,10:18) = (amplitude{f,n}(pat{2}) - mean_min_rand{f}) / (mean_max_rand{f} - mean_min_rand{f});
        
        else
            mean_min_flick{f} = min(mean_amplitude(f,pat{3}));
            mean_max_flick{f} = max(mean_amplitude(f,pat{3}));
            mean_norm(f,1:9) = (mean_amplitude(f,pat{3}) - mean_min_flick{f}) / (mean_max_flick{f} - mean_min_flick{f});
            single_norm{f}(n,1:9) = (amplitude{f,n}(pat{3}) - mean_min_flick{f}) / (mean_max_flick{f} - mean_min_flick{f});
        end
    end
end

%% plot peak potential
%bar = (1:18) %loom = (19:36)
figure(4);clf;set(gcf,'Color','w','defaultAxesColorOrder',cm);
sgtitle([cell_type ' cell amplitude (n=' num2str(size(mean_Vm_tr_all,1)) ')']);hold on;

for f=1:pat_num
    subplot(1,3,f);
    title(patname{f});hold on;
    if f==1 || f==2
        errorbar((1:9)-.15, mean_amplitude(f,pat{1}), sem(f,pat{1}), 'Color',ones(1,3)*0.8); hold on;
        plot((1:9)-.15,mean_amplitude(f,pat{1}),'Color','b','Marker','o','MarkerFaceColor','b');

        errorbar((1:9), mean_amplitude(f,pat{2}), sem(f,pat{2}), 'Color',ones(1,3)*0.8);
        plot((1:9),mean_amplitude(f,pat{2}),'Color','r','Marker','o','MarkerFaceColor','r');

        %%%%%% compare flick and Random %%%%%%%
        for k=2:8
            locat=mean_amplitude(f,pat{1}(k))-2;
            [h p(k)]=ttest(amplitude2{f,pat{1}(k)},amplitude2{f,pat{2}(k)});
            if (p(k)<0.001)
                text(k-0.1,locat+0.05,'***');
            elseif (p(k)<0.01)
                text(k-0.1,locat+0.05,'**');
            elseif p(k)<0.05
                text(k-0.1,locat+0.05,'*');
            end
            text(k-0.35,locat,num2str(p(k)));
        end
        %%%%%% compare with noise 100 %%%%%%%
        for k=1:8
            locat=mean_amplitude(f,pat{1}(k))+2;
            [h p1(k)]=ttest(amplitude2{f,pat{1}(end)},amplitude2{f,pat{1}(k)});
            if (p1(k)<0.001)
                text(k-0.1,locat+.15,'***','Color','b');
            elseif (p1(k)<0.01)
                text(k-0.1,locat+.15,'**','Color','b');
            elseif p1(k)<0.05
                text(k-0.1,locat+.15,'*','Color','b');
            end
            text(k-0.35,locat,num2str(p1(k)),'Color','b');

            locat=mean_amplitude(f,pat{2}(k))+7;
            [h p2(k)]=ttest(amplitude2{f,pat{2}(end)},amplitude2{f,pat{2}(k)});
            if (p2(k)<0.001)
                text(k-0.1,locat,'***','Color','r');
            elseif (p2(k)<0.01)
                text(k-0.1,locat,'**','Color','r');
            elseif p2(k)<0.05
                text(k-0.1,locat,'*','Color','r');
            end
            text(k+0.35,locat+.5,num2str(p2(k)),'Color','r');

        end

    else
        errorbar((1:9)+.15, mean_amplitude(f,pat{3}), sem(f,pat{3}), 'Color',ones(1,3)*0.8);
        plot((1:9)+.15,mean_amplitude(f,pat{3}),'Color','b','Marker','o','MarkerFaceColor','b');
        %%%%%% compare with noise 100 %%%%%%%
        for k=1:8
            locat=mean_amplitude(f,pat{3}(k))+5;
            [h p1(k)]=ttest(amplitude2{f,pat{3}(end)},amplitude2{f,pat{3}(k)});
            if (p1(k)<0.001)
                text(k-0.1,locat+.15,'***','Color','b');
            elseif (p1(k)<0.01)
                text(k-0.1,locat+.15,'**','Color','b');
            elseif p1(k)<0.05
                text(k-0.1,locat+.15,'*','Color','b');
            end
            text(k-0.35,locat,num2str(p1(k)),'Color','b');
        end

    end

    ylabel('del V'); xlabel('noise (%)')
    ylim([-4 13]);

    set(gca,'Box','off','TickDir','out');
    xticks([1:9]);
    set(gca,'XTickLabel',{0,10,20,30,40,50,60,70,100});
end

savefig(gcf,[folder_save cell_type '_cell amplitude_(n=' num2str(size(mean_Vm_tr_all,1)) ')']);

%% Plot normalized peak potential -- Figure 5D

figure(4);clf;set(gcf,'Color','w','defaultAxesColorOrder',cm);
sgtitle([cell_type ' cell normalized amplitude (n=' num2str(size(mean_Vm_tr_all,1)) ')']);hold on;

for f=1:pat_num 
    for pattern_idx=1:size(single_norm{f},2)
        for n=1:size(mean_Vm_tr_all,1)
            sem_norm(f,pattern_idx)=std(single_norm{f}(:,pattern_idx),0,1)/sqrt(size(amplitude,2))*1.96;
        end
    end
    subplot(1,3,f);title(patname{f});hold on;

    if f==1 || f==2
        errorbar((1:9)-.15, mean(single_norm{f}(:,1:9),1), sem_norm(f,1:9), 'k','LineStyle','none');
        errorbar((1:9), mean(single_norm{f}(:,10:18),1), sem_norm(f,10:18), 'k','LineStyle','none');
        plot((1:9)-.15,mean(single_norm{f}(:,1:9),1),'b','Marker','o','MarkerFaceColor','b');hold on; 
        plot((1:9),mean(single_norm{f}(:,10:18),1),'r','Marker','o','MarkerFaceColor','r');
    else
        errorbar((1:9)-.15, mean(single_norm{f}(:,1:9),1),sem_norm(f,1:9), 'k','LineStyle','none');
        plot((1:9)-.15,mean(single_norm{f}(:,1:9),1),'b','Marker','o','MarkerFaceColor','b');
    end

    %%%%%% compare flick and Random %%%%%%%
    if f==1 || f==2
        for k=2:8
            locat=mean(single_norm{f}(:,k))-0.25;
            [h p(k)]=ttest(single_norm{f}(:,k+9),single_norm{f}(:,k));
            if (p(k)<0.001)
                text(k-0.1,locat+0.05,'***');
            elseif (p(k)<0.01)
                text(k-0.1,locat+0.05,'**');
            elseif p(k)<0.05
                text(k-0.1,locat+0.05,'*');
            end
            text(k-0.35,locat,num2str(p(k)));
        end
        %%%%%%%%compare with noise 100 vs Randmotion %%%%%%%%%%%
        for k=10:17
            locat=mean(single_norm{f}(:,k))+0.3;
            [h p3{f,k}]=ttest(single_norm{f}(:,18),single_norm{f}(:,k));
            if (p3{f,k}<0.001)
                text(k-9.1,locat,'***','Color','r');
            elseif (p3{f,k}<0.01)
                text(k-9.1,locat,'**','Color','r');
            elseif p3{f,k}<0.05
                text(k-9.1,locat,'*','Color','r');
            end
            text(k-9.1,locat,num2str(p3{f,k}),'Color','r');
        end
    end
    %%%%%% compare with noise 100 %%%%%%%
    for k=1:8
        locat=mean(single_norm{f}(:,k))+0.5;
        if f==1 || f==2
            [h p3{f,k}]=ttest(single_norm{f}(:,f*9),single_norm{f}(:,k));
        else
            [h p3{f,k}]=ttest(single_norm{f}(:,9),single_norm{f}(:,k));
        end
        if (p3{f,k}<0.001)
            text(k-0.1,locat-.15,'***','Color','b');
        elseif (p3{f,k}<0.01)
            text(k-0.1,locat-.15,'**','Color','b');
        elseif p3{f,k}<0.05
            text(k-0.1,locat-.15,'*','Color','b');
        end
        text(k-0.35,locat,num2str(p3{f,k}),'Color','b');

    end

    ylabel('del V'); xlabel('Noise level(%)')

    set(gca,'Box','off','TickDir','out');
    ylim([-0.4 1.8]);
    set(gca,'XTick',[1:9]);
    set(gca,'XTickLabel',{0,10,20,30,40,50,60,70,100});    % axes(haxes(end));

end
savefig(gcf,[folder_save cell_type '_cell normalized amplitude_(n=' num2str(size(mean_Vm_tr_all,1)) ')']);


%% Latency
pat={[1,3,5:10,19],[1,11,13:18,19],[1,3,5:10,12]};
response_idx_lat=find(t>1.5 & t<=1.7);
% response_idx2=(seg_idx{pat_idx}>1.5*10^4 & seg_idx{pat_idx}<=PATDUR(pat_idx)*10^4)
for f=1:pat_num
    for p=1:size(based_Vm,2)
        for n=1:size(based_Vm{f,p},1)
            [peak(n,p) peak_idx(n,p)]=max(based_Vm{f,p}(n,response_idx_lat));
            if isempty(find(based_Vm{f,p}(n,response_idx_lat)>= peak(n,p)*0.5,1))
                half_peak_idx{f}(n,p)=response_idx_lat(end);
            else
                half_peak_idx{f}(n,p)=find(based_Vm{f,p}(n,response_idx_lat)>= peak(n,p)*0.5,1)+response_idx_lat(1);
            end
        end
    end

    for p=1:9
        for n=1:size(based_Vm{f,p},1)
            if f==3
                latency{f}(n,1:9)=seg_idx{1}(1,half_peak_idx{f}(n,pat{3}))/10^4;
            else
                latency{f}(n,1:9)=seg_idx{1}(1,half_peak_idx{f}(n,pat{1}))/10^4;
                latency{f}(n,10:18)=seg_idx{1}(1,half_peak_idx{f}(n,pat{2}))/10^4;
            end
        end
    end
    mean_latency{f}=mean(latency{f},1,"omitnan");
end


%% Plot Latency
%%%%HS cell
% pat={[1,3,5:10,37],[1,11,13:18,37],[19,21,23:28,37],[19,29,31:37]};
%%%%%DNp06
% pat={[1,3,5:10,48],[1,11,13:18,48],[19,21,23:28,48],[19,29,31:36,48]};

figure(5);clf;set(gcf,'Color','w','defaultAxesColorOrder',cm);
sgtitle([cell_type ' cell latency (n=' num2str(size(mean_Vm_tr_all,1)) ')']);hold on;

for f=1:pat_num
    subplot(1,3,f);title(patname{f});hold on;

    if f==1 || f==2
        errorbar((1:9)-.15, mean_latency{f}(:,1:9), std(latency{f}(:,1:9),0,1)/sqrt(size(latency{f},1))*1.96, 'k','LineStyle','none');
        errorbar((1:9), mean_latency{f}(:,10:18), std(latency{f}(:,10:18),0,1)/sqrt(size(latency{f},1))*1.96, 'k','LineStyle','none');
        plot((1:9)-.15, mean_latency{f}(:,1:9),'b','Marker','o','MarkerFaceColor','b'); plot((1:9),mean_latency{f}(:,10:18),'r','Marker','o','MarkerFaceColor','r');
        %%%%%%%%%%compare with noise 0 random motion %%%%%%%%%%
        for k=11:18
            locat=mean_latency{f}(k)+.01;
            [h p5(k)]=ttest(latency{f}(:,10),latency{f}(:,k));
            if (p5(k)<0.001)
                text(k-10.1,locat,'***','Color','r');
            elseif (p5(k)<0.01)
                text(k-10.1,locat,'**','Color','r');
            elseif p5(k)<0.05
                text(k-10.1,locat,'*','Color','r');
            end
            text(k-10.35,locat+.05,num2str(p5(k)),'Color','r');
        end
    else
        errorbar((1:9)-.15, mean_latency{f}(:,1:9), std(latency{f}(:,1:9),0,1)/sqrt(size(latency{f},1))*1.96, 'k','LineStyle','none');
        plot((1:9)-.15, mean_latency{f}(:,1:9),'b','Marker','o','MarkerFaceColor','b');
    end

    %%%%%% compare with noise 0 %%%%%%%
    for k=2:9
        locat=mean_latency{f}(:,k)+.03;
        [h p4(k)]=ttest(latency{f}(:,1),latency{f}(:,k));
        if (p4(k)<0.001)
            text(k-0.1,locat+.015,'***','Color','b');
        elseif (p4(k)<0.01)
            text(k-0.1,locat+.015,'**','Color','b');
        elseif p4(k)<0.05
            text(k-0.1,locat+.015,'*','Color','b');
        end
        text(k-0.35,locat,num2str(p4(k)),'Color','b');

    end

    ylabel('Latency (s)');

    set(gca,'Box','off','TickDir','out')%,'YLim',[-0.05 0.6]);
    % set(gca,'XTickLabel',[]);
    set(gca,'XTick',[1:9]);
    set(gca,'XTickLabel',{[],0,10,20,30,40,50,60,70,100});
    % axes(haxes(end));
    xlabel('Pattern id');
    ylim([1.45 1.7]);

end
savefig(gcf,[folder_save cell_type '_cell_latency_(n=' num2str(size(mean_Vm_tr_all,1)) ')']);


%% AUC(area under curve) - trapezoidal rule of integration(contain all non-significant) -- Figure 3H

%%%%%%%%%%%%%%%%%%%% flickering %%%%%%%%%%%%%%%%%%%%
for pattern_idx=1:pat_num
    for n=1:1:size(single_norm{pattern_idx},1)
        % calculate with area under curve
        auc2(pattern_idx,n)=sum(single_norm{pattern_idx}(n,2:8))*10;
    end
end

for pattern_idx=1:pat_num
    for n=1:1:size(single_norm{pattern_idx},1)
        % calculate with mean value
        auc3(pattern_idx,n)=mean(single_norm{pattern_idx}(n,2:8))*100;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% random motion %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for pattern_idx=1:2
    for n=1:1:size(single_norm{pattern_idx},1)
        % calculate with area under curve
        auc4(pattern_idx,n)=sum(single_norm{pattern_idx}(n,11:17))*10;
    end
end

for pattern_idx=1:2
    for n=1:1:size(single_norm{pattern_idx},1)
        % calculate with mean value
        auc5(pattern_idx,n)=mean(single_norm{pattern_idx}(n,11:17))*100;
    end
end

%% Compare ANOVA

if convertCharsToStrings(cell_type) == "HS(81G07)"
    g_bar= repmat({'bar'},size(single_norm{1},1),1);
    g_grat= repmat({'grating'},size(single_norm{2},1),1);
    g_bar_Rd= repmat({'barRandom'},size(single_norm{1},1),1);
    g_grat_Rd= repmat({'gratingRandom'},size(single_norm{2},1),1);

    c = [auc3(1,1:size(single_norm{1},1))' ; auc3(2,1:size(single_norm{2},1))';...
        auc4(1,1:size(single_norm{1},1))' ; auc4(2,1:size(single_norm{2},1))'];
    g1 = [ g_bar ; g_grat; g_bar_Rd ; g_grat_Rd ];

else
    g_bar= repmat({'bar'},size(single_norm{1},1),1);
    g_loom= repmat({'loom'},size(single_norm{2},1),1);
    g_spot= repmat({'spot'},size(single_norm{3},1),1);

    g_bar_Rd= repmat({'barRandom'},size(single_norm{1},1),1);
    g_loom_Rd= repmat({'loomRandom'},size(single_norm{2},1),1);

    c = [auc3(1,1:size(single_norm{1},1))' ; auc3(2,1:size(single_norm{2},1))'; auc3(3,1:size(single_norm{3},1))';...
        auc5(1,1:size(single_norm{1},1))' ; auc5(2,1:size(single_norm{2},1))'];
    g1 = [ g_bar ; g_loom; g_spot; g_bar_Rd ; g_loom_Rd ];
end


[p7,t2,stats]=anova1(c,g1);
set(gcf,'Color','w');
sgtitle(['Noise Performance Index (p=' num2str(p7) ')']);
set(gca,'Box','off','TickDir','out','FontSize',12);

ii=100*ones(1,pat_num+2);
means2=stats.means;
for i=1:size(ii,2)
    text(i,ii(i),num2str(means2(i))); hold on;
end

ylim([-10 160]);


saveas(gcf,[folder_save 'AUC2_ANOVA_NotchPlot_trapezoidal']);

figure;
[q,m,h,gnames] = multcompare(stats);
%
for i=1:size(q,1)
    disp([ num2str(q(i,1)) ' with ' num2str(q(i,2)) ' pValue : ' num2str(q(i,6))]);
end

saveas(gcf,[folder_save 'Compare_AUC_ANOVA']);


save([folder_save cell_type 'quantified_gcamp_260428'], 't','mean_amplitude','c','auc2', ...
    'auc3','auc4','auc5','single_norm','means2');
