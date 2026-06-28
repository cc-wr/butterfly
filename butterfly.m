function expt = butterfly(subjID, list, paramFile)
%%%This is the main function that controls the entire process, from reading
%%%in input parameters to actually running the experiment

    %Screen('Preference','VisualDebugLevel', 0) % switch to 1 for debugging
    %Screen('Preference', 'SkipSyncTests', 0) % switch to 1 for debugging

    % example of what's in each of the list files
    %imageTriggers indicate the trigger code for images, always base item +
    %100, except Fillers which are always 200+
    %imageTriggers = [111]
    %jpgList indicate the .jpg file for each item
    %jpgList = {'Images/ant.jpg'}
    % questionTriggers codes indicate the stimulus ID number of each item
    %questionTriggers = [11];
    % itemTriggers indicate the condition of each item (241-244), together with
    % questionTriggers this uniquely identifies the stimulus 
    %itemTriggers = [201];
    % wavList idicates the .wav file for each item
    %wavList = {'Speech/act.wav'};

    %this the trigger for the question prompt; question triggers also indicate
    %whether the answer should be yes (235) or no (236)

    questionText = {'Next.'};

    %% practice
    practiceImageTrigger = [234;234;234;234;234;];
    practiceJpg = {
        'decoration',
        'examination',
        'migration',
        'dancing',
        'folding'
    };
    practiceWav = {
        'decoration',
        'examination',
        'migration',
        'dancing',
        'folding'
        };


    
    practiceTrigger = [237;237;237;237;237;];
    practiceOffset = [238;238;238;238;238;];
    %questionPracticeTriggers: 211 = yes; 212 = no
    questionPracticeTriggers = [239;240;239;240;239;];
    practiceText = {
        'The correct response was THE DECORATION OF THE CAKE.\nPress the space bar to continue',
        'The correct response was THE EXAMINATION OF THE CAT.\nPress the space bar to continue',
        'The correct response was THE MIGRATION OF THE BIRDS.\nPress the space bar to continue',
        'The correct response was THE DANCING OF THE COUPLE.\nPress the space bar to continue',
        'The correct response was THE FOLDING OF THE LAUNDRY.\nPress the space bar to continue'};
    
    %% intro, breaks, endings
    beginExpt = {
        'In this experiment, you will first hear a question, and then a picture will briefly appear. Note that you will not have the information necessary to answer the question until the image appears. Use the picture to come up with the answer to the question, and say it silently in your head.\n\nDuring the experiment, focus your eyes on the cross in the center of the screen when it appears. Try not to blink, or move your eyes or body. DO NOT speak until you see the RED MICROPHONE.\n\nWhen the RED MICROPHONE appears, say the answer out loud.\n\nDuring setup, you reviewed the training material for all of the items in this experiment. Unlike the other items, the practice items were included with the questions you will hear and their answers. You will now be given a binder containing training material for just the practice items, without the questions or correct answers. Please review the binder before continuing to the practice items.\n\nWhen you are done reviewing the binder, let the researcher know and they will collect the binder. Then press Spacebar to continue.'};
    endBreak = {'This is the end of practice.\n\nThe test will contain 120 items, which are divided into five sections. There will be a break between each section.\n\nYou will now be given a binder containing the training material for the first section. Please review the binder before continuing. At each break, you will be given the binder of training material for the next section to review. Unlike the practice items, you will not receive any feedback during the test.\n\nReminder:\n            During the experiment, focus your eyes on the cross in the center of the screen when it appears. Try not to blink, or move your eyes or body. After the image appears, say the answer silently in your head. DO NOT speak until you see the RED MICROPHONE.\n\nTell the researcher if you have any questions. When you are done reviewing the binder, let the researcher know and they will collect the binder. Then press Spacebar to continue.'};
    pauseText = {'You may now take a break.\n\nPlease review the binder for the next section before continuing. You may also rest, drink water, or use the restroom.\n\nReminder:\n            During the experiment, focus your eyes on the cross in the center of the screen when it appears. Try not to blink, or move your eyes or body. After the image appears, say the answer silently in your head. DO NOT speak until you see the RED MICROPHONE.\n\nWhen you are done reviewing the binder, let the researcher know and they will collect the binder. Then press Spacebar to continue.'};
    endExpt = {'This is the end of this experiment.\n\nThank you!'};

    %% Initialize keyboard
    KbCheck; %takes a while to load the first time
    KbName('UnifyKeyNames');
    par.escapeKey = KbName('ESCAPE');

    %% Initialize PsychPortAudio
    %%% This routine loads the the PsychPortAudio sound driver for high-precision,
    %%% low-latency, multi-channel sound playback and recording 
    InitializePsychSound(1);

    %% Force GetSecs and WaitSecs into memory to avoid latency later on:
    GetSecs;
    WaitSecs(0.1);
    
    %% Select parameter files and enter subject and list ID.
    % [exptFileName, exptPath] = uigetfile('*.txt', 'Select experiment file');
    if nargin < 1
        [paramFileName, paramPath] = uigetfile('*.par', 'Select parameter file');
        subjID = input('Enter subject ID: ', 's');
        list = input('Enter list number: ', 's');
    else
        [paramPath, paramName, paramExt] = fileparts(paramFile);
        paramPath = [paramPath, '/'];
        paramFileName = [paramName, paramExt];
    end
    
    %% Pick Stims

    if list == 'A'
        load listA.mat
    elseif list == 'B'
        load listB.mat
    elseif list == 'C'
        load listC.mat
    elseif list == 'D'
        load listD.mat
    else
        error('Invalid List Entry')
    end
    
    %% Initialize file names
    par.logFileName = strcat(paramPath,'logs/',subjID,'_',list,'.log'); %%logs events in same directory as experiment file

    %%next few lines to facilitate naming the production recordings
    par.subjID = subjID;
    par.list = list;
    par.recordingPath = strcat(paramPath, 'recordings/');
    if ~exist(par.recordingPath, 'dir')
        mkdir(par.recordingPath);
    end


    %% Create log file, first test that it doesn't already exist
    fExist = fopen(par.logFileName, 'r');
    
    if fExist == -1
        fid = fopen(par.logFileName,'w');
        if fid == -1
            error('Cannot write to log file.')
        end
        fclose(fid);
    else
        error('log file with this name already exists')
    end
    
   
    %% ReadParameterFile stores the parameters in the struct 'par'.
    paramFileNameAndPath = strcat(paramPath,paramFileName);
    par = ReadParameterFile(paramFileNameAndPath,par);
    fprintf('Parameter file read');
    
    %% par things
    %par.timing.configTrigger = 0;
    %par.timing.beginTrigger = 0;
    %par.timing.responseTriggers = [];
    %par.timing.responseIndex = 1;
    %par.timing.stimulusTriggers = [];
    %par.timing.index = 1;
    %par.timing.questionTrigger1 = [];
    %par.timing.question1Index = 1;
    %par.timing.questionTrigger2 = [];
    %par.timing.question2Index = 1;

    %% Configure the data acquisition device
    clear device
    par.demoMode = true;
    ports = serialportlist("available");
    for p = 1:length(ports)
        try
            device = serialport(ports(p),115200,"Timeout",1);
            device.flush()
            write(device,"_c1","char")
            query_return = read(device,5,"char");
            if length(query_return) > 0 && query_return == "_xid0"
                par.demoMode = false;
                break
            end
        catch
        end
    end
    clear device

    if par.demoMode
        Screen('Preference', 'SkipSyncTests', 1);
        fprintf('No XID device found. Running in demo mode.\n');
    end

    par.pulsewidth = 5;
    %setPulseDuration(device, par.pulsewidth)

    %% Run experiment
    par = runExperiment(imageTriggers, jpgList, questionTriggers, wavList, itemTriggers, questionText, par, practiceImageTrigger, practiceJpg, practiceTrigger, practiceWav, practiceOffset, practiceText, pauseText, endBreak, endExpt, beginExpt);
