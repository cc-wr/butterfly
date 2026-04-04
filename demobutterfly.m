function demobutterfly()
    baseDir = fileparts(mfilename('fullpath'));
    subjID = 'demo';
    list = 'A';

    % Delete existing demo data
    logFile = fullfile(baseDir, 'logs', [subjID, '_', list, '.log']);
    if exist(logFile, 'file'), delete(logFile); end

    recPath = fullfile(baseDir, 'recordings');
    if exist(recPath, 'dir')
        demoRecs = dir(fullfile(recPath, [subjID, '_', list, '_*.wav']));
        for i = 1:length(demoRecs)
            delete(fullfile(recPath, demoRecs(i).name));
        end
    end

    fprintf('Cleaned demo data. Launching experiment...\n');
    butterfly(subjID, list, fullfile(baseDir, 'butterfly.par'));
end
