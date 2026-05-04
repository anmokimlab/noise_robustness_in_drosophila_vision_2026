%analyze_2p_edr.m
%220110--edited by hyosun
clear all;


% List of patterns for treatment octopamine in LPLC2
PATNAMES={'pattern01 gs1',...
    'pattern02 gs2',...
    'pattern03 gs3',...
    'pattern04 bar r 12p noise0',...
    'pattern05 bar l 12p noise0',...
    'pattern06 bar r 12p noise10',...
    'pattern07 bar l 12p noise10',...
    'pattern08 bar r 12p noise20',...
    'pattern09 bar r 12p noise30',...
    'pattern10 bar r 12p noise40',...
    'pattern11 bar r 12p noise50',...
    'pattern12 bar r 12p noise60',...
    'pattern13 bar r 12p noise70',...
    'pattern14 looming r noise0',...
    'pattern15 looming l noise0',...
    'pattern16 looming r noise10',...
    'pattern17 looming l noise10',...
    'pattern18 looming r noise20',...
    'pattern19 looming r noise30',...
    'pattern20 looming r noise40',...
    'pattern21 looming r noise50',...
    'pattern22 looming r noise60',...
    'pattern23 looming r noise70',...
    'pattern24 spot up r noise0',...
    'pattern25 spot up l noise0',...
    'pattern26 spot up r noise10',...
    'pattern27 spot up l noise10',...
    'pattern28 spot up r noise20',...
    'pattern29 spot up r noise30',...
    'pattern30 spot up r noise40',...
    'pattern31 spot up r noise50',...
    'pattern32 spot up r noise60',...
    'pattern33 spot up r noise70',...
    'pattern34_looming_R_6p_noise_0',...
    'pattern35_looming_R_6p_noise_0_016',...
    'pattern36 noise100'};
%%
PATID = [4:23,34:36];

PATDUR=4*ones(size(PATID));
num_avg=3;
nBlocks=3;