end

function par = ReadParameterFile(paramFileName, par)

	fid = fopen(paramFileName,'rt');
	
	if (-1 == fid)
		error('Could not open experiment parameters file.')
	end
	
	textLine = fgets(fid);
	
	while (-1 ~= textLine)
		%comments in the parameter file are on lines starting with '#'
		if(textLine(1)=='#')
			textLine = fgets(fid);
			continue
        end
        
        fxnToEval = strcat('par.',textLine,';');      
		if (~strcmp(fxnToEval,'par.;'))
			%fprintf(strcat('this is the function to evaluate: ',fxnToEval,'\n'));
			eval(fxnToEval); % This looks fancy, but just a way to do assignment of par variables in the text file
		end
		textLine = fgets(fid);
	end
	
	fclose(fid);
end

function par = runExperiment(imageTriggers, jpgList, questionTriggers, wavList, itemTriggers, questionText, par, practiceImageTrigger, practiceJpg, practiceTrigger, practiceWav, practiceOffset, practiceText, pauseText, endBreak, endExpt, beginExpt)
      
     %Grab a time baseline for the entire experiment and send a trigger to log
     baseTime = GetSecs();
     tic;
     if ~par.demoMode
         sendTrigger(par.beginTrigger);
     end
     par.timing.beginTrigger(1) = toc; %send the 'toc' so that the timing gets logged
    
     clear device 

    par.screenNumber = 0;
	par.wPtr = Screen('OpenWindow',par.screenNumber,0,[],32,2);  % This command outputs a lot of text to the Matlab window
	HideCursor();
    par.black = BlackIndex(par.wPtr);
    Screen('TextSize',par.wPtr,par.textSize);
    drawBlock(par, beginExpt{1});
    Screen('DrawingFinished',par.wPtr);
    ClearButtonPress;
    Screen('Flip',par.wPtr);
    GetButtonPress([par.moveOnButton],[par.moveOnTrigger],par,1);

    %% practice
    for practices = 1:length(practiceTrigger)
        checkEscape(par);
        results = InitResults;
        results = runTrial(practiceImageTrigger(practices, 1), practiceJpg{practices}, practiceTrigger(practices,1), practiceWav{practices}, questionText, par, results, practiceOffset(practices, 1));
        WriteLogFile(results,par.logFileName);

        Screen('TextSize',par.wPtr,par.textSize);
        DrawFormattedText(par.wPtr,sprintf(practiceText{practices}),'center','center',WhiteIndex(par.wPtr));
        Screen('DrawingFinished',par.wPtr);
        ClearButtonPress;
        Screen('Flip',par.wPtr);
        GetButtonPress([par.moveOnButton],[par.moveOnTrigger],par,1);
        DrawFormattedText(par.wPtr,'','center','center',WhiteIndex(par.wPtr));
        Screen('Flip',par.wPtr);
        WaitSecs(1);
  
    end
    
    %% end of practice
    Screen('TextSize',par.wPtr,par.textSize);
    drawBlock(par, endBreak{1});
    Screen('DrawingFinished',par.wPtr);
    ClearButtonPress;
    Screen('Flip',par.wPtr);
    GetButtonPress([par.moveOnButton],[par.moveOnTrigger],par,1);
    WaitSecs(2);

    %% experiment
    for trials = 1:length(questionTriggers)
        checkEscape(par);
        results = InitResults;
        %%insert breaks at specified hardcoded positions (will run before
        %%the trials specified)
        if trials == 25 || trials == 49  || trials == 73 || trials == 97 
            Screen('TextSize',par.wPtr,par.textSize);
            drawBlock(par, pauseText{1});
            Screen('DrawingFinished',par.wPtr);
            ClearButtonPress;
            Screen('Flip',par.wPtr);
            GetButtonPress([par.moveOnButton],[par.moveOnTrigger],par,1);
            WaitSecs(2);
            results = runTrial(imageTriggers(trials,1), jpgList{trials}, questionTriggers(trials,1), wavList{trials}, questionText, par, results, itemTriggers(trials, 1));
            WriteLogFile(results,par.logFileName);
        else
            
        results = runTrial(imageTriggers(trials,1), jpgList{trials}, questionTriggers(trials,1), wavList{trials}, questionText, par, results, itemTriggers(trials, 1));
        WriteLogFile(results,par.logFileName);
            
        end
    end
    
    %% End window
    Screen('TextSize',par.wPtr,par.textSize);
    DrawFormattedText(par.wPtr,endExpt{1},'center','center',WhiteIndex(par.wPtr));
    Screen('DrawingFinished',par.wPtr);
    ClearButtonPress;
    Screen('Flip',par.wPtr);
    GetButtonPress([par.moveOnButton],[par.moveOnTrigger],par,1);
    sca;

    clear device
