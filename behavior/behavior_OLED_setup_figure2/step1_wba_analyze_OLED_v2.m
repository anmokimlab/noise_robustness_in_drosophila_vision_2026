clc;clear;close all;

winedr_folder = "/Volumes/nisl/hyosun/1.Noise_Experiment/V11_new/TNTxCS/v2_Flickering_loomgrating";
folder0 = "/Volumes/nisl/hyosun/1.Noise_Experiment/V11_new/matFiles";
cd(winedr_folder);

edrs = dir(fullfile(winedr_folder, '**', '*.EDR'));
degree_threshold=-15;
voltage_threshold=(degree_threshold+45)/135*5;

patID_to_be_tested = (1:48);


% import EDR file
for n = 1:size(edrs,1)

    list(n).filename=edrs(n).name;
    list(n).location=edrs(n).folder;

    disp(['importing Fly' num2str(n) '...' '(filename: ' list(n).filename ')']);

    [data, h] = import_edr_v3(fullfile(list(n).location, list(n).filename));

    %read edr data
    t=data(:,1);
    objloc=data(:,3);
    lwba0 = data(:,4);
    rwba0 = data(:,5);
    dt=h.DT;

    %clear "shock" noise in the wing beat signal
    lwba0 = clear_wingbeat_noise1(lwba0,dt);
    rwba0 = clear_wingbeat_noise1(rwba0,dt);

    patid=round(calibrate_patid(data(:,2),patID_to_be_tested));
    

    %change(need to change if using different length of pattern)
    %time related variable
    patternDuration = 3;
    latency = 0.14;
    latencyidxlength= latency / dt;
    idxLengthPerPattern = patternDuration / dt;

    fc = 25;
    lwba1=bpf_ak_v2(lwba0,dt,0,fc);  
    rwba1=bpf_ak_v2(rwba0,dt,0,fc);

    
    %build an exclusion vector 
    % 1. exclude if either wingbeat drops below a threshold
    bExclude = false(size(lwba0));
    bExclude(lwba0<voltage_threshold)=true;
    bExclude(rwba0<voltage_threshold)=true;

    % 2. exclude if the wingbeat changes too rapidly
    diffLWBA = abs(diff(lwba0([1 1:end])));
    diffRWBA = abs(diff(rwba0([1 1:end])));

    bExclude(diffLWBA>1*10^3)=true;
    bExclude(diffRWBA>1*10^3)=true;

    for p=1:length(patID_to_be_tested)
       
        onset_idx=find(patid([1 1:(end-1)])<0 & patid==patID_to_be_tested(p));
  
        plot(t,patid,'k',t(onset_idx),patid(onset_idx),'r*');


        trial_idx=round(-1/dt):round((patternDuration+1)/dt)+ latencyidxlength;
        cnt = 0;
        for i=1:length(onset_idx)
            segment_idx_here = (onset_idx(i)+trial_idx);
            critical_segment_idx_here = onset_idx(i)+(round(0.5/dt):round(2.5/dt));%this is the interval that is plotted for the paper
            if  segment_idx_here(end) < length(lwba1) && sum(bExclude(critical_segment_idx_here))==0
                cnt = cnt +1; 
                lwba_tr(cnt,:)=lwba1(segment_idx_here);
                rwba_tr(cnt,:)=rwba1(segment_idx_here);
                patid_tr(cnt,:)=patid(segment_idx_here);
            end
        end

        if cnt>=2 %use only if the trial number is greater than or equal to 3
            experimental_data(p,1,n)={trial_idx*dt};
            experimental_data(p,2,n)={patid_tr};
            experimental_data(p,3,n)={lwba_tr};
            experimental_data(p,4,n)={rwba_tr};
        else
            experimental_data(p,1,n)={nan(size(trial_idx))};
            experimental_data(p,2,n)={nan(size(trial_idx))};
            experimental_data(p,3,n)={nan(size(trial_idx))};
            experimental_data(p,4,n)={nan(size(trial_idx))};
        end

        clear patid_tr
        clear rwba_tr
        clear lwba_tr

    end

end

nfly = size(experimental_data,3);
npattern = size(experimental_data,1);

patternlinspace = dt:dt:idxLengthPerPattern*dt;
cd(folder0);

save(['TNTxCS_' winedr_folder{1}(end-21:end) '_' num2str(nfly) '.mat'], 'experimental_data', '-mat');
