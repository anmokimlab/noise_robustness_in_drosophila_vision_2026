% hyosun make -- 251027
clear;

folder_data = '/Users/hyosunkim/0_psychopy/test4/data/final_data';

csvs=search_for_csv(folder_data);

for i=1:length(csvs)
    T=readtable(csvs(i).name);

    data = table2cell(T(7:size(T,1),1));

    % if csvs(i).name(28) == '5'
    data(:,2)= table2cell(T(7:size(T,1),11));
    data(:,3)= table2cell(T(7:size(T,1),17)); %latency
    
    % elseif i == length(csvs)-4 || i == length(csvs)-2
    %     data(:,2)= table2cell(T(7:size(T,1),74)); %resp_mouse_clicked_name
    %     data(:,3)= table2cell(T(7:size(T,1),80)); %resp_mouse_latency_time
    % else
    %     data(:,2)= table2cell(T(7:size(T,1),76));
    %     data(:,3)= table2cell(T(7:size(T,1),82));
    % end

    b=1; s=1; l=1; g=1; b1=1; s1=1; l1=1; g1=1;
    for j=1:size(data,1) %patterns
        if isempty(data{j,1})
            continue
        elseif size(data{j,2},2) == 2
            data{j,2} = nan;
        else
            corr_ans{j,1} = data{j,1}(22:end-4);
            % percent{j,1} = num2str(data{j,1}(end-5:end-4));
            % human_ans{j,1} = data{j,2}(3:end-2);
            if data{j,1}(end-5) == 'v'
                data{j,1}(end-5:end-4)= '90';
            elseif data{j,1}(end-5) == '_'
                data{j,1}(end-5:end-4)= '00';
            end
            switch corr_ans{j}(1:9)
                case 'bar_R_12p'
                    barR{i}{b,1} = str2num(data{j,1}(end-5:end-4)); %percent
                    barR{i}{b,2} = data{j,2}(3:end-2); %human answer
                    barR{i}{b,3} = str2num(data{j,3}(2:end-1)); %latency
                    b=b+1;
                case 'bar_L_12p'
                    barL{i}{b1,1} = str2num(data{j,1}(end-5:end-4)); %percent
                    barL{i}{b1,2} = data{j,2}(3:end-2); %human answer
                    barL{i}{b1,3} = str2num(data{j,3}(2:end-1)); %latency
                    b1=b1+1;
                case 'spotup_R_'
                    spotR{i}{s,1} = str2num(data{j,1}(end-5:end-4));
                    spotR{i}{s,2} = data{j,2}(3:end-2);
                    spotR{i}{s,3} = str2num(data{j,3}(2:end-1)); %latency
                    s=s+1;
                case 'spotup_L_'
                    spotL{i}{s1,1} = str2num(data{j,1}(end-5:end-4));
                    spotL{i}{s1,2} = data{j,2}(3:end-2);
                    spotL{i}{s1,3} = str2num(data{j,3}(2:end-1)); %latency
                    s1=s1+1;
                case 'looming_R'
                    loomR{i}{l,1} = str2num(data{j,1}(end-5:end-4));
                    loomR{i}{l,2} = data{j,2}(3:end-2);
                    loomR{i}{l,3} = str2num(data{j,3}(2:end-1)); %latency
                    l=l+1;
                case 'looming_L'
                    loomL{i}{l1,1} = str2num(data{j,1}(end-5:end-4));
                    loomL{i}{l1,2} = data{j,2}(3:end-2);
                    loomL{i}{l1,3} = str2num(data{j,3}(2:end-1)); %latency
                    l1=l1+1;
                case 'grating_R'
                    gratingR{i}{g,1} = str2num(data{j,1}(end-5:end-4));
                    gratingR{i}{g,2} = data{j,2}(3:end-2);
                    gratingR{i}{g,3} = str2num(data{j,3}(2:end-1)); %latency
                    g=g+1;
                case 'grating_L'
                    gratingL{i}{g1,1} = str2num(data{j,1}(end-5:end-4));
                    gratingL{i}{g1,2} = data{j,2}(3:end-2);
                    gratingL{i}{g1,3} = str2num(data{j,3}(2:end-1)); %latency
                    g1=g1+1;
            end
        end     
    end
end

