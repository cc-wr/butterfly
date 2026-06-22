function verify_lists()
    baseDir = fileparts(mfilename('fullpath'));
    letters = {'A','B','C','D'};
    for k = 1:numel(letters)
        S = load(fullfile(baseDir, ['List' letters{k} '.mat']));
        n = numel(S.questionTriggers);
        assert(n==120, 'List %s: %d items', letters{k}, n);
        % itemTriggers must be a permutation of 1..120
        assert(isequal(sort(S.itemTriggers(:))', 1:120), ...
            'List %s: itemTriggers not 1..120', letters{k});
        % every image and audio file must exist
        missImg = 0; missWav = 0;
        for i = 1:n
            if ~isfile(fullfile(baseDir,'images',[S.jpgList{i} '.jpg'])); missImg=missImg+1; end
            if ~isfile(fullfile(baseDir,'audio', [S.wavList{i} '.wav'])); missWav=missWav+1; end
        end
        % condition/trigger coherence: questionTrigger group must match itemTrigger band
        bad = 0;
        for i = 1:n
            it = S.itemTriggers(i);
            grp = ceil(it/30); % 1..4
            expQ = 200 + grp*10;       % 210/220/230/240
            expImg = 200 + grp;        % 201/202/203/204
            if S.questionTriggers(i)~=expQ || S.imageTriggers(i)~=expImg
                bad = bad + 1;
            end
        end
        fprintf('List %s: 120 items, itemTriggers=perm(1:120), missImg=%d missWav=%d triggerMismatch=%d\n', ...
            letters{k}, missImg, missWav, bad);
    end
    % cross-list: orders should differ
    A = load(fullfile(baseDir,'ListA.mat')); B = load(fullfile(baseDir,'ListB.mat'));
    fprintf('A vs B identical order? %d (expect 0)\n', isequal(A.itemTriggers, B.itemTriggers));
end
