function task_representations

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WRITE DESCRIPTION OF TASK
% Participants will solve a series of mazes and reprot on their su  bsequent
% awareness of obstaclesn          
% Participants can perform 10 practice trials
%
% Org Author: Jason da Silva Castanheira 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% !!!!!!!!!!!!!!!!!!!! TO REMOVE TO REMOVE TO REMOVE  !!!!!!!!!!!!!!!
% !!!!!!!!!!!!!!!!!!!! TO REMOVE TO REMOVE TO REMOVE  !!!!!!!!!!!!!!!
Screen('Preference', 'SkipSyncTests', 1); 
% !!!!!!!!!!!!!!!!!!!! TO REMOVE TO REMOVE TO REMOVE  !!!!!!!!!!!!!!!
 
%% set up of experimental parameters 
CurrentFrameRateHz=FrameRate(0);

if (round(CurrentFrameRateHz)~=60)
    disp('Screen refresh rate is not 60Hz. Plese adjust Screen refresh rate to 60 Hz!')
    disp('check resolution')
    return
end

%EXPERIMENT INFORMATION
     
prompt={'SubjectID:','Gender','Age','Handedness (1=LEFT or 2=RIGHT): ','Dummymode (1=Yes; 0=No)','Practice (1=Yes; 2=No)'};
title='EXPERIMENT INFORMATION'; 
answer=inputdlg(prompt,title);
subjectID = char(answer{1});
Gender=char(answer{2});
Age=str2num(answer{3});
handiness = str2num(answer{4});
dummymode = str2num(answer{5});
practice = str2num(answer{6});
experiment = 'VGC_lat_behav';

% MAKE TRIAL MATRIX

% Call function to update Maze stims
create_VGC_stims()

%reset(RandStream.getGlobalStream,sum(100*clock));
rand('state',sum(100*clock));

% colour gradient from green to yellow 
cMap = interp1([0;1],[0 1 0; 1 1 0],linspace(0,1,256));

% load in stims
load('./StimMazes_RGB_4_Matlab.mat');

% now let us make one big trail matrix 
maze= repmat([1:24],1,4)';
lateralized=repelem([0,1],1,48)';
side= repelem([1,2,1,2],1,24)';
temp=repmat([maze,lateralized, side], 1,1); % repeat trial matrix two time
trialMatrix= table(temp(:,1), temp(:,2), temp(:,3));
trialMatrix.Properties.VariableNames = ["mazeNo", "lateralized", "side"];

trialMatrix = trialMatrix(randperm(size(trialMatrix,1)), :);
trialMatrix = trialMatrix(randperm(size(trialMatrix,1)), :);
nTrials=size(trialMatrix,1);

% save colours for easy access
maze_array= {};
maze_array([trialMatrix.lateralized== 1 & trialMatrix.side ==1])=stim_right_mazes_lat(trialMatrix.mazeNo([trialMatrix.lateralized== 1 & trialMatrix.side ==1]));
maze_array([trialMatrix.lateralized== 1 & trialMatrix.side ==2])=stim_left_mazes_lat(trialMatrix.mazeNo([trialMatrix.lateralized== 1 & trialMatrix.side ==2]));
maze_array([trialMatrix.lateralized== 0 & trialMatrix.side ==1])=stim_flipped_mazes_nonlat(trialMatrix.mazeNo([trialMatrix.lateralized== 0 & trialMatrix.side ==1]));
maze_array([trialMatrix.lateralized== 0 & trialMatrix.side ==2])=stim_orig_mazes_nonlat(trialMatrix.mazeNo([trialMatrix.lateralized== 0 & trialMatrix.side ==2]));


% save obstacle numbers for easy access
maze_obstacles= {};
maze_obstacles([trialMatrix.lateralized== 1 & trialMatrix.side ==1])=right_mazes_lat(trialMatrix.mazeNo([trialMatrix.lateralized== 1 & trialMatrix.side ==1]));
maze_obstacles([trialMatrix.lateralized== 1 & trialMatrix.side ==2])=left_mazes_lat(trialMatrix.mazeNo([trialMatrix.lateralized== 1 & trialMatrix.side ==2]));
maze_obstacles([trialMatrix.lateralized== 0 & trialMatrix.side ==1])=flipped_mazes_nonlat(trialMatrix.mazeNo([trialMatrix.lateralized== 0 & trialMatrix.side ==1]));
maze_obstacles([trialMatrix.lateralized== 0 & trialMatrix.side ==2])=orig_mazes_nonlat(trialMatrix.mazeNo([trialMatrix.lateralized== 0 & trialMatrix.side ==2]));


%SET UP DISPLAY

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Open window
WaitSecs(1);
Screens=Screen('Screens'); %gets all the Screens and initializes mex files
ScreenNumber=max(Screens); %assumes that the Screen that you want to display on is the Lowest number 
ShowCursor(0);	% arrow cursortest
HideCursor;
white = WhiteIndex(ScreenNumber);
black = BlackIndex(ScreenNumber);
grey=0.5;

[mainWin, windowRect] = PsychImaging('OpenWindow', ScreenNumber, grey);
slack = Screen('GetFlipInterval', mainWin)/2;
IFI = Screen('GetFlipInterval', mainWin);

[width, height] = Screen('WindowSize', mainWin); % Get the size of the on screen window
r=Screen(mainWin,'Rect');
[xCenter, yCenter] = RectCenter(windowRect);
centerX = round(r(3)/2);
centerY = round(r(4)/2);
Screen(mainWin,'TextSize',14);
Screen(mainWin,'TextFont','Arial');
Screen(mainWin,'FillRect',grey);
Screen('Flip', mainWin );


% set up locations of squares and fixation
color_fixation= stim_right_mazes_lat{1,1};
index_fix_temp=cell2mat(cellfun(@sum, color_fixation, 'UniformOutput', false)) > 0;

color_fixation(index_fix_temp) = {[1 1 1]};
color_fixationtemp=color_fixation;
color_fixation= reshape(color_fixation, [1, 11*11]);
color_fixation= vertcat(color_fixation{:})';

color_mask= color_fixation;
color_mask(:, 1:2:121) = 0;

% center fixation location (middle of center square) 
center_fix_loc= [centerX-20 centerY-15; centerX+20 centerY-15; centerX, centerY-35; centerX, centerY+5]';

