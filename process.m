function process(y, fps)

% Parameters to play with
WINDOW_SECONDS = 6;             % [s] Sliding window length
BPM_SAMPLING_PERIOD = 0.5;      % [s] Time between heart rate estimations
BPM_L = 40; BPM_H = 230;        % [bpm] Valid heart rate range
FILTER_STABILIZATION_TIME = 1;  % [s] Filter startup transient
CUT_START_SECONDS = 0;          % [s] Initial signal period to cut off
FINE_TUNING_FREQ_INCREMENT = 1; % [bpm] Separation between test tones for smoothing
ANIMATION_SPEED_FACTOR = 2;     % [] This makes the animation run faster or slower than real time

% Build and apply input filter
[b, a] = butter(2, [(((BPM_L)/60)/fps*2) (((BPM_H)/60)/fps*2)]);
yf = filter(b, a, y);
y = yf((fps * max(FILTER_STABILIZATION_TIME, CUT_START_SECONDS))+1:size(yf, 2));

% Some initializations and precalculations
num_window_samples = round(WINDOW_SECONDS * fps);
bpm_sampling_period_samples = round(BPM_SAMPLING_PERIOD * fps);
num_bpm_samples = floor((size(y, 2) - num_window_samples) / bpm_sampling_period_samples);
fcl = BPM_L / 60; fch = BPM_H / 60;
orig_y = y;
bpm = [];
bpm_smooth = [];

max_freq_plot_amplitude = 0;
max_time_plot_bpm = 100;
min_time_plot_bpm = 50;

for i=1:num_bpm_samples,
    
    % Fill sliding window with original signal
    window_start = (i-1)*bpm_sampling_period_samples+1;
    ynw = orig_y(window_start:window_start+num_window_samples);
    % Use Hanning window to bring edges to zero. In this way, no artificial
    % high frequencies appear when the signal is treated as periodic by the
    % FFT
    y = ynw .* hann(size(ynw, 2))';
    gain = abs(fft(y));

    % FFT indices of frequencies where the human heartbeat is
    il = floor(fcl * (size(y, 2) / fps))+1; ih = ceil(fch * (size(y, 2) / fps))+1;
    index_range = il:ih;
    
    % Plot the amplitude of the frequencies of interest
    figure(1);
    subplot(2, 1, 1);
    hold off;
    
    fft_plot = plot((index_range-1) * (fps / size(y, 2)) * 60, gain(index_range), 'b', 'LineWidth', 2);
    hold on;    
    max_freq_plot_amplitude = max(max_freq_plot_amplitude, max(gain(index_range)));
    axis([BPM_L BPM_H 0 max_freq_plot_amplitude]);
    grid on;
    xlabel('Heart rate (BPM)');
    ylabel('Amplitude');
    title('Frequency analysis and time evolution of heart rate signal');

    % Find peaks in the interest frequency range and locate the highest
    [pks, locs] = findpeaks(gain(index_range));
    [max_peak_v, max_peak_i] = max(pks);
    max_f_index = index_range(locs(max_peak_i));
    bpm(i) = (max_f_index-1) * (fps / size(y, 2)) * 60;
    
    % Smooth the highest peak frequency by finding the frequency that
    % best "correlates" in the resolution range around the peak
    freq_resolution = 1 / WINDOW_SECONDS;
    lowf = bpm(i) / 60 - 0.5 * freq_resolution;
    freq_inc = FINE_TUNING_FREQ_INCREMENT / 60;
    test_freqs = round(freq_resolution / freq_inc);
    power = zeros(1, test_freqs);
    freqs = (0:test_freqs-1) * freq_inc + lowf;
    for h = 1:test_freqs,
        re = 0; im = 0;
        for j = 0:(size(y, 2) - 1),
            phi = 2 * pi * freqs(h) * (j / fps);
            re = re + y(j+1) * cos(phi);
            im = im + y(j+1) * sin(phi);
        end
        power(h) = re * re + im * im;
    end
    [max_peak_v, max_peak_i] = max(power);
    bpm_smooth(i) = 60*freqs(max_peak_i);

    % Plot amplitudes in the fine-tuning interval
    hold on;
    smoothing_plot = plot(freqs*60, sqrt(power), 'r', 'LineWidth', 2);

    % Plot legend
    set(fft_plot, 'Displayname', 'FFT modulus');
    set(smoothing_plot, 'Displayname', 'Peak smoothing');
    legend('Location', 'NorthEast');
    
    % Plot BPM over time
    subplot(2, 1, 2);
    t = (0:i-1) * ((size(orig_y, 2) / fps) / (num_bpm_samples - 1));
    hold off;
    plot(t, bpm_smooth, 'r', 'LineWidth', 2);
    max_time_plot_bpm = max(max_time_plot_bpm, max(bpm_smooth));
    min_time_plot_bpm = min(min_time_plot_bpm, min(bpm_smooth));
    axis([0 ((size(orig_y, 2)-1) / fps) min_time_plot_bpm max_time_plot_bpm]);
    grid on;
    xlabel('Time (s)');
    ylabel('Heart rate (BPM)');

    % Print speed factor over real time
    box = uicontrol('style', 'text');
    set(box, 'String', [num2str(ANIMATION_SPEED_FACTOR) 'x']);
    set(box, 'Position', [512-42, 7, 40, 38]);
    set(box, 'FontName', 'Ubuntu Condensed');
    set(box, 'ForegroundColor', hex2dec({'88' '88' '88'})/255);
    set(box, 'FontSize', 22);
    set(box, 'BackgroundColor', hex2dec({'cc' 'cc' 'cc'})/255);

    drawnow();  % Flush graphics    
    pause(BPM_SAMPLING_PERIOD / ANIMATION_SPEED_FACTOR);
        
end

disp(['Mean HR: ' num2str(mean(bpm_smooth)) ' bpm']);

end