all_pat(1,:)=barR;
all_pat(2,:)=barL;
all_pat(3,:)=spotR;
all_pat(4,:)=spotL;
all_pat(5,:)=loomR;
all_pat(6,:)=loomL;
all_pat(7,:)=gratingR;
all_pat(8,:)=gratingL;


for i=1:size(all_pat,1)
    for n=1:size(all_pat,2)
        switch i
            case 1
                corr='bar_R';
            case 2
                corr='bar_L';
            case 3
                corr='spot_R';
            case 4
                corr='spot_L';
            case 5
                corr='looming_R';
            case 6
                corr='looming_L';
            case 7
                corr='grating_R';
            case 8
                corr='grating_L';
        end

        for trial=1:size(all_pat{i,n},1)
            if all_pat{i,n}{trial,2}(1) == corr(1) && all_pat{i,n}{trial,2}(end) == corr(end) 
                all_pat{i,n}{trial,4}=1;

            else
                all_pat{i,n}{trial,4}=0;
                all_pat{i,n}{trial,3}=nan;
            end
        end
    end
    % accuracy(i)=sum(score{i})/size(score{i},1);
end

accuracy=cell(8,10); latency=cell(8,10);
for p=1:size(all_pat,1)
    for n=1:size(all_pat,2)
        for trial=1:size(all_pat{p,n},1)
            accuracy{p,all_pat{p,n}{trial,1}/10+1}{n}={};
            latency{p,all_pat{p,n}{trial,1}/10+1}{n}={};
        end
    end
end



for p=1:size(all_pat,1)
    for n=1:size(all_pat,2) % number of people
        for trial=1:size(all_pat{p,n},1)
            if isempty(accuracy{p,all_pat{p,n}{trial,1}/10+1}{n})
                % accuracy{p,all_pat{p,n}{trial,1}/10+1}{n}={};
                accuracy{p,all_pat{p,n}{trial,1}/10+1}{n} = all_pat{p,n}{trial,4};
            else
                accuracy{p,all_pat{p,n}{trial,1}/10+1}{n} = [accuracy{p,all_pat{p,n}{trial,1}/10+1}{n}, all_pat{p,n}{trial,4}];
            end

            if isempty(latency{p,all_pat{p,n}{trial,1}/10+1}{n})
                % accuracy{p,all_pat{p,n}{trial,1}/10+1}{n}={};
                latency{p,all_pat{p,n}{trial,1}/10+1}{n} = all_pat{p,n}{trial,3}-1.5;
            else
                latency{p,all_pat{p,n}{trial,1}/10+1}{n} = [latency{p,all_pat{p,n}{trial,1}/10+1}{n}, all_pat{p,n}{trial,3}-1.5];
            end

        end
    end
end


for p=1:size(all_pat,1)
    for np=1:size(accuracy,2) % noise percent
        for n=1:size(accuracy{p,np},2)
            % avg_acc{p,np}(n) = mean(accuracy{p,np}{1,n},'omitnan');
            if mod(p,2)==1
                avg_acc{p,np}(n)=mean(accuracy{p,np}{1,n},'omitnan');
                avg_latency{p,np}(n)=mean(latency{p,np}{1,n},'omitnan');
            else
                avg_acc{p-1,np}(n+size(accuracy{p,np},2))=mean(accuracy{p,np}{1,n},'omitnan');
                avg_latency{p-1,np}(n+size(accuracy{p,np},2))=mean(latency{p,np}{1,n},'omitnan');
            end
        end
    end
end


for p=1:2:size(all_pat,1)
    for np=1:size(accuracy,2)
        avg_avg_acc(p,np) = mean(avg_acc{p,np},'omitnan');
        sem(p,np)=std(avg_acc{p,np}(1,:),[],2,"omitmissing")/sqrt(size(avg_acc{p,np},2))*1.96;
        avg_avg_lat(p,np) = mean(avg_latency{p,np},'omitnan');
        sem_lat(p,np)=std(avg_latency{p,np}(1,:),[],2,"omitmissing")/sqrt(size(avg_latency{p,np},2))*1.96;
    end
end

avg_avg_acc(6,:)=[];avg_avg_acc(4,:)=[];avg_avg_acc(2,:)=[];
avg_avg_lat(6,:)=[];avg_avg_lat(4,:)=[];avg_avg_lat(2,:)=[];