end

function results = runTrial(imageTriggers, jpgItemName, questionTriggers, wavItemName, questionText, par, results, itemTriggers)
    
    %% trial

    % NOTE: BUTTERFLY XID code enumerates serial ports at the start of every
    % trial. This is redundant and slow — could be done once at experiment
    % start with the device handle passed via par.
    % TODO: all demoMode trigger guards below should be consolidated into a
    % single send function.
    if ~par.demoMode
        clear device

        device_found = 0;
        ports = serialportlist("available");

        for p = 1:length(ports)
            device = serialport(ports(p),115200,"Timeout",1);
            %In order to identify an XID device, you need to send it "_c1", to
            %which it will respond with "_xid" followed by a protocol value. 0 is
            %"XID", and we will not be covering other protocols.
            device.flush()
            write(device,"_c1","char")
            query_return = read(device,5,"char");
            if length(query_return) > 0 && query_return == "_xid0"
                device_found = 1;
                break
            end
        end

        if device_found == 0
            % NOTE: silently returns mid-trial with no fallback. Should
            % handle this more gracefully.
            disp("No XID device found. Exiting.")
            return
        end

        setPulseDuration(device, 5)
    end

    % Prep Screen
    Screen('TextSize',par.wPtr,par.textSize);
	DrawFormattedText(par.wPtr,'','center','center',WhiteIndex(par.wPtr));
	Screen('DrawingFinished',par.wPtr);
	Screen('Flip',par.wPtr);
    
    %Get image ready
    jpgItem = strcat('images/',jpgItemName,'.jpg');
    picStim = imread(jpgItem);
    picStim = imresize(picStim, [par.picSize NaN]);

    %Get microphone image ready
    micItem = strcat('microphone.jpg');
    micPic = imread(micItem);
    micPic = imresize(micPic, [par.micSize NaN]);

    