edr_files=dir('*.EDR');
for file_idx = 1:length(edr_files)

    file_name=edr_files(file_idx).name;
    disp(['loading ' file_name]);
    load([file_name(1:end-7) '00' file_name((end-6):end-4) '_roi.mat']);
    figure(1);clf;plot(mu0-mu0_bg);
    % load EDR
    [data, h] = import_edr_v3(file_name);

    dt = h.DT; %load sampling interval (DT) (1/1000)
    t = (0:(size(data,1)-1))*dt;
    t=t';
    xpos = data(:, 2)';
    ypos = data(:, 3)';
    patid = round(calibrate_patid(data(:,6), PATID));
   
    %%%%%%%%%%%%% patid error %%%%%%%%%%%%%%%%%
    pat_idx=find(patid([1 1:(end-1)])< 0 & patid>0);
    for i=1:size(pat_idx,1)
        patid(pat_idx(i):pat_idx(i)+50)= patid(pat_idx(i)+100);
    end

    frame_trig=data(:,7)';
    t=(0:(length(frame_trig)-1))*dt;
    frame_trig_diff=diff(frame_trig([1 1:end]));
    [counts, centers]=hist(frame_trig_diff(frame_trig_diff<0),500);

    cum_counts=cumsum(counts);
    cum_counts=cum_counts/cum_counts(end);
    [tmp idx]=find(cum_counts>0.05,1,'first');%change 0.025/0.015 to different values to change the relative threshold
    threshold=centers(idx);%threshold for noise (non-peak signals) removal
    frame_trig_diff(frame_trig_diff>threshold)=0;
   
    [peaks peak_idx]=find(frame_trig_diff==0 & frame_trig_diff([2:end end])<0);

    %remove outliers by meand and standard deviation of the amplitude;
    delmu=mu0-mu0_bg;
    mu=mean(frame_trig(peak_idx));
    std0=std(frame_trig(peak_idx));
    peak_idx=peak_idx(frame_trig(peak_idx)<mu+std0*5 & frame_trig(peak_idx)>mu-std0*5);

    for i=1:length(mu0)
        for j=(i-1)*num_avg+1
            if j>length(peak_idx)
                continue;
            else
                peak_idx2(i)=peak_idx(j);
            end
        end
    end

    err=find(peak_idx2>length(frame_trig),1,'first');
    if isempty(err)
        peak_idx2=peak_idx2;
    else
        peak_idx2=peak_idx2(1:err-1);
    end

    %plottting
    figure(1);clf;set(gcf,'Color','w');
    haxes(1)=subplot(311);
    plot(t,frame_trig);hold on;plot(dt*peak_idx2,frame_trig(peak_idx2),'r.');
    title(['Scanhead y pos (' file_name ')'],'Interpreter','none')
    ylabel('scanhead y pos (au)');
    haxes(2)=subplot(312);
    plot(dt*peak_idx2,diff(peak_idx2([1 1:end]))*dt);
    ylabel({'inter-frame', 'interval (ms)'})
    haxes(3)=subplot(313);
    plot(t,frame_trig_diff);hold on;
    plot(dt*[0 length(frame_trig_diff)],threshold*[1 1],'r');
    xlabel('Time (s)');ylabel('diff(scanhead y pos)');
    linkaxes(haxes,'x');set(haxes,'Box','off','TickDir','out');
    set(haxes(1:2),'XTickLabel',[]);
    disp(['total number of detected frames: ' num2str(length(frame_trig))]);
    disp(['   mean inter-frame interval: ' num2str(mean(diff(peak_idx2))*dt*1000) ' ms']);
    disp(['   max inter-frame interval: ' num2str(max(diff(peak_idx2))*dt*1000) ' ms']);
    disp(['   min inter-frame interval: ' num2str(min(diff(peak_idx2))*dt*1000) ' ms']);


    %%
    if length(peak_idx2) > length(mu0)
        gcamp=interp1(t(peak_idx2(1:length(mu0))), delmu(1,1:length(peak_idx2(1:length(mu0)))),t);
    else
        gcamp=interp1(t(peak_idx2), delmu(1,1:length(peak_idx2)),t);
    end
    
    figure(3);
    subplot(211);plot(t,patid,t,xpos);
    subplot(212);plot(t,gcamp,'r');

    %%%% extract start idx for each patid
    gcamp_tr=cell(length(PATID),1);
    patid_tr=cell(length(PATID),1);
    xpos_tr=cell(length(PATID),1);
    seg_idx=cell(length(PATDUR),1);

    for i=1:length(PATDUR)
        seg_idx{i}=round(-1/dt):round((PATDUR(i)+5)/dt);
    end
    start_idx=cell(length(PATID),1);

    %% plot the traces across the stimuli in single fly
    
    figure(4); set(gcf,'Color','w');
    for p=1:length(PATID)
        subplot(6,4,p);
        start_idx{p,:}=find(patid([1 1:(end-1)])< 0 & patid==PATID(p));

        for i=1:numel(start_idx{p,1})
            m=[start_idx{p,1}(i)+seg_idx{p}];
            if m(end)>length(data)
                continue;
            else
                gcamp_tr{p,i}=gcamp(start_idx{p,1}(i)+seg_idx{p});
                patid_tr{p,i}=patid(start_idx{p,1}(i)+seg_idx{p});
                xpos_tr{p,i}=xpos(start_idx{p,1}(i)+seg_idx{p});
               
                gcamp_tr{p,i}=gcamp_tr{p,i}/mean(gcamp_tr{p,i}(1:120));
                plot(seg_idx{p}*dt,gcamp_tr{p,i},'Color',[0.5 0.5 0.5],'LineWidth',0.3); hold all
            end
        end
        set(gca,'Box','off','TickDir','out');

        title(PATNAMES{PATID(p)});
        xlabel('time(s)');
        ylabel('average of dF');
        for i=1:length(start_idx{p})
            if length(gcamp_tr{p,i})>0
                gcamp_tr_v2(i,:) = gcamp_tr{p,i}(1,:);
            else
                continue
            end
        end
        mean_gcamp_tr{p}=[mean(gcamp_tr_v2,1)];

        plot([1.5 1.5],[0.9 1.6],'--')
        plot(seg_idx{p}*dt,mean_gcamp_tr{p},'r','LineWidth',1); hold off;
        %                 ylim([0.9 1.8]);
        xlim([-1 PATDUR(p)]);
    end

    savefig(['figure/' file_name(1:end-4)]);
    save([file_name(1:end-7) '00' file_name((end-6):end-4) '_roi.mat'],'-append','PATNAMES','dt','seg_idx','mean_gcamp_tr','gcamp_tr');
end