% list of locations of all squares
% 11 by 11 grid
stim_loc=[[centerX-180 centerY-120 centerX-150 centerY-90];
    [centerX-150 centerY-120 centerX-120 centerY-90];
[centerX-120 centerY-120 centerX-90 centerY-90]; 
[centerX-90 centerY-120 centerX-60 centerY-90];
[centerX-60 centerY-120 centerX-30 centerY-90];
[centerX-30 centerY-120 centerX+0 centerY-90];
[centerX+0 centerY-120 centerX+30 centerY-90];  
[centerX+30 centerY-120 centerX+60 centerY-90]; 
[centerX+60 centerY-120 centerX+90 centerY-90]; 
[centerX+90 centerY-120 centerX+120 centerY-90]; 
[centerX+120 centerY-120 centerX+150 centerY-90]; 
...
[centerX-180 centerY-90 centerX-150 centerY-60];
[centerX-150 centerY-90 centerX-120 centerY-60];
[centerX-120 centerY-90 centerX-90 centerY-60];
[centerX-90 centerY-90 centerX-60 centerY-60 ];
[centerX-60 centerY-90 centerX-30 centerY-60]; 
[centerX-30 centerY-90 centerX+0 centerY-60];
[centerX+0 centerY-90 centerX+30 centerY-60];  
[centerX+30 centerY-90 centerX+60 centerY-60]; 
[centerX+60 centerY-90 centerX+90 centerY-60];
[centerX+90 centerY-90 centerX+120 centerY-60]; 
[centerX+120 centerY-90 centerX+150 centerY-60]; 
...
[centerX-180 centerY-60 centerX-150 centerY-30];
[centerX-150 centerY-60 centerX-120 centerY-30];
[centerX-120 centerY-60 centerX-90 centerY-30];
[centerX-90 centerY-60 centerX-60 centerY-30];
[centerX-60 centerY-60 centerX-30 centerY-30]; 
[centerX-30 centerY-60 centerX centerY-30];
[centerX+0 centerY-60 centerX+30 centerY-30]; 
[centerX+30 centerY-60 centerX+60 centerY-30]; 
[centerX+60 centerY-60 centerX+90 centerY-30]; 
[centerX+90 centerY-60 centerX+120 centerY-30]; 
[centerX+120 centerY-60 centerX+150 centerY-30]; 
...
[centerX-180 centerY-30 centerX-150 centerY-0];
[centerX-150 centerY-30 centerX-120 centerY-0];
[centerX-120 centerY-30 centerX-90 centerY-0];
[centerX-90 centerY-30 centerX-60 centerY]; 
[centerX-60 centerY-30 centerX-30 centerY]; 
[centerX-30 centerY-30 centerX+0 centerY];
 [centerX+0 centerY-30 centerX+30 centerY]; 
 [centerX+30 centerY-30 centerX+60 centerY]; 
[centerX+60 centerY-30 centerX+90 centerY-0];
[centerX+90 centerY-30 centerX+120 centerY-0]; 
[centerX+120 centerY-30 centerX+150 centerY-0]; 
...
[centerX-180 centerY-0 centerX-150 centerY+30];
[centerX-150 centerY-0 centerX-120 centerY+30];
[centerX-120 centerY-0 centerX-90 centerY+30];
[centerX-90 centerY-0 centerX-60 centerY+30];
[centerX-60 centerY-0 centerX-30 centerY+30]; 
[centerX-30 centerY-0 centerX centerY+30];
[centerX+0 centerY-0 centerX+30 centerY+30]; 
[centerX+30 centerY-0 centerX+60 centerY+30]; 
[centerX+60 centerY-0 centerX+90 centerY+30];
[centerX+90 centerY-0 centerX+120 centerY+30]; 
[centerX+120 centerY-0 centerX+150 centerY+30]; 
...
[centerX-180 centerY+30 centerX-150 centerY+60]; 
[centerX-150 centerY+30 centerX-120 centerY+60];
[centerX-120 centerY+30 centerX-90 centerY+60]; 
[centerX-90 centerY+30 centerX-60 centerY+60];
[centerX-60 centerY+30 centerX-30 centerY+60];
[centerX-30 centerY+30 centerX centerY+60];
[centerX+0 centerY+30 centerX+30 centerY+60];
[centerX+30 centerY+30 centerX+60 centerY+60]; 
[centerX+60 centerY+30 centerX+90 centerY+60]; 
[centerX+90 centerY+30 centerX+120 centerY+60]; 
[centerX+120 centerY+30 centerX+150 centerY+60]; 
...
[centerX-180 centerY+60 centerX-150 centerY+90];
[centerX-150 centerY+60 centerX-120 centerY+90];
[centerX-120 centerY+60 centerX-90 centerY+90];
[centerX-90 centerY+60 centerX-60 centerY+90];
[centerX-60 centerY+60 centerX-30 centerY+90];
[centerX-30 centerY+60 centerX centerY+90];
[centerX+0 centerY+60 centerX+30 centerY+90];
[centerX+30 centerY+60 centerX+60 centerY+90];
[centerX+60 centerY+60 centerX+90 centerY+90]; 
[centerX+90 centerY+60 centerX+120 centerY+90];
[centerX+120 centerY+60 centerX+150 centerY+90]; 
...
[centerX-180 centerY+90 centerX-150 centerY+120];
[centerX-150 centerY+90 centerX-120 centerY+120];
[centerX-120 centerY+90 centerX-90 centerY+120];
[centerX-90 centerY+90 centerX-60 centerY+120];
[centerX-60 centerY+90 centerX-30 centerY+120];
[centerX-30 centerY+90 centerX centerY+120];
[centerX+0 centerY+90 centerX+30 centerY+120];
[centerX+30 centerY+90 centerX+60 centerY+120];
[centerX+60 centerY+90 centerX+90 centerY+120]; 
[centerX+90 centerY+90 centerX+120 centerY+120];
[centerX+120 centerY+90 centerX+150 centerY+120]; 
...
[centerX-180 centerY+120 centerX-150 centerY+150];
[centerX-150 centerY+120 centerX-120 centerY+150];
[centerX-120 centerY+120 centerX-90 centerY+150];
[centerX-90 centerY+120 centerX-60 centerY+150];
[centerX-60 centerY+120 centerX-30 centerY+150];
[centerX-30 centerY+120 centerX centerY+150];
[centerX+0 centerY+120 centerX+30 centerY+150];
[centerX+30 centerY+120 centerX+60 centerY+150]; 
[centerX+60 centerY+120 centerX+90 centerY+150]; 
[centerX+90 centerY+120 centerX+120 centerY+150]; 
[centerX+120 centerY+120 centerX+150 centerY+150]; 
...
[centerX-180 centerY+150 centerX-150 centerY+180];
[centerX-150 centerY+150 centerX-120 centerY+180]; 
[centerX-120 centerY+150 centerX-90 centerY+180];
[centerX-90 centerY+150 centerX-60 centerY+180];
[centerX-60 centerY+150 centerX-30 centerY+180];
[centerX-30 centerY+150 centerX centerY+180];
[centerX+0 centerY+150 centerX+30 centerY+180];
[centerX+30 centerY+150 centerX+60 centerY+180]; 
[centerX+60 centerY+150 centerX+90 centerY+180]; 
[centerX+90 centerY+150 centerX+120 centerY+180];
[centerX+120 centerY+150 centerX+150 centerY+180]; 
...
[centerX-180 centerY+180 centerX-150 centerY+210];
[centerX-150 centerY+180 centerX-120 centerY+210];
[centerX-120 centerY+180 centerX-90 centerY+210];
[centerX-90 centerY+180 centerX-60 centerY+210];
[centerX-60 centerY+180 centerX-30 centerY+210];
[centerX-30 centerY+180 centerX centerY+210];
[centerX+0 centerY+180 centerX+30 centerY+210];
[centerX+30 centerY+180 centerX+60 centerY+210];
[centerX+60 centerY+180 centerX+90 centerY+210]; 
[centerX+90 centerY+180 centerX+120 centerY+210]; 
[centerX+120 centerY+180 centerX+150 centerY+210] ];

% move things over to center in the middle of the display bc uneven number
% of rows and cols
stim_loc(:,1)= stim_loc(:, 1)+15;
stim_loc(:,2)= stim_loc(:, 2)-60;
stim_loc(:,3)= stim_loc(:, 3)+15;
stim_loc(:,4)= stim_loc(:, 4)-60;

%SET UP KEYBOARD
KbName('UnifyKeyNames');
KbCheckList = [KbName('space'),KbName('ESCAPE')];

%OPEN THE OUTPUT FILE AND GIVE IT HEADINGS 

fname = [subjectID,'.csv'];
fid = fopen(fname,'a');   
fprintf(fid,'%-16.16s,','Subject Code');
fprintf(fid,'%-16.16s,','Gender');
fprintf(fid,'%-16.16s,','Age');
fprintf(fid,'%-16.16s,','Experiment');
fprintf(fid,'%-16.16s,','Handiness');
fprintf(fid,'%-16.16s,','Trial.Number');
fprintf(fid,'%-16.16s,','MazeID');
fprintf(fid,'%-16.16s,','Lateralized');
fprintf(fid,'%-16.16s,','Side');
fprintf(fid,'%-16.16s,','Moves');
fprintf(fid,'%-16.16s,','Solution.RT');
fprintf(fid,'%-16.16s,','Obs.No');                                
fprintf(fid,'%-16.16s,','sVGC.Obs'); 
fprintf(fid,'%-16.16s,','dVGC.Obs'); 
fprintf(fid,'%-16.16s,', 'Orig.RandPos');  
fprintf(fid,'%-16.16s,', 'Aware.ReportObs');  
fprintf(fid,'%-16.16s,','Subj.RT');  
fprintf(fid,'%-16.16s,\n','Time.Trial');  
itrial=1;

%------------------------------------------------------------
%SET UP EYE TRACKER
%------------------------------------------------------------

%Start Eye Tracking
if dummymode == 0
       Eyelink('Initialize')
elseif dummymode == 1
       Eyelink('InitializeDummy')
end

% Specify Graphic environment    
el=EyelinkInitDefaults(mainWin);

if ~EyelinkInit(dummymode, 1)
    fprintf('Eyelink Init aborted.\n');
    cleanup;  % cleanup function
    return;
end
    