%   Flip Fixation cross
    Screen('TextSize',par.wPtr,par.textSize);
	DrawFormattedText(par.wPtr,'+','center','center',WhiteIndex(par.wPtr));
	Screen('DrawingFinished',par.wPtr);
	Screen('Flip',par.wPtr);
    
    %Go ahead and get critical image ready to flip immediately after prime plays
    imTexture = Screen('MakeTexture', par.wPtr, picStim);
    Screen('DrawTexture', par.wPtr, imTexture); 
    
    % Get recording parameters ready - ALEX  
    % Recording duration is set to picture duration    
    % Set recorder
    %Fs = 44100;
    %nBits = 16;
    %nChannels = 1;
    %recorder = audiorecorder(Fs, nBits, nChannels);  
    
    WaitSecs(.25);
   
    % Sound onset
    wavItem = strcat('audio/',wavItemName,'.wav');
    sentence = rot90(audioread(wavItem));       %EFL not using readWav b/c Ciaran already recorded in stereo; rot90 transposes column to row for PsychPortAudio
    pahandle = PsychPortAudio('Open',[],1,[],48000,1); %Last '1' indicates mono recording
    PsychPortAudio('FillBuffer', pahandle, sentence);
    PsychPortAudio('Start', pahandle);
    if ~par.demoMode
        write(device,sprintf("mh%c%c", questionTriggers, 0), "char"); %Turn trigger on
    end
    timeToLog = GetSecs;
    results = UpdateResults(results, timeToLog, wavItemName, questionTriggers);

    WaitSecs(length(sentence)/48000); %EFL note this estimate may be slightly inaccurate, doesn't include the time to execute the intervening commands above
