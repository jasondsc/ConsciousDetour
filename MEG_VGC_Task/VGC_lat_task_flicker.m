function task_representations

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WRITE DESCRIPTION OF TASK
% Participants will solve a series of mazes and reprot on their subsequent
% awareness of obstaclesn          
% Participants can perform 10 practice trials
%
% Org Author: Jason da Silva Castanheira 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% !!!!!!!!!!!!!!!!!!!! TO REMOVE TO REMOVE TO REMOVE  !!!!!!!!!!!!!!!
Screen('Preference', 'SkipSyncTests', 1); 
% !!!!!!!!!!!!!!!!!!!! TO REMOVE TO REMOVE TO REMOVE  !!!!!!!!!!!!!!!

RefreshRate= 1000*(1/480);


%%
% NEED TO ADD PROPRIXXX COMMANDS FOR TRIGGERING FIRST PIXEL

%% set up of experimental parameters 
CurrentFrameRateHz=FrameRate(0);

if (round(CurrentFrameRateHz)~=60)
    disp('Screen refresh rate is not 60Hz. Plese adjust Screen refresh rate to 60 Hz!')
    disp('check resolution')
    return
end

%EXPERIMENT INFORMATION
     
prompt={'SubjectID:','Gender','Age','Handiness (1=LEFT or 2=RIGHT): ','Practice (1=Yes; 2=No)'};
title='EXPERIMENT INFORMATION'; 
answer=inputdlg(prompt,title);
subjectID = char(answer{1});
Gender=char(answer{2});
Age=str2num(answer{3});
handiness = str2num(answer{4});
practice = str2num(answer{5});
experiment = 'VGC_lat_behav';

% MAKE TRIAL MATRIX

% Call function to update Maze stims
create_VGC_stims()

reset(RandStream.getGlobalStream,sum(100*clock));

% colour gradient from green to yellow 
cMap = interp1([0;1],[0 1 0; 1 1 0],linspace(0,1,256));

% load in stims
load('./StimMazes_RGB_4_Matlab.mat');

% now let us make one big trail matrix 
maze= repmat([1:24],1,4)';
lateralized=repelem([0,1],1,48)';
side= repelem([1,2,1,2],1,24)';
temp=repmat([maze,lateralized, side], 2,1); % repeat trial matrix three time
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

% save task relevance
maze_relevance= {};
maze_relevance([trialMatrix.lateralized== 1 & trialMatrix.side ==1])=rel_right_mazes_lat(trialMatrix.mazeNo([trialMatrix.lateralized== 1 & trialMatrix.side ==1]));
maze_relevance([trialMatrix.lateralized== 1 & trialMatrix.side ==2])=rel_left_mazes_lat(trialMatrix.mazeNo([trialMatrix.lateralized== 1 & trialMatrix.side ==2]));
maze_relevance([trialMatrix.lateralized== 0 & trialMatrix.side ==1])=rel_flipped_mazes_lat(trialMatrix.mazeNo([trialMatrix.lateralized== 0 & trialMatrix.side ==1]));
maze_relevance([trialMatrix.lateralized== 0 & trialMatrix.side ==2])=rel_orig_mazes_lat(trialMatrix.mazeNo([trialMatrix.lateralized== 0 & trialMatrix.side ==2]));


% save task irrel
maze_irrelevance= {};
maze_irrelevance([trialMatrix.lateralized== 1 & trialMatrix.side ==1])=irrel_right_mazes_lat(trialMatrix.mazeNo([trialMatrix.lateralized== 1 & trialMatrix.side ==1]));
maze_irrelevance([trialMatrix.lateralized== 1 & trialMatrix.side ==2])=irrel_left_mazes_lat(trialMatrix.mazeNo([trialMatrix.lateralized== 1 & trialMatrix.side ==2]));
maze_irrelevance([trialMatrix.lateralized== 0 & trialMatrix.side ==1])=irrel_flipped_mazes_lat(trialMatrix.mazeNo([trialMatrix.lateralized== 0 & trialMatrix.side ==1]));
maze_irrelevance([trialMatrix.lateralized== 0 & trialMatrix.side ==2])=irrel_orig_mazes_lat(trialMatrix.mazeNo([trialMatrix.lateralized== 0 & trialMatrix.side ==2]));


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
grey = white / 2;

[mainWin, windowRect] = PsychImaging('OpenWindow', ScreenNumber, grey);
slack = Screen('GetFlipInterval', mainWin)/2;
IFI = Screen('GetFlipInterval', mainWin);

[screenXpixels, screenYpixels] = Screen('WindowSize', mainWin); % Get the size of the on screen window
r=Screen(mainWin,'Rect');
[xCenter, yCenter] = RectCenter(windowRect);
centerX = round(r(3)/2);
centerY = round(r(4)/2);
centerXhalf = round(centerX/2);
centerYhalf = round(centerY/2);
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
center_fix_loc1= [centerX-20-centerXhalf, centerY-centerYhalf-15; centerX-centerXhalf+20, centerY-centerYhalf-15; centerX-centerXhalf , centerY-centerYhalf-35; centerX-centerXhalf, centerY-centerYhalf+5]';
center_fix_loc2= [centerX-20+centerXhalf, centerY-centerYhalf-15; centerX+centerXhalf+20, centerY-centerYhalf-15; centerX+centerXhalf, centerY-centerYhalf-35; centerX+centerXhalf, centerY-centerYhalf+5]';
center_fix_loc3= [centerX-centerXhalf-20, centerY+centerYhalf-15; centerX-centerXhalf+20, centerY+centerYhalf-15; centerX-centerXhalf, centerY+centerYhalf-35; centerX-centerXhalf, centerY+centerYhalf+5]';
center_fix_loc4= [centerX+centerXhalf-20, centerY+centerYhalf-15; centerX+centerXhalf+20, centerY+centerYhalf-15; centerX+centerXhalf, centerY+centerYhalf-35; centerX+centerXhalf, centerY+centerYhalf+5]';

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

% stim loc for each quads
stim_loc1= stim_loc;
stim_loc1(:,1)= stim_loc(:, 1)-centerXhalf;
stim_loc1(:,2)= stim_loc(:, 2)-centerYhalf;
stim_loc1(:,3)= stim_loc(:, 3)-centerXhalf;
stim_loc1(:,4)= stim_loc(:, 4)-centerYhalf;

stim_loc2= stim_loc;
stim_loc2(:,1)= stim_loc(:, 1)+centerXhalf;
stim_loc2(:,2)= stim_loc(:, 2)-centerYhalf;
stim_loc2(:,3)= stim_loc(:, 3)+centerXhalf;
stim_loc2(:,4)= stim_loc(:, 4)-centerYhalf;

stim_loc3= stim_loc;
stim_loc3(:,1)= stim_loc(:, 1)-centerXhalf;
stim_loc3(:,2)= stim_loc(:, 2)+centerYhalf;
stim_loc3(:,3)= stim_loc(:, 3)-centerXhalf;
stim_loc3(:,4)= stim_loc(:, 4)+centerYhalf;

stim_loc4= stim_loc;
stim_loc4(:,1)= stim_loc(:, 1)+centerXhalf;
stim_loc4(:,2)= stim_loc(:, 2)+centerYhalf;
stim_loc4(:,3)= stim_loc(:, 3)+centerXhalf;
stim_loc4(:,4)= stim_loc(:, 4)+centerYhalf;

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

%DISPLAY SETUP

%message windows

messageWindow = Screen(mainWin,'OpenOffscreenWindow',grey);
Screen(messageWindow,'TextSize',11);

%% 

%------------------------------------------------------------
% DISPLAY BEGINING SCREEN
%------------------------------------------------------------

