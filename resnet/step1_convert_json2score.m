%% ============================================================
%  R → MATLAB 변환 코드
%  원본: JSON 결과 파일을 읽어 패턴별 노이즈 Accuracy 분석 및 시각화
%% ============================================================

%% 1. 경로 설정 및 JSON 읽기
work_dir = '/Volumes/nisl/4alum/soobin/1.3DResnet/2.RESULTS(onon)/5.HMDB_RESOLUTION(320x240)_movement/NOISE_W.G.N.TRAIN/NOISE_20/results2';
cd(work_dir);

%% ============================================================
%  JSON → MATLAB 변환 코드 (구조 수정판)
%% ============================================================

%% 1. JSON 읽기
val_json = jsondecode(fileread('val.json'));
field_names = fieldnames(val_json.results);
disp(['총 클립 수: ', num2str(length(field_names))]);

%% 2. table_func: JSON → 테이블 변환
function Scores = table_func(val_json)
    field_names  = fieldnames(val_json.results);
    ground_truth = {};
    noise_pct    = {};
    label        = {};
    score_vals   = [];

    for i = 1:length(field_names)
        fname = field_names{i};  % e.g. "grating_L_width_1_vel_3_noise_20"
        parts = strsplit(fname, '_');

        % ground truth = 첫 두 파트 (e.g. "grating_L")
        gt = strjoin(parts(1:2), '_');

        % noise % = "noise" 다음 숫자
        noise_idx = find(strcmp(parts, 'noise'));
        if ~isempty(noise_idx)
            np = parts{noise_idx + 1};
        else
            np = '0';
        end

        % top1 결과 (struct 배열의 첫 번째 원소)
        clip_data = val_json.results.(fname);  % 8×1 struct
        top1_label = clip_data(1).label;
        top1_score = clip_data(1).score;

        ground_truth{end+1,1} = gt;
        noise_pct{end+1,1}    = np;
        label{end+1,1}        = top1_label;
        score_vals(end+1,1)   = top1_score;
    end

    Scores = table(ground_truth, noise_pct, label, score_vals, ...
                   'VariableNames', {'ground_truth','noise_pct','label','score'});
end

Scores = table_func(val_json);
writetable(Scores, 'Scores.csv');
disp('Scores.csv 저장 완료');
disp(head(Scores));

%% 3. Accuracy 계산
l = 180;  % 패턴+노이즈 조합당 총 샘플 수 (필요시 조정)

patterns   = unique(Scores.ground_truth);
noise_levs = unique(str2double(Scores.noise_pct));
noise_levs = sort(noise_levs);

gt_col  = {};
np_col  = [];
hit_col = [];
avg_col = [];
acc_col = [];

for p = 1:length(patterns)
    for n = 1:length(noise_levs)
        pat = patterns{p};
        noi = noise_levs(n);

        idx = strcmp(Scores.ground_truth, pat) & ...
              str2double(Scores.noise_pct) == noi;
        subset = Scores(idx, :);

        % 실제 샘플 수 사용 (l 대신)
        total = height(subset);

        hit_idx = strcmp(subset.ground_truth, subset.label);
        hit_num = sum(hit_idx);

        if hit_num > 0
            avg_score = mean(subset.score(hit_idx));
        else
            avg_score = 0;
        end

        gt_col{end+1,1}  = pat;
        np_col(end+1,1)  = noi;
        hit_col(end+1,1) = hit_num;
        avg_col(end+1,1) = avg_score;
        if total > 0
            acc_col(end+1,1) = hit_num / total * 100;
        else
            acc_col(end+1,1) = 0;
        end
    end
end

ACC_RESULT = table(gt_col, np_col, hit_col, avg_col, acc_col, ...
                   'VariableNames', {'ground_truth','noise_pct','hit_num','avg','acc'});
writetable(ACC_RESULT, 'acc_result.csv');
disp('acc_result.csv 저장 완료');

