%noise_loom_model_v10.m
%change in v10 -- no WBA normalization
%glmfit - linear-sigmoid
%control & TNT-silenced fly data used in combination to calculate the LPLC2/LC4 coefficients
%silencing residual coefficients were from noise_loom_model_v0.m

clear all;

noise_percent = 0:10:70; % noise levels in percent

noise_response_table = readtable("noise_response_loom_summary.csv");
pat_name = noise_response_table.Loom;
max_WBA = 22.29;%max wing beat amplitude of LC4>TNT

% Control flies
% collect samples to learn the model (CS x TNT)
WBA = noise_response_table.WBA;
LPLC2 = noise_response_table.LPLC2;
LC4 = noise_response_table.LC4;


% from LPLC2>TNT
LPLC2_silencing_residual_ratio = 0.22;
WBA(:, end+1)  = noise_response_table.WBA_LPLC2_TNT_;
LPLC2(:,end+1) = LPLC2_silencing_residual_ratio * noise_response_table.LPLC2; %0.45 is estimated from the sequential estimation method
LC4(:,end+1) = noise_response_table.LC4;


% from LC4>TNT
LC4_silencing_residual_ratio = 0.59;
WBA(:, end+1)  = noise_response_table.WBA_LC4_TNT_;
LPLC2(:,end+1) = noise_response_table.LPLC2; 
LC4(:,end+1) = LC4_silencing_residual_ratio * noise_response_table.LC4; %0.55 is estimated from the sequential estimation method


%squeeze input/output vectors
WBA = WBA(:);
LPLC2 = LPLC2(:);
LC4 = LC4(:);

WBA(WBA<0.01) = 0.01;
%WBA(WBA>0.99) = 0.99;
B = glmfit([LPLC2 LC4], WBA/max_WBA, 'normal', 'link','logit');


% use only CS x TNT fly data
LPLC2  = LPLC2(1:8);
LC4  = LC4(1:8);

% prediction
WBA_pred = max_WBA ./ (1 + exp(-(B(1) + B(2)*LPLC2 + B(3)*LC4)));
figure(3);clf;set(gcf,'Color','w');
haxes(1) = subplot(231);
plot(noise_percent, WBA(1:8), 'marker', '.', 'markersize', 12);hold on;
plot(noise_percent, WBA_pred, 'marker', '.', 'markersize', 12);
title('Control');
legend({'Actual','Predicted'});
xlabel('Noise level (%)');

haxes(4) = subplot(234);
plot(noise_percent, WBA(1:8)./max(WBA(1:8)), 'marker', '.', 'markersize', 12);hold on;

haxes(5) = subplot(235);
plot(noise_percent, WBA_pred, 'marker', '.', 'markersize', 12);hold on;


haxes(6) = subplot(236);
plot(noise_percent, WBA_pred./max(WBA_pred), 'marker', '.', 'markersize', 12);hold on;

%% estimate the residual responses after silencing
% LPLC2-silenced
% % collect samples to learn the model (LPLC2 > TNT)
WBA2 = noise_response_table.WBA_LPLC2_TNT_;
WBA2 = WBA2(1:8);

WBA2(WBA2<0.01) = 0.01;

LPLC2 = LPLC2_silencing_residual_ratio * noise_response_table.LPLC2; %0.45 is estimated from the sequential estimation method
LC4 = noise_response_table.LC4;

WBA2_pred = max_WBA ./ (1 + exp(-(B(1) + B(2)*LPLC2(1:8) + B(3)*LC4(1:8))));

haxes(2) = subplot(232);
plot(noise_percent, WBA2, 'marker', '.', 'markersize', 12);hold on;
plot(noise_percent, WBA2_pred, 'marker', '.', 'markersize', 12);
title('LPLC2-silenced');
legend({'Actual','Predicted'});

subplot(234);
plot(noise_percent, WBA2/max(WBA2), 'marker', '.', 'markersize', 12);hold on;

subplot(235);
plot(noise_percent, WBA2_pred, 'marker', '.', 'markersize', 12);hold on;

subplot(236);
plot(noise_percent, WBA2_pred./max(WBA2_pred), 'marker', '.', 'markersize', 12);hold on;

% LC4 silenced
% % collect samples to learn the model (LC4 > TNT)
WBA3  = noise_response_table.WBA_LC4_TNT_;
WBA3 = WBA3(1:8);
WBA3 = WBA3;

WBA3(WBA3<0.01) = 0.01;

LPLC2 =  noise_response_table.LPLC2; %0.45 is estimated from the sequential estimation method
LC4 = LC4_silencing_residual_ratio * noise_response_table.LC4;

% Re-estimate B(3) using the changed WBA
WBA3_pred = max_WBA ./ (1 + exp(-(B(1) + B(2)*LPLC2(1:8) + B(3)*LC4(1:8))));

haxes(3) = subplot(233);
plot(noise_percent, WBA3, 'marker', '.', 'markersize', 12);hold on;
plot(noise_percent, WBA3_pred, 'marker', '.', 'markersize', 12);
title('LC4-silenced');
legend({'Actual','Predicted'});

subplot(234);
plot(noise_percent, WBA3/max(WBA3), 'marker', '.', 'markersize', 12);hold on;
legend({'CS x TNT', 'LPLC2>TNT', 'LC4>TNT'});
title('Actual WBA (normalized)'); ylabel('Normalized WBA (au)');


subplot(235);
plot(noise_percent, WBA3_pred, 'marker', '.', 'markersize', 12);hold on;
legend({'CS x TNT', 'LPLC2>TNT', 'LC4>TNT'});
title('Predicted WBA'); ylabel('WBA (au)');

subplot(236);
plot(noise_percent, WBA3_pred./max(WBA3_pred), 'marker', '.', 'markersize', 12);hold on;
legend({'CS x TNT', 'LPLC2>TNT', 'LC4>TNT'});
title('Predicted WBA'); ylabel('Normalized WBA (au)');

set(haxes,'box','off','tickdir','out','fontsize',12,'xlim',[0 70],'xtick',[0:10:70]);

disp(['LPLC2 coefficient: ' num2str(B(2)) ', LC4 coefficient: ' num2str(B(3)) ', offset: ' num2str(B(1))]);
savefig4(gcf,'noise_loom_model2', [1700 800]);