%     DaqDOut(par.di,1,itemTriggers); %Turn trigger on ADD OFFSET TRIGGER
%     DaqDOut(par.di,1,0); %Turn trigger off
    PsychPortAudio('Close', pahandle);
    results = UpdateResults(results, timeToLog, wavItemName, itemTriggers);
    
    WaitSecs(par.postAudio-.017) %subtract screen refresh of 17ms to get desired ISI

    
    % Image presentation
    timeToLog = Screen('Flip', par.wPtr);
    if ~par.demoMode
        write(device,sprintf("mh%c%c", imageTriggers, 0), "char"); %Turn trigger on
    end
    results = UpdateResults(results, timeToLog, jpgItemName, imageTriggers);
 
    WaitSecs(par.picDuration-.017) %subtract screen refresh of 17ms to get desired ISI

    
    % Fixation cross again
    Screen('TextSize',par.wPtr,par.textSize);
	DrawFormattedText(par.wPtr,'+','center','center',WhiteIndex(par.wPtr));
	Screen('DrawingFinished',par.wPtr);
	Screen('Flip',par.wPtr);
    
    WaitSecs(par.postPic-.017) %subtract screen refresh of 17ms to get desired ISI
    
  
    % Microphone appears, recording begins
    imTexture = Screen('MakeTexture', par.wPtr, micPic);
    Screen('DrawTexture', par.wPtr, imTexture);
	timeToLog = Screen('Flip',par.wPtr);
    if ~par.demoMode
        write(device,sprintf("mh%c%c", itemTriggers, 0), "char"); %Turn trigger on
    end
    results = UpdateResults(results, timeToLog, 'mic_prompt', itemTriggers);

    if par.demoMode
        recStart = GetSecs;
        while GetSecs - recStart < par.recDuration
            checkEscape(par);
            WaitSecs(0.05);
        end
    else
        WaitSecs(par.recDuration-.017) %subtract screen refresh of 17ms to get desired ISI
    end
    %recordblocking(recorder,par.recDuration); ALEX

    clear device

    
    %% Save audio file with trigger of first word of current item ALEX
    %audioPath =
    %'/Users/cnllab/Desktop/OtherExperiments/homolosine/recordings/';
    %audioFileName = strcat(audioPath,par.subjID,'_',par.list,'_',jpgItemName,'.wav');
    %audioFile = getaudiodata(recorder);
    %audiowrite(audioFileName, audioFile, 44100);
    %clearvars audioFile
    %clearvars recorder
    %WaitSecs(par.picDuration); 
    Screen('Close');

    
end

%%Dec 12 2023 testing%%
%function startTime(obj,event, results)
%    recTimeToLog = num2str(GetSecs)
%    m = 'Hello'
%    results = UpdateResults(results, recTimeToLog, 'recording', 444); 
    
%end

%%%%%%%%%%%%%Gathering responses%%%%%%%%%%%%%%%%