%% 4. 패턴별 데이터 분리 헬퍼
function dt = filter_pattern(ACC_RESULT, pat_list)
    idx = false(height(ACC_RESULT), 1);
    for k = 1:length(pat_list)
        idx = idx | strcmp(ACC_RESULT.ground_truth, pat_list{k});
    end
    dt = ACC_RESULT(idx, :);
    dt = sortrows(dt, 'noise_pct');
end

dt_bar     = filter_pattern(ACC_RESULT, {'bar_L',     'bar_R'    });
dt_grating = filter_pattern(ACC_RESULT, {'grating_L', 'grating_R'});
dt_looming = filter_pattern(ACC_RESULT, {'looming_L', 'looming_R'});
dt_spotup  = filter_pattern(ACC_RESULT, {'spotup_L',  'spotup_R' });

%% 5. 개별 패턴 그래프 (2×2)
figure('Name', 'Pattern Accuracy by Noise', 'Position', [100 100 1200 800]);

subplot(2,2,1); plot_pattern(dt_bar,     'bar\_R and bar\_L');
subplot(2,2,2); plot_pattern(dt_grating, 'grating\_R and grating\_L');
subplot(2,2,3); plot_pattern(dt_looming, 'looming\_R and looming\_L');
subplot(2,2,4); plot_pattern(dt_spotup,  'spotup\_R and spotup\_L');

function plot_pattern(dt, ttl)
    groups = unique(dt.ground_truth);
    colors = lines(length(groups));
    hold on; box off;
    for g = 1:length(groups)
        idx = strcmp(dt.ground_truth, groups{g});
        plot(dt.noise_pct(idx), dt.acc(idx), ...
             '-o', 'Color', colors(g,:), 'LineWidth', 1.5, ...
             'MarkerSize', 5, 'DisplayName', strrep(groups{g},'_','\_'));
    end
    legend('Location', 'southwest');
    title(ttl, 'FontWeight', 'bold');
    xlabel('Noise (%)');
    ylabel('Accuracy (%)');
    xlim([-5 75]); ylim([0 100]);
    xticks(0:10:70);
    hold off;
end

%% 6. 방향 합산 (L+R 평균) 그래프
function dt_merged = merge_directions(ACC_RESULT, pat_pair, pat_name)
    idx = strcmp(ACC_RESULT.ground_truth, pat_pair{1}) | ...
          strcmp(ACC_RESULT.ground_truth, pat_pair{2});
    dt  = ACC_RESULT(idx, :);

    noise_vals = unique(dt.noise_pct);
    noise_vals = sort(noise_vals);
    acc_mean   = arrayfun(@(n) mean(dt.acc(dt.noise_pct == n)), noise_vals);

    dt_merged = table(noise_vals, acc_mean, ...
                      repmat({pat_name}, length(noise_vals), 1), ...
                      'VariableNames', {'noise_pct', 'acc', 'ground_truth'});
end

dt_bar2     = merge_directions(ACC_RESULT, {'bar_L',     'bar_R'    }, 'bar'    );
dt_grating2 = merge_directions(ACC_RESULT, {'grating_L', 'grating_R'}, 'grating');
dt_looming2 = merge_directions(ACC_RESULT, {'looming_L', 'looming_R'}, 'looming');
dt_spotup2  = merge_directions(ACC_RESULT, {'spotup_L',  'spotup_R' }, 'spotup' );

dt_all = [dt_bar2; dt_grating2; dt_looming2; dt_spotup2];
dt_all = sortrows(dt_all, 'noise_pct');

figure('Name', 'Mean Accuracy of Each Pattern', 'Position', [100 100 800 500]);
groups = unique(dt_all.ground_truth);
colors = lines(length(groups));
hold on; box off;
for g = 1:length(groups)
    idx = strcmp(dt_all.ground_truth, groups{g});
    plot(dt_all.noise_pct(idx), dt_all.acc(idx), ...
         '-', 'Color', colors(g,:), 'LineWidth', 2, ...
         'DisplayName', groups{g});
end
legend('Location', 'southwest');
title('Mean accuracy of each pattern', 'FontWeight', 'bold', 'FontSize', 15);
xlabel('Noise (%)');
ylabel('Accuracy (%)');
xlim([-5 75]); ylim([0 100]);
xticks(0:10:70);
hold off;