WaitSecs(1);
messageWindow = Screen(mainWin,'OpenOffscreenWindow',grey);
Screen(messageWindow,'TextSize',22)
Width=Screen(messageWindow,'TextBounds','VGC behavioural task');
Screen('DrawText',messageWindow,'VGC behavioural task',centerX-(round(Width(3)/2))-centerXhalf, centerY-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press the Spacebar to Continute');
Screen('DrawText',messageWindow,'Press the Spacebar to Continute',centerX-(round(Width(3)/2))-centerXhalf, centerY-centerYhalf+150, white);

Width=Screen(messageWindow,'TextBounds','VGC behavioural task');
Screen('DrawText',messageWindow,'VGC behavioural task',centerX-(round(Width(3)/2))+centerXhalf, centerY-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press the Spacebar to Continute');
Screen('DrawText',messageWindow,'Press the Spacebar to Continute',centerX-(round(Width(3)/2))+centerXhalf, centerY-centerYhalf+150, white);

Width=Screen(messageWindow,'TextBounds','VGC behavioural task');
Screen('DrawText',messageWindow,'VGC behavioural task',centerX-(round(Width(3)/2))-centerXhalf, centerY+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press the Spacebar to Continute');
Screen('DrawText',messageWindow,'Press the Spacebar to Continute',centerX-(round(Width(3)/2))-centerXhalf, centerY+centerYhalf+150, white);

Width=Screen(messageWindow,'TextBounds','VGC behavioural task');
Screen('DrawText',messageWindow,'VGC behavioural task',centerX-(round(Width(3)/2))+centerXhalf, centerY+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press the Spacebar to Continute');
Screen('DrawText',messageWindow,'Press the Spacebar to Continute',centerX-(round(Width(3)/2))+centerXhalf, centerY+centerYhalf+150, white);

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
Screen('DrawText',messageWindow,'Please Make Sure That CAPS is OFF',centerX-(round(Width(3)/2))-centerXhalf, centerY-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press the Spacebar to Continute');
Screen('DrawText',messageWindow,'Press the Spacebar to Continute',centerX-(round(Width(3)/2))-centerXhalf, centerY-centerYhalf+150, white);

Width=Screen(messageWindow,'TextBounds','Please Make Sure That CAPS is OFF');
Screen('DrawText',messageWindow,'Please Make Sure That CAPS is OFF',centerX-(round(Width(3)/2))+centerXhalf, centerY-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press the Spacebar to Continute');
Screen('DrawText',messageWindow,'Press the Spacebar to Continute',centerX-(round(Width(3)/2))+centerXhalf, centerY-centerYhalf+150, white);

Width=Screen(messageWindow,'TextBounds','Please Make Sure That CAPS is OFF');
Screen('DrawText',messageWindow,'Please Make Sure That CAPS is OFF',centerX-(round(Width(3)/2))-centerXhalf, centerY+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press the Spacebar to Continute');
Screen('DrawText',messageWindow,'Press the Spacebar to Continute',centerX-(round(Width(3)/2))-centerXhalf, centerY+centerYhalf+150, white);

Width=Screen(messageWindow,'TextBounds','Please Make Sure That CAPS is OFF');
Screen('DrawText',messageWindow,'Please Make Sure That CAPS is OFF',centerX-(round(Width(3)/2))+centerXhalf, centerY+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press the Spacebar to Continute');
Screen('DrawText',messageWindow,'Press the Spacebar to Continute',centerX-(round(Width(3)/2))+centerXhalf, centerY+centerYhalf+150, white);

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
Screen('DrawText',messageWindow,'In this task you will be asked to solve a series of mazes',centerX-(round(Width(3)/2))-centerXhalf, centerY-centerYhalf-230, white);
Width=Screen(messageWindow,'TextBounds','Here is an example maze');
Screen('DrawText',messageWindow,'Here is an example maze',centerX-(round(Width(3)/2))-centerXhalf, centerY-centerYhalf-200, white);

Width=Screen(messageWindow,'TextBounds','In this task you will be asked to solve a series of mazes');
Screen('DrawText',messageWindow,'In this task you will be asked to solve a series of mazes',centerX-(round(Width(3)/2))+centerXhalf, centerY-centerYhalf-230, white);
Width=Screen(messageWindow,'TextBounds','Here is an example maze');
Screen('DrawText',messageWindow,'Here is an example maze',centerX-(round(Width(3)/2))+centerXhalf, centerY-centerYhalf-200, white);

Width=Screen(messageWindow,'TextBounds','In this task you will be asked to solve a series of mazes');
Screen('DrawText',messageWindow,'In this task you will be asked to solve a series of mazes',centerX-(round(Width(3)/2))-centerXhalf, centerY+centerYhalf-230, white);
Width=Screen(messageWindow,'TextBounds','Here is an example maze');
Screen('DrawText',messageWindow,'Here is an example maze',centerX-(round(Width(3)/2))-centerXhalf, centerY+centerYhalf-200, white);

Width=Screen(messageWindow,'TextBounds','In this task you will be asked to solve a series of mazes');
Screen('DrawText',messageWindow,'In this task you will be asked to solve a series of mazes',centerX-(round(Width(3)/2))+centerXhalf, centerY+centerYhalf-230, white);
Width=Screen(messageWindow,'TextBounds','Here is an example maze');
Screen('DrawText',messageWindow,'Here is an example maze',centerX-(round(Width(3)/2))+centerXhalf, centerY+centerYhalf-200, white);


colour_stims= reshape(stim_right_mazes_lat{1}', [1, 11*11]);
colour_stims= vertcat(colour_stims{:})';

position_self{1,1}= stim_right_mazes_lat{1}';
[irow ,icol]=find(cellfun(@sum, (cellfun(@(x) x==[0 1 1], position_self{1,1}, 'UniformOutput', false))) ==3);
self_pos=  stim_loc(11*(icol-1) + irow, :);

Screen('FillRect',messageWindow,colour_stims ,stim_loc1');
Screen('FrameRect',messageWindow,black ,stim_loc1', 0.5  );
Screen('DrawLines',messageWindow,center_fix_loc1, 7, white);
Screen('DrawDots', messageWindow, [centerX-centerXhalf, centerY-15-centerYhalf], 7, black, [], 2)

Screen('FillRect',messageWindow,colour_stims ,stim_loc2');
Screen('FrameRect',messageWindow,black ,stim_loc2', 0.5  );
Screen('DrawLines',messageWindow,center_fix_loc2, 7, white);
Screen('DrawDots', messageWindow, [centerX+centerXhalf, centerY-centerYhalf-15], 7, black, [], 2)

Screen('FillRect',messageWindow,colour_stims ,stim_loc3');
Screen('FrameRect',messageWindow,black ,stim_loc3', 0.5  );
Screen('DrawLines',messageWindow,center_fix_loc3, 7, white);
Screen('DrawDots', messageWindow, [centerX-centerXhalf, centerY+centerYhalf-15], 7, black, [], 2)

Screen('FillRect',messageWindow,colour_stims ,stim_loc4');
Screen('FrameRect',messageWindow,black ,stim_loc4', 0.5  );
Screen('DrawLines',messageWindow,center_fix_loc4, 7, white);
Screen('DrawDots', messageWindow, [centerX+centerXhalf, centerY+centerYhalf-15], 7, black, [], 2)

Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-centerXhalf-(round(Width(3)/2)),centerY-centerYhalf+200, white);
Screen('DrawTexture',mainWin,messageWindow);
Screen('Flip',mainWin)

Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX+centerXhalf-(round(Width(3)/2)),centerY-centerYhalf+200, white);
Screen('DrawTexture',mainWin,messageWindow);
Screen('Flip',mainWin)

Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-centerXhalf-(round(Width(3)/2)),centerY+centerYhalf+200, white);
Screen('DrawTexture',mainWin,messageWindow);
Screen('Flip',mainWin)

Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX+centerXhalf-(round(Width(3)/2)),centerY+centerYhalf+200, white);
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
Width=Screen(messageWindow,'TextBounds','you will navigate yourself (a red circle) to the goal (the green square)');
Screen('DrawText',messageWindow,'you will navigate yourself (a red circle) to the goal (the green square)',centerX-(round(Width(3)/2))-centerXhalf, centerY-230-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','you will start at the cyan square, make it to the green square before it turns yellow');
Screen('DrawText',messageWindow,'you will start at the cyan square, make it to the green square before it turns yellow',centerX-(round(Width(3)/2))-centerXhalf, centerY-200-centerYhalf, white);

Width=Screen(messageWindow,'TextBounds','you will navigate yourself (a red circle) to the goal (the green square)');
Screen('DrawText',messageWindow,'you will navigate yourself (a red circle) to the goal (the green square)',centerX-(round(Width(3)/2))+centerXhalf, centerY-230-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','you will start at the cyan square, make it to the green square before it turns yellow');
Screen('DrawText',messageWindow,'you will start at the cyan square, make it to the green square before it turns yellow',centerX-(round(Width(3)/2))+centerXhalf, centerY-200-centerYhalf, white);

Width=Screen(messageWindow,'TextBounds','you will navigate yourself (a red circle) to the goal (the green square)');
Screen('DrawText',messageWindow,'you will navigate yourself (a red circle) to the goal (the green square)',centerX-(round(Width(3)/2))-centerXhalf, centerY-230+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','you will start at the cyan square, make it to the green square before it turns yellow');
Screen('DrawText',messageWindow,'you will start at the cyan square, make it to the green square before it turns yellow',centerX-(round(Width(3)/2))-centerXhalf, centerY-200+centerYhalf, white);

Width=Screen(messageWindow,'TextBounds','you will navigate yourself (a red circle) to the goal (the green square)');
Screen('DrawText',messageWindow,'you will navigate yourself (a red circle) to the goal (the green square)',centerX-(round(Width(3)/2))+centerXhalf, centerY-230+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','you will start at the cyan square, make it to the green square before it turns yellow');
Screen('DrawText',messageWindow,'you will start at the cyan square, make it to the green square before it turns yellow',centerX-(round(Width(3)/2))+centerXhalf, centerY-200+centerYhalf, white);

Screen('FillRect',messageWindow,colour_stims ,stim_loc1');
Screen('FrameRect',messageWindow,black ,stim_loc1', 0.5  );
Screen('DrawLines',messageWindow,center_fix_loc1, 7, white);
Screen('DrawDots', messageWindow, [centerX-centerXhalf, centerY-centerYhalf-15], 7, black, [], 2)
Screen('DrawDots', messageWindow, [self_pos(1)-centerXhalf+15, self_pos(2)-centerYhalf+ 15], 20, [1 0 0 ], [], 2)

Screen('FillRect',messageWindow,colour_stims ,stim_loc2');
Screen('FrameRect',messageWindow,black ,stim_loc2', 0.5  );
Screen('DrawLines',messageWindow,center_fix_loc2, 7, white);
Screen('DrawDots', messageWindow, [centerX+centerXhalf, centerY-centerYhalf-15], 7, black, [], 2)
Screen('DrawDots', messageWindow, [self_pos(1)+centerXhalf+ 15, self_pos(2)-centerYhalf+ 15], 20, [1 0 0 ], [], 2)

Screen('FillRect',messageWindow,colour_stims ,stim_loc3');
Screen('FrameRect',messageWindow,black ,stim_loc3', 0.5  );
Screen('DrawLines',messageWindow,center_fix_loc3, 7, white);
Screen('DrawDots', messageWindow, [centerX-centerXhalf, centerY+centerYhalf-15], 7, black, [], 2)
Screen('DrawDots', messageWindow, [self_pos(1)-centerXhalf+ 15, self_pos(2)+centerYhalf+ 15], 20, [1 0 0 ], [], 2)

Screen('FillRect',messageWindow,colour_stims ,stim_loc4');
Screen('FrameRect',messageWindow,black ,stim_loc4', 0.5  );
Screen('DrawLines',messageWindow,center_fix_loc4, 7, white);
Screen('DrawDots', messageWindow, [centerX+centerXhalf, centerY+centerYhalf-15], 7, black, [], 2)
Screen('DrawDots', messageWindow, [self_pos(1)+centerXhalf+ 15, self_pos(2)+centerYhalf+ 15], 20, [1 0 0 ], [], 2)

Width=Screen(messageWindow,'TextBounds','BEWARE of obstacles in blue');
Screen('DrawText',messageWindow,'BEWARE of obstacles in blue',centerX-(round(Width(3)/2))-centerXhalf, centerY+200-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))-centerXhalf,centerY+230-centerYhalf, white);

Width=Screen(messageWindow,'TextBounds','BEWARE of obstacles in blue');
Screen('DrawText',messageWindow,'BEWARE of obstacles in blue',centerX-(round(Width(3)/2))+centerXhalf, centerY+200-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))+centerXhalf,centerY+230-centerYhalf, white);

Width=Screen(messageWindow,'TextBounds','BEWARE of obstacles in blue');
Screen('DrawText',messageWindow,'BEWARE of obstacles in blue',centerX-(round(Width(3)/2))-centerXhalf, centerY+200+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))-centerXhalf,centerY+230+centerYhalf, white);

Width=Screen(messageWindow,'TextBounds','BEWARE of obstacles in blue');
Screen('DrawText',messageWindow,'BEWARE of obstacles in blue',centerX-(round(Width(3)/2))+centerXhalf, centerY+200+ centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))+centerXhalf,centerY+230+ centerYhalf, white);

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
Screen('DrawText',messageWindow,'we ask that you keep looking at the cross in the middle throughout the task',centerX-(round(Width(3)/2))-centerXhalf, centerY-230-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds',' and to minimize eye movements when the maze is on the screen');
Screen('DrawText',messageWindow,'and to minimize eye movements when the maze is on the screen',centerX-(round(Width(3)/2))-centerXhalf, centerY-200-centerYhalf, white);

Width=Screen(messageWindow,'TextBounds',' we ask that you keep looking at the cross in the middle throughout the task');
Screen('DrawText',messageWindow,'we ask that you keep looking at the cross in the middle throughout the task',centerX-(round(Width(3)/2))+centerXhalf, centerY-230-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds',' and to minimize eye movements when the maze is on the screen');
Screen('DrawText',messageWindow,'and to minimize eye movements when the maze is on the screen',centerX-(round(Width(3)/2))+centerXhalf, centerY-200-centerYhalf, white);

Width=Screen(messageWindow,'TextBounds',' we ask that you keep looking at the cross in the middle throughout the task');
Screen('DrawText',messageWindow,'we ask that you keep looking at the cross in the middle throughout the task',centerX-(round(Width(3)/2))-centerXhalf, centerY-230+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','and to minimize eye movements when the maze is on the screen');
Screen('DrawText',messageWindow, 'and to minimize eye movements when the maze is on the screen',centerX-(round(Width(3)/2))-centerXhalf, centerY-200+centerYhalf, white);

Width=Screen(messageWindow,'TextBounds',' we ask that you keep looking at the cross in the middle throughout the task');
Screen('DrawText',messageWindow,'we ask that you keep looking at the cross in the middle throughout the task',centerX-(round(Width(3)/2))+centerXhalf, centerY-230+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds',' and to minimize eye movements when the maze is on the screen');
Screen('DrawText',messageWindow,'and to minimize eye movements when the maze is on the screen',centerX-(round(Width(3)/2))+centerXhalf, centerY-200+centerYhalf, white);

Screen('FillRect',messageWindow,colour_stims ,stim_loc1');
Screen('FrameRect',messageWindow,black ,stim_loc1', 0.5  );
Screen('DrawLines',messageWindow,center_fix_loc1, 7, white);
Screen('DrawDots', messageWindow, [centerX-centerXhalf, centerY-centerYhalf-15], 7, black, [], 2)
Screen('DrawDots', messageWindow, [self_pos(1)-centerXhalf+15, self_pos(2)-centerYhalf+ 15], 20, [1 0 0 ], [], 2)

Screen('FillRect',messageWindow,colour_stims ,stim_loc2');
Screen('FrameRect',messageWindow,black ,stim_loc2', 0.5  );
Screen('DrawLines',messageWindow,center_fix_loc2, 7, white);
Screen('DrawDots', messageWindow, [centerX+centerXhalf, centerY-centerYhalf-15], 7, black, [], 2)
Screen('DrawDots', messageWindow, [self_pos(1)+centerXhalf+ 15, self_pos(2)-centerYhalf+ 15], 20, [1 0 0 ], [], 2)

Screen('FillRect',messageWindow,colour_stims ,stim_loc3');
Screen('FrameRect',messageWindow,black ,stim_loc3', 0.5  );
Screen('DrawLines',messageWindow,center_fix_loc3, 7, white);
Screen('DrawDots', messageWindow, [centerX-centerXhalf, centerY+centerYhalf-15], 7, black, [], 2)
Screen('DrawDots', messageWindow, [self_pos(1)-centerXhalf+ 15, self_pos(2)+centerYhalf+ 15], 20, [1 0 0 ], [], 2)

Screen('FillRect',messageWindow,colour_stims ,stim_loc4');
Screen('FrameRect',messageWindow,black ,stim_loc4', 0.5  );
Screen('DrawLines',messageWindow,center_fix_loc4, 7, white);
Screen('DrawDots', messageWindow, [centerX+centerXhalf, centerY+centerYhalf-15], 7, black, [], 2)
Screen('DrawDots', messageWindow, [self_pos(1)+centerXhalf+ 15, self_pos(2)+centerYhalf+ 15], 20, [1 0 0 ], [], 2)


Width=Screen(messageWindow,'TextBounds','REMEBER TO KEEP YOUR EYES FIXATED ON THE CENTRE CROSS' );
Screen('DrawText',messageWindow,'REMEBER TO KEEP YOUR EYES FIXATED ON THE CENTRE CROSS',centerX-(round(Width(3)/2))-centerXhalf, centerY+200-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))-centerXhalf,centerY+230-centerYhalf, white);

Width=Screen(messageWindow,'TextBounds','REMEBER TO KEEP YOUR EYES FIXATED ON THE CENTRE CROSS' );
Screen('DrawText',messageWindow,'REMEBER TO KEEP YOUR EYES FIXATED ON THE CENTRE CROSS',centerX-(round(Width(3)/2))+centerXhalf, centerY+200-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))+centerXhalf,centerY+230-centerYhalf, white);

Width=Screen(messageWindow,'TextBounds','REMEBER TO KEEP YOUR EYES FIXATED ON THE CENTRE CROSS' );
Screen('DrawText',messageWindow,'REMEBER TO KEEP YOUR EYES FIXATED ON THE CENTRE CROSS',centerX-(round(Width(3)/2))-centerXhalf, centerY+200+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))-centerXhalf,centerY+230+centerYhalf, white);

Width=Screen(messageWindow,'TextBounds','REMEBER TO KEEP YOUR EYES FIXATED ON THE CENTRE CROSS' );
Screen('DrawText',messageWindow,'REMEBER TO KEEP YOUR EYES FIXATED ON THE CENTRE CROSS',centerX-(round(Width(3)/2))+centerXhalf, centerY+200+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))+centerXhalf,centerY+230+centerYhalf, white);

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
Width=Screen(messageWindow,'TextBounds','At the start of each trial, you will have a few seconds to PLAN');
Screen('DrawText',messageWindow,'At the start of each trial, you will have a few seconds to PLAN',centerX-(round(Width(3)/2))-centerXhalf, centerY-230-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','At the start of each trial, you will have a few seconds to PLAN');
Screen('DrawText',messageWindow,'At the start of each trial, you will have a few seconds to PLAN',centerX-(round(Width(3)/2))+centerXhalf, centerY-230-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','At the start of each trial, you will have a few seconds to PLAN');
Screen('DrawText',messageWindow,'At the start of each trial, you will have a few seconds to PLAN',centerX-(round(Width(3)/2))-centerXhalf, centerY-230+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','At the start of each trial, you will have a few seconds to PLAN');
Screen('DrawText',messageWindow,'At the start of each trial, you will have a few seconds to PLAN',centerX-(round(Width(3)/2))+centerXhalf, centerY-230+centerYhalf, white);

Width=Screen(messageWindow,'TextBounds','Afterwards the maze will disappear; when the red circle reappears you can start to move');
Screen('DrawText',messageWindow,'Afterwards the maze will disappear; when the red circle reappears you can start to move',centerX-(round(Width(3)/2))-centerXhalf, centerY-200-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Afterwards the maze will disappear; when the red circle reappears you can start to move');
Screen('DrawText',messageWindow,'Afterwards the maze will disappear; when the red circle reappears you can start to move',centerX-(round(Width(3)/2))+centerXhalf, centerY-200-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Afterwards the maze will disappear; when the red circle reappears you can start to move');
Screen('DrawText',messageWindow,'Afterwards the maze will disappear; when the red circle reappears you can start to move',centerX-(round(Width(3)/2))-centerXhalf, centerY-200+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Afterwards the maze will disappear; when the red circle reappears you can start to move');
Screen('DrawText',messageWindow,'Afterwards the maze will disappear; when the red circle reappears you can start to move',centerX-(round(Width(3)/2))+centerXhalf, centerY-200+centerYhalf, white);


Width=Screen(messageWindow,'TextBounds','Use the arrow keys to navigate through the maze with your RIGHT index finger');
Screen('DrawText',messageWindow,'Use the arrow keys to navigate through the maze with your RIGHT index finger',centerX-(round(Width(3)/2))-centerXhalf, centerY-170-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Use the arrow keys to navigate through the maze with your RIGHT index finger');
Screen('DrawText',messageWindow,'Use the arrow keys to navigate through the maze with your RIGHT index finger',centerX-(round(Width(3)/2))+centerXhalf, centerY-170-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Use the arrow keys to navigate through the maze with your RIGHT index finger');
Screen('DrawText',messageWindow,'Use the arrow keys to navigate through the maze with your RIGHT index finger',centerX-(round(Width(3)/2))-centerXhalf, centerY-170+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Use the arrow keys to navigate through the maze with your RIGHT index finger');
Screen('DrawText',messageWindow,'Use the arrow keys to navigate through the maze with your RIGHT index finger',centerX-(round(Width(3)/2))+centerXhalf, centerY-170+centerYhalf, white);


Width=Screen(messageWindow,'TextBounds','Please navigate the mazes as quickly and as accurately as possible');
Screen('DrawText',messageWindow,'Please navigate the mazes as quickly and as accurately as possible',centerX-(round(Width(3)/2))-centerXhalf, centerY-140-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Please navigate the mazes as quickly and as accurately as possible');
Screen('DrawText',messageWindow,'Please navigate the mazes as quickly and as accurately as possible',centerX-(round(Width(3)/2))+centerXhalf, centerY-140-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Please navigate the mazes as quickly and as accurately as possible');
Screen('DrawText',messageWindow,'Please navigate the mazes as quickly and as accurately as possible',centerX-(round(Width(3)/2))-centerXhalf, centerY-140+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Please navigate the mazes as quickly and as accurately as possible');
Screen('DrawText',messageWindow,'Please navigate the mazes as quickly and as accurately as possible',centerX-(round(Width(3)/2))+centerXhalf, centerY-140+centerYhalf, white);


Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))-centerXhalf,centerY+230-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))+centerXhalf,centerY+230-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))-centerXhalf,centerY+230+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))+centerXhalf,centerY+230+centerYhalf, white);
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
Screen('DrawText',messageWindow,'We are interested in your thought process while navigating each maze',centerX-(round(Width(3)/2))-centerXhalf, centerY-230-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','We are interested in your thought process while navigating each maze');
Screen('DrawText',messageWindow,'We are interested in your thought process while navigating each maze',centerX-(round(Width(3)/2))+centerXhalf, centerY-230-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','We are interested in your thought process while navigating each maze');
Screen('DrawText',messageWindow,'We are interested in your thought process while navigating each maze',centerX-(round(Width(3)/2))-centerXhalf, centerY-230+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','We are interested in your thought process while navigating each maze');
Screen('DrawText',messageWindow,'We are interested in your thought process while navigating each maze',centerX-(round(Width(3)/2))+centerXhalf, centerY-230+centerYhalf, white);


Width=Screen(messageWindow,'TextBounds','Following each trial we will ask how AWARE of an obstacle you were at any point');
Screen('DrawText',messageWindow,'Following each trial we will ask how AWARE of an obstacle you were at any point',centerX-(round(Width(3)/2))-centerXhalf, centerY-200-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Following each trial we will ask how AWARE of an obstacle you were at any point');
Screen('DrawText',messageWindow,'Following each trial we will ask how AWARE of an obstacle you were at any point',centerX-(round(Width(3)/2))+centerXhalf, centerY-200-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Following each trial we will ask how AWARE of an obstacle you were at any point');
Screen('DrawText',messageWindow,'Following each trial we will ask how AWARE of an obstacle you were at any point',centerX-(round(Width(3)/2))-centerXhalf, centerY-200+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Following each trial we will ask how AWARE of an obstacle you were at any point');
Screen('DrawText',messageWindow,'Following each trial we will ask how AWARE of an obstacle you were at any point',centerX-(round(Width(3)/2))+centerXhalf, centerY-200+centerYhalf, white);

Width=Screen(messageWindow,'TextBounds','Your answer should reflect the amount you paid ATTENTION this obstacle');
Screen('DrawText',messageWindow,'Your answer should reflect the amount you paid ATTENTION this obstacle',centerX-(round(Width(3)/2))-centerXhalf, centerY-170-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Your answer should reflect the amount you paid ATTENTION this obstacle');
Screen('DrawText',messageWindow,'Your answer should reflect the amount you paid ATTENTION this obstacle',centerX-(round(Width(3)/2))+centerXhalf, centerY-170-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Your answer should reflect the amount you paid ATTENTION this obstacle');
Screen('DrawText',messageWindow,'Your answer should reflect the amount you paid ATTENTION this obstacle',centerX-(round(Width(3)/2))-centerXhalf, centerY-170+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Your answer should reflect the amount you paid ATTENTION this obstacle');
Screen('DrawText',messageWindow,'Your answer should reflect the amount you paid ATTENTION this obstacle',centerX-(round(Width(3)/2))+centerXhalf, centerY-170+centerYhalf, white);


Width=Screen(messageWindow,'TextBounds','during the PLANNING PHASE');
Screen('DrawText',messageWindow,'during the PLANNING PHASE',centerX-(round(Width(3)/2))-centerXhalf, centerY-140-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','during the PLANNING PHASE');
Screen('DrawText',messageWindow,'during the PLANNING PHASE',centerX-(round(Width(3)/2))+centerXhalf, centerY-140-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','during the PLANNING PHASE');
Screen('DrawText',messageWindow,'during the PLANNING PHASE',centerX-(round(Width(3)/2))-centerXhalf, centerY-140+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','during the PLANNING PHASE');
Screen('DrawText',messageWindow,'during the PLANNING PHASE',centerX-(round(Width(3)/2))+centerXhalf, centerY-140+centerYhalf, white);


Width=Screen(messageWindow,'TextBounds','YOUR ANSWER WILL NOT AFFECT YOUR PERFORMANCE ON THE TASK');
Screen('DrawText',messageWindow,'YOUR ANSWER WILL NOT AFFECT YOUR PERFORMANCE ON THE TASK',centerX-(round(Width(3)/2))-centerXhalf, centerY-110-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','YOUR ANSWER WILL NOT AFFECT YOUR PERFORMANCE ON THE TASK');
Screen('DrawText',messageWindow,'YOUR ANSWER WILL NOT AFFECT YOUR PERFORMANCE ON THE TASK',centerX-(round(Width(3)/2))+centerXhalf, centerY-110-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','YOUR ANSWER WILL NOT AFFECT YOUR PERFORMANCE ON THE TASK');
Screen('DrawText',messageWindow,'YOUR ANSWER WILL NOT AFFECT YOUR PERFORMANCE ON THE TASK',centerX-(round(Width(3)/2))-centerXhalf, centerY-110+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','YOUR ANSWER WILL NOT AFFECT YOUR PERFORMANCE ON THE TASK');
Screen('DrawText',messageWindow,'YOUR ANSWER WILL NOT AFFECT YOUR PERFORMANCE ON THE TASK',centerX-(round(Width(3)/2))+centerXhalf, centerY-110+centerYhalf, white);

Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))-centerXhalf, centerY+230-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))+centerXhalf, centerY+230-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))-centerXhalf, centerY+230+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))+centerXhalf, centerY+230+centerYhalf, white);
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
Screen('DrawText',messageWindow,'At the end of each trial, you will be asked',centerX-(round(Width(3)/2))-centerXhalf, centerY-230-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','At the end of each trial, you will be asked');
Screen('DrawText',messageWindow,'At the end of each trial, you will be asked',centerX-(round(Width(3)/2))+centerXhalf, centerY-230-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','At the end of each trial, you will be asked');
Screen('DrawText',messageWindow,'At the end of each trial, you will be asked',centerX-(round(Width(3)/2))-centerXhalf, centerY-230+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','At the end of each trial, you will be asked');
Screen('DrawText',messageWindow,'At the end of each trial, you will be asked',centerX-(round(Width(3)/2))+centerXhalf, centerY-230+centerYhalf, white);


Screen(messageWindow,'TextSize'  , 30)
Width=Screen(messageWindow,'TextBounds','How aware of the highlighted obstacle were you at any point?');
Screen('DrawText',messageWindow,'How aware of the highlighted obstacle were you at any point?',centerX-(round(Width(3)/2))-centerXhalf, centerY-190-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','How aware of the highlighted obstacle were you at any point?');
Screen('DrawText',messageWindow,'How aware of the highlighted obstacle were you at any point?',centerX-(round(Width(3)/2))+centerXhalf, centerY-190-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','How aware of the highlighted obstacle were you at any point?');
Screen('DrawText',messageWindow,'How aware of the highlighted obstacle were you at any point?',centerX-(round(Width(3)/2))-centerXhalf, centerY-190+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','How aware of the highlighted obstacle were you at any point?');
Screen('DrawText',messageWindow,'How aware of the highlighted obstacle were you at any point?',centerX-(round(Width(3)/2))+centerXhalf, centerY-190+centerYhalf, white);



% draw scale 
 scale_pos= [centerX-200, centerY+0; centerX+200, centerY+0; 
                               centerX-200, centerY-20; centerX-200, centerY+20; 
                            centerX-150, centerY-20; centerX-150, centerY+20;
                            centerX-100, centerY-20; centerX-100, centerY+20;
                            centerX-50, centerY-20; centerX-50, centerY+20;
                           centerX-0, centerY-20; centerX-0, centerY+20;
                           centerX+50, centerY-20; centerX+50, centerY+20;
                           centerX+100, centerY-20; centerX+100, centerY+20;
                           centerX+150, centerY-20; centerX+150, centerY+20;
                           centerX+200, centerY-20; centerX+200, centerY+20]';
scale_pos1=scale_pos;
scale_pos1(1,:)=scale_pos(1,:)-centerXhalf;
scale_pos1(2,:)=scale_pos(2,:)-centerYhalf 

scale_pos2=scale_pos;
scale_pos2(1,:)=scale_pos(1,:)+centerXhalf;
scale_pos2(2,:)=scale_pos(2,:)-centerYhalf;

scale_pos3=scale_pos;
scale_pos3(1,:)=scale_pos(1,:)-centerXhalf;
scale_pos3(2,:)=scale_pos(2,:)+centerYhalf;

scale_pos4=scale_pos;
scale_pos4(1,:)=scale_pos(1,:)+centerXhalf;
scale_pos4(2,:)=scale_pos(2,:)+centerYhalf;


Screen('DrawLines',messageWindow,scale_pos1, 10, black);
Screen('DrawLines',messageWindow,scale_pos2, 10, black);
Screen('DrawLines',messageWindow,scale_pos3, 10, black);
Screen('DrawLines',messageWindow,scale_pos4, 10, black);


head1   = [ centerX-centerXhalf, centerY-centerYhalf-40 ]; % coordinates of head
width  = 20;           % width of arrow head
points1 = [ head1-[width,0]         % left corner
               head1+[width,0]         % right corner
               head1+[0,width] ];      % vertex
Screen('FillPoly', messageWindow, white, points1);

head2   = [ centerX+centerXhalf, centerY-centerYhalf-40 ]; % coordinates of head
points2 = [ head2-[width,0]         % left corner
               head2+[width,0]         % right corner
               head2+[0,width] ];      % vertex
Screen('FillPoly', messageWindow, white, points2);

head3   = [ centerX-centerXhalf, centerY+centerYhalf-40 ]; % coordinates of head
points3 = [ head3-[width,0]         % left corner
               head3+[width,0]         % right corner
               head3+[0,width] ];      % vertex
Screen('FillPoly', messageWindow, white, points3);

head4   = [ centerX+centerXhalf, centerY+centerYhalf-40 ]; % coordinates of head
points4 = [ head4-[width,0]         % left corner
               head4+[width,0]         % right corner
               head4+[0,width] ];      % vertex
Screen('FillPoly', messageWindow, white, points4);

Screen(messageWindow,'TextSize'  , 22)
Width=Screen(messageWindow,'TextBounds','use the arrow keys to move the cursor along the scale');
Screen('DrawText',messageWindow,'use the arrow keys to move the cursor along the scale',centerX-(round(Width(3)/2))-centerXhalf, centerY+170-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','use the arrow keys to move the cursor along the scale');
Screen('DrawText',messageWindow,'use the arrow keys to move the cursor along the scale',centerX-(round(Width(3)/2))+centerXhalf, centerY+170-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','use the arrow keys to move the cursor along the scale');
Screen('DrawText',messageWindow,'use the arrow keys to move the cursor along the scale',centerX-(round(Width(3)/2))-centerXhalf, centerY+170+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','use the arrow keys to move the cursor along the scale');
Screen('DrawText',messageWindow,'use the arrow keys to move the cursor along the scale',centerX-(round(Width(3)/2))+centerXhalf, centerY+170+centerYhalf, white);


Width=Screen(messageWindow,'TextBounds','press space when you are ready to submit your answer');
Screen('DrawText',messageWindow,'press space when you are ready to submit your answer',centerX-(round(Width(3)/2))-centerXhalf, centerY+200-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','press space when you are ready to submit your answer');
Screen('DrawText',messageWindow,'press space when you are ready to submit your answer',centerX-(round(Width(3)/2))+centerXhalf, centerY+200-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','press space when you are ready to submit your answer');
Screen('DrawText',messageWindow,'press space when you are ready to submit your answer',centerX-(round(Width(3)/2))-centerXhalf, centerY+200+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','press space when you are ready to submit your answer');
Screen('DrawText',messageWindow,'press space when you are ready to submit your answer',centerX-(round(Width(3)/2))+centerXhalf, centerY+200+centerYhalf, white);

Width=Screen(messageWindow,'TextBounds','not a lot');
Screen('DrawText',messageWindow,'not a lot',centerX-290-(round(Width(3)/2))-centerXhalf, centerY-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','a lot');
Screen('DrawText',messageWindow,'a lot',centerX+300-(round(Width(3)/2))-centerXhalf, centerY-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','not a lot');
Screen('DrawText',messageWindow,'not a lot',centerX-290-(round(Width(3)/2))+centerXhalf, centerY-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','a lot');
Screen('DrawText',messageWindow,'a lot',centerX+300-(round(Width(3)/2))+centerXhalf, centerY-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','not a lot');
Screen('DrawText',messageWindow,'not a lot',centerX-290-(round(Width(3)/2))-centerXhalf, centerY+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','a lot');
Screen('DrawText',messageWindow,'a lot',centerX+300-(round(Width(3)/2))-centerXhalf, centerY+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','not a lot');
Screen('DrawText',messageWindow,'not a lot',centerX-290-(round(Width(3)/2))+centerXhalf, centerY+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','a lot');
Screen('DrawText',messageWindow,'a lot',centerX+300-(round(Width(3)/2))+centerXhalf, centerY+centerYhalf, white);


Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))-centerXhalf, centerY+230-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))+centerXhalf, centerY+230-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))-centerXhalf, centerY+230+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))+centerXhalf, centerY+230+centerYhalf, white);
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
Screen('DrawText',messageWindow,'You will now perform 5 practice trials',centerX-(round(Width(3)/2))-centerXhalf, centerY-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))-centerXhalf, centerY+230-centerYhalf, white);

Width=Screen(messageWindow,'TextBounds','You will now perform 5 practice trials');
Screen('DrawText',messageWindow,'You will now perform 5 practice trials',centerX-(round(Width(3)/2))+centerXhalf, centerY-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))+centerXhalf, centerY+230-centerYhalf, white);

Width=Screen(messageWindow,'TextBounds','You will now perform 5 practice trials');
Screen('DrawText',messageWindow,'You will now perform 5 practice trials',centerX-(round(Width(3)/2))-centerXhalf, centerY+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))-centerXhalf, centerY+230+centerYhalf, white);

Width=Screen(messageWindow,'TextBounds','You will now perform 5 practice trials');
Screen('DrawText',messageWindow,'You will now perform 5 practice trials',centerX-(round(Width(3)/2))+centerXhalf, centerY+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press Spacebar to Continue');
Screen('DrawText',messageWindow,'Press Spacebar to Continue',centerX-(round(Width(3)/2))+centerXhalf, centerY+230+centerYhalf, white);

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
Screen('DrawText',messageWindow,'Press the spacebar to start practice',centerX-(round(Width(3)/2))-centerXhalf, centerY-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press the spacebar to start practice');
Screen('DrawText',messageWindow,'Press the spacebar to start practice',centerX-(round(Width(3)/2))+centerXhalf, centerY-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press the spacebar to start practice');
Screen('DrawText',messageWindow,'Press the spacebar to start practice',centerX-(round(Width(3)/2))-centerXhalf, centerY+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press the spacebar to start practice');
Screen('DrawText',messageWindow,'Press the spacebar to start practice',centerX-(round(Width(3)/2))+centerXhalf, centerY+centerYhalf, white);
Screen('DrawTexture',mainWin,messageWindow);
Screen('Flip',mainWin)
           
while 1
    [keyIsDown,secs,keyCode] = KbCheck; 
    if  keyCode(32)==1 || keyCode(44)==1
        break
    end
end

randtrials4pract= randperm(size(trialMatrix,1),nPracticeTrials);



scale_pos1=scale_pos;
scale_pos1(1,:)=scale_pos(1,:)-centerXhalf;
scale_pos1(2,:)=scale_pos(2,:)-centerYhalf+220 

scale_pos2=scale_pos;
scale_pos2(1,:)=scale_pos(1,:)+centerXhalf;
scale_pos2(2,:)=scale_pos(2,:)-centerYhalf+220;

scale_pos3=scale_pos;
scale_pos3(1,:)=scale_pos(1,:)-centerXhalf;
scale_pos3(2,:)=scale_pos(2,:)+centerYhalf+220;

scale_pos4=scale_pos;
scale_pos4(1,:)=scale_pos(1,:)+centerXhalf;
scale_pos4(2,:)=scale_pos(2,:)+centerYhalf+220;

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
                    
                FixOffSOA = round((120 - 60)*rand(1,1) + 60); %random between 500ms and 1000ms   
                colour_stims= maze_array(1,this_practicetrial);
                relevant_thistrial= maze_relevance(1,this_practicetrial);
                irrelevant_thistrial= maze_irrelevance(1,this_practicetrial);

                % test %
                % 
                index_relv= reshape((relevant_thistrial{1}==1)',1, []);

                colour_stims_temp=colour_stims;
                colour_stims{1}(relevant_thistrial{1}==1) = {[0.5 0 1]};
                colour_stims= reshape(colour_stims{1}', [1, 11*11]);
                colour_stims= vertcat(colour_stims{:})';
                colour_stims_temp= reshape(colour_stims_temp{1}', [1, 11*11]);
                colour_stims_temp= vertcat(colour_stims_temp{:})';

                colour_stims2= colour_stims_temp;
                index_obs=find(sum(colour_stims_temp) ==1 & colour_stims_temp(3,:) ==1);
                colour_stims2([1,2],index_obs)=1;

                colour_stims_1=colour_stims(:,index_relv);
                colour_stims_1(1,:)= 0;
                colour_stims_1(2,:)= 0;
                colour_stims_1(3,:)= 1;

                colour_stims_9=colour_stims(:,index_relv);
                colour_stims_9(1,:)= 1;
                colour_stims_9(2,:)= 1;
                colour_stims_9(3,:)= 1;

                planningphase_rel= cell([1, round(6000/RefreshRate)]);
                planningphase_rel(:) = {colour_stims(:,index_relv)};

                planningphase_rel(1:8:end)={colour_stims_1};
                planningphase_rel(2:8:end)={colour_stims_1};
                planningphase_rel(3:8:end)={colour_stims_1};
                planningphase_rel(4:8:end)={colour_stims_1};
                planningphase_rel(5:8:end)={colour_stims_9};
                planningphase_rel(6:8:end)={colour_stims_9};
                planningphase_rel(7:8:end)={colour_stims_9};
                planningphase_rel(8:8:end)={colour_stims_9};

                index_irrelv= reshape((irrelevant_thistrial{1}==1)',1, []);

                colour_stims_1=colour_stims(:,index_irrelv);
                colour_stims_1(1,:)= 0;
                colour_stims_1(2,:)= 0;
                colour_stims_1(3,:)= 1;

                colour_stims_9=colour_stims(:,index_irrelv);
                colour_stims_9(1,:)= 1;
                colour_stims_9(2,:)= 1;
                colour_stims_9(3,:)= 1;

                planningphase_irrel= cell([1, round(6000/RefreshRate)]);
                planningphase_irrel(:) = {colour_stims(:,index_irrelv)};

                planningphase_irrel(1:6:end)={colour_stims_1};
                planningphase_irrel(2:6:end)={colour_stims_1};
                planningphase_irrel(3:6:end)={colour_stims_1};
                planningphase_irrel(4:6:end)={colour_stims_9};
                planningphase_irrel(5:6:end)={colour_stims_9};
                planningphase_irrel(6:6:end)={colour_stims_9};



                    % Screen priority
                    Priority(MaxPriority(mainWin));
                    Priority(2);
                     
                    %show grey Screen, 
                    Screen('DrawTexture',mainWin,GreyScreen);
                    GreyWinTime=Screen('flip',mainWin);

                    %show Fixation
                    Screen('FillRect',mainWin,color_fixation ,stim_loc1');
                    Screen('FrameRect',mainWin,black ,stim_loc1', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc1, 7, white);
                    Screen('DrawDots', mainWin, [centerX-centerXhalf, centerY-15-centerYhalf], 7, black, [], 2)

                    Screen('FillRect',mainWin,color_fixation ,stim_loc2');
                    Screen('FrameRect',mainWin,black ,stim_loc2', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc2, 7, white);
                    Screen('DrawDots', mainWin, [centerX+centerXhalf, centerY-15-centerYhalf], 7, black, [], 2)

                    Screen('FillRect',mainWin,color_fixation ,stim_loc3');
                    Screen('FrameRect',mainWin,black ,stim_loc3', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc3, 7, white);
                    Screen('DrawDots', mainWin, [centerX-centerXhalf, centerY-15-+centerYhalf], 7, black, [], 2)

                    Screen('FillRect',mainWin,color_fixation ,stim_loc4');
                    Screen('FrameRect',mainWin,black ,stim_loc4', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc4, 7, white);
                    Screen('DrawDots', mainWin, [centerX+centerXhalf, centerY-15+centerYhalf], 7, black, [], 2)
                    FixationWinTime=Screen('flip',mainWin,GreyWinTime + (FixOffSOA*IFI) - slack,0); 

                    %show Fixation
                    Screen('FillRect',mainWin,color_fixation ,stim_loc1');
                    Screen('FrameRect',mainWin,black ,stim_loc1', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc1, 7, white);
                    Screen('DrawDots', mainWin, [centerX-centerXhalf, centerY-15-centerYhalf], 7, black, [], 2)

                    Screen('FillRect',mainWin,color_fixation ,stim_loc2');
                    Screen('FrameRect',mainWin,black ,stim_loc2', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc2, 7, white);
                    Screen('DrawDots', mainWin, [centerX+centerXhalf, centerY-15-centerYhalf], 7, black, [], 2)

                    Screen('FillRect',mainWin,color_fixation ,stim_loc3');
                    Screen('FrameRect',mainWin,black ,stim_loc3', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc3, 7, white);
                    Screen('DrawDots', mainWin, [centerX-centerXhalf, centerY-15-+centerYhalf], 7, black, [], 2)

                    Screen('FillRect',mainWin,color_fixation ,stim_loc4');
                    Screen('FrameRect',mainWin,black ,stim_loc4', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc4, 7, white);
                    Screen('DrawDots', mainWin, [centerX+centerXhalf, centerY-15+centerYhalf], 7, black, [], 2)
                    FixationWinTime=Screen('flip',mainWin,FixationWinTime + (120*IFI) - slack,0); 


                    %% FLICKER
                     for f= 1:4:round(6000/RefreshRate)% 6000 ms in number of screens 

                    Screen('FillRect',mainWin,colour_stims ,stim_loc1');
                    Screen('FrameRect',mainWin,black ,stim_loc1', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc1, 7, white);
                    Screen('DrawDots', mainWin, [centerX-centerXhalf, centerY-15-centerYhalf], 7, black, [], 2)

                    Screen('FillRect',mainWin,colour_stims ,stim_loc2');
                    Screen('FrameRect',mainWin,black ,stim_loc2', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc2, 7, white);
                    Screen('DrawDots', mainWin, [centerX+centerXhalf, centerY-15-centerYhalf], 7, black, [], 2)

                    Screen('FillRect',mainWin,colour_stims ,stim_loc3');
                    Screen('FrameRect',mainWin,black ,stim_loc3', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc3, 7, white);
                    Screen('DrawDots', mainWin, [centerX-centerXhalf, centerY-15-+centerYhalf], 7, black, [], 2)

                    Screen('FillRect',mainWin,colour_stims ,stim_loc4');
                    Screen('FrameRect',mainWin,black ,stim_loc4', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc4, 7, white);
                    Screen('DrawDots', mainWin, [centerX+centerXhalf, centerY-15+centerYhalf], 7, black, [], 2)
                   
                        %show Stimuluas
                        Screen('FillRect',mainWin, planningphase_rel{f} ,stim_loc1(index_relv,:)');
                        Screen('FrameRect',mainWin,black ,stim_loc1(index_relv,:)', 0.5  );

                        Screen('FillRect',mainWin, planningphase_rel{f+1} ,stim_loc2(index_relv,:)');
                        Screen('FrameRect',mainWin,black ,stim_loc2(index_relv,:)', 0.5  );

                        Screen('FillRect',mainWin, planningphase_rel{f+2} ,stim_loc3(index_relv,:)');
                        Screen('FrameRect',mainWin,black ,stim_loc3(index_relv,:)', 0.5  );
 
                        Screen('FillRect',mainWin, planningphase_rel{f+3} ,stim_loc4(index_relv,:)');
                        Screen('FrameRect',mainWin,black ,stim_loc4(index_relv,:)', 0.5  );

                         %show Stimuluas
                        Screen('FillRect',mainWin, planningphase_irrel{f} ,stim_loc1(index_irrelv,:)');
                        Screen('FrameRect',mainWin,black ,stim_loc1(index_irrelv,:)', 0.5  );

                        Screen('FillRect',mainWin, planningphase_irrel{f+1} ,stim_loc2(index_irrelv,:)');
                        Screen('FrameRect',mainWin,black ,stim_loc2(index_irrelv,:)', 0.5  );

                        Screen('FillRect',mainWin, planningphase_irrel{f+2} ,stim_loc3(index_irrelv,:)');
                        Screen('FrameRect',mainWin,black ,stim_loc3(index_irrelv,:)', 0.5  );
 
                        Screen('FillRect',mainWin, planningphase_irrel{f+3} ,stim_loc4(index_irrelv,:)');
                        Screen('FrameRect',mainWin,black ,stim_loc4(index_irrelv,:)', 0.5  );

                        Screen('flip',mainWin,FixationWinTime + (1*IFI) - slack,0);
                    end


                    %%

                    %show Delay period
                    Screen('FillRect',mainWin,color_fixation ,stim_loc1');
                    Screen('FrameRect',mainWin,black ,stim_loc1', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc1, 7, white);
                    Screen('DrawDots', mainWin, [centerX-centerXhalf, centerY-15-centerYhalf], 7, black, [], 2)

                    Screen('FillRect',mainWin,color_fixation ,stim_loc2');
                    Screen('FrameRect',mainWin,black ,stim_loc2', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc2, 7, white);
                    Screen('DrawDots', mainWin, [centerX+centerXhalf, centerY-15-centerYhalf], 7, black, [], 2)

                    Screen('FillRect',mainWin,color_fixation ,stim_loc3');
                    Screen('FrameRect',mainWin,black ,stim_loc3', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc3, 7, white);
                    Screen('DrawDots', mainWin, [centerX-centerXhalf, centerY-15+centerYhalf], 7, black, [], 2)

                    Screen('FillRect',mainWin,color_fixation ,stim_loc4');
                    Screen('FrameRect',mainWin,black ,stim_loc4', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc4, 7, white);
                    Screen('DrawDots', mainWin, [centerX+centerXhalf, centerY-15+centerYhalf], 7, black, [], 2)
     
                    StimulusOffsetWinTime= Screen('flip',mainWin,FixationWinTime + (1*IFI) - slack,0);
              
                    % offset coloured obstacles


                    %show Start of response 
                    Screen('FillRect',mainWin, colour_stims2 ,stim_loc1');
                    Screen('FrameRect',mainWin,black ,stim_loc1', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc1, 7, white);
                    Screen('DrawDots', mainWin, [centerX-centerXhalf, centerY-15-centerYhalf], 7, black, [], 2)

                    Screen('FillRect',mainWin, colour_stims2 ,stim_loc2');
                    Screen('FrameRect',mainWin,black ,stim_loc2', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc2, 7, white);
                    Screen('DrawDots', mainWin, [centerX+centerXhalf, centerY-15-centerYhalf], 7, black, [], 2)

                    Screen('FillRect',mainWin, colour_stims2 ,stim_loc3');
                    Screen('FrameRect',mainWin,black ,stim_loc3', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc3, 7, white);
                    Screen('DrawDots', mainWin, [centerX-centerXhalf, centerY-15+centerYhalf], 7, black, [], 2)

                    Screen('FillRect',mainWin, colour_stims2 ,stim_loc4');
                    Screen('FrameRect',mainWin,black ,stim_loc4', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc4, 7, white);
                    Screen('DrawDots', mainWin, [centerX+centerXhalf, centerY-15+centerYhalf], 7, black, [], 2)

                    ResponseWinTime= Screen('flip',mainWin,StimulusOffsetWinTime + (120*IFI) - slack,0);


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

                                 if keyCode(1) == 37 &&  irow-1 > 0  &&  irow-1 < 12 &&  sum(position_self{1}{ irow-1, icol} == [0 0 1]) ~=3 &&  sum(position_self{1}{ irow-1, icol} == [0 0 0]) ~=3
                                     irow= irow-1;
                                     moves=moves+1;

                                 elseif keyCode(1) == 40 &&  icol+1 > 0 &&  icol+1 < 12 &&  sum(position_self{1}{ irow, icol+1} == [0 0 1]) ~=3 &&  sum(position_self{1}{ irow, icol+1} == [0 0 0]) ~=3
                                     icol= icol+1;
                                     moves=moves+1;

                                 elseif keyCode(1) == 39 &&  irow+1 > 0 &&  irow+1 < 12 &&  sum(position_self{1}{ irow+1, icol} == [0 0 1]) ~=3 &&  sum(position_self{1}{ irow+1, icol} == [0 0 0]) ~=3
                                      irow= irow+1;
                                      moves=moves+1;

                                 elseif keyCode(1) == 38 &&  icol-1 > 0 &&  icol-1 < 12 &&  sum(position_self{1}{ irow, icol-1} == [0 0 1]) ~=3 &&  sum(position_self{1}{ irow, icol-1} == [0 0 0]) ~=3
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
                        Screen('FillRect',mainWin, colour_stims2 ,stim_loc1');
                        Screen('FillRect',mainWin,  cMap(Time_Factor,:) , [goal_pos(1)-centerXhalf, goal_pos(2)-centerYhalf, goal_pos(3)-centerXhalf, goal_pos(4)-centerYhalf]);
                        Screen('FrameRect',mainWin,black ,stim_loc1', 0.5  );
                        Screen('DrawDots', mainWin, [self_pos(1) + 15- centerXhalf, self_pos(2) + 15-centerYhalf], 20, [1 0 0 ], [], 2)
                        Screen('DrawLines',mainWin,center_fix_loc1, 7, white);
                        Screen('DrawDots', mainWin, [centerX- centerXhalf, centerY-15-centerYhalf], 7, black, [], 2)

                        Screen('FillRect',mainWin, colour_stims2 ,stim_loc2');
                        Screen('FillRect',mainWin,  cMap(Time_Factor,:) , [goal_pos(1)+centerXhalf, goal_pos(2)-centerYhalf, goal_pos(3)+centerXhalf, goal_pos(4)-centerYhalf]);
                        Screen('FrameRect',mainWin,black ,stim_loc2', 0.5  );
                        Screen('DrawDots', mainWin, [self_pos(1) + 15+centerXhalf, self_pos(2) + 15-centerYhalf], 20, [1 0 0 ], [], 2)
                        Screen('DrawLines',mainWin,center_fix_loc2, 7, white);
                        Screen('DrawDots', mainWin, [centerX+ centerXhalf, centerY-15-centerYhalf], 7, black, [], 2)

                        Screen('FillRect',mainWin, colour_stims2 ,stim_loc3');
                        Screen('FillRect',mainWin,  cMap(Time_Factor,:) , [goal_pos(1)-centerXhalf, goal_pos(2)+centerYhalf, goal_pos(3)-centerXhalf, goal_pos(4)+centerYhalf]);
                        Screen('FrameRect',mainWin,black ,stim_loc3', 0.5  );
                        Screen('DrawDots', mainWin, [self_pos(1) + 15- centerXhalf, self_pos(2) + 15+centerYhalf], 20, [1 0 0 ], [], 2)
                        Screen('DrawLines',mainWin,center_fix_loc3, 7, white);
                        Screen('DrawDots', mainWin, [centerX- centerXhalf, centerY-15+centerYhalf], 7, black, [], 2)

                        Screen('FillRect',mainWin, colour_stims2 ,stim_loc4');
                        Screen('FillRect',mainWin,  cMap(Time_Factor,:) , [goal_pos(1)+centerXhalf, goal_pos(2)+centerYhalf, goal_pos(3)+centerXhalf, goal_pos(4)+centerYhalf]);
                        Screen('FrameRect',mainWin,black ,stim_loc4', 0.5  );
                        Screen('DrawDots', mainWin, [self_pos(1) + 15+ centerXhalf, self_pos(2) + 15+centerYhalf], 20, [1 0 0 ], [], 2)
                        Screen('DrawLines',mainWin,center_fix_loc4, 7, white);
                        Screen('DrawDots', mainWin, [centerX+centerXhalf, centerY-15+centerYhalf], 7, black, [], 2)

                        Screen('flip',mainWin,ResponseWinTime + (1*IFI) - slack,0);

                        % break loop if solved
                        if irow == grow && icol == gcol
                            % add code here to get RT
                            mazeRT= GetSecs - ResponseWinTime;
                            break;
                        end

                    end

                    % ask about subjective report now
                    Screen('FillRect',mainWin,color_mask ,stim_loc1');
                    Screen('FrameRect',mainWin,black ,stim_loc1', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc1, 7, white);
                    Screen('DrawDots', mainWin, [centerX-centerXhalf, centerY-15-centerYhalf], 7, black, [], 2)

                    Screen('FillRect',mainWin,color_mask ,stim_loc2');
                    Screen('FrameRect',mainWin,black ,stim_loc2', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc2, 7, white);
                    Screen('DrawDots', mainWin, [centerX+centerXhalf, centerY-15-centerYhalf], 7, black, [], 2)

                    Screen('FillRect',mainWin,color_mask ,stim_loc3');
                    Screen('FrameRect',mainWin,black ,stim_loc3', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc3, 7, white);
                    Screen('DrawDots', mainWin, [centerX-centerXhalf, centerY-15+centerYhalf], 7, black, [], 2)

                    Screen('FillRect',mainWin,color_mask ,stim_loc4');
                    Screen('FrameRect',mainWin,black ,stim_loc4', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc4, 7, white);
                    Screen('DrawDots', mainWin, [centerX+centerXhalf, centerY-15+centerYhalf], 7, black, [], 2)

                    Screen('flip',mainWin,mazeRT + (1*IFI) - slack,0);

                    for numobstacles =0:5 % index off bc of python
                         % start at random position of subj report scale not to bias participant response
                         %subjpos=randi([1 9], 1);
                         subjpos=5;
                         subjposorig=subjpos;
    
                         % draw scale 
                        Screen(mainWin, 'TextSize' , 22)
                        Width=Screen(mainWin,'TextBounds','How aware of  the highlighted obstacle were you at any point?');
                        Screen('DrawText',mainWin,'How aware of  the highlighted obstacle were you at any point?',centerX-(round(Width(3)/2))-centerXhalf, centerY-230-centerYhalf, white);
                        Width=Screen(mainWin,'TextBounds','How aware of  the highlighted obstacle were you at any point?');
                        Screen('DrawText',mainWin,'How aware of  the highlighted obstacle were you at any point?',centerX-(round(Width(3)/2))+centerXhalf, centerY-230-centerYhalf, white);
                        Width=Screen(mainWin,'TextBounds','How aware of  the highlighted obstacle were you at any point?');
                        Screen('DrawText',mainWin,'How aware of  the highlighted obstacle were you at any point?',centerX-(round(Width(3)/2))-centerXhalf, centerY-230+centerYhalf, white);
                        Width=Screen(mainWin,'TextBounds','How aware of  the highlighted obstacle were you at any point?');
                        Screen('DrawText',mainWin,'How aware of  the highlighted obstacle were you at any point?',centerX-(round(Width(3)/2))+centerXhalf, centerY-230+centerYhalf, white);
                        
                        colour_stims= color_fixationtemp;
                        %colour_stims= maze_array{1, this_practicetrial};
                        obstacles=maze_obstacles{1, this_practicetrial};
                        index_obstacle=  obstacles == num2str(numobstacles);
                        colour_stims(index_obstacle) = {[1,0 0]};
    
                        colour_stims= reshape(colour_stims', [1, 11*11]);
                        colour_stims= vertcat(colour_stims{:})';
    
                        %show Start of response 
                        Screen('FillRect',mainWin, colour_stims ,stim_loc1');
                        Screen('FrameRect',mainWin,black ,stim_loc1', 0.5  );
                        Screen('DrawLines',mainWin,center_fix_loc1, 7, white);
                        Screen('DrawDots', mainWin, [centerX-centerXhalf, centerY-15-centerYhalf], 7, black, [], 2)

                        Screen('FillRect',mainWin, colour_stims ,stim_loc2');
                        Screen('FrameRect',mainWin,black ,stim_loc2', 0.5  );
                        Screen('DrawLines',mainWin,center_fix_loc2, 7, white);
                        Screen('DrawDots', mainWin, [centerX+centerXhalf, centerY-15-centerYhalf], 7, black, [], 2)

                        Screen('FillRect',mainWin, colour_stims ,stim_loc3');
                        Screen('FrameRect',mainWin,black ,stim_loc3', 0.5  );
                        Screen('DrawLines',mainWin,center_fix_loc3, 7, white);
                        Screen('DrawDots', mainWin, [centerX-centerXhalf, centerY-15+centerYhalf], 7, black, [], 2)

                        Screen('FillRect',mainWin, colour_stims ,stim_loc4');
                        Screen('FrameRect',mainWin,black ,stim_loc4', 0.5  );
                        Screen('DrawLines',mainWin,center_fix_loc4, 7, white);
                        Screen('DrawDots', mainWin, [centerX+centerXhalf, centerY-15+centerYhalf], 7, black, [], 2)
                       
                            
                            Screen('DrawLines',mainWin,scale_pos1, 10, black);
                            Screen('DrawLines',mainWin,scale_pos2, 10, black);
                            Screen('DrawLines',mainWin,scale_pos3, 10, black);
                            Screen('DrawLines',mainWin,scale_pos4, 10, black);


                            head1   = [ (centerX-centerXhalf+ ((400/8) * (subjpos- 5))), centerY+210-40-centerYhalf ]; % coordinates of head
                            width  = 20;           % width of arrow head
                            points1 = [ head1-[width,0]         % left corner
                                           head1+[width,0]         % right corner
                                           head1+[0,width] ];      % vertex

                            head2   = [ (centerX+centerXhalf+ ((400/8) * (subjpos- 5))), centerY+210-40-centerYhalf ]; % coordinates of head
                            width  = 20;           % width of arrow head
                            points2 = [ head2-[width,0]         % left corner
                                           head2+[width,0]         % right corner
                                           head2+[0,width] ];      % vertex

                            head3   = [ (centerX-centerXhalf+ ((400/8) * (subjpos- 5))), centerY+210-40+centerYhalf ]; % coordinates of head
                            width  = 20;           % width of arrow head
                            points3 = [ head3-[width,0]         % left corner
                                           head3+[width,0]         % right corner
                                           head3+[0,width] ];      % vertex

                            head4   = [ (centerX+centerXhalf+ ((400/8) * (subjpos- 5))), centerY+210-40+centerYhalf ]; % coordinates of head
                            width  = 20;           % width of arrow head
                            points4 = [ head4-[width,0]         % left corner
                                           head4+[width,0]         % right corner
                                           head4+[0,width] ];      % vertex

                            Screen('FillPoly', mainWin, white, points1);
                            Screen('FillPoly', mainWin, white, points2);
                            Screen('FillPoly', mainWin, white, points3);
                            Screen('FillPoly', mainWin, white, points4);
                            
                            Width=Screen(mainWin,'TextBounds','not a lot');
                            Screen('DrawText',mainWin,'not a lot',centerX-260-(round(Width(3)/2))-centerXhalf, centerY+210-centerYhalf, white);
                            Width=Screen(mainWin,'TextBounds','a lot');
                            Screen('DrawText',mainWin,'a lot',centerX+240-(round(Width(3)/2))-centerXhalf, centerY+210-centerYhalf, white);

                            Width=Screen(mainWin,'TextBounds','not a lot');
                            Screen('DrawText',mainWin,'not a lot',centerX-260-(round(Width(3)/2))+centerXhalf, centerY+210-centerYhalf, white);
                            Width=Screen(mainWin,'TextBounds','a lot');
                            Screen('DrawText',mainWin,'a lot',centerX+240-(round(Width(3)/2))+centerXhalf, centerY+210-centerYhalf, white);

                            Width=Screen(mainWin,'TextBounds','not a lot');
                            Screen('DrawText',mainWin,'not a lot',centerX-260-(round(Width(3)/2))-centerXhalf, centerY+210+centerYhalf, white);
                            Width=Screen(mainWin,'TextBounds','a lot');
                            Screen('DrawText',mainWin,'a lot',centerX+240-(round(Width(3)/2))-centerXhalf, centerY+210+centerYhalf, white);

                            Width=Screen(mainWin,'TextBounds','not a lot');
                            Screen('DrawText',mainWin,'not a lot',centerX-260-(round(Width(3)/2))+centerXhalf, centerY+210+centerYhalf, white);
                            Width=Screen(mainWin,'TextBounds','a lot');
                            Screen('DrawText',mainWin,'a lot',centerX+240-(round(Width(3)/2))+centerXhalf, centerY+220+centerYhalf, white);

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
                         Screen(mainWin, 'TextSize' , 22)
                       Width=Screen(mainWin,'TextBounds','How aware of  the highlighted obstacle were you at any point?');
                        Screen('DrawText',mainWin,'How aware of  the highlighted obstacle were you at any point?',centerX-(round(Width(3)/2))-centerXhalf, centerY-230-centerYhalf, white);
                        Width=Screen(mainWin,'TextBounds','How aware of  the highlighted obstacle were you at any point?');
                        Screen('DrawText',mainWin,'How aware of  the highlighted obstacle were you at any point?',centerX-(round(Width(3)/2))+centerXhalf, centerY-230-centerYhalf, white);
                        Width=Screen(mainWin,'TextBounds','How aware of  the highlighted obstacle were you at any point?');
                        Screen('DrawText',mainWin,'How aware of  the highlighted obstacle were you at any point?',centerX-(round(Width(3)/2))-centerXhalf, centerY-230+centerYhalf, white);
                        Width=Screen(mainWin,'TextBounds','How aware of  the highlighted obstacle were you at any point?');
                        Screen('DrawText',mainWin,'How aware of  the highlighted obstacle were you at any point?',centerX-(round(Width(3)/2))+centerXhalf, centerY-230+centerYhalf, white);
                        
                         Screen('FillRect',mainWin, colour_stims ,stim_loc1');
                        Screen('FrameRect',mainWin,black ,stim_loc1', 0.5  );
                        Screen('DrawLines',mainWin,center_fix_loc1, 7, white);
                        Screen('DrawDots', mainWin, [centerX-centerXhalf, centerY-15-centerYhalf], 7, black, [], 2)

                        Screen('FillRect',mainWin, colour_stims ,stim_loc2');
                        Screen('FrameRect',mainWin,black ,stim_loc2', 0.5  );
                        Screen('DrawLines',mainWin,center_fix_loc2, 7, white);
                        Screen('DrawDots', mainWin, [centerX+centerXhalf, centerY-15-centerYhalf], 7, black, [], 2)

                        Screen('FillRect',mainWin, colour_stims ,stim_loc3');
                        Screen('FrameRect',mainWin,black ,stim_loc3', 0.5  );
                        Screen('DrawLines',mainWin,center_fix_loc3, 7, white);
                        Screen('DrawDots', mainWin, [centerX-centerXhalf, centerY-15+centerYhalf], 7, black, [], 2)

                        Screen('FillRect',mainWin, colour_stims ,stim_loc4');
                        Screen('FrameRect',mainWin,black ,stim_loc4', 0.5  );
                        Screen('DrawLines',mainWin,center_fix_loc4, 7, white);
                        Screen('DrawDots', mainWin, [centerX+centerXhalf, centerY-15+centerYhalf], 7, black, [], 2)

                            Screen('DrawLines',mainWin,scale_pos1, 10, black);
                            Screen('DrawLines',mainWin,scale_pos2, 10, black);
                            Screen('DrawLines',mainWin,scale_pos3, 10, black);
                            Screen('DrawLines',mainWin,scale_pos4, 10, black);

    
                            head1   = [ (centerX-centerXhalf+ ((400/8) * (subjpos- 5))), centerY+210-40-centerYhalf ]; % coordinates of head
                            width  = 20;           % width of arrow head
                            points1 = [ head1-[width,0]         % left corner
                                           head1+[width,0]         % right corner
                                           head1+[0,width] ];      % vertex

                            head2   = [ (centerX+centerXhalf+ ((400/8) * (subjpos- 5))), centerY+210-40-centerYhalf ]; % coordinates of head
                            width  = 20;           % width of arrow head
                            points2 = [ head2-[width,0]         % left corner
                                           head2+[width,0]         % right corner
                                           head2+[0,width] ];      % vertex

                            head3   = [ (centerX-centerXhalf+ ((400/8) * (subjpos- 5))), centerY+210-40+centerYhalf ]; % coordinates of head
                            width  = 20;           % width of arrow head
                            points3 = [ head3-[width,0]         % left corner
                                           head3+[width,0]         % right corner
                                           head3+[0,width] ];      % vertex

                            head4   = [ (centerX+centerXhalf+ ((400/8) * (subjpos- 5))), centerY+210-40+centerYhalf ]; % coordinates of head
                            width  = 20;           % width of arrow head
                            points4 = [ head4-[width,0]         % left corner
                                           head4+[width,0]         % right corner
                                           head4+[0,width] ];      % vertex

                            Screen('FillPoly', mainWin, white, points1);
                            Screen('FillPoly', mainWin, white, points2);
                            Screen('FillPoly', mainWin, white, points3);
                            Screen('FillPoly', mainWin, white, points4);
                            
                            Width=Screen(mainWin,'TextBounds','not a lot');
                            Screen('DrawText',mainWin,'not a lot',centerX-260-(round(Width(3)/2))-centerXhalf, centerY+210-centerYhalf, white);
                            Width=Screen(mainWin,'TextBounds','a lot');
                            Screen('DrawText',mainWin,'a lot',centerX+240-(round(Width(3)/2))-centerXhalf, centerY+210-centerYhalf, white);

                            Width=Screen(mainWin,'TextBounds','not a lot');
                            Screen('DrawText',mainWin,'not a lot',centerX-260-(round(Width(3)/2))+centerXhalf, centerY+210-centerYhalf, white);
                            Width=Screen(mainWin,'TextBounds','a lot');
                            Screen('DrawText',mainWin,'a lot',centerX+240-(round(Width(3)/2))+centerXhalf, centerY+210-centerYhalf, white);

                            Width=Screen(mainWin,'TextBounds','not a lot');
                            Screen('DrawText',mainWin,'not a lot',centerX-260-(round(Width(3)/2))-centerXhalf, centerY+210+centerYhalf, white);
                            Width=Screen(mainWin,'TextBounds','a lot');
                            Screen('DrawText',mainWin,'a lot',centerX+240-(round(Width(3)/2))-centerXhalf, centerY+210+centerYhalf, white);

                            Width=Screen(mainWin,'TextBounds','not a lot');
                            Screen('DrawText',mainWin,'not a lot',centerX-260-(round(Width(3)/2))+centerXhalf, centerY+210+centerYhalf, white);
                            Width=Screen(mainWin,'TextBounds','a lot');
                            Screen('DrawText',mainWin,'a lot',centerX+240-(round(Width(3)/2))+centerXhalf, centerY+220+centerYhalf, white);

                            SubjWinTime= Screen('flip',mainWin,SubjWinTime + (1*IFI) - slack,0);
                            WaitSecs(0.1);
                        end
                    end

                    %show Black Screen
                    Screen('DrawTexture',mainWin,GreyScreen);
                    Screen('flip',mainWin,0);
                   
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
Screen('DrawText',messageWindow,'Practice is completed',centerX-(round(Width(3)/2))-centerXhalf, centerY-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press the Spacebar to Continue');
Screen('DrawText',messageWindow,'Press the Spacebar to Continue',centerX-(round(Width(3)/2))-centerXhalf, centerY+230-centerYhalf, white);

Width=Screen(messageWindow,'TextBounds','Practice is completed');
Screen('DrawText',messageWindow,'Practice is completed',centerX-(round(Width(3)/2))+centerXhalf, centerY-centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press the Spacebar to Continue');
Screen('DrawText',messageWindow,'Press the Spacebar to Continue',centerX-(round(Width(3)/2))+centerXhalf, centerY+230-centerYhalf, white);

Width=Screen(messageWindow,'TextBounds','Practice is completed');
Screen('DrawText',messageWindow,'Practice is completed',centerX-(round(Width(3)/2))-centerXhalf, centerY+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press the Spacebar to Continue');
Screen('DrawText',messageWindow,'Press the Spacebar to Continue',centerX-(round(Width(3)/2))-centerXhalf, centerY+230+centerYhalf, white);

Width=Screen(messageWindow,'TextBounds','Practice is completed');
Screen('DrawText',messageWindow,'Practice is completed',centerX-(round(Width(3)/2))+centerXhalf, centerY+centerYhalf, white);
Width=Screen(messageWindow,'TextBounds','Press the Spacebar to Continue');
Screen('DrawText',messageWindow,'Press the Spacebar to Continue',centerX-(round(Width(3)/2))+centerXhalf, centerY+230+centerYhalf, white);

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
                index_obs=find(sum(colour_stims) ==1 & colour_stims(3,:) ==1);
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
                    
                    % Screen priority
                    Priority(MaxPriority(mainWin));
                    Priority(2);
                     
                    %show grey Screen, 
                    Screen('DrawTexture',mainWin,GreyScreen);
                    GreyWinTime=Screen('flip',mainWin);

                    %show Fixation
                    Screen('FillRect',mainWin,color_fixation ,stim_loc');
                    Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc, 7, white);
                    Screen('DrawDots', mainWin, [centerX, centerY-15], 7, black, [], 2)
                    FixationWinTime=Screen('flip',mainWin,GreyWinTime + (FixOffSOA*IFI) - slack,0); 
                    
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
              
                    %show Start of response 
                    Screen('FillRect',mainWin, colour_stims2 ,stim_loc');
                    Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc, 7, white);
                    Screen('DrawDots', mainWin, [centerX, centerY-15], 7, black, [], 2)
                    ResponseWinTime= Screen('flip',mainWin,StimulusOffsetWinTime + (60*IFI) - slack,0);


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

                                 if keyCode(1) == 37 &&  irow-1 > 0  &&  irow-1 < 12 &&  sum(position_self{1}{ irow-1, icol} == [0 0 1]) ~=3 &&  sum(position_self{1}{ irow-1, icol} == [0 0 0]) ~=3
                                     irow= irow-1;
                                     moves=moves+1;

                                 elseif keyCode(1) == 40 &&  icol+1 > 0 &&  icol+1 < 12 &&  sum(position_self{1}{ irow, icol+1} == [0 0 1]) ~=3 &&  sum(position_self{1}{ irow, icol+1} == [0 0 0]) ~=3
                                     icol= icol+1;
                                     moves=moves+1;

                                 elseif keyCode(1) == 39 &&  irow+1 > 0 &&  irow+1 < 12 &&  sum(position_self{1}{ irow+1, icol} == [0 0 1]) ~=3 &&  sum(position_self{1}{ irow+1, icol} == [0 0 0]) ~=3
                                      irow= irow+1;
                                      moves=moves+1;

                                 elseif keyCode(1) == 38 &&  icol-1 > 0 &&  icol-1 < 12 &&  sum(position_self{1}{ irow, icol-1} == [0 0 1]) ~=3 &&  sum(position_self{1}{ irow, icol-1} == [0 0 0]) ~=3
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

                    % ask about subjective report now

                    % add fixation to avoid after images
                    Screen('FillRect',mainWin,color_mask ,stim_loc');
                    Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                    Screen('DrawLines',mainWin,center_fix_loc, 7, white);
                    Screen('DrawDots', mainWin, [centerX, centerY-15], 7, black, [], 2)
                    Screen('flip',mainWin,mazeRT + (1*IFI) - slack,0);

                    for numobstacles =0:5 % index off bc of python
                    %subjpos=randi([1 9], 1); % start at random position 
                    subjpos=5;
                    subjposorig(numobstacles+1)= subjpos;

                     % draw scale 
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

             
                    %------------------------------------------------------------
                    % BLOCK CHECK
                    %------------------------------------------------------------
    
                    if (itrial < nTrials) && (mod(itrial,16)==0)
    
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
            if keyCode(32)==1 || keyCode(44)==1
                break
            end
        end
        fclose(fid);
        sca
         
end
