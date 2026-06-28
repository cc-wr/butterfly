function convert_audio()
%CONVERT_AUDIO  Convert source .mp3 cues to mono/48000/16-bit .wav.
% All source mp3s are 48 kHz; we downmix to mono and keep the native rate
% (no resampling). butterfly.m opens the audio device at 48000 Hz mono.
    srcDir = 'C:\Users\ccooley\Downloads\current-words\audio';
    dstDir = fullfile(fileparts(mfilename('fullpath')), 'audio');
    targetFs = 48000;

    files = dir(fullfile(srcDir, '*.mp3'));
    fprintf('Converting %d mp3 files...\n', numel(files));
    for i = 1:numel(files)
        [~, name, ~] = fileparts(files(i).name);
        [y, fs] = audioread(fullfile(srcDir, files(i).name));
        if size(y,2) > 1, y = mean(y, 2); end                  % stereo -> mono
        if fs ~= targetFs, y = resample(y, targetFs, fs); end  % safety (all 48k)
        m = max(abs(y)); if m > 1, y = y / m; end              % clip guard
        audiowrite(fullfile(dstDir, [name '.wav']), y, targetFs, 'BitsPerSample', 16);
    end
    fprintf('Done. Wrote %d .wav (mono/%d/16-bit) to %s\n', numel(files), targetFs, dstDir);
end