% Checking Version    
sw_version = 0;
[v vs]=Eyelink('GetTrackerVersion');
fprintf('Running experiment on a ''%s'' tracker.\n', vs ); 
%
% Setting the resolution, calibration type and data file contents
%
Eyelink('Command', 'screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, height-1);
Eyelink('Message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, height-1);
Eyelink('Command', 'calibration_type = HV5');

% setting the saccadic parameters
Eyelink('Command', 'saccade_velocity_threshold = 30'); %40
Eyelink('Command', 'saccade_acceleration_threshold = 9500'); %80000
Eyelink('Command', 'saccade_motion_threshold = 0.5'); %0.2

% setting the link data through link_sample_data and link_event_filter
Eyelink('Command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
Eyelink('Command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    
% check the software version and record the possible target data
if sw_version >= 4
    Eyelink('Command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,HTARGET,GAZERES,STATUS,INPUT');
    Eyelink('Command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');
else
    Eyelink('Command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT');
    Eyelink('Command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
end

% allow keypress via buttons
Eyelink('Command', 'button_function 5 "accept_target_fixation"');

% Open File

filename = [subjectID, '.edf'];
Eyelink('OpenFile',filename)

% check that the eye tracker is still connected.
if Eyelink('IsConnected') ~= 1 && dummymode == 0
    fprintf('Not connected, clean up\n');
    Eyelink('Shutdown');
    Screen('CloseAll');
    return;
end

%------------------------------------------------------------
% CALIBRATION
%------------------------------------------------------------

% setup the proper calibration foreground and background colors
el.backgroundcolour = grey;
el.calibrationtargetcolour = [0 0 0];

% set the second value in each line to 0 to turn off the sound
el.cal_target_beep = [600 0.5 0.05];
el.drift_correction_target_beep = [600 0.5 0.05];
el.calibration_failed_beep = [400 0.5 0.25];
el.calibration_success_beep = [800 0.5 0.25];
el.drift_correction_failed_beep = [400 0.5 0.25];
el.drift_correction_success_beep = [800 0.5 0.25];
EyelinkUpdateDefaults(el);
EyelinkDoTrackerSetup(el);

%SET UP KEYBOARD

KbName('UnifyKeyNames');
KbCheckList = [KbName('space'),KbName('ESCAPE')];

%------------------------------------------------------------
% DISPLAY BEGINING SCREEN
%------------------------------------------------------------

%message windows

messageWindow = Screen(mainWin,'OpenOffscreenWindow',grey);
Screen(messageWindow,'TextSize',11);

WaitSecs(1);
messageWindow = Screen(mainWin,'OpenOffscreenWindow',grey);
Screen(messageWindow,'TextSize',22)
Width=Screen(messageWindow,'TextBounds','VGC behavioural task');
Screen('DrawText',messageWindow,'VGC behavioural task',centerX-(round(Width(3)/2)), centerY, white);
Width=Screen(messageWindow,'TextBounds','Press the Spacebar to Continute');
Screen('DrawText',messageWindow,'Press the Spacebar to Continute',centerX-(round(Width(3)/2)), centerY+350, white);
Screen('DrawTexture',mainWin,messageWindow);
Screen('Flip',mainWin)
           
          while 1
    [keyIsDown,secs,keyCode] = KbCheck; 
    if  keyCode(32)==1 || keyCode(44)==1
        break
    end
end


WaitSecs(1);
messageWindow = Screen(mainWin,'OpenOffscreenWindow',grey);
Screen(messageWindow,'TextSize'  , 22)
Width=Screen(messageWindow,'TextBounds','Please Make Sure That CAPS is OFF');
Screen('DrawText',messageWindow,'Please Make Sure That CAPS is OFF',centerX-(round(Width(3)/2)), centerY, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2)),centerY+350, white);
Screen('DrawTexture',mainWin,messageWindow);
Screen('Flip',mainWin)

while 1
    [keyIsDown,secs,keyCode] = KbCheck; 
    if  keyCode(32)==1 || keyCode(44)==1
        break
    end
end

WaitSecs(1);
messageWindow = Screen(mainWin,'OpenOffscreenWindow',grey);
Screen(messageWindow,'TextSize'  , 22)
Width=Screen(messageWindow,'TextBounds','In this task you will be asked to solve a series of mazes');
Screen('DrawText',messageWindow,'In this task you will be asked to solve a series of mazes',centerX-(round(Width(3)/2)), centerY-300, white);
Width=Screen(messageWindow,'TextBounds','Here is an example maze:');
Screen('DrawText',messageWindow,'Here is an example maze:',centerX-(round(Width(3)/2)), centerY-260, white);

colour_stims= reshape(stim_right_mazes_lat{1}', [1, 11*11]);
colour_stims= vertcat(colour_stims{:})';

position_self{1,1}= stim_right_mazes_lat{1}';
[irow ,icol]=find(cellfun(@sum, (cellfun(@(x) x==[0 1 1], position_self{1,1}, 'UniformOutput', false))) ==3);
self_pos=  stim_loc(11*(icol-1) + irow, :);

Screen('FillRect',messageWindow,colour_stims ,stim_loc');
Screen('FrameRect',messageWindow,black ,stim_loc', 0.5  );
Screen('DrawLines',messageWindow,center_fix_loc, 7, white);
Screen('DrawDots', messageWindow, [centerX, centerY-15], 7, black, [], 2)

Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2)),centerY+350, white);
Screen('DrawTexture',mainWin,messageWindow);
Screen('Flip',mainWin)

while 1
    [keyIsDown,secs,keyCode] = KbCheck; 
    if  keyCode(32)==1 || keyCode(44)==1
        break
    end
end


WaitSecs(1);
messageWindow = Screen(mainWin,'OpenOffscreenWindow',grey);
Screen(messageWindow,'TextSize'  , 22)
Width=Screen(messageWindow,'TextBounds','you will navigate yourself (a red circle) to the goal');
Screen('DrawText',messageWindow,'you will navigate yourself (a red circle) to the goal',centerX-(round(Width(3)/2)), centerY-360, white);
Width=Screen(messageWindow,'TextBounds','your character will start at the cyan square');
Screen('DrawText',messageWindow,'your character will start at the cyan square',centerX-(round(Width(3)/2)), centerY-320, white);
Width=Screen(messageWindow,'TextBounds','and you will need to make it to the green square');
Screen('DrawText',messageWindow,'and you will need to make it to the green square',centerX-(round(Width(3)/2)), centerY-280, white);

Screen('FillRect',messageWindow,colour_stims ,stim_loc');
Screen('FrameRect',messageWindow,black ,stim_loc', 0.5  );
Screen('DrawLines',messageWindow,center_fix_loc, 7, white);
Screen('DrawDots', messageWindow, [centerX, centerY-15], 7, black, [], 2)
Screen('DrawDots', messageWindow, [self_pos(1) + 15, self_pos(2) + 15], 20, [1 0 0 ], [], 2)


Width=Screen(messageWindow,'TextBounds','try to make it to the green square before it turns yellow');
Screen('DrawText',messageWindow,'try to make it to the green square before it turns yellow',centerX-(round(Width(3)/2)), centerY+260, white);
Width=Screen(messageWindow,'TextBounds','BEWARE of obstacles in blue');
Screen('DrawText',messageWindow,'BEWARE of obstacles in blue',centerX-(round(Width(3)/2)), centerY+300, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2)),centerY+350, white);
Screen('DrawTexture',mainWin,messageWindow);
Screen('Flip',mainWin)

while 1
    [keyIsDown,secs,keyCode] = KbCheck; 
    if  keyCode(32)==1 || keyCode(44)==1
        break
    end   
end



WaitSecs(1);
messageWindow = Screen(mainWin,'OpenOffscreenWindow',grey);
Screen(messageWindow,'TextSize'  , 22)
Width=Screen(messageWindow,'TextBounds',' we ask that you keep looking at the cross in the middle throughout the task');
Screen('DrawText',messageWindow,'we ask that you keep looking at the cross in the middle throughout the task',centerX-(round(Width(3)/2)), centerY-360, white);
Width=Screen(messageWindow,'TextBounds',' and to minimize eye movements when the maze is on the screen');
Screen('DrawText',messageWindow,'and to minimize eye movements when the maze is on the screen',centerX-(round(Width(3)/2)), centerY-320, white);

Screen('FillRect',messageWindow,colour_stims ,stim_loc');
Screen('FrameRect',messageWindow,black ,stim_loc', 0.5  );
Screen('DrawLines',messageWindow,center_fix_loc, 7, white);
Screen('DrawDots', messageWindow, [centerX, centerY-15], 7, black, [], 2)
Screen('DrawDots', messageWindow, [self_pos(1) + 15, self_pos(2) + 15], 20, [1 0 0 ], [], 2)


Width=Screen(messageWindow,'TextBounds','REMEBER TO KEEP YOUR EYES FIXATED ON THE CENTRE CROSS' );
Screen('DrawText',messageWindow,'REMEBER TO KEEP YOUR EYES FIXATED ON THE CENTRE CROSS',centerX-(round(Width(3)/2)), centerY+260, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2)),centerY+350, white);
Screen('DrawTexture',mainWin,messageWindow);
Screen('Flip',mainWin)

while 1
    [keyIsDown,secs,keyCode] = KbCheck; 
    if  keyCode(32)==1 || keyCode(44)==1
        break
    end   
end


WaitSecs(1);
messageWindow = Screen(mainWin,'OpenOffscreenWindow',grey);
Screen(messageWindow,'TextSize'  , 22)
Width=Screen(messageWindow,'TextBounds','At the start of each trial, you will have');
Screen('DrawText',messageWindow,'At the start of each trial, you will have',centerX-(round(Width(3)/2)), centerY-300, white);
Width=Screen(messageWindow,'TextBounds','a few seconds to PLAN how you will solve the maze');
Screen('DrawText',messageWindow,'a few seconds to PLAN how you will solve the maze',centerX-(round(Width(3)/2)), centerY-240, white);
Width=Screen(messageWindow,'TextBounds','Afterwards the maze will disappear');
Screen('DrawText',messageWindow,'Afterwards the maze will disappear',centerX-(round(Width(3)/2)), centerY-180, white);
Width=Screen(messageWindow,'TextBounds','When the red circle reappears you can begin to solve it!');
Screen('DrawText',messageWindow,'When the red circle reappears you can begin to solve it!',centerX-(round(Width(3)/2)), centerY-120, white);
Width=Screen(messageWindow,'TextBounds','Use the arrow keys to navigate through the maze with your RIGHT hand');
Screen('DrawText',messageWindow,'Use the arrow keys to navigate through the maze with your RIGHT hand',centerX-(round(Width(3)/2)), centerY-60, white);
Width=Screen(messageWindow,'TextBounds','Please navigate the mazes as quickly and as accurately as possible');
Screen('DrawText',messageWindow,'Please navigate the mazes as quickly and as accurately as possible',centerX-(round(Width(3)/2)), centerY-0, white);

Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2)),centerY+350, white);
Screen('DrawTexture',mainWin,messageWindow);
Screen('Flip',mainWin)

while 1
    [keyIsDown,secs,keyCode] = KbCheck; 
    if  keyCode(32)==1 || keyCode(44)==1
        break
    end   
end


WaitSecs(1);
messageWindow = Screen(mainWin,'OpenOffscreenWindow',grey);
Screen(messageWindow,'TextSize'  , 22)
Width=Screen(messageWindow,'TextBounds','We are interested in your thought process while navigating each maze');
Screen('DrawText',messageWindow,'We are interested in your thought process while navigating each maze',centerX-(round(Width(3)/2)), centerY-300, white);
Width=Screen(messageWindow,'TextBounds','Following each trial we will ask how AWARE of an obstacle you were at any point');
Screen('DrawText',messageWindow,'Following each trial we will ask how AWARE of an obstacle you were at any point',centerX-(round(Width(3)/2)), centerY-240, white);
Width=Screen(messageWindow,'TextBounds','Your answer should reflect the amount you paid ATTENTION this obstacle');
Screen('DrawText',messageWindow,'Your answer should reflect the amount you paid ATTENTION this obstacle',centerX-(round(Width(3)/2)), centerY-180, white);
Width=Screen(messageWindow,'TextBounds','during the PLANNING PHASE');
Screen('DrawText',messageWindow,'during the PLANNING PHASE',centerX-(round(Width(3)/2)), centerY-120, white);
Width=Screen(messageWindow,'TextBounds','YOUR ANSWER WILL NOT AFFECT YOUR PERFORMANCE ON THE TASK');
Screen('DrawText',messageWindow,'YOUR ANSWER WILL NOT AFFECT YOUR PERFORMANCE ON THE TASK',centerX-(round(Width(3)/2)), centerY-60, white);

Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2)), centerY+350, white);
Screen('DrawTexture',mainWin,messageWindow);
Screen('Flip',mainWin)


