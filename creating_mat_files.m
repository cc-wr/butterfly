%%commands for creating .mat stim files
%%after using import data command on exp_list text files
% The target output is a 'struct' with fields containing all of the triggers in your
% experiment, as well as whatever files that will be presented (images,
% audio, etc.). However you get there is fine! See the MATLAB objects in
% the HOMOLOSINE folder (listA.mat) as a reference.

% read in your CSV file:
data = readtable('test_list.csv');

% any numerical values (triggers) should be stored as arrays of doubles
questionTriggers = table2array(data(:,5));
imageTriggers = table2array(data(:,6));
itemTriggers = table2array(data(:,7));

% any text values (file names) should be stored as cells
jpgList = table2cell(data(:,3));
wavList = table2cell(data(:,4));


% specify the file name and save
fileName = 'ListX.mat'
save(fileName, 'questionTriggers', 'imageTriggers','itemTriggers','jpgList','wavList');
