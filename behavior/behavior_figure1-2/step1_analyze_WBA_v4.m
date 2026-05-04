clear;

folder_data="/Volumes/nisl/hyosun/1.Noise_Experiment/V1_Behavioral Experiment/data/looming_grating";
folder0="/Volumes/nisl/hyosun/1.Noise_Experiment/V4-10_TNT_re-analyze";

if sum(folder_data{1}(end-14:end)=='looming_grating')>14
    patID_to_be_tested = [43:1:75];
else
    patID_to_be_tested =[11:1:42,75];
end

% listing edr files
edrs=search_for_edr(folder_data);   
degree_threshold=-15;
nan_threshold=3000;
voltage_threshold=(degree_threshold+45)/135*5;

for n=1:size(edrs,1) 
    list(n).filename=edrs(n).name;
    list(n).location=edrs(n).folder;
    disp(['analyzing ' list(n).filename]);
    cd(list(n).location);
    [data, h] = import_edr(list(n).filename);
    dt=h.DT;
    DUR = 3;

    %downsample
    dt = dt*10;

    %load with downsampling
    t=data(1:10:end,1);
    xpos=data(1:10:end,2);
    lwba0=data(1:10:end,4);
    rwba0=data(1:10:end,5);

    %clear "shock" noise in the wing beat signal
    lwba0 = clear_wingbeat_noise1(lwba0,dt);
    rwba0 = clear_wingbeat_noise1(rwba0,dt);


    if list(n).location(end) == 'k'
        patid=round(calibrate_patid(data(1:10:end,3),patID_to_be_tested));
    else
        patid=round(calibrate_patid(data(1:10:end,6),patID_to_be_tested));
    end

    
   fc = 25;
    lwba1=bpf_ak_v2(lwba0,dt,0,fc);  %%% V11_new folder
    rwba1=bpf_ak_v2(rwba0,dt,0,fc);
    % lwba1=lwba0; rwba1=rwba0;


    %build an exclusion vector 
    % 1. exclude if either wingbeat drops below a threshold
    bExclude = false(size(lwba0));
    bExclude(lwba0<voltage_threshold)=true;
    bExclude(rwba0<voltage_threshold)=true;

    % 2. exclude if the wingbeat changes too rapidly
    diffLWBA = abs(diff(lwba0([1 1:end])));
    diffRWBA = abs(diff(rwba0([1 1:end])));

    bExclude(diffLWBA>1)=true;
    bExclude(diffRWBA>1)=true;



    for p=1:length(patID_to_be_tested)
        % if p==33
        %     onset_idx=find(patid([1 1:(end-1)])<0 & patid==max(patid));
        % else
        onset_idx=find(patid([1 1:(end-1)])<0 & patid==patID_to_be_tested(p));
        % end
        plot(t,patid,'k',t(onset_idx),patid(onset_idx),'r*');
        % if n==2 && p==14 || n==14 && p==14  %HCSxTNT barspot
        %     onset_idx=onset_idx(1:6);
        % end

        trial_idx=round(-1/dt):round((DUR+1)/dt);
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


cd(folder0);

save('CSxTNT_loomgrating_260308.mat', 'experimental_data', '-mat');