function [reactionTime, button, buttonTrigger, par] = GetButtonPress(buttons,buttonTriggers,par,timed)
%% Waits for a button press by the user of the buttons whose numbers (found using KbName) 
%are specified in the array of buttons. Send the corresponding trigger for that button, as specified in
%the array buttonTriggers. If the boolean value timed == 1, after par.qDuration seconds the function ends.  
%If timed == 0, waits forever until the user types one of the specified
%EAP--the next three lines added at BNU
%tri_port1     = digitalio('parallel','LPT1');  
%out_lines = addline(tri_port1,0:7,0,'out');
%putvalue(tri_port1.Line(1:8),0);
%buttons.
    begWaitTime = GetSecs();
    timeCutoff = begWaitTime + par.qDuration;                    
    flag = 0;
    button = -1;
    buttonTrigger = -1;
    
    %% Loop that waits for a response or breaks if timeCutoff is exceeded
    while (true)
        [keyDetect,reactionTime,keyCode] = KbCheck(-1);
        if keyCode(par.escapeKey)
            sca;
            error('Experiment aborted by user.');
        end
        %is there a faster way to compare each button??  Can we do this simultaneously for all buttons??
        for i = 1:length(buttons)
            if (keyCode(buttons(i)))
                if ~par.demoMode
                    sendTrigger(buttonTriggers(i));
                end
                button = buttons(i);
                buttonTrigger = buttonTriggers(i);
                flag = 1;
                break;
            end
        end
        
        %%This part just allows you to break if a button was pressed
        if (flag == 1)
            break;
        end

        if (timed && GetSecs() > timeCutoff)
            break;
        end
    end
end

function ClearButtonPress()
%% Makes sure no buttons are being pressed/held down before get the new button press.
%This is important for when, for example, two textslides are one after the
%other, or for any case when one button press triggers another stage of the
%experiment that can be moved on from by pressing the same button that ended the last
%stage.
    while(true)
        [keyDetect,reactionTime,keyCode] = KbCheck(-1);
        if(~keyDetect)
            break;
        end
    end
end

%%%%%%% Writing results %%%%%%%%

function results = InitResults
	results.times = [];
	results.words = {};
	results.triggers = {};
end

function results = UpdateResults(results, timeToLog, currentWord, currentTriggers)
    
   results.times = AddEntry(results.times,timeToLog);
   results.words = AddEntry(results.words,currentWord);
   results.triggers = AddEntry(results.triggers,currentTriggers);
end
 
function WriteLogFile(results,logFileName)
	fid = fopen(logFileName,'a');
	while(fid == -1)
		logFileName = input('There was an error opening the log file.  Please reenter the log filename:', 's');
		fid = fopen(logFileName,'a');
	end
	
	fmt = '%.3f\t%s\t%s\n';  %%controls formatting of output
	for x = 1:length(results.times)
	   currentTriggers = questionTriggersToString(results.triggers{x});
	   fprintf(fid,fmt,results.times{x}, results.words{x},currentTriggers);
	end
	fclose(fid);

end


function str = ParToString(par)
%Returns a string value encoding all the parameters stored in the
%variable par, for writing out to the .rec file
	str = '';
	par_fields = fieldnames(par);
	nfields = length(par_fields);
	if (nfields < 1)
		fprintf('No parameters were entered! Check the parameter file.');
		return
	end
	str = par_fields(1);
	if (nfields > 1)
		for fieldindex = 2:nfields
			field = par_fields(fieldindex);
			value = eval(strcat('par.',char(field),';'));
			if(~isa(value,'string'))
				value = num2str(value);
			end
			str = strcat(str,'\n',field,':',value);
			%fprintf(char(strcat(str,'\n#####\n')));
		end
	end
end

function list = AddEntry(list,entry)
    if (length(list)<1)
        list{1} = entry;
    else
        list{length(list)+1} = entry;
    end
end

function triggerString = questionTriggersToString(questionTriggers)
    if(length(questionTriggers) < 1)
        triggerString = 'no triggers sent';
        return
    end
    triggerString = int2str(questionTriggers(1));
    if (length(questionTriggers)>1)
         for i = 2:length(questionTriggers)
                triggerString = strcat(triggerString,', ',int2str(questionTriggers(i)));
         end
    end
end

