tbl = readtable('Scores.csv');

pat_names = {'grating_L', 'grating_R', 'looming_L', 'looming_R', 'bar_L','bar_R','spotup_L','spotup_R'};
num_pat_occurrence = zeros(8,length(pat_names));
num_hit = zeros(8,length(pat_names));

for i = 1:size(tbl, 1)
    ground_truth = tbl{i, "ground_truth"}{1};  % extract string from cell
    noise_pct_idx = tbl{i, "noise_pct"}/10+1;
    match_idx = find(strcmp(pat_names, ground_truth));
    if isempty(match_idx)
       fprintf('Row %d: "%s" has no match in pat_names\n', i, ground_truth);
    else
        num_pat_occurrence(noise_pct_idx, match_idx)= num_pat_occurrence(noise_pct_idx, match_idx)+1;
        if(strcmpi(tbl{i, "label"}{1}, tbl{i, "ground_truth"}{1}))
            num_hit(noise_pct_idx, match_idx) = num_hit(noise_pct_idx, match_idx) +1;
        end
    end
end

accuracy = num_hit./num_pat_occurrence;
accuracy_per_pattern = [accuracy(:,2) (accuracy(:,3)+accuracy(:,4))/2 (accuracy(:,5)+accuracy(:,6))/2, (accuracy(:,7)+accuracy(:,8))/2];


figure(1);clf;set(gcf,'color','w');
ax(1) = subplot(121);
plot(accuracy*100,'.-');
legend(pat_names);
xlabel('Noise level (%)');
set(gca,'tickdir','out','xtick',[1:8],'xticklabel',0:10:70);
ylabel('Accuracy (%)');
title('trained with noise level up to 10%')
ax(2) = subplot(122);
plot(accuracy_per_pattern*100,'.-');
legend('grating_R','looming','bar','spotup');
xlabel('Noise level (%)');
set(gca,'tickdir','out','xtick',[1:8],'xticklabel',0:10:70);
ylabel('Accuracy (%)');
set(ax,'tickdir','out','box','off');
title('L/R merged (except for grating)')

save('noise_10_accuracy_v2','accuracy','accuracy_per_pattern');