sem(6,:)=[];sem(4,:)=[];sem(2,:)=[];
sem_lat(6,:)=[];sem_lat(4,:)=[];sem_lat(2,:)=[];

tit={'bar','spot','loom','grating'};



%%
c='bmrg';
figure(1); set(gcf,'Color','w');
for p=1:size(avg_avg_acc,1)
    subplot(2,2,p);
    errorbar(1:9, avg_avg_acc(p,1:9), sem(p,1:9),'Color',ones(1,3)*0.8);hold on;
    plot(avg_avg_acc(p,1:9),'Marker','o','MarkerFaceColor',c(p));
    title(tit{p});
    set(gca,'Box','off','TickDir','out','FontSize',12);
    ylabel('accuracy');xlabel('Noise (%)');
    set(gca,'XTick',1:9,'XTickLabel',{'0' '10' '20' '30' '40' '50' '60' '70' '80'});
end

%%
figure(2); set(gcf,'Color','w');
c='bmrg';

for p=1:size(avg_avg_acc,1)
    switch p
        case 1
            i=1; ii=1;
        case 2
            i=2; ii=1;
        case 3
            i=2; ii=2;
        case 4
            i=1; ii=2;
    end

    subplot(1,2,i);
    errorbar((1:9) +.2*ii, avg_avg_acc(p,1:9), sem(p,1:9),'Color',ones(1,3)*0.8);hold on;
    plot((1:9)+.2*ii, avg_avg_acc(p,1:9),'color',c(p),'Marker','o','MarkerFaceColor',c(p));
    %%%%%%%%%%%%%%%%%%%% caculate p-value %%%%%%%%%%%%%%%%%%%%%%%%%

    for i=1:8
        locat=mean(avg_acc{p*2-1,i},2)+.15;
        [h p1]=ttest(avg_acc{p*2-1,i}(1,:)-avg_acc{p*2-1,9}(1,:));
        if(p1<0.001)
            text(i, locat, '***','color',c(p));
        elseif(p1<0.01)
            text(i, locat, '**','color',c(p));
        elseif(p1<0.05)
            text(i, locat, '*','color',c(p));
        end
    end


    title(tit{p});
    set(gca,'Box','off','TickDir','out','FontSize',12);
    ylabel('accuracy');xlabel('Noise (%)');
    set(gca,'XTick',1:9,'XTickLabel',{'0' '10' '20' '30' '40' '50' '60' '70' '80'});
end

%%
figure(2); set(gcf,'Color','w');
for p=1:size(avg_avg_lat,1)
    switch p
        case 1
            i=1; ii=1;
        case 2
            i=2; ii=1;
        case 3
            i=2; ii=2;
        case 4
            i=1; ii=2;
    end

    subplot(1,2,i);
    errorbar((1:9) +.2*ii, avg_avg_lat(p,1:9), sem_lat(p,1:9),'Color',ones(1,3)*0.8);hold on;
    plot((1:9) +.2*ii, avg_avg_lat(p,1:9),'color',c(p),'Marker','o','MarkerFaceColor',c(p));

    %%%%%%%%%%%%%%%%%%%% caculate p-value %%%%%%%%%%%%%%%%%%%%%%%%%

    for i=2:9
        locat=mean(avg_latency{p*2-1,i},2)+.15;
        [h p1(p,i)]=ttest(avg_latency{p*2-1,i}(1,:)-avg_latency{p*2-1,1}(1,:));
        if(p1(p,i)<0.001)
            text(i, locat, '***','color',c(p));
        elseif(p1(p,i)<0.01)
            text(i, locat, '**','color',c(p));
        elseif(p1(p,i)<0.05)
            text(i, locat, '*','color',c(p));
        end
    end

    title(tit{p});
    set(gca,'Box','off','TickDir','out','FontSize',12);
    ylabel('latency');xlabel('Noise (%)'); 
    ylim([0.2 1.4]);
    set(gca,'XTick',1:9,'XTickLabel',{'0' '10' '20' '30' '40' '50' '60' '70' '80'});
end

  save(['human_Latency' ], 'avg_latency','sem_lat', 'avg_avg_lat');

