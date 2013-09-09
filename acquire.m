function y = acquire(video_file)

if ischar(video_file),
    display(['Loading file ' video_file]);
    v = VideoReader(video_file);
else
    v = video_file;
end

numFrames = v.NumberOfFrames;

display(['Total frames: ' num2str(numFrames)]);

y = zeros(1, numFrames);
for i=1:numFrames,
    display(['Processing ' num2str(i) '/' num2str(numFrames)]);
    frame = read(v, i);
    redPlane = frame(:, :, 1);
    y(i) = sum(sum(redPlane)) / (size(frame, 1) * size(frame, 2));   
end

display('Signal acquired.');
display(' ');
display(['Sampling rate is ' num2str(v.FrameRate) '. You can now run process(your_signal_variable, ' num2str(v.FrameRate) ')']);

end

