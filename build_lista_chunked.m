function build_lista_chunked()
%BUILD_LISTA_CHUNKED  Rebuild ListA.mat with chunk-constrained order.
% Order = chunk1..chunk5 (membership from the list-a binder PDFs); the order
% WITHIN each chunk is randomized with a fixed seed. jpg = wav = word (each
% word has its own picture and audio cue). Triggers come from the word's
% condition via current_list.csv. Chunk boundaries align with the breaks
% inserted in butterfly.m before trials 25/49/73/97.
    baseDir = fileparts(mfilename('fullpath'));
    seed = 101;

    % word -> [questionTrigger imageTrigger itemTrigger]
    master = readtable(fullfile(baseDir,'current_list.csv'), ...
        'ReadVariableNames', false, 'Delimiter', ',');
    mwords = string(master.Var3);
    trig   = [master.Var5, master.Var6, master.Var7];
    map = containers.Map(cellstr(mwords), num2cell(trig, 2));

    % word -> chunk (1..5)
    ch = readtable(fullfile(baseDir,'chunks_lista.csv'), ...
        'ReadVariableNames', false, 'Delimiter', ',');
    cwords = string(ch.Var1);
    cnum   = ch.Var2;

    rng(seed);
    jpgList = {}; wavList = {};
    questionTriggers = []; imageTriggers = []; itemTriggers = [];
    for c = 1:5
        ws = cwords(cnum == c);
        ws = ws(randperm(numel(ws)));            % randomize within chunk
        for k = 1:numel(ws)
            w = char(ws(k));
            t = map(w);                          % [q img it]
            jpgList{end+1,1} = w;
            wavList{end+1,1} = w;
            questionTriggers(end+1,1) = t(1);
            imageTriggers(end+1,1)    = t(2);
            itemTriggers(end+1,1)     = t(3);
        end
    end

    assert(numel(jpgList)==120, 'expected 120 items, got %d', numel(jpgList));
    save(fullfile(baseDir,'ListA.mat'), 'questionTriggers','imageTriggers', ...
        'itemTriggers','jpgList','wavList');
    fprintf('Wrote ListA.mat: 120 items in chunk order, within-chunk shuffle seed %d\n', seed);
end