% Send Trigger Function - only use this outside of trials, when timing
% doesn't particularly matter
% NOTE: enumerates all serial ports on every call. This is redundant —
% could reuse a persistent device handle.
function sendTrigger(triggerCode)
    clear device

    device_found = 0;
    ports = serialportlist("available");
    
    for p = 1:length(ports)
        device = serialport(ports(p),115200,"Timeout",1);
        %In order to identify an XID device, you need to send it "_c1", to
        %which it will respond with "_xid" followed by a protocol value. 0 is
        %"XID", and we will not be covering other protocols.
        device.flush()
        write(device,"_c1","char")
        query_return = read(device,5,"char");
        if length(query_return) > 0 && query_return == "_xid0"
            device_found = 1;
            break
        end
    end
    
    if device_found == 0
        disp("No XID device found. Exiting.")
        return
    end

    setPulseDuration(device, 5)

    write(device,sprintf("mh%c%c", triggerCode, 0), "char")

    clear device
end

% Functions for the XID device
function byte = getByte(val, index)
    byte = bitand(bitshift(val,-8*(index-1)), 255);
end

function setPulseDuration(device, duration)
%mp sets the pulse duration on the XID device. The duration is a four byte
%little-endian integer.
    write(device, sprintf("mp%c%c%c%c", getByte(duration,1),...
        getByte(duration,2), getByte(duration,3),...
        getByte(duration,4)), "char")
end

function checkEscape(par)
    [~, ~, keyCode] = KbCheck(-1);
    if keyCode(par.escapeKey)
        sca;
        error('Experiment aborted by user.');
    end
end

function drawBlock(par, txt)
%DRAWBLOCK  Draw a multi-line instruction block: word-wrap each sentence to a
% target width (so the longest lines come out roughly equal length), left-align
% every line to one shared margin, and center that block horizontally and
% vertically. Continuation lines of a wrapped sentence are indented.
    Screen('TextSize', par.wPtr, par.textSize);
    [winW, ~] = Screen('WindowSize', par.wPtr);
    wrapPx = round(winW * 0.60);            % target max line width (tune here)
    txt = wrapText(par, txt, wrapPx, '            ');
    lines = regexp(txt, '\\n', 'split');
    maxW = 0;
    for i = 1:numel(lines)
        if isempty(lines{i}), continue; end   % blank lines have no width to measure
        b = Screen('TextBounds', par.wPtr, lines{i});
        maxW = max(maxW, b(3));
    end
    sx = round((winW - maxW) / 2);
    if sx < 0, sx = 0; end
    DrawFormattedText(par.wPtr, txt, sx, 'center', WhiteIndex(par.wPtr));
end

function out = wrapText(par, txt, wrapPx, indent)
%WRAPTEXT  Greedy word-wrap each paragraph (\n-separated piece) of txt to wrapPx
% pixels. A paragraph with NO leading whitespace gets a hanging indent (first
% line flush, continuations indented by `indent`). A paragraph that BEGINS with
% whitespace is block-indented: every one of its lines carries that same leading
% whitespace. Blank lines are preserved; sub-lines rejoined with literal \n.
    logical = regexp(txt, '\\n', 'split');
    outLines = {};
    for i = 1:numel(logical)
        L = logical{i};
        if isempty(strtrim(L))
            outLines{end+1} = '';
            continue;
        end
        lead = regexp(L, '^\s*', 'match', 'once');   % leading whitespace, if any
        words = strsplit(strtrim(L));
        if isempty(lead)
            cur = words{1};                % hanging: first line flush
            contIndent = indent;
        else
            cur = [lead words{1}];         % block: first line carries the lead
            contIndent = lead;             % ...and so do continuation lines
        end
        for k = 2:numel(words)
            trial = [cur ' ' words{k}];
            b = Screen('TextBounds', par.wPtr, trial);
            if b(3) > wrapPx
                outLines{end+1} = cur;
                cur = [contIndent words{k}];
            else
                cur = trial;
            end
        end
        outLines{end+1} = cur;
    end
    out = strjoin(outLines, '\\n');   % literal \n, matching the rest of the pipeline
end





