function verify_lista_chunked()
    baseDir = fileparts(mfilename('fullpath'));
    S = load(fullfile(baseDir,'ListA.mat'));
    n = numel(S.questionTriggers);
    fprintf('items: %d\n', n);

    ch = readtable(fullfile(baseDir,'chunks_lista.csv'),'ReadVariableNames',false,'Delimiter',',');
    cmap = containers.Map(cellstr(string(ch.Var1)), num2cell(ch.Var2));
    bounds = [1 24; 25 48; 49 72; 73 96; 97 120];

    okChunk = true;
    for c=1:5
        for i=bounds(c,1):bounds(c,2)
            if cmap(S.jpgList{i}) ~= c
                okChunk=false;
                fprintf('  MISPLACED trial %d word %s in chunk %d expected %d\n', i, S.jpgList{i}, c, cmap(S.jpgList{i}));
            end
        end
    end
    fprintf('chunk placement correct: %d\n', okChunk);

    missImg=0; missWav=0; jw=0;
    for i=1:n
        if ~strcmp(S.jpgList{i},S.wavList{i}), jw=jw+1; end
        if ~isfile(fullfile(baseDir,'images',[S.jpgList{i} '.jpg'])), missImg=missImg+1; end
        if ~isfile(fullfile(baseDir,'audio',[S.wavList{i} '.wav'])), missWav=missWav+1; end
    end
    fprintf('jpg~=wav: %d | missImg: %d | missWav: %d\n', jw, missImg, missWav);
    fprintf('itemTriggers perm(1:120): %d\n', isequal(sort(S.itemTriggers(:))',1:120));

    bad=0;
    for i=1:n
        g=ceil(S.itemTriggers(i)/30);
        if S.questionTriggers(i)~=200+g*10 || S.imageTriggers(i)~=200+g, bad=bad+1; end
    end
    fprintf('trigger mismatches: %d\n', bad);

    for c=1:5
        idx=bounds(c,1):(bounds(c,1)+5);
        fprintf('chunk %d head: %s\n', c, strjoin(S.jpgList(idx),', '));
    end

    prac={'decoration','examination','migration','dancing','folding'};
    pm=0;
    for i=1:numel(prac)
        if ~isfile(fullfile(baseDir,'images',[prac{i} '.jpg'])), pm=pm+1; fprintf('  missing practice img %s\n',prac{i}); end
        if ~isfile(fullfile(baseDir,'audio',[prac{i} '.wav'])), pm=pm+1; fprintf('  missing practice wav %s\n',prac{i}); end
    end
    fprintf('practice missing files: %d\n', pm);

    ai = audioinfo(fullfile(baseDir,'audio',[S.wavList{1} '.wav']));
    fprintf('sample audio %s: %dHz %dch %dbit\n', S.wavList{1}, ai.SampleRate, ai.NumChannels, ai.BitsPerSample);
end
