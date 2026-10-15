% clear; close all; clc;
% % 正常现象
% figure(1);
% f0 = 1000;          % 信号频率 (Hz)
% fs = 10000;         % 采样率 (Hz)
% T  = 2e-3;          % 观察时长 (s)
% 
% t = 0 : 1/fs : T-1/fs;   % ★ 时间轴必须这样构造
% x = sin(2*pi*f0*t);
% 
% plot(t*1e3, x, '.-');
% xlabel('时间 (ms)'); ylabel('幅值'); grid on;
% 
% %欠采样波形图
% figure(2);
% f0 = 1000;          % 信号频率 (Hz)
% fs = 1200;         % 采样率 (Hz)
% T  = 0.1;          % 观察时长 (s)
% 
% t = 0 : 1/fs : T-1/fs;   % ★ 时间轴必须这样构造
% x = sin(2*pi*f0*t);
% 
% plot(t*1e3, x, '.-');
% xlabel('时间 (ms)'); ylabel('幅值'); grid on;
% 
% %频谱图
% figure(3);
% N = 1024;
% X = fft(x, N) / N;          % 记得归一化，否则幅度随 N 变
% f = (0:N-1) * (fs/N);
% half = 1:N/2;
% plot(f(half), abs(X(half))); xlabel('频率 (Hz)'); ylabel('幅值');
% 
% %重合对比图
% figure(4);
% plot(t*1e3, x, 'o-', 'MarkerSize', 8); hold on;   % 欠采样得到的点
% plot(t*1e3,  sin(2*pi*200*t), 'x--');             % 真实 200 Hz —— 对不上
% plot(t*1e3, -sin(2*pi*200*t), 's:');              % 反相 200 Hz —— 会重合
% 
% %幻影频率 vs 采样率 锯齿曲线
% figure(5);
% fs_sweep = 200 : 5 : 10000;
% f_alias  = abs(f0 - round(f0 ./ fs_sweep) .* fs_sweep);
% plot(fs_sweep, f_alias);
% xlabel('采样率 fs (Hz)'); ylabel('混叠后看到的频率 (Hz)');


%% ===== 混叠演示 aliasing_demo.m =====
% 目的：演示采样定理、混叠现象、混叠的不可逆性
% 用法：直接运行；或只改下面"参数区"后重跑
% 作者 / 日期：<你的名字> / 2026.10

clear; close all; clc;

%% ---------- 参数区（只改这里）----------
f0       = 1000;      % 信号频率 (Hz)
fs_good  = 10000;     % 正常采样率 (Hz)，远高于奈奎斯特
fs_bad   = 1200;      % 欠采样率 (Hz)，低于奈奎斯特 2*f0 = 2000
T_short  = 2e-3;      % 短观察时长 (s)，用来看波形
T_long   = 0.1;       % 长观察时长 (s)，用来做频谱
N_fft    = 1024;      % FFT 点数
save_fig = false;     % 改成 true 就自动把图存成 png
% save_fig = true;     % 改成 true 就自动把图存成 png

%% ---------- 实验 A：正常采样 ----------
t_a = 0 : 1/fs_good : T_short - 1/fs_good;
x_a = sin(2*pi*f0*t_a);

figure(1);
plot(t_a*1e3, x_a, '.-', 'MarkerSize', 10);
xlabel('时间 (ms)'); ylabel('幅值');
title(sprintf('实验A 正常采样：f_0 = %d Hz，fs = %d Hz', f0, fs_good));
grid on;

%% ---------- 实验 B1：欠采样波形 ----------
t_b = 0 : 1/fs_bad : T_long - 1/fs_bad;
x_b = sin(2*pi*f0*t_b);

figure(2);
plot(t_b*1e3, x_b, '.-', 'MarkerSize', 10);
xlabel('时间 (ms)'); ylabel('幅值');
title(sprintf('实验B1 欠采样：f_0 = %d Hz，fs = %d Hz（奈奎斯特 = %d Hz）', f0, fs_bad, fs_bad/2));
   
grid on;

%% ---------- 实验 B2：频谱 ----------
X      = fft(x_b, N_fft) / length(x_b);
f_axis = (0:N_fft-1) * (fs_bad/N_fft);
half   = 1:N_fft/2;

figure(3);
plot(f_axis(half), abs(X(half)), 'LineWidth', 1.2);
xlabel('频率 (Hz)'); ylabel('幅值');
title(sprintf('实验B2 频谱：%d Hz 信号在 fs = %d Hz 下看起来是 %d Hz', f0, fs_bad, abs(f0-fs_bad)));
    
grid on; xlim([0 fs_bad/2]);

%% ---------- 实验 B3：混叠不可逆 ----------
f_alias = abs(f0 - fs_bad);        % 理论混叠频率

figure(4);
plot(t_b*1e3, x_b, 'o-', 'MarkerSize', 7, 'LineWidth', 1); hold on;
plot(t_b*1e3,  sin(2*pi*f_alias*t_b), 'x--', 'MarkerSize', 10);
plot(t_b*1e3, -sin(2*pi*f_alias*t_b), 's:', 'MarkerSize', 7);
hold off;
xlabel('时间 (ms)'); ylabel('幅值');
title(sprintf('实验B3 混叠不可逆：%d Hz 与 -%d Hz 采出同一组点', f0, f_alias));
legend('欠采样数据（来自 1000 Hz）', sprintf('+%d Hz（对不上）', f_alias), sprintf('-%d Hz（完全重合）', f_alias), 'Location', 'best');
    
grid on; xlim([0 10]);          % 只看前 10 ms，点太密反而看不清

%% ---------- 实验 C：幻影频率 vs 采样率 ----------
fs_sweep      = 200 : 5 : 10000;
f_alias_sweep = abs(f0 - round(f0 ./ fs_sweep) .* fs_sweep);

figure(5);
subplot(2,1,1);
plot(fs_sweep, f_alias_sweep);
xlabel('采样率 fs (Hz)'); ylabel('混叠频率 (Hz)');
title('线性坐标：锯齿集中在 fs < f_0 的区域'); grid on;

subplot(2,1,2);
semilogx(fs_sweep, f_alias_sweep);  %在**对数 X 轴**上，这些齿尖会**均匀隔开**
xlabel('采样率 fs (Hz，对数)'); ylabel('混叠频率 (Hz)');
title('对数坐标：齿尖在 fs = f_0/k 处等间距（此处混叠为 0，变成直流）'); grid on;
% `semilogx(x,y)`
% 和普通`plot`区别：
% - `plot`：X、Y 都是**线性坐标**（等距离代表等数值）
% - `semilogx`：**X 轴对数坐标，Y 轴线性坐标**

%% ---------- 一键保存图片 ----------
if save_fig
    fig_names = {'01_normal_sampling', '02_undersampling_waveform', ...
        '03_spectrum_200Hz',  '04_aliasing_irreversible', ...
        '05_alias_vs_fs'};
    for k = 1:5
        exportgraphics(figure(k), sprintf('%s.png', fig_names{k}), 'Resolution', 150);
    end
    disp('5 张图已保存到当前目录');
end