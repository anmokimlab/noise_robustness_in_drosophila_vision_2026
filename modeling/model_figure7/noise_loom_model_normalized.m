%noise_loom_model_v1.m
%glmfit - linear-sigmoid

clear all;

noise_response_table = readtable("noise_response_loom_summary.csv");
pat_name = noise_response_table.Loom;


% Control flies
% collect samples to learn the model (CS x TNT)
WBA = noise_response_table.WBA/max(noise_response_table.WBA);
LPLC2 = noise_response_table.LPLC2;
LC4 = noise_response_table.LC4;

%squeeze input/output vectors
WBA = WBA(:);
LPLC2 = LPLC2(:);
LC4 = LC4(:);

WBA(WBA<0.01) = 0.01;
WBA(WBA>0.99) = 0.99;
B = glmfit([LPLC2 LC4], WBA, 'normal', 'link','logit');

% use only CS x TNT fly data
LPLC2  = LPLC2(1:8);
LC4  = LC4(1:8);

% prediction
WBA_pred = 1 ./ (1 + exp(-(B(1) + B(2)*LPLC2 + B(3)*LC4)));
figure(3);clf;set(gcf,'Color','w');
subplot(131);
plot(WBA(1:8));hold on;plot(WBA_pred);
title('Control');


%% estimate the residual responses after silencing
% LPLC2-silenced
% % collect samples to learn the model (LPLC2 > TNT)
WBA2  = noise_response_table.WBA_LPLC2_TNT_;
WBA2 = WBA2(1:8);
WBA2 = WBA2/max(WBA2);

WBA2(WBA2<0.01) = 0.01;
WBA2(WBA2>0.99) = 0.99;

% Create the Offset
fixed_intercept = B(1); 
fixed_B_LC4  = B(3);
myOffset = fixed_intercept + (fixed_B_LC4 * LC4);

% Re-estimate B(2) using the changed WBA
B_LPLC2_re_estimated = glmfit(LPLC2, WBA2, 'normal', 'link', 'logit', ...
                        'Offset', myOffset, 'constant', 'off');
WBA2_pred = 1 ./ (1 + exp(-(B(1) + B_LPLC2_re_estimated*LPLC2(1:8) + B(3)*LC4(1:8))));

subplot(132);
plot(WBA2);hold on;plot(WBA2_pred);
title('LPLC2-silenced');




% LC4 silenced
% % collect samples to learn the model (LC4 > TNT)
WBA3  = noise_response_table.WBA_LC4_TNT_;
WBA3 = WBA3(1:8);
WBA3 = WBA3/max(WBA3);

WBA3(WBA3<0.01) = 0.01;
WBA3(WBA3>0.99) = 0.99;

% Create the Offset
fixed_intercept = B(1); 
fixed_B_LPLC2  = B(2);
myOffset = fixed_intercept + (fixed_B_LPLC2 * LPLC2);

% Re-estimate B(3) using the changed WBA
B_LC4_re_estimated = glmfit(LC4, WBA3, 'normal', 'link', 'logit', ...
                        'Offset', myOffset, 'constant', 'off');
WBA3_pred = 1 ./ (1 + exp(-(B(1) + B(2)*LPLC2(1:8) + B_LC4_re_estimated*LC4(1:8))));

subplot(133);
plot(WBA3);hold on;plot(WBA3_pred);
title('LC4-silenced');


disp(['LPLC2 coefficient: ' num2str(B(2)) ', LC4 coefficient: ' num2str(B(3)) ', offset: ' num2str(B(1))]);
disp(['LPLC2 silencing residual ratio: ' num2str(B_LPLC2_re_estimated/B(2)) ', LC4 silencing residual ratio: ' num2str(B_LC4_re_estimated/B(3))])