while 1
    [keyIsDown,secs,keyCode] = KbCheck; 
    if  keyCode(32)==1 || keyCode(44)==1
        break
    end
end
         
    
WaitSecs(1);
messageWindow = Screen(mainWin,'OpenOffscreenWindow',grey);
Screen(messageWindow,'TextSize'  , 22)
Width=Screen(messageWindow,'TextBounds','At the end of each trial, you will be asked');
Screen('DrawText',messageWindow,'At the end of each trial, you will be asked',centerX-(round(Width(3)/2)), centerY-300, white);
Screen(messageWindow,'TextSize'  , 30)
Width=Screen(messageWindow,'TextBounds','How aware of the highlighted obstacle were you at any point?');
Screen('DrawText',messageWindow,'How aware of the highlighted obstacle were you at any point?',centerX-(round(Width(3)/2)), centerY-240, white);
Screen(messageWindow,'TextSize'  , 22)
Width=Screen(messageWindow,'TextBounds','You will respond on a 9 point scale like the one below:');
Screen('DrawText',messageWindow,'You will respond on a 9 point scale like the one below:',centerX-(round(Width(3)/2)), centerY-160, white);

% draw scale 
                   scale_pos= [centerX-400, centerY+0; centerX+400, centerY+0; 
                               centerX-400, centerY-40; centerX-400, centerY+40; 
                            centerX-300, centerY-40; centerX-300, centerY+40;
                            centerX-200, centerY-40; centerX-200, centerY+40;
                            centerX-100, centerY-40; centerX-100, centerY+40;
                           centerX-0, centerY-40; centerX-0, centerY+40;
                           centerX+100, centerY-40; centerX+100, centerY+40;
                           centerX+200, centerY-40; centerX+200, centerY+40;
                           centerX+300, centerY-40; centerX+300, centerY+40;
                           centerX+400, centerY-40; centerX+400, centerY+40]';

Screen('DrawLines',messageWindow,scale_pos, 10, black);
head   = [ centerX-0, centerY-40 ]; % coordinates of head
width  = 20;           % width of arrow head
points = [ head-[width,0]         % left corner
               head+[width,0]         % right corner
               head+[0,width] ];      % vertex
Screen('FillPoly', messageWindow, white, points);

Width=Screen(messageWindow,'TextBounds','use the arrow keys to move the cursor along the scale');
Screen('DrawText',messageWindow,'use the arrow keys to move the cursor along the scale',centerX-(round(Width(3)/2)), centerY+220, white);
Width=Screen(messageWindow,'TextBounds','press space when you are ready to submit your answer');
Screen('DrawText',messageWindow,'press space when you are ready to submit your answer',centerX-(round(Width(3)/2)), centerY+260, white);

Width=Screen(messageWindow,'TextBounds','not a lot');
Screen('DrawText',messageWindow,'not a lot',centerX-490-(round(Width(3)/2)), centerY, white);
Width=Screen(messageWindow,'TextBounds','a lot');
Screen('DrawText',messageWindow,'a lot',centerX+500-(round(Width(3)/2)), centerY, white);


Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2)), centerY+350, white);
Screen('DrawTexture',mainWin,messageWindow);
Screen('Flip',mainWin)


while 1
    [keyIsDown,secs,keyCode] = KbCheck; 
    if  keyCode(32)==1 || keyCode(44)==1
        break
    end
end
                  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRACTICE TRIALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 if practice == 1
    
%------------------------------------------------------------
%PRACTICE MATRIX
%------------------------------------------------------------ 

nPracticeTrials=5;

%------------------------------------------------------------
%PRACTICE MESSAGE
%------------------------------------------------------------ 

WaitSecs(1);
messageWindow = Screen(mainWin,'OpenOffscreenWindow',grey);
Screen(messageWindow,'TextSize'  , 22)
Width=Screen(messageWindow,'TextBounds','You will now perform 5 practice trials');
Screen('DrawText',messageWindow,'You will now perform 5 practice trials',centerX-(round(Width(3)/2)), centerY, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2)), centerY+350, white);
Screen('DrawTexture',mainWin,messageWindow);
Screen('Flip',mainWin)
           
while 1
    [keyIsDown,secs,keyCode] = KbCheck; 
    if  keyCode(32)==1 || keyCode(44)==1
        break
    end
end


WaitSecs(1);        
messageWindow = Screen(mainWin,'OpenOffscreenWindow',grey);
Screen(messageWindow, 'TextSize' , 22)
Width=Screen(messageWindow,'TextBounds','Press the spacebar to start practice');
Screen('DrawText',messageWindow,'Press the spacebar to start practice',centerX-(round(Width(3)/2)), centerY, white);
Screen('DrawTexture',mainWin,messageWindow);
Screen('Flip',mainWin)
           
while 1
    [keyIsDown,secs,keyCode] = KbCheck; 
    if  keyCode(32)==1 || keyCode(44)==1
        break
    end
end

randtrials4pract= randperm(size(trialMatrix,1),nPracticeTrials);

%------------------------------------------------------------
%ALLPRACTICETRIALS
%------------------------------------------------------------    
    
for iptrial=1:nPracticeTrials

    this_practicetrial=randtrials4pract(iptrial);

%------------------------------------------------------------
%DISPLAY SETUP
%------------------------------------------------------------

    %taskwindows
    GreyScreen=Screen('OpenOffscreenWindow',mainWin,grey);

%-------------------------------------------------------------------------------------------
%DISPLAY PREPARATION AND ORGANIZATION OF FIXATION
%------------------------------------------------------------------------------------------
                
                %--------------------------------------------------------------------
                %STREAM LOOP AND COLLECT RESPONSE
                %--------------------------------------------------------------------                        
                     tic 
                    %Reset Variables
                    GreyWinTime=0;
                    FixationWinTime=0;
                    StimulusWinTime=0;
                    StimulusOffsetWinTime=0;
                    ResponseWinTime=0;

                    irow=0;
                    icol= 0;
                    grow=0;
                    gcol=0;
                    colour_stims=0;

                    keyIsDown=0;
                    secs=0;
                    keyCode=[];
                    subjreported=0;
                    Subjective_key_pressed=0;

                %------------------------------------------------------------
                %Fixation-Cue SOA
                %------------------------------------------------------------                     
                    
                FixOffSOA = round((60 - 30)*rand(1,1) + 30); %random between 500ms and 1000ms   
                colour_stims= maze_array(1,this_practicetrial);
                colour_stims= reshape(colour_stims{1}', [1, 11*11]);
                colour_stims= vertcat(colour_stims{:})';

                colour_stims2= colour_stims;
                index_obs=find(sum(colour_stims2) ==2 & colour_stims2(3,:) ==1  & colour_stims2(1,:) ==0.5);
                colour_stims2([1,2],index_obs)=1;

                    % Screen priority
                    Priority(MaxPriority(mainWin));
                    Priority(2);
                     
                    %show grey Screen, 
                    Screen('DrawTexture',mainWin,GreyScreen);
                    GreyWinTime=Screen('flip',mainWin);
                    
                    % start recording eye position
                    Eyelink('startrecording');
                    % record a few samples before we actually start displaying
                    WaitSecs(0.1);
                    % mark zero-plot time in data file
                    Eyelink('message', 'SYNCTIME');
                    
                    %show white
                    Screen('FillRect',mainWin,white ,stim_loc');
                    Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                    BlankWinTime=Screen('flip',mainWin,GreyWinTime + (20*IFI) - slack,0); 

                    %show Fixation
                    Screen('FillRect',mainWin,color_fixation ,stim_loc');
                    Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc, 7, white);
                    Screen('DrawDots', mainWin, [centerX, centerY-15], 7, black, [], 2)
                    FixationWinTime=Screen('flip',mainWin,BlankWinTime + (FixOffSOA*IFI) - slack,0);

                    
                    SetMouse(300,300);
                    % Making Sure that the participants look at fixation
                    while 1 
                            [keyIsDown,secs,keyCode] = KbCheck; 
                                if  keyCode(81)==1 
                                    sca;
                                    break
                                end
                                
                            error=Eyelink('checkrecording');        % Check recording status, stop display if error
                            if(error~=0)
                                break;
                            end       
                            
                        fixrect = SetRect(centerX-25,centerY-40,centerX+25,centerY+10);
                            
                        % check for endsaccade events
                        if Eyelink('isconnected') == el.dummyconnected % in dummy mode use mousecoordinates
                            ShowCursor;
                            [x,y,button] = GetMouse(window);
                            evt.gavx=x;
                            evt.gavy=y;
                            evtype=el.STARTFIX;
                                    if  1==IsInRect(evt.gavx,evt.gavy,fixrect)
                                        FixationTime = GetSecs;
                                        FixationWinToFix = FixationTime - FixationWinTime;
                                        HideCursor;
                                        break;
                                    end
                        else % check for events
                            evtype=Eyelink('getnextdatatype');
                        end
                        
                        if evtype==8
                            if Eyelink('isconnected') == el.connected % if we're really measuring eye-movements
                                evt = Eyelink('getfloatdata', evtype);
                                    if  1==IsInRect(evt.gavx,evt.gavy,fixrect)
                                        FixationTime = GetSecs;
                                        FixationWinToFix = FixationTime - FixationWinTime;
                                        break;
                                    end
                            end
                            
                    elseif evtype == 6
                            if Eyelink('isconnected') == el.connected % if we're really measuring eye-movements
                                evt = Eyelink('getfloatdata', evtype);
                                    if  1==IsInRect(evt.genx,evt.geny,fixrect)
                                    FixationTime = GetSecs;
                                    FixationWinToFix = FixationTime - FixationWinTime;
                                    break;
                                    end
                            end                            
                        end
                    end              
                    
                    %show Stimuluas
                    Screen('FillRect',mainWin, colour_stims ,stim_loc');
                    Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc, 7, white);
                    Screen('DrawDots', mainWin, [centerX, centerY-15], 7, black, [], 2)
                    StimulusWinTime= Screen('flip',mainWin,FixationWinTime + (60*IFI) - slack,0);


                    %show Delay period
                    Screen('FillRect',mainWin,color_fixation ,stim_loc');
                    Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc, 7, white);
                    Screen('DrawDots', mainWin, [centerX, centerY-15], 7, black, [], 2)
                    StimulusOffsetWinTime= Screen('flip',mainWin,StimulusWinTime + (360*IFI) - slack,0);
              
                    % offset coloured obstacles
                    Screen('FillRect',mainWin, colour_stims2 ,stim_loc');
                    Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc, 7, white);
                    Screen('DrawDots', mainWin, [centerX, centerY-15], 7, black, [], 2)
                    ResponseWinTime= Screen('flip',mainWin,StimulusOffsetWinTime + (60*IFI) - slack,0);


                    % get starting position of icon
                    position_self= maze_array(1,this_practicetrial);
                    position_self{1,1}= position_self{1,1}';
                    [irow ,icol]=find(cellfun(@sum, (cellfun(@(x) x==[0 1 1], position_self{1,1}, 'UniformOutput', false))) ==3);

                    % get position of goal
                    [grow ,gcol]=find(cellfun(@sum, (cellfun(@(x) x==[0 1 0], position_self{1,1}, 'UniformOutput', false))) ==3);
                    moves=0;

                    while 1
                        % update position of icon if participant moved
                             [keyIsDown,secs,keyCode]=KbCheck;

                             if keyIsDown==1
                                 keyCode= find(keyCode==1);

                                 if keyCode(1) == 37 &&  irow-1 > 0  &&  irow-1 < 12 &&  sum(position_self{1}{ irow-1, icol} == [0.5 0.5 1]) ~=3 &&  sum(position_self{1}{ irow-1, icol} == [0 0 0]) ~=3
                                     irow= irow-1;
                                     moves=moves+1;

                                 elseif keyCode(1) == 40 &&  icol+1 > 0 &&  icol+1 < 12 &&  sum(position_self{1}{ irow, icol+1} == [0.5 0.5 1]) ~=3 &&  sum(position_self{1}{ irow, icol+1} == [0 0 0]) ~=3
                                     icol= icol+1;
                                     moves=moves+1;

                                 elseif keyCode(1) == 39 &&  irow+1 > 0 &&  irow+1 < 12 &&  sum(position_self{1}{ irow+1, icol} == [0.5 0.5 1]) ~=3 &&  sum(position_self{1}{ irow+1, icol} == [0 0 0]) ~=3
                                      irow= irow+1;
                                      moves=moves+1;

                                 elseif keyCode(1) == 38 &&  icol-1 > 0 &&  icol-1 < 12 &&  sum(position_self{1}{ irow, icol-1} == [0.5 0.5 1]) ~=3 &&  sum(position_self{1}{ irow, icol-1} == [0 0 0]) ~=3
                                      icol= icol-1;
                                      moves=moves+1;
                                 end
                                 KbReleaseWait;
                             end
                             self_pos=  stim_loc(11*(icol-1) + irow, :);
                             goal_pos=  stim_loc(11*(gcol-1) + grow, :);

                             % change goal to yellow to motivate
                             % participants 

                             Time_Factor= (GetSecs-ResponseWinTime)/8;

                             if Time_Factor > 1
                                 Time_Factor =1;
                             end

                             Time_Factor=round(256*Time_Factor);

                             if Time_Factor ==0
                                 Time_Factor=1;
                             end

                        %show Start of response 
                        Screen('FillRect',mainWin, colour_stims2 ,stim_loc');
                        Screen('FillRect',mainWin,  cMap(Time_Factor,:) ,goal_pos);
                        Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                        % add circle 
                        Screen('DrawDots', mainWin, [self_pos(1) + 15, self_pos(2) + 15], 20, [1 0 0 ], [], 2)
                        Screen('DrawLines',mainWin,center_fix_loc, 7, white);
                        Screen('DrawDots', mainWin, [centerX, centerY-15], 7, black, [], 2)
                        Screen('flip',mainWin,ResponseWinTime + (1*IFI) - slack,0);

                        % break loop if solved
                        if irow == grow && icol == gcol
                            % add code here to get RT
                            mazeRT= GetSecs - ResponseWinTime;
                            break;
                        end

                    end

                    % ask about subjective report now
                    Screen('FillRect',mainWin,color_mask ,stim_loc');
                    Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc, 7, white);
                    Screen('DrawDots', mainWin, [centerX, centerY-15], 7, black, [], 2)
                    Screen('flip',mainWin,mazeRT + (1*IFI) - slack,0);


                    for numobstacles =0:5 % index off bc of python
                         % start at random position of subj report scale not to bias participant response
                         %subjpos=randi([1 9], 1);
                         subjpos=5;
                         subjposorig=subjpos;
    
                         % draw scale 
                        Screen(mainWin, 'TextSize' , 22)
                        Width=Screen(mainWin,'TextBounds','How aware of  the highlighted obstacle were you at any point?');
                        Screen('DrawText',mainWin,'How aware of  the highlighted obstacle were you at any point?',centerX-(round(Width(3)/2)), centerY-300, white);
                        
                        colour_stims= color_fixationtemp;
                        %colour_stims= maze_array{1, this_practicetrial};
                        obstacles=maze_obstacles{1, this_practicetrial};
                        index_obstacle=  obstacles == num2str(numobstacles);
                        colour_stims(index_obstacle) = {[1,0 0]};
    
                        colour_stims= reshape(colour_stims', [1, 11*11]);
                        colour_stims= vertcat(colour_stims{:})';
    
                        %show Start of response 
                        Screen('FillRect',mainWin, colour_stims ,stim_loc');
                        Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                        Screen('DrawLines',mainWin,center_fix_loc, 7, white);
                        Screen('DrawDots', mainWin, [centerX, centerY-15], 7, black, [], 2)
                        
                       scale_pos= [centerX-400, centerY+270; centerX+400, centerY+270; 
                           centerX-400, centerY+270-30; centerX-400, centerY+270+30; 
                                centerX-300, centerY+270-30; centerX-300, centerY+270+30;
                                centerX-200, centerY+270-30; centerX-200, centerY+270+30;
                                centerX-100, centerY+270-30; centerX-100, centerY+270+30;
                               centerX-0, centerY+270-30; centerX-0, centerY+270+30;
                               centerX+100, centerY+270-30; centerX+100, centerY+270+30;
                               centerX+200, centerY+270-30; centerX+200, centerY+270+30;
                               centerX+300, centerY+270-30; centerX+300, centerY+270+30;
                               centerX+400, centerY+270-30; centerX+400, centerY+270+30]';
                            
                            Screen('DrawLines',mainWin,scale_pos, 10, black);
                            head   = [ (centerX+ ((800/8) * (subjpos- 5))), centerY+270-40 ]; % coordinates of head
                            width  = 20;           % width of arrow head
                            points = [ head-[width,0]         % left corner
                                           head+[width,0]         % right corner
                                           head+[0,width] ];      % vertex
                            Screen('FillPoly', mainWin, white, points);
                            
                            Width=Screen(mainWin,'TextBounds','not a lot');
                            Screen('DrawText',mainWin,'not a lot',centerX-490-(round(Width(3)/2)), centerY+270, white);
                            Width=Screen(mainWin,'TextBounds','a lot');
                            Screen('DrawText',mainWin,'a lot',centerX+500-(round(Width(3)/2)), centerY+270, white);
                            Width=Screen(mainWin,'TextBounds','Press the spacebar to submit');
                            Screen('DrawText',mainWin,'Press the spacebar to submit',centerX-(round(Width(3)/2)), centerY+380, white);
                            SubjWinTime= Screen('flip',mainWin,mazeRT + (31*IFI) - slack,0);
    
                            subjreported=1;
                            KbReleaseWait;
    
                            % loop until participant says they are happy
                            % with report by pressing space (subjreported)
                        while subjreported
                               [keyIsDown,secs,keyCode]=KbCheck;
                                 if keyIsDown==1
                                     keyCode= find(keyCode==1);
                                     if keyCode(1) == 37 &&  subjpos-1 > 0 &&  subjpos-1 < 10
                                         subjpos= subjpos-1;
                                     elseif keyCode(1) == 39 &&  subjpos+1 > 0 && subjpos+1 < 10
                                          subjpos= subjpos+1;
                                     elseif  keyCode(1) == 32 
                                         subjreported=0;
                                     end
                                 end
    
                        % draw scale 
                            Width=Screen(mainWin,'TextBounds','How aware of  the highlighted obstacle were you at any point?');
                            Screen('DrawText',mainWin,'How aware of  the highlighted obstacle were you at any point?',centerX-(round(Width(3)/2)), centerY-300, white);
                            
                             %show Start of response 
                            Screen('FillRect',mainWin, colour_stims ,stim_loc');
                            Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                            Screen('DrawLines',mainWin,center_fix_loc, 7, white);
                            Screen('DrawDots', mainWin, [centerX, centerY-15], 7, black, [], 2)
    
                            Screen('DrawLines',mainWin,scale_pos, 10, black);
                            head   = [ (centerX+ ((800/8) * (subjpos-5))), centerY+270-40 ]; % coordinates of head
                            width  = 20;           % width of arrow head
                            points = [ head-[width,0]         % left corner
                                           head+[width,0]         % right corner
                                           head+[0,width] ];      % vertex
                            Screen('FillPoly', mainWin, white, points);
                            
                            Width=Screen(mainWin,'TextBounds','not a lot');
                            Screen('DrawText',mainWin,'not a lot',centerX-490-(round(Width(3)/2)), centerY+270, white);
                            Width=Screen(mainWin,'TextBounds','a lot');
                            Screen('DrawText',mainWin,'a lot',centerX+500-(round(Width(3)/2)), centerY+270, white);
                            Width=Screen(mainWin,'TextBounds','Press the spacebar to submit');
                            Screen('DrawText',mainWin,'Press the spacebar to submit',centerX-(round(Width(3)/2)), centerY+380, white);
                            SubjWinTime= Screen('flip',mainWin,SubjWinTime + (1*IFI) - slack,0);
                            WaitSecs(0.1);
                        end
                    end

                    %show Black Screen
                    Screen('DrawTexture',mainWin,GreyScreen);
                    GreyWinTime=Screen('flip',mainWin,0);
                   
                    %END STREAM LOOP
                    %---------------
                    % AlLow other processes to run optimally
                    Priority(0); 
                    toc
 
end

%------------------------------------------------------------
%END PRACTICE MESSAGE
%------------------------------------------------------------

WaitSecs(1);      
messageWindow = Screen(mainWin,'OpenOffscreenWindow',grey);
Screen(messageWindow,'TextSize'  , 22)
Width=Screen(messageWindow,'TextBounds','Practice is completed');
Screen('DrawText',messageWindow,'Practice is completed',centerX-(round(Width(3)/2)), centerY, white);
Width=Screen(messageWindow,'TextBounds','Press the Spacebar to Continue');
Screen('DrawText',messageWindow,'Press the Spacebar to Continue',centerX-(round(Width(3)/2)), centerY+350, white);
Screen('DrawTexture',mainWin,messageWindow);
Screen('Flip',mainWin)
           
while 1
    [keyIsDown,secs,keyCode] = KbCheck; 
    if  keyCode(32)==1 || keyCode(44)==1
        break
    end
end

end        
                    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END PRACTICE TRIALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TASK TRIALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                      

WaitSecs(1);
messageWindow = Screen(mainWin,'OpenOffscreenWindow',grey);
Screen(messageWindow,'TextSize',22)
Width=Screen(messageWindow,'TextBounds','You will now perform the task');
Screen('DrawText',messageWindow,'You will now perform the task',centerX-(round(Width(3)/2)), centerY, white);
Width=Screen(messageWindow,'TextBounds','Press the Spacebar to Continue');
Screen('DrawText',messageWindow,'Press the Spacebar to Continue',centerX-(round(Width(3)/2)), centerY+350, white);
Screen('DrawTexture',mainWin,messageWindow);
Screen('Flip',mainWin)
           
while 1
    [keyIsDown,secs,keyCode] = KbCheck; 
    if  keyCode(32)==1 || keyCode(44)==1
        break
    end
end



WaitSecs(1);
messageWindow = Screen(mainWin,'OpenOffscreenWindow',grey);
Screen(messageWindow,'TextSize',22)
Width=Screen(messageWindow,'TextBounds','Press Space Bar to Begin Task');
Screen('DrawText',messageWindow,'Press Space Bar to Begin Task',centerX-(round(Width(3)/2)), centerY, white);
Screen('DrawTexture',mainWin,messageWindow);
Screen('Flip',mainWin)
           
while 1
    [keyIsDown,secs,keyCode] = KbCheck; 
    if  keyCode(32)==1 || keyCode(44)==1
        break
    end
end

%------------------------------------------------------------
%BLOCK SETUP
%------------------------------------------------------------    

block = 1;

%------------------------------------------------------------
%TRIALS SETUP
%------------------------------------------------------------    

for this_trial=1:nTrials
        
%------------------------------------------------------------
%DISPLAY SETUP
%------------------------------------------------------------

    %taskwindows
    GreyScreen=Screen('OpenOffscreenWindow',mainWin,grey);

%-------------------------------------------------------------------------------------------
%DISPLAY PREPARATION AND ORGANIZATION OF FIXATION
%------------------------------------------------------------------------------------------

                tic
                %------------------------------------------------------------
                %Fixation-Cue SOA
                %------------------------------------------------------------                     
                    
                FixOffSOA = round((60 - 30)*rand(1,1) + 30); %random between 500ms and 1000ms   colour_stims= maze_array(1,this_trial);
                colour_stims= maze_array(1,this_trial);
                colour_stims= reshape(colour_stims{1}', [1, 11*11]);
                colour_stims= vertcat(colour_stims{:})';

                colour_stims2= colour_stims;
                index_obs=find(sum(colour_stims2) ==2 & colour_stims2(3,:) ==1  & colour_stims2(1,:) ==0.5);
                colour_stims2([1,2],index_obs)=1;
                
                %--------------------------------------------------------------------
                %STREAM LOOP AND COLLECT RESPONSE
                %--------------------------------------------------------------------                        
                    
                    %Reset Variables
                    GreyWinTime=0;
                    FixationWinTime=0;
                    StimulusWinTime=0;
                    StimulusOffsetWinTime=0;
                    ResponseWinTime=0;

                    irow=0;
                    icol= 0;
                    grow=0;
                    gcol=0;

                    keyIsDown=0;
                    secs=0;
                    keyCode=[];
                    subjectivereports=[];
                    mazeRT=0;
                    
                     Eyelink('Message', 'TRIALID Trial %d', this_trial);
                Eyelink('Command', 'record_status_message "TRIAL Trial %d"', this_trial);  
                Eyelink('Command', 'set_idle_mode');
                    
               
                % start recording eye movements for the current trial  (waitsecs used to record a few samples before actually displaying the stimuli, less data loss)
                Eyelink('StartRecording');
                WaitSecs(0.1);
                % run the drift correction sequence
                Eyelink('Command', 'clear_screen 0');
                Eyelink('Command', 'draw_filled_box %d %d %d %d 2', centerX-25,centerY-40,centerX+25,centerY+10); 
                Eyelink('Command', 'draw_filled_box %d %d %d %d 4' ,795,360,1125,690)
                    
                    % Screen priority
                    Priority(MaxPriority(mainWin));
                    Priority(2);
                     
                    %show grey Screen, 
                    Screen('DrawTexture',mainWin,GreyScreen);
                    GreyWinTime=Screen('flip',mainWin);
                    Eyelink('Message', 'Grey'); 

                    
                    %show white
                    Screen('FillRect',mainWin,white ,stim_loc');
                    Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                    BlankWinTime=Screen('flip',mainWin,GreyWinTime + (20*IFI) - slack,0); 
                     Eyelink('Message', 'Blank'); 

                    %show Fixation
                    Screen('FillRect',mainWin,color_fixation ,stim_loc');
                    Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc, 7, white);
                    Screen('DrawDots', mainWin, [centerX, centerY-15], 7, black, [], 2);
                    Screen('FillRect',mainWin,[1,0,0] ,[centerX-25,centerY-40,centerX+25,centerY+10]);
                    FixationWinTime=Screen('flip',mainWin,BlankWinTime + (FixOffSOA*IFI) - slack,0);
                    Eyelink('Message', 'Fixation');
                    
                    SetMouse(300,300);
                    % Making Sure that the participants look at fixation
                    while 1 
                            [keyIsDown,secs,keyCode] = KbCheck; 
                                if  keyCode(81)==1 
                                    sca;
                                    break
                                end
                                
                            error=Eyelink('checkrecording');        % Check recording status, stop display if error
                            if(error~=0)
                                break;
                            end       
                            
                        fixrect = SetRect(centerX-25,centerY-40,centerX+25,centerY+10);
                            
                        % check for endsaccade events
                        if Eyelink('isconnected') == el.dummyconnected % in dummy mode use mousecoordinates
                            ShowCursor;
                            [x,y,button] = GetMouse(window);
                            evt.gavx=x;
                            evt.gavy=y;
                            evtype=el.STARTFIX;
                                    if  1==IsInRect(evt.gavx,evt.gavy,fixrect)
                                        FixationTime = GetSecs;
                                        FixationWinToFix = FixationTime - FixationWinTime;
                                        HideCursor;
                                        break;
                                    end
                        else % check for events
                            evtype=Eyelink('getnextdatatype');
                        end
                        
                        if evtype==8
                            if Eyelink('isconnected') == el.connected % if we're really measuring eye-movements
                                evt = Eyelink('getfloatdata', evtype);
                                    if  1==IsInRect(evt.gavx,evt.gavy,fixrect)
                                        FixationTime = GetSecs;
                                        FixationWinToFix = FixationTime - FixationWinTime;
                                        break;
                                    end
                            end
                            
                    elseif evtype == 6
                            if Eyelink('isconnected') == el.connected % if we're really measuring eye-movements
                                evt = Eyelink('getfloatdata', evtype);
                                    if  1==IsInRect(evt.genx,evt.geny,fixrect)
                                    FixationTime = GetSecs;
                                    FixationWinToFix = FixationTime - FixationWinTime;
                                    break;
                                    end
                            end                            
                        end
                    end              
           
                    
                    %show Stimuluas
                    Screen('FillRect',mainWin, colour_stims ,stim_loc');
                    Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc, 7, white);
                    Screen('DrawDots', mainWin, [centerX, centerY-15], 7, black, [], 2)
                    StimulusWinTime= Screen('flip',mainWin,FixationWinTime + (60*IFI) - slack,0);
                    Eyelink('Message', 'Maze');

                    %show Delay period
                    Screen('FillRect',mainWin,color_fixation ,stim_loc');
                    Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc, 7, white);
                    Screen('DrawDots', mainWin, [centerX, centerY-15], 7, black, [], 2)
                    StimulusOffsetWinTime= Screen('flip',mainWin,StimulusWinTime + (360*IFI) - slack,0);
                    Eyelink('Message', 'Delay');
              
                    % START NAVIGATING
                    %---------------
                    Screen('FillRect',mainWin, colour_stims2 ,stim_loc');
                    Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc, 7, white);
                    Screen('DrawDots', mainWin, [centerX, centerY-15], 7, black, [], 2)
                    ResponseWinTime= Screen('flip',mainWin,StimulusOffsetWinTime + (60*IFI) - slack,0);
                    Eyelink('Message', 'ResponseStart');

                    % get starting position of icon
                    position_self= maze_array(1,this_trial);
                    position_self{1,1}= position_self{1,1}';
                    [irow ,icol]=find(cellfun(@sum, (cellfun(@(x) x==[0 1 1], position_self{1,1}, 'UniformOutput', false))) ==3);

                     % get position of goal
                    [grow ,gcol]=find(cellfun(@sum, (cellfun(@(x) x==[0 1 0], position_self{1,1}, 'UniformOutput', false))) ==3);
                    moves=0;

                    while 1

                        % update position of icon if participant moved
                             [keyIsDown,secs,keyCode]=KbCheck;

                             if keyIsDown==1
                                 keyCode= find(keyCode==1);

                                 if keyCode(1) == 37 &&  irow-1 > 0  &&  irow-1 < 12 &&  sum(position_self{1}{ irow-1, icol} == [0.5 0.5 1]) ~=3 &&  sum(position_self{1}{ irow-1, icol} == [0 0 0]) ~=3
                                     irow= irow-1;
                                     moves=moves+1;

                                 elseif keyCode(1) == 40 &&  icol+1 > 0 &&  icol+1 < 12 &&  sum(position_self{1}{ irow, icol+1} == [0.5 0.5 1]) ~=3 &&  sum(position_self{1}{ irow, icol+1} == [0 0 0]) ~=3
                                     icol= icol+1;
                                     moves=moves+1;

                                 elseif keyCode(1) == 39 &&  irow+1 > 0 &&  irow+1 < 12 &&  sum(position_self{1}{ irow+1, icol} == [0.5 0.5 1]) ~=3 &&  sum(position_self{1}{ irow+1, icol} == [0 0 0]) ~=3
                                      irow= irow+1;
                                      moves=moves+1;

                                 elseif keyCode(1) == 38 &&  icol-1 > 0 &&  icol-1 < 12 &&  sum(position_self{1}{ irow, icol-1} == [0.5 0.5 1]) ~=3 &&  sum(position_self{1}{ irow, icol-1} == [0 0 0]) ~=3
                                      icol= icol-1;
                                      moves=moves+1;
                                 end
                                 KbReleaseWait;
                             end

                             self_pos=  stim_loc(11*(icol-1) + irow, :);
                             goal_pos=  stim_loc(11*(gcol-1) + grow, :);

                             % change goal to yellow to motivate
                             % participants 

                             Time_Factor= (GetSecs-ResponseWinTime)/8;

                             if Time_Factor > 1
                                 Time_Factor =1;
                             end

                             Time_Factor=round(256*Time_Factor);

                             if Time_Factor ==0
                                 Time_Factor=1;
                             end


                        %show Start of response 
                        Screen('FillRect',mainWin, colour_stims2 ,stim_loc');
                        Screen('FillRect',mainWin,  cMap(Time_Factor,:) ,goal_pos);
                        Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );


                        % add circle 
                        Screen('DrawDots', mainWin, [(self_pos(1) +15), (self_pos(2) + 15)], 20, [1 0 0 ], [], 2)
                        Screen('DrawLines',mainWin,center_fix_loc, 7, white);
                        Screen('DrawDots', mainWin, [centerX, centerY-15], 7, black, [], 2)

                        Screen('flip',mainWin,ResponseWinTime + (1*IFI) - slack,0);

                        % break loop if solved
                        if irow == grow && icol == gcol
                            % add code here to get RT
                            mazeRT= GetSecs - ResponseWinTime;
                            break;
                        end
                        
                        if (GetSecs - ResponseWinTime) > 20
                            mazeRT= GetSecs - ResponseWinTime;
                            break;
                        end
                    end

                    % add fixation to avoid after images
                    Screen('FillRect',mainWin,color_mask ,stim_loc');
                    Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc, 7, white);
                    Screen('DrawDots', mainWin, [centerX, centerY-15], 7, black, [], 2)
                    Screen('flip',mainWin,mazeRT + (1*IFI) - slack,0);
                    Eyelink('Message', 'SubjectiveReport');
                    
                    
                    %draw subj scale
                    %---------------

                    for numobstacles =0:5 % index off bc of python
                    %subjpos=randi([1 9], 1); % start at random position 
                    subjpos=5;
                    subjposorig(numobstacles+1)= subjpos;

                    Screen(mainWin, 'TextSize' , 22)
                    Width=Screen(mainWin,'TextBounds','How aware of  the highlighted obstacle were you at any point?');
                    Screen('DrawText',mainWin,'How aware of  the highlighted obstacle were you at any point?',centerX-(round(Width(3)/2)), centerY-300, white);
                    
                    colour_stims= color_fixationtemp;
                    obstacles=maze_obstacles{1, this_trial};
                    index_obstacle=  obstacles == num2str(numobstacles);
                    colour_stims(index_obstacle) = {[1,0 0]};

                    colour_stims= reshape(colour_stims', [1, 11*11]);
                    colour_stims= vertcat(colour_stims{:})';

                    %show Start of response 
                    Screen('FillRect',mainWin, colour_stims ,stim_loc');
                    Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc, 7, white);
                    Screen('DrawDots', mainWin, [centerX, centerY-15], 7, black, [], 2)
                    
                       scale_pos= [centerX-400, centerY+270; centerX+400, centerY+270; 
                           centerX-400, centerY+270-30; centerX-400, centerY+270+30; 
                                centerX-300, centerY+270-30; centerX-300, centerY+270+30;
                                centerX-200, centerY+270-30; centerX-200, centerY+270+30;
                                centerX-100, centerY+270-30; centerX-100, centerY+270+30;
                               centerX-0, centerY+270-30; centerX-0, centerY+270+30;
                               centerX+100, centerY+270-30; centerX+100, centerY+270+30;
                               centerX+200, centerY+270-30; centerX+200, centerY+270+30;
                               centerX+300, centerY+270-30; centerX+300, centerY+270+30;
                               centerX+400, centerY+270-30; centerX+400, centerY+270+30]';
                        
                        Screen('DrawLines',mainWin,scale_pos, 10, black);
                        head   = [ (centerX+ ((800/8) * (subjpos- 5))), centerY+270-40 ]; % coordinates of head
                        width  = 20;           % width of arrow head
                        points = [ head-[width,0]         % left corner
                                       head+[width,0]         % right corner
                                       head+[0,width] ];      % vertex
                        Screen('FillPoly', mainWin, white, points);
                        
                        Width=Screen(mainWin,'TextBounds','not a lot');
                        Screen('DrawText',mainWin,'not a lot',centerX-490-(round(Width(3)/2)), centerY+270, white);
                        Width=Screen(mainWin,'TextBounds','a lot');
                        Screen('DrawText',mainWin,'a lot',centerX+500-(round(Width(3)/2)), centerY+270, white);
                        Width=Screen(mainWin,'TextBounds','Press the spacebar to submit');
                        Screen('DrawText',mainWin,'Press the spacebar to submit',centerX-(round(Width(3)/2)), centerY+380, white);
                        SubjWinTime= Screen('flip',mainWin,mazeRT + (31*IFI) - slack,0);

                        subjreported=1;
                        KbReleaseWait;

                    while subjreported
                           [keyIsDown,secs,keyCode]=KbCheck;
                            if keyIsDown==1
                                 keyCode= find(keyCode==1);
                                 if keyCode(1) == 37 &&  subjpos-1 > 0 &&  subjpos-1 < 10
                                     subjpos= subjpos-1;
                                 elseif keyCode(1) == 39 &&  subjpos+1 > 0 && subjpos+1 < 10
                                      subjpos= subjpos+1;
                                 elseif  keyCode(1) == 32 
                                     subjreported=0;
                                 end
                                 KbReleaseWait;
                             end

                        Width=Screen(mainWin,'TextBounds','How aware of  the highlighted obstacle were you at any point?');
                        Screen('DrawText',mainWin,'How aware of  the highlighted obstacle were you at any point?',centerX-(round(Width(3)/2)), centerY-300, white);
                        
                         %show Start of response 
                        Screen('FillRect',mainWin, colour_stims ,stim_loc');
                        Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                        Screen('DrawLines',mainWin,center_fix_loc, 7, white);
                        Screen('DrawDots', mainWin, [centerX, centerY-15], 7, black, [], 2)

                        Screen('DrawLines',mainWin,scale_pos, 10, black);
                        head   = [ (centerX+ ((800/8) * (subjpos-5))), centerY+270-40 ]; % coordinates of head
                        width  = 20;           % width of arrow head
                        points = [ head-[width,0]         % left corner
                                       head+[width,0]         % right corner
                                       head+[0,width] ];      % vertex
                        Screen('FillPoly', mainWin, white, points);
                        
                        Width=Screen(mainWin,'TextBounds','not a lot');
                        Screen('DrawText',mainWin,'not a lot',centerX-490-(round(Width(3)/2)), centerY +270, white);
                        Width=Screen(mainWin,'TextBounds','a lot');
                        Screen('DrawText',mainWin,'a lot',centerX+500-(round(Width(3)/2)), centerY+270, white);
                        Width=Screen(mainWin,'TextBounds','Press the spacebar to submit');
                        Screen('DrawText',mainWin,'Press the spacebar to submit',centerX-(round(Width(3)/2)), centerY+380, white);
                        SubjWinTime= Screen('flip',mainWin,SubjWinTime + (1*IFI) - slack,0);
                        WaitSecs(0.01);
                    end
                        subjectivereports(numobstacles+1) = subjpos;
                    end

                    % subj RT
                    SubjRT= GetSecs -(mazeRT+ ResponseWinTime);

                    %show Black Screen
                    Screen('DrawTexture',mainWin,GreyScreen);
                    GreyWinTime=Screen('flip',mainWin,0);
                   
                    %END STREAM LOOP
                    %---------------
                    % AlLow other processes to run optimally
                    Priority(0); 
                    TimeTrial=toc;
                    
                    % stop recording eye movements for the current trial
                    Eyelink('StopRecording');
                 
                    %--------------------------------------------------------
                    %DEFINE FORMAT AND PRINT OUTPUT
                    %--------------------------------------------------------
    
                    format = '%s, %s, %f, %s, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f\n'; %19
    
                    % write a line for each obstacle they reported
                    % awareness of (6 obstacles total per trial) 
                    for obstaclenum=1:6
                        if  trialMatrix.lateralized(this_trial) ==1
                            fprintf(fid,format,subjectID,Gender,Age,experiment,handiness,this_trial,trialMatrix.mazeNo(this_trial), ...
                               trialMatrix.lateralized(this_trial), trialMatrix.side(this_trial), moves, mazeRT, obstaclenum,sVGC_right_mazes_lat(obstaclenum,trialMatrix.mazeNo(this_trial)), ...
                                dVGC_right_mazes_lat(obstaclenum,trialMatrix.mazeNo(this_trial)), subjposorig(obstaclenum),subjectivereports(obstaclenum),SubjRT, TimeTrial); 
                        elseif  trialMatrix.lateralized(this_trial) ==0
                               fprintf(fid,format,subjectID,Gender,Age,experiment,handiness,this_trial,trialMatrix.mazeNo(this_trial), ...
                               trialMatrix.lateralized(this_trial), trialMatrix.side(this_trial), moves, mazeRT, obstaclenum,sVGC_orig_mazes_nonlat(obstaclenum,trialMatrix.mazeNo(this_trial)), ...
                               dVGC_orig_mazes_nonlat(obstaclenum,trialMatrix.mazeNo(this_trial)), subjposorig(obstaclenum),subjectivereports(obstaclenum), SubjRT, TimeTrial); 

                        end
                    end
                    
                    % recording ROIs for the trial
                    Eyelink('Message', '!V IAREA RECTANGLE 2 %d %d %d %d fixation', centerX-25,centerY-40,centerX+25,centerY+10); 
                    Eyelink('Message', '!V IAREA RECTANGLE 2 %d %d %d %d fixation',795,360,1125,690)
                    
                    % recording trial data into an output edf file
                    WaitSecs(0.001);
                    Eyelink('Message', '!V TRIAL_VAR ParticipantID %s', subjectID);
                    Eyelink('Message', '!V TRIAL_VAR TrialNum %d', this_trial);
                    WaitSecs(0.001); % allow some time between var messages just in case
                    Eyelink('Message', '!V TRIAL_VAR MazeID %d', trialMatrix.mazeNo(this_trial));
                    Eyelink('Message', '!V TRIAL_VAR Lateralized %d', trialMatrix.lateralized(this_trial));
                    WaitSecs(0.001); % allow some time between var messages just in case
                    Eyelink('Message', '!V TRIAL_VAR Side %d', trialMatrix.side(this_trial));
                    Eyelink('Message', '!V TRIAL_VAR Moves %d', moves);
                    WaitSecs(0.001); % allow some time between var messages just in case
                    Eyelink('Message', '!V TRIAL_VAR MazeRT %d', (round(mazeRT)*1000));
                    Eyelink('Message', '!V TRIAL_VAR SubjRT %d', (round(SubjRT)*1000));
            
                    %End Trial
                    Eyelink('Message', 'TRIAL_RESULT 0');

             
                    %------------------------------------------------------------
                    % BLOCK CHECK
                    %------------------------------------------------------------
    
                    if (itrial < nTrials) && (mod(itrial,8)==0)
                        

                                            EyelinkDoDriftCorrection(el);
                                            WaitSecs(1);
                                            messageWindow = Screen(mainWin,'OpenOffscreenWindow',grey);
                                            Screen(messageWindow,'TextSize',22)
                                            blockMessage = sprintf('End of Block %d of 12 blocks.',block);
                                            Width1=Screen(messageWindow,'TextBounds',blockMessage);
                                            Screen('DrawText', messageWindow,blockMessage,centerX-(round(Width1(3)/2)),centerY-100, white);
                                            Width=Screen(messageWindow,'TextBounds','REMEBER TO KEEP YOUR EYES FIXATED ON THE CENTRE CROSS' );
                                            Screen('DrawText',messageWindow,'REMEBER TO KEEP YOUR EYES FIXATED ON THE CENTRE CROSS',centerX-(round(Width(3)/2)), centerY, white);
                                            Width=Screen(messageWindow,'TextBounds','Press Space Bar to Continue');
                                            Screen('DrawText',messageWindow,'Press Space Bar to Continue',centerX-(round(Width(3)/2)),centerY+75, white);
                                            Screen('DrawTexture',mainWin,messageWindow);
                                            Screen('flip',mainWin);

                                            while 1
                                                [keyIsDown,secs,keyCode] = KbCheck;
                                                if keyCode(44)==1 || keyCode(32)==1
                                                    break
                                                elseif keyCode(41)==1 || keyCode(27)==1
                                                        Screen('closeall')
                                                return;
                                                end
                                            end

                                            WaitSecs(1);
                                            messageWindow = Screen(mainWin,'OpenOffscreenWindow',grey);
                                            Screen(messageWindow,'TextSize',22)
                                            Width=Screen(messageWindow,'TextBounds','Press Space Bar to Start the Next Block');
                                            Screen('DrawText',messageWindow,'Press Space Bar to Start the Next Block',centerX-(round(Width(3)/2)),centerY-50, white);
                                            Screen('DrawTexture',mainWin,messageWindow);
                                            Screen('Flip',mainWin)

                                            while 1
                                                [keyIsDown,secs,keyCode] = KbCheck;
                                                if keyCode(44)==1 || keyCode(32)==1
                                                    break
                                                end
                                            end
                                            WaitSecs(1);
                                            block=block+1;
                     
                    end
                    
                    %------------------------------------------------------------
                    % UPDATE TRIAL NUMBER
                    %------------------------------------------------------------
                    
                    itrial=itrial+1;
                    
                    %------------------------------------------------------------
                    %CLOSE WINDOWS
                    %------------------------------------------------------------  

                    Screen('Close');  
                    
                    %------------------------------------------------------------
                    % EXIT EXPERIMENT (PRESS ESC KEY DURING TRIAL)KbName('KeyNames')
                        [keyIsDown,secs,keyCode]=KbCheck;
                         if keyIsDown==1
                                 keyCode= find(keyCode==1);
                         end
                    
                    if keyCode(1) ==27
                        clear all
                        fclose(fid);
                        sca
                        close all
                    end   
                    
end

Eyelink('Command', 'set_idle_mode');
WaitSecs(0.5);
Eyelink('CloseFile');

try
    fprintf('Receiving data file ''%s''\n', filename);
    status = Eyelink('ReceiveFile', filename);
    if status > 0
        fprintf('ReceiveFile status %d\n', status);
    end
    if exist(edfFile, 'file') == 2
        fprintf('Data file ''%s'' can be found in ''%s''\n', filename, pwd);
    end
   
    % close the eye tracker and window
      Eyelink('ShutDown');
catch
    fprintf('Problem receiving data file ''%s''\n', filename);
end
  
%------------------------------------------------------------
% CLOSING EXPERIMENT
%------------------------------------------------------------

messageWindow = Screen(mainWin,'OpenOffscreenWindow',grey);
Screen(messageWindow,'TextSize',11)
Width=Screen(messageWindow,'TextBounds','Experiment is complete');
Screen('DrawText',messageWindow,'Experiment is complete',centerX-(round(Width(3)/2)),centerY-50, white);
Width=Screen(messageWindow,'TextBounds','PLEASE SEE EXPERIMENTER');
Screen('DrawText',messageWindow,'PLEASE SEE EXPERIMENTER',centerX-(round(Width(3)/2)),centerY+50, white);
Screen('DrawTexture',mainWin,messageWindow);
Screen('Flip',mainWin)

while 1
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyCode(32)==1 || keyCode(44)==1 || keyCode(81)==1 
        break
    end
end
fclose(fid);
sca
         
end
