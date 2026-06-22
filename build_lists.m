function build_lists()
%BUILD_LISTS  Construct ListA/B/C/D.mat from current_list.csv.
% Each list contains all 120 items in an independent randomized order.
% Rows are permuted as a unit, so each item's triggers travel with it.
% A fixed seed per list makes the randomization reproducible.

    baseDir = fileparts(mfilename('fullpath'));
    csvFile = fullfile(baseDir, 'current_list.csv');

    opts = detectImportOptions(csvFile, 'ReadVariableNames', false, ...
        'Delimiter', ',');
    data = readtable(csvFile, opts);

    % Column layout: 1 phrase, 2 condition, 3 jpg, 4 wav,
    %                5 questionTrigger, 6 imageTrigger, 7 itemTrigger
    jpgAll  = table2cell(data(:,3));
    wavAll  = table2cell(data(:,4));
    qAll    = table2array(data(:,5));
    imgAll  = table2array(data(:,6));
    itemAll = table2array(data(:,7));

    nItems = height(data);
    assert(nItems == 120, 'Expected 120 rows, found %d', nItems);

    lists = {'A',1; 'B',2; 'C',3; 'D',4};

    for k = 1:size(lists,1)
        letter = lists{k,1};
        seed   = lists{k,2};
        rng(seed);
        p = randperm(nItems);

        jpgList         = jpgAll(p);
        wavList         = wavAll(p);
        questionTriggers = qAll(p);
        imageTriggers    = imgAll(p);
        itemTriggers     = itemAll(p);

        fname = fullfile(baseDir, ['List' letter '.mat']);
        save(fname, 'questionTriggers', 'imageTriggers', 'itemTriggers', ...
            'jpgList', 'wavList');
        fprintf('Wrote %s (seed %d, %d items)\n', fname, seed, nItems);
    end
end
