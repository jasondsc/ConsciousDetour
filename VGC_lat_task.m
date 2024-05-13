function task_representations

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WRITE DESCRIPTION OF TASK
% Participants will solve a series of mazes and reprot on their subsequent
% awareness of obstacles
% Participants can perform 10 practice trials
%
% Org Author: Jason da Silva Castanheira 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% !!!!!!!!!!!!!!!!!!!! TO REMOVE TO REMOVE TO REMOVE  !!!!!!!!!!!!!!!
% !!!!!!!!!!!!!!!!!!!! TO REMOVE TO REMOVE TO REMOVE  !!!!!!!!!!!!!!!
%Screen('Preference', 'SkipSyncTests', 1); 
% !!!!!!!!!!!!!!!!!!!! TO REMOVE TO REMOVE TO REMOVE  !!!!!!!!!!!!!!!
% !!!!!!!!!!!!!!!!!!!! TO REMOVE TO REMOVE TO REMOVE  !!!!!!!!!!!!!!!


CurrentFrameRateHz=FrameRate(0);

%if (FrameRate(0)~=75)
%     disp('Screen refresh rate is not 75Hz. Plese adjust Screen refresh rate to 75 Hz!')
%     disp('check resolution')
%     return
%end

%------------------------------------------------------------
%EXPERIMENT INFORMATION
%------------------------------------------------------------  
        
prompt={'SubjectID:','Gender','Age','Handiness (1=LEFT or 2=RIGHT): ','Practice (1=Yes; 2=No)'};
title='EXPERIMENT INFORMATION'; 
answer=inputdlg(prompt,title);
subjectID = char(answer{1});
Gender=char(answer{2});
Age=str2num(answer{3});
handiness = str2num(answer{4});
practice = str2num(answer{5});
experiment = 'VGC_lat_behav';

%------------------------------------------------------------
% MAKE TRIAL MATRIX
%------------------------------------------------------------

% Call function to update Maze stims
create_VGC_stims()

% load in stims
load('./StimMazes_RGB_4_Matlab.mat');

% now let us make one big trail matrix 
maze= repmat([1:48],1,4)';
lateralized=repelem([0,1],1,96)';
side= repelem([1,2,1,2],1,48)';
temp=repmat([maze,lateralized, side], 6,1);
trialMatrix= table(temp(:,1), temp(:,2), temp(:,3));
trialMatrix.Properties.VariableNames = ["mazeNo", "lateralized", "side"];

trialMatrix = trialMatrix(randperm(size(trialMatrix,1)), :);
nTrials=size(trialMatrix,1);

maze_array= {};
maze_array([trialMatrix.lateralized== 1 & trialMatrix.side ==1])=stim_right_mazes_lat(trialMatrix.mazeNo([trialMatrix.lateralized== 1 & trialMatrix.side ==1]));
maze_array([trialMatrix.lateralized== 1 & trialMatrix.side ==2])=stim_left_mazes_lat(trialMatrix.mazeNo([trialMatrix.lateralized== 1 & trialMatrix.side ==2]));
maze_array([trialMatrix.lateralized== 0 & trialMatrix.side ==1])=stim_orig_mazes_nonlat(trialMatrix.mazeNo([trialMatrix.lateralized== 0 & trialMatrix.side ==1]));
maze_array([trialMatrix.lateralized== 0 & trialMatrix.side ==2])=stim_flipped_mazes_nonlat(trialMatrix.mazeNo([trialMatrix.lateralized== 0 & trialMatrix.side ==2]));

maze_obstacles= {};
maze_obstacles([trialMatrix.lateralized== 1 & trialMatrix.side ==1])=right_mazes_lat(trialMatrix.mazeNo([trialMatrix.lateralized== 1 & trialMatrix.side ==1]));
maze_obstacles([trialMatrix.lateralized== 1 & trialMatrix.side ==2])=left_mazes_lat(trialMatrix.mazeNo([trialMatrix.lateralized== 1 & trialMatrix.side ==2]));
maze_obstacles([trialMatrix.lateralized== 0 & trialMatrix.side ==1])=orig_mazes_nonlat(trialMatrix.mazeNo([trialMatrix.lateralized== 0 & trialMatrix.side ==1]));
maze_obstacles([trialMatrix.lateralized== 0 & trialMatrix.side ==2])=flipped_mazes_nonlat(trialMatrix.mazeNo([trialMatrix.lateralized== 0 & trialMatrix.side ==2]));


%------------------------------------------------------------
%SET UP DISPLAY
%------------------------------------------------------------
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
Screen(mainWin,'TextSize',14);
Screen(mainWin,'TextFont','Arial');
Screen(mainWin,'FillRect',grey);
Screen('Flip', mainWin    );


% set up locations of squares and fixation

color_fixation= stim_right_mazes_lat{1,1};
index_fix_temp=cell2mat(cellfun(@sum, color_fixation, 'UniformOutput', false)) > 0;

color_fixation(index_fix_temp) = {[1 1 1]};
color_fixation= reshape(color_fixation, [1, 11*11]);
color_fixation= vertcat(color_fixation{:})';


stim_loc=[[centerX-240 centerY-160 centerX-200 centerY-120]; [centerX-200 centerY-160 centerX-160 centerY-120];
[centerX-160 centerY-160 centerX-120 centerY-120]; [centerX-120 centerY-160 centerX-80 centerY-120];
[centerX-80 centerY-160 centerX-40 centerY-120]; [centerX-40 centerY-160 centerX+0 centerY-120]; [centerX+0 centerY-160 centerX+40 centerY-120];  
[centerX+40 centerY-160 centerX+80 centerY-120]; [centerX+80 centerY-160 centerX+120 centerY-120]; 
[centerX+120 centerY-160 centerX+160 centerY-120]; [centerX+160 centerY-160 centerX+200 centerY-120]; 
...
[centerX-240 centerY-120 centerX-200 centerY-80]; [centerX-200 centerY-120 centerX-160 centerY-80];
[centerX-160 centerY-120 centerX-120 centerY-80]; [centerX-120 centerY-120 centerX-80 centerY-80 ]; [centerX-80 centerY-120 centerX-40 centerY-80]; 
[centerX-40 centerY-120 centerX+0 centerY-80]; [centerX+0 centerY-120 centerX+40 centerY-80];  
[centerX+40 centerY-120 centerX+80 centerY-80]; [centerX+80 centerY-120 centerX+120 centerY-80]; [centerX+120 centerY-120 centerX+160 centerY-80]; 
[centerX+160 centerY-120 centerX+200 centerY-80]; 
...
[centerX-240 centerY-80 centerX-200 centerY-40]; [centerX-200 centerY-80 centerX-160 centerY-40];
[centerX-160 centerY-80 centerX-120 centerY-40]; [centerX-120 centerY-80 centerX-80 centerY-40];
[centerX-80 centerY-80 centerX-40 centerY-40]; [centerX-40 centerY-80 centerX centerY-40];
[centerX+0 centerY-80 centerX+40 centerY-40]; [centerX+40 centerY-80 centerX+80 centerY-40];  [centerX+80 centerY-80 centerX+120 centerY-40]; 
[centerX+120 centerY-80 centerX+160 centerY-40]; [centerX+160 centerY-80 centerX+200 centerY-40]; 
...
[centerX-240 centerY-40 centerX-200 centerY-0];[centerX-200 centerY-40 centerX-160 centerY-0];[centerX-160 centerY-40 centerX-120 centerY-0];
[centerX-120 centerY-40 centerX-80 centerY]; [centerX-80 centerY-40 centerX-40 centerY]; 
[centerX-40 centerY-40 centerX+0 centerY];  [centerX+0 centerY-40 centerX+40 centerY];  [centerX+40 centerY-40 centerX+80 centerY]; 
[centerX+80 centerY-40 centerX+120 centerY-0]; [centerX+120 centerY-40 centerX+160 centerY-0]; 
[centerX+160 centerY-40 centerX+200 centerY-0]; 
...
[centerX-240 centerY-0 centerX-200 centerY+40];[centerX-200 centerY-0 centerX-160 centerY+40];
[centerX-160 centerY-0 centerX-120 centerY+40];[centerX-120 centerY-0 centerX-80 centerY+40];
[centerX-80 centerY-0 centerX-40 centerY+40]; [centerX-40 centerY-0 centerX centerY+40];
[centerX+0 centerY-0 centerX+40 centerY+40]; [centerX+40 centerY-0 centerX+80 centerY+40]; 
[centerX+80 centerY-0 centerX+120 centerY+40]; [centerX+120 centerY-0 centerX+160 centerY+40]; 
[centerX+160 centerY-0 centerX+200 centerY+40]; 
...
[centerX-240 centerY+40 centerX-200 centerY+80]; [centerX-200 centerY+40 centerX-160 centerY+80];
[centerX-160 centerY+40 centerX-120 centerY+80]; [centerX-120 centerY+40 centerX-80 centerY+80];
[centerX-80 centerY+40 centerX-40 centerY+80]; [centerX-40 centerY+40 centerX centerY+80];
[centerX+0 centerY+40 centerX+40 centerY+80];[centerX+40 centerY+40 centerX+80 centerY+80]; 
[centerX+80 centerY+40 centerX+120 centerY+80]; [centerX+120 centerY+40 centerX+160 centerY+80]; 
[centerX+160 centerY+40 centerX+200 centerY+80]; 
...
[centerX-240 centerY+80 centerX-200 centerY+120];[centerX-200 centerY+80 centerX-160 centerY+120];
[centerX-160 centerY+80 centerX-120 centerY+120];[centerX-120 centerY+80 centerX-80 centerY+120];[centerX-80 centerY+80 centerX-40 centerY+120];
[centerX-40 centerY+80 centerX centerY+120];[centerX+0 centerY+80 centerX+40 centerY+120];
[centerX+40 centerY+80 centerX+80 centerY+120]; [centerX+80 centerY+80 centerX+120 centerY+120]; 
[centerX+120 centerY+80 centerX+160 centerY+120]; [centerX+160 centerY+80 centerX+200 centerY+120]; 
...
[centerX-240 centerY+120 centerX-200 centerY+160];[centerX-200 centerY+120 centerX-160 centerY+160];
[centerX-160 centerY+120 centerX-120 centerY+160];[centerX-120 centerY+120 centerX-80 centerY+160];[centerX-80 centerY+120 centerX-40 centerY+160];
[centerX-40 centerY+120 centerX centerY+160]; [centerX+0 centerY+120 centerX+40 centerY+160];
[centerX+40 centerY+120 centerX+80 centerY+160]; [centerX+80 centerY+120 centerX+120 centerY+160]; 
[centerX+120 centerY+120 centerX+160 centerY+160]; [centerX+160 centerY+120 centerX+200 centerY+160]; 
...
[centerX-240 centerY+160 centerX-200 centerY+200];[centerX-200 centerY+160 centerX-160 centerY+200];
[centerX-160 centerY+160 centerX-120 centerY+200];[centerX-120 centerY+160 centerX-80 centerY+200];
[centerX-80 centerY+160 centerX-40 centerY+200];[centerX-40 centerY+160 centerX centerY+200];
[centerX+0 centerY+160 centerX+40 centerY+200];[centerX+40 centerY+160 centerX+80 centerY+200]; 
[centerX+80 centerY+160 centerX+120 centerY+200]; [centerX+120 centerY+160 centerX+160 centerY+200]; 
[centerX+160 centerY+160 centerX+200 centerY+200]; 
...
[centerX-240 centerY+200 centerX-200 centerY+240];[centerX-200 centerY+200 centerX-160 centerY+240]; [centerX-160 centerY+200 centerX-120 centerY+240];
[centerX-120 centerY+200 centerX-80 centerY+240];[centerX-80 centerY+200 centerX-40 centerY+240];
[centerX-40 centerY+200 centerX centerY+240];[centerX+0 centerY+200 centerX+40 centerY+240];
[centerX+40 centerY+200 centerX+80 centerY+240]; [centerX+80 centerY+200 centerX+120 centerY+240]; 
[centerX+120 centerY+200 centerX+160 centerY+240]; [centerX+160 centerY+200 centerX+200 centerY+240]; 
...
[centerX-240 centerY+240 centerX-200 centerY+280];[centerX-200 centerY+240 centerX-160 centerY+280];[centerX-160 centerY+240 centerX-120 centerY+280];
[centerX-120 centerY+240 centerX-80 centerY+280];[centerX-80 centerY+240 centerX-40 centerY+280];
[centerX-40 centerY+240 centerX centerY+280];[centerX+0 centerY+240 centerX+40 centerY+280];
[centerX+40 centerY+240 centerX+80 centerY+280]; [centerX+80 centerY+240 centerX+120 centerY+280]; 
[centerX+120 centerY+240 centerX+160 centerY+280]; [centerX+160 centerY+240 centerX+200 centerY+280] ];

stim_loc(:,2)= stim_loc(:, 2)-60;
stim_loc(:,4)= stim_loc(:, 4)-60;

%------------------------------------------------------------
%SET UP KEYBOARD
%------------------------------------------------------------

 KbName('UnifyKeyNames');
KbCheckList = [KbName('space'),KbName('ESCAPE')];

%-------------------------------------------------------
%OPEN THE OUTPUT FILE AND GIVE IT HEADINGS 
%-------------------------------------------------------

fname = [subjectID,'.txt'];
fid = fopen(fname,'a');   
fprintf(fid,'%-16.16s\t','Subject Code');
fprintf(fid,'%-16.16s\t','Gender');
fprintf(fid,'%-16.16s\t','Age');
fprintf(fid,'%-16.16s\t','Experiment');
fprintf(fid,'%-16.16s\t','Handiness');
fprintf(fid,'%-16.16s\t','Trial.Number');
fprintf(fid,'%-16.16s\t','MazeName');
fprintf(fid,'%-16.16s\t','MazeID');
fprintf(fid,'%-16.16s\t','Lateralized');
fprintf(fid,'%-16.16s\t','Sie');
fprintf(fid,'%-16.16s\t','Solution.RT');                                     
fprintf(fid,'%-16.16s\t','Awareness.ReportObs1'); 
fprintf(fid,'%-16.16s\t','Awareness.ReportObs2');  

%------------------------------------------------------------
%ALLTRIALS
%------------------------------------------------------------  

itrial=1;

%------------------------------------------------------------
%DISPLAY SETUP
%------------------------------------------------------------

%message windows

messageWindow = Screen(mainWin,'OpenOffscreenWindow',grey);
Screen(messageWindow,'TextSize',11);

%------------------------------------------------------------
% DISPLAY BEGINING SCREEN
%------------------------------------------------------------

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

colour_stims= reshape(stim_right_mazes_lat{1}, [1, 11*11]);
colour_stims= vertcat(colour_stims{:})';

Screen('FillRect',messageWindow,colour_stims ,stim_loc');
Screen('FrameRect',messageWindow,black ,stim_loc', 0.5  );

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
Width=Screen(messageWindow,'TextBounds','At the start of each trial, you will have');
Screen('DrawText',messageWindow,'At the start of each trial, you will have',centerX-(round(Width(3)/2)), centerY-300, white);
Width=Screen(messageWindow,'TextBounds','a few seconds to plan how you will solve the maze');
Screen('DrawText',messageWindow,'a few seconds to plan how you will solve the maze',centerX-(round(Width(3)/2)), centerY-260, white);
Width=Screen(messageWindow,'TextBounds','Afterwards the maze will disapear');
Screen('DrawText',messageWindow,'Afterwards the maze will disapear',centerX-(round(Width(3)/2)), centerY-220, white);
Width=Screen(messageWindow,'TextBounds','When the maze reappears you can begin to solve it!');
Screen('DrawText',messageWindow,'When the maze reappears you can begin to solve it!',centerX-(round(Width(3)/2)), centerY-180, white);
Width=Screen(messageWindow,'TextBounds','Use the arrow keys to navigate through the maze with your RIGHT index finger');
Screen('DrawText',messageWindow,'Use the arrow keys to navigate through the maze with your RIGHT index finger',centerX-(round(Width(3)/2)), centerY+100, white);
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
Width=Screen(messageWindow,'TextBounds','At the end of each trial, you will be asked');
Screen('DrawText',messageWindow,'At the end of each trial, you will be asked',centerX-(round(Width(3)/2)), centerY-300, white);
Width=Screen(messageWindow,'TextBounds','How aware of the highlighted obstacle were you at any point?');
Screen('DrawText',messageWindow,'How aware of the highlighted obstacle were you at any point?',centerX-(round(Width(3)/2)), centerY-260, white);
Width=Screen(messageWindow,'TextBounds','You will respond on an 8 point scale like the one below');
Screen('DrawText',messageWindow,'You will respond on an 8 point scale like the one below',centerX-(round(Width(3)/2)), centerY-220, white);

% draw scale 
                   scale_pos= [centerX-350, centerY+0; centerX+350, centerY+0; 
                            centerX-350, centerY-40; centerX-350, centerY+40;
                            centerX-250, centerY-40; centerX-250, centerY+40;
                            centerX-150, centerY-40; centerX-150, centerY+40;
                           centerX-50, centerY-40; centerX-50, centerY+40;
                           centerX+50, centerY-40; centerX+50, centerY+40;
                           centerX+150, centerY-40; centerX+150, centerY+40;
                           centerX+250, centerY-40; centerX+250, centerY+40;
                           centerX+350, centerY-40; centerX+350, centerY+40]';

Screen('DrawLines',messageWindow,scale_pos, 10, black);
head   = [ centerX-50, centerY-40 ]; % coordinates of head
width  = 20;           % width of arrow head
points = [ head-[width,0]         % left corner
               head+[width,0]         % right corner
               head+[0,width] ];      % vertex
Screen('FillPoly', messageWindow, white, points);

Width=Screen(messageWindow,'TextBounds','unaware');
Screen('DrawText',messageWindow,'unaware',centerX-450-(round(Width(3)/2)), centerY, white);
Width=Screen(messageWindow,'TextBounds','aware');
Screen('DrawText',messageWindow,'aware',centerX+450-(round(Width(3)/2)), centerY, white);


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

PracticeTrialSequence=trialMatrix(1:10,:);
nPracticeTrials=10;

%------------------------------------------------------------
%PRACTICE MESSAGE
%------------------------------------------------------------ 

WaitSecs(1);
messageWindow = Screen(mainWin,'OpenOffscreenWindow',grey);
Screen(messageWindow,'TextSize'  , 22)
Width=Screen(messageWindow,'TextBounds','You will now perform 10 practice trials');
Screen('DrawText',messageWindow,'You will now perform 10 practice trials',centerX-(round(Width(3)/2)), centerY, white);
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


%------------------------------------------------------------
%ALLPRACTICETRIALS
%------------------------------------------------------------    
    
for this_practicetrial=1:nPracticeTrials

%------------------------------------------------------------
%DISPLAY SETUP
%------------------------------------------------------------

    %taskwindows
    GreyScreen=Screen('OpenOffscreenWindow',mainWin,grey);
    FixationWin=Screen('openoffScreenwindow',mainWin,grey); 
    PostFixationWin=Screen('openoffScreenwindow',mainWin,grey); 
    CueWin=Screen('openoffScreenwindow',mainWin,grey); 
    PostCueWin=Screen('openoffScreenwindow',mainWin,grey);
    TgtWin=Screen('openoffScreenwindow',mainWin,grey);
    PostTgtWin=Screen('openoffScreenwindow',mainWin,grey);
    MaskWin=Screen('openoffScreenwindow',mainWin,grey);
    PostmaskWin=Screen('openoffScreenwindow',mainWin,grey);
    GreyScreenWin=Screen('openoffScreenwindow',mainWin,grey);
    SubjectiveWin=Screen('OpenOffscreenWindow',mainWin,grey); 

%-------------------------------------------------------------------------------------------
%DISPLAY PREPARATION AND ORGANIZATION OF FIXATION
%------------------------------------------------------------------------------------------

                %------------------------------------------------------------
                %Fixation-Cue SOA
                %------------------------------------------------------------                     
                    
                FixOffSOA = round((154 - 77)*rand(1,1) + 77); %random between 1000ms and 2000ms   
                OffStartSOA = 54;  % period between the offset of the task and the start of the trial
                
                colour_stims= maze_array(1,this_practicetrial);
                colour_stims= reshape(colour_stims{1}, [1, 11*11]);
                colour_stims= vertcat(colour_stims{:})';
                
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
                    subjreported=0;
                    Subjective_key_pressed=0;
                    
                    % Screen priority
                    Priority(MaxPriority(mainWin));
                    Priority(2);
                     
                    %show grey Screen, 
                    Screen('DrawTexture',mainWin,GreyScreen);
                    GreyWinTime=Screen('flip',mainWin);

                    %show Fixation
                    Screen('FillRect',mainWin,color_fixation ,stim_loc');
                    Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                    FixationWinTime=Screen('flip',mainWin,GreyWinTime + (FixOffSOA*IFI) - slack,0); 
                    
                    %show Stimuluas
                    Screen('FillRect',mainWin, colour_stims ,stim_loc');
                    Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                    StimulusWinTime= Screen('flip',mainWin,FixationWinTime + (177*IFI) - slack,0);

                    %show Delay period
                    Screen('FillRect',mainWin,color_fixation ,stim_loc');
                    Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                    StimulusOffsetWinTime= Screen('flip',mainWin,StimulusWinTime + (177*IFI) - slack,0);
              
                    %show Start of response 
                    Screen('FillRect',mainWin, colour_stims ,stim_loc');
                    Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                    ResponseWinTime= Screen('flip',mainWin,StimulusOffsetWinTime + (177*IFI) - slack,0);


                    % get starting position of icon
                    position_self= maze_array(1,this_practicetrial);
                    [irow ,icol]=find(cellfun(@sum, (cellfun(@(x) x==[0 1 1], position_self{1,1}, 'UniformOutput', false))) ==3);

                    % get position of goal
                    [grow ,gcol]=find(cellfun(@sum, (cellfun(@(x) x==[0 1 0], position_self{1,1}, 'UniformOutput', false))) ==3);

                    while 1

                        % update position of icon if participant moved
                             [keyIsDown,secs,keyCode]=KbCheck;

                             if keyIsDown==1
                                 keyCode= find(keyCode==1)(1);

                                 if keyCode == 37 &&  irow-1 > 0  &&  irow-1 < 12 &&  sum(position_self{1}{ irow-1, icol} == [0 0 1]) ~=3 &&  sum(position_self{1}{ irow-1, icol} == [0 0 0]) ~=3
                                     irow= irow-1;

                                 elseif keyCode == 40 &&  icol+1 > 0 &&  icol+1 < 12 &&  sum(position_self{1}{ irow, icol+1} == [0 0 1]) ~=3 &&  sum(position_self{1}{ irow, icol+1} == [0 0 0]) ~=3
                                     icol= icol+1;

                                 elseif keyCode == 39 &&  irow+1 > 0 &&  irow+1 < 12 &&  sum(position_self{1}{ irow+1, icol} == [0 0 1]) ~=3 &&  sum(position_self{1}{ irow+1, icol} == [0 0 0]) ~=3
                                      irow= irow+1;

                                 elseif keyCode == 38 &&  icol-1 > 0 &&  icol-1 < 12 &&  sum(position_self{1}{ irow, icol-1} == [0 0 1]) ~=3 &&  sum(position_self{1}{ irow, icol-1} == [0 0 0]) ~=3
                                      icol= icol-1;
                                 end
                                 KbReleaseWait;
                             end

                             self_pos=  stim_loc(11*(icol-1) + irow, :);


                        %show Start of response 
                        Screen('FillRect',mainWin, colour_stims ,stim_loc');
                        Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                        % add circle 
                        Screen('DrawDots', mainWin, [self_pos(1) + 20, self_pos(2) + 20], 20, [1 0 0 ], [], 2)
                        Screen('flip',mainWin,ResponseWinTime + (1*IFI) - slack,0);

                        % break loop if solved
                        if irow == grow && icol == gcol
                            % add code here to get RT
                            mazeRT= GetSecs - ResponseWinTime;
                            break;
                        end

                    end

                    % ask about subjective report now

                    for numobstacles =0:5 % index off bc of python
                    subjpos=randi([1 8], 1); % start at random position

                     % draw scale 
                     Screen(mainWin, 'TextSize' , 22)
                    Width=Screen(mainWin,'TextBounds','How aware of  the highlighted obstacle were you at any point?');
                    Screen('DrawText',mainWin,'How aware of  the highlighted obstacle were you at any point?',centerX-(round(Width(3)/2)), centerY-300, white);
                    
                    colour_stims= maze_array(1,this_practicetrial);
                    obstacles=maze_obstacles{1, this_practicetrial};
                    index_obstacle=  obstacles == num2str(numobstacles);
                    colour_stims{1}(index_obstacle) = {[1,0 0]};

                    colour_stims= reshape(colour_stims{1}, [1, 11*11]);
                    colour_stims= vertcat(colour_stims{:})';

                    %show Start of response 
                    Screen('FillRect',mainWin, colour_stims ,stim_loc');
                    Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );
                    
                   scale_pos= [centerX-350, centerY+270; centerX+350, centerY+270; 
                            centerX-350, centerY+270-30; centerX-350, centerY+270+30;
                            centerX-250, centerY+270-30; centerX-250, centerY+270+30;
                            centerX-150, centerY+270-30; centerX-150, centerY+270+30;
                           centerX-50, centerY+270-30; centerX-50, centerY+270+30;
                           centerX+50, centerY+270-30; centerX+50, centerY+270+30;
                           centerX+150, centerY+270-30; centerX+150, centerY+270+30;
                           centerX+250, centerY+270-30; centerX+250, centerY+270+30;
                           centerX+350, centerY+270-30; centerX+350, centerY+270+30]';
                        
                        Screen('DrawLines',mainWin,scale_pos, 10, black);
                        head   = [ (centerX+ ((800/8) * (subjpos- 4.5))), centerY+270-40 ]; % coordinates of head
                        width  = 20;           % width of arrow head
                        points = [ head-[width,0]         % left corner
                                       head+[width,0]         % right corner
                                       head+[0,width] ];      % vertex
                        Screen('FillPoly', mainWin, white, points);
                        
                        Width=Screen(mainWin,'TextBounds','unaware');
                        Screen('DrawText',mainWin,'unaware',centerX-450-(round(Width(3)/2)), centerY+340, white);
                        Width=Screen(mainWin,'TextBounds','aware');
                        Screen('DrawText',mainWin,'aware',centerX+450-(round(Width(3)/2)), centerY+340, white);
                        Width=Screen(mainWin,'TextBounds','Press the spacebar to submit');
                        Screen('DrawText',mainWin,'Press the spacebar to submit',centerX-(round(Width(3)/2)), centerY+380, white);
                        SubjWinTime= Screen('flip',mainWin,mazeRT + (1*IFI) - slack,0);

                        subjreported=1;
                        KbReleaseWait;

                    while subjreported
                           [keyIsDown,secs,keyCode]=KbCheck;
                             if keyIsDown==1
                                 keyCode= find(keyCode==1)(1);
                                 if keyCode == 37 &&  subjpos-1 > 0 &&  subjpos-1 < 9
                                     subjpos= subjpos-1;
                                 elseif keyCode == 39 &&  subjpos+1 > 0 && subjpos+1 < 9
                                      subjpos= subjpos+1;
                                 elseif  keyCode == 32 
                                     subjreported=0;
                                 end
                             end

                    % draw scale 
                        Width=Screen(mainWin,'TextBounds','How aware of  the highlighted obstacle were you at any point?');
                        Screen('DrawText',mainWin,'How aware of  the highlighted obstacle were you at any point?',centerX-(round(Width(3)/2)), centerY-300, white);
                        
                         %show Start of response 
                        Screen('FillRect',mainWin, colour_stims ,stim_loc');
                        Screen('FrameRect',mainWin,black ,stim_loc', 0.5  );

                        Screen('DrawLines',mainWin,scale_pos, 10, black);
                        head   = [ (centerX+ ((800/8) * (subjpos-4.5))), centerY+270-40 ]; % coordinates of head
                        width  = 20;           % width of arrow head
                        points = [ head-[width,0]         % left corner
                                       head+[width,0]         % right corner
                                       head+[0,width] ];      % vertex
                        Screen('FillPoly', mainWin, white, points);
                        
                        Width=Screen(mainWin,'TextBounds','unaware');
                        Screen('DrawText',mainWin,'unaware',centerX-450-(round(Width(3)/2)), centerY +340, white);
                        Width=Screen(mainWin,'TextBounds','aware');
                        Screen('DrawText',mainWin,'aware',centerX+450-(round(Width(3)/2)), centerY+340, white);
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
Screen('DrawText',messageWindow,'Press the Spacebar to Continue',centerX-(round(Width(3)/2)), CenterY+350, white);
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
FixationWin=Screen('openoffScreenwindow',mainWin,grey); 
PostFixationWin=Screen('openoffScreenwindow',mainWin,grey); 
CueWin=Screen('openoffScreenwindow',mainWin,grey); 
PostCueWin=Screen('openoffScreenwindow',mainWin,grey);
TgtWin=Screen('openoffScreenwindow',mainWin,grey);
PostTgtWin=Screen('openoffScreenwindow',mainWin,grey);
MaskWin=Screen('openoffScreenwindow',mainWin,grey);
Postmaskwin=Screen('openoffScreenwindow',mainWin,grey);
SubjectiveWin=Screen('OpenOffscreenWindow',mainWin,grey); 

%------------------------------------------------------------
%VARIABLES RESETTING
%------------------------------------------------------------

Detec_RT=0;
Detec_key_expected=0;
Detec_key_pressed=0;
Detec_Accuracy=0;


%-------------------------------------------------------------------------------------------
%DISPLAY PREPARATION AND ORGANIZATION OF FIXATION
%------------------------------------------------------------------------------------------
                 
                    % Load cue
               if (AllTrialSequence(this_trial,1)==0)             

                    CuePresent = 0;
                    CueCode = 002;
                                        
           elseif (AllTrialSequence(this_trial,1)==1)             
                    
                    CuePresent = 1;
                    CueCode = 003; 

               end     
                                        
                    
                if (AllTrialSequence(this_trial,2)==0)
                    
                    TargetCode = 004;


            elseif (AllTrialSequence(this_trial,2)==1)

                    TargetCode = 005;


            elseif (AllTrialSequence(this_trial,2)==2)

                    TargetCode = 006;

               end

                    % Mask
                    Mask_img = imread('mask','jpg');
                    MaskWin=Screen('MakeTexture',mainWin,Mask_img);  
                    MaskCode=15;
                    
                %------------------------------------------------------------
                %Fixation-Cue SOA
                %------------------------------------------------------------                     
                    
                FixTargetSOA = round((154 - 77)*rand(1,1) + 77); %random between 1000ms and 2000ms   
                FixCueSOA = FixTargetSOA - 54;   
                
                %------------------------------------------------------------
                %Mask Latencies 
                %------------------------------------------------------------                     
                        
                MaskLantecy = 6;

                
                %------------------------------------------------------------
                %Contrast
                %------------------------------------------------------------    
                
                contrast= QuestQuantile(Q_block);
                
                if contrast <0.02
                    contrast = 0.02;
                elseif contrast > 0.9
                    contrast = 0.9;
                end
                
                %------------------------------------------------------------
                %Target & Key Info Info
                %------------------------------------------------------------                 
                
                TargetType = (AllTrialSequence(this_trial,2));
                
                    if Counterbalancing == 1 && TargetType ==1
                        Detec_key_expected = 70;
                elseif Counterbalancing == 1 && TargetType ==0
                        Detec_key_expected = 74;
                elseif Counterbalancing == 2 && TargetType ==1
                        Detec_key_expected = 74;
                elseif Counterbalancing == 2 && TargetType ==0
                        Detec_key_expected = 70;
                   end

                %--------------------------------------------------------------------
                %STREAM LOOP AND COLLECT RESPONSE
                %--------------------------------------------------------------------                        
                    
                    %Reset Variables
                    greyWinTime=0;
                    FixationWinTime=0;
                    CueWinTime=0;
                    TgtWinTime=0;
                    MaskWinTime=0;
                    PostmaskWinTime=0;
                    SubjectiveWinTime=0;
                    keyIsDown=0;
                    secs=0;
                    keyCode=[];
                    Detec_key_pressed=0;
                    KeyDown = 0;
                    Subjective_key_pressed=0;
                    
                     % Screen priority
                     Priority(MaxPriority(mainWin));
                     Priority(2);

                     %show grey Screen,
                     Screen('DrawTexture',mainWin,GreyScreen);
                     GreyWinTime=Screen('flip',mainWin);
                     
                    %show Fixation
                    Screen('DrawDots', mainWin, [xCenter yCenter], 15, [0 0 0], [], 2);
                    Screen('FrameOval', mainWin, black, [xCenter-53 yCenter-53 xCenter+53 yCenter+53], 5, [], []);
                    Screen('FillRect',mainWin,black,[45 743 55 753]);
                    FixationWinTime=Screen('flip',mainWin,GreyWinTime + (77*IFI) - slack,0); 
                     outp(address, 001)
                     WaitSecs(0.004)
                     outp(address, 0)
                     
                    %show PostFixation
                    Screen('DrawDots', mainWin, [xCenter yCenter], 15, [0 0 0], [], 2);
                    Screen('FrameOval', mainWin, black, [xCenter-53 yCenter-53 xCenter+53 yCenter+53], 5, [], []);
                    Screen('flip',mainWin,FixationWinTime + (1*IFI) - slack,0);

                    %show Cue (Flash Fixation)
                    if ((AllTrialSequence(this_trial,1)==0))
                        
                        Screen('DrawDots', mainWin, [xCenter yCenter], 15, [0 0 0], [], 2);
                        Screen('FrameOval', mainWin, black, [xCenter-53 yCenter-53 xCenter+53 yCenter+53], 5, [], []);
                    elseif ((AllTrialSequence(this_trial,1)==1))
                        Screen('DrawDots', mainWin, [xCenter yCenter], 15, [0 0 0], [], 2);
                        Screen('FrameOval', mainWin, black, [xCenter-63 yCenter-63 xCenter+63 yCenter+63], 20, [], []);
                    end
                    Screen('FillRect',mainWin,black,[45 743 55 753]);
                    CueWinTime=Screen('flip',mainWin,FixationWinTime + (FixCueSOA*IFI) - slack,0);
                    outp(address, CueCode)
                    WaitSecs(0.004)
                    outp(address, 0) 

                    %show Post Cue
                    Screen('DrawDots', mainWin, [xCenter yCenter], 15, [0 0 0], [], 2);
                    Screen('FrameOval', mainWin, black, [xCenter-53 yCenter-53 xCenter+53 yCenter+53], 5, [], []);
                    PostCueWinTime=Screen('flip',mainWin,CueWinTime + (12*IFI) - slack,0); 
                    
                    % Show mask
                    Screen('Drawtexture',mainWin,MaskWin); 
                    Screen('DrawDots', mainWin, [xCenter yCenter], 15, [0 0 0], [], 2);
                    Screen('FrameOval', mainWin, black, [xCenter-53 yCenter-53 xCenter+53 yCenter+53], 5, [], []);
                    Screen('FillRect',mainWin,black,[45 743 55 753]);
                    MaskOneWinTime=Screen('Flip',mainWin, PostCueWinTime + (54*IFI) - slack,0);
                    outp(address, 14)
                    WaitSecs(0.004)
                    outp(address, 0)
                    
                    %Show Post mask
                    Screen('Drawtexture',mainWin,MaskWin); 
                    Screen('DrawDots', mainWin, [xCenter yCenter], 15, [0 0 0], [], 2);
                    Screen('FrameOval', mainWin, black, [xCenter-53 yCenter-53 xCenter+53 yCenter+53], 5, [], []);
                    PostMaskOneWinTime=Screen('Flip',mainWin, MaskOneWinTime + (1*IFI) - slack,0);   

                    %Pretarget
                    Screen('DrawDots', mainWin, [xCenter yCenter], 15, [0 0 0], [], 2);
                    Screen('FrameOval', mainWin, black, [xCenter-53 yCenter-53 xCenter+53 yCenter+53], 5, [], []);
                    PreTargetWinTime=Screen('flip',mainWin,MaskOneWinTime + (MaskLantecy*IFI) - slack,0); 
                
                    
                    %show Target                
                   if ((AllTrialSequence(this_trial,3)==1))
                            orientation = 15;
                   elseif ((AllTrialSequence(this_trial,3)==2))
                            orientation = -15;
                    end
                    gaborDimPix = 72 ;
                    sigma = gaborDimPix / 6 ;
                    aspectRatio = 1.0;
                    phase = .1;
                    numCycles = 3;
                    freq = numCycles / gaborDimPix;
                    backgroundOffset = [0.5 0.5 0.5 0];
                    disableNorm = 1;
                    preContrastMultiplier = 0.5;
                    gabortex = CreateProceduralGabor(mainWin, gaborDimPix, gaborDimPix, [],backgroundOffset, disableNorm, preContrastMultiplier);
                    propertiesMat = [phase, freq, sigma, contrast, aspectRatio, 0, 0, 0];
                    if ((AllTrialSequence(this_trial,2)==0))
                        Screen('DrawTexture',mainWin,GreyScreen);
                elseif ((AllTrialSequence(this_trial,2)==1))
                    Screen('DrawTextures', mainWin, [gabortex],[],[xCenter-50 yCenter-50 xCenter+50 yCenter+50],[orientation ] , [], [], [], [],kPsychDontDoRotation, propertiesMat');
                    end
                    Screen('DrawDots', mainWin, [xCenter yCenter], 15, [0 0 0], [], 2);
                    Screen('FrameOval', mainWin, black, [xCenter-53 yCenter-53 xCenter+53 yCenter+53], 5, [], []);
                    Screen('FillRect',mainWin,black,[45 743 55 753]);
                    %Screen('Drawtexture',mainWin,TgtWin);
                    TgtWinTime=Screen('flip',mainWin,PreTargetWinTime + (MaskLantecy*IFI) - slack,0);
                    outp(address, TargetCode)
                    WaitSecs(0.004)
                    outp(address, 0)                  

                            %COLLECT RESPONSE FOR DetecRIMINATION REPORT
                            %-------------------------------------------------                               
                                while GetSecs - TgtWinTime < (1*IFI) - slack 
                                   [keyIsDown,secs,keyCode]=KbCheck;
                                   if keyIsDown==1
                                   Detec_RT=GetSecs-TgtWinTime;
                                   Detec_key_pressed=find(keyCode==1);
                                   KeyDown=GetSecs;
                                            if  Detec_key_expected == Detec_key_pressed
                                                        Detec_Accuracy=1;
                                                        outp(address, 032)
                                                        WaitSecs(0.004)
                                                        outp(address, 0)
                                            else   
                                                        Detec_Accuracy=0;
                                                        outp(address, 064)
                                                        WaitSecs(0.004)
                                                        outp(address, 0)                                                
                                            end
                                   break
                                   end
                                end                      
  
                    if Detec_key_pressed == 0                                                  
                    %show PostTarget
                    Screen('DrawDots', mainWin, [xCenter yCenter], 15, [0 0 0], [], 2);
                    Screen('FrameOval', mainWin, black, [xCenter-53 yCenter-53 xCenter+53 yCenter+53], 5, [], []);
                    PostTgtWinTime=Screen('flip',mainWin,TgtWinTime + (1*IFI) - slack,0); 
                   
                            %COLLECT RESPONSE FOR DetecRIMINATION REPORT
                            %-------------------------------------------------                               
                                while GetSecs - PostTgtWinTime < (1*IFI) - slack 
                                   [keyIsDown,secs,keyCode]=KbCheck;
                                   if keyIsDown==1
                                   Detec_RT=GetSecs-TgtWinTime;
                                   Detec_key_pressed=find(keyCode==1);
                                   KeyDown=GetSecs;
                                            if  Detec_key_expected == Detec_key_pressed
                                                        Detec_Accuracy=1;
                                                        outp(address, 032)
                                                        WaitSecs(0.004)
                                                        outp(address, 0)
                                            else   
                                                        Detec_Accuracy=0;
                                                        outp(address, 064)
                                                        WaitSecs(0.004)
                                                        outp(address, 0)                                                
                                            end
                                   break
                                   end
                                end      
                    end
                    
                    if Detec_key_pressed == 0              
                    %show Mask
                    Screen('Drawtexture',mainWin,MaskWin);
                    Screen('DrawDots', mainWin, [xCenter yCenter], 15, [0 0 0], [], 2);
                    Screen('FrameOval', mainWin, black, [xCenter-53 yCenter-53 xCenter+53 yCenter+53], 5, [], []);
                    Screen('FillRect',mainWin,black,[45 743 55 753]);
                    MaskTwoWinTime=Screen('Flip',mainWin, PostTgtWinTime + (MaskLantecy*IFI) - slack,0); 
                    outp(address, 15)
                    WaitSecs(0.004)
                    outp(address, 0)
                            %COLLECT RESPONSE FOR Detec REPORT
                            %-------------------------------------------------                               
                                while 1
                                   [keyIsDown,secs,keyCode]=KbCheck;
                                   if keyIsDown==1
                                   Detec_RT=GetSecs-TgtWinTime;
                                   Detec_key_pressed=find(keyCode==1);
                                   KeyDown=GetSecs;
                                            if  Detec_key_expected == Detec_key_pressed
                                                        Detec_Accuracy=1;
                                                        outp(address, 032)
                                                        WaitSecs(0.004)
                                                        outp(address, 0)
                                            else   
                                                        Detec_Accuracy=0;
                                                        outp(address, 064)
                                                        WaitSecs(0.004)
                                                        outp(address, 0)                                                
                                            end
                                   break
                                   end
                                end 
                    end
                    if Detec_key_pressed == 0  
                    %Show Post mask
                    Screen('Drawtexture',mainWin,MaskWin); 
                    Screen('DrawDots', mainWin, [xCenter yCenter], 15, [0 0 0], [], 2);
                    Screen('FrameOval', mainWin, black, [xCenter-53 yCenter-53 xCenter+53 yCenter+53], 5, [], []);
                    PostMaskOneWinTime=Screen('Flip',mainWin, MaskTwoWinTime + (1*IFI) - slack,0);   

                    
                            %COLLECT RESPONSE FOR Detec REPORT
                            %-------------------------------------------------                               
                                while 1
                                   [keyIsDown,secs,keyCode]=KbCheck;
                                   if keyIsDown==1
                                   Detec_RT=GetSecs-TgtWinTime;
                                   Detec_key_pressed=find(keyCode==1);
                                   KeyDown=GetSecs;
                                            if  Detec_key_expected == Detec_key_pressed
                                                        Detec_Accuracy=1;
                                                        outp(address, 032)
                                                        WaitSecs(0.004)
                                                        outp(address, 0)
                                            else   
                                                        Detec_Accuracy=0;
                                                        outp(address, 064)
                                                        WaitSecs(0.004)
                                                        outp(address, 0)                                                
                                            end
                                   break
                                   end
                                end  
                    
                    end
                    KbReleaseWait   
                    Screen('DrawTexture',mainWin,GreyScreen);
                    greyWinTime=Screen('flip',mainWin,0);
                    
                    %COLLECT RESPONSE FOR SUBJECTIVE REPORT
                    %-------------------------------------------------                    
                    %show Subjective                
                    Screen('DrawTexture',mainWin,SubjectiveWin);
                    Screen('flip',mainWin,greyWinTime + (1*IFI),0); 
                         
                 
                    %END STREAM LOOP
                    %---------------
                    % AlLow other processes to run optimally
                    Priority(0); 
                 
                    %--------------------------------------------------------
                    %DEFINE FORMAT AND PRINT OUTPUT
                    %--------------------------------------------------------
    
                    format = '%s\t %s\t %f\t %s\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\t %f\n'; %19

                    fprintf(fid,format,subjectID,Gender,Age,experiment,Counterbalancing,handiness,itrial,CuePresent,FixTargetSOA,54,MaskLantecy,contrast,TargetType,orientation,Detec_RT,Detec_key_expected,Detec_key_pressed,Detec_Accuracy); 
             
                    
                    %--------------------------------------------------------
                    %Update Quest Structure
                    %--------------------------------------------------------                   
                    
                    if block == 1 && TargetType ==1 && CuePresent ==0
                            Q_block=QuestUpdate(Q_block,contrast,Detec_Accuracy); 
                    end
                    
                    %------------------------------------------------------------
                    % BLOCK CHECK
                    %------------------------------------------------------------
    
                    if (itrial < nTrials) && (mod(itrial,120)==0)
    
                                            WaitSecs(1);
                                            messageWindow = Screen(mainWin,'OpenOffscreenWindow',grey);
                                            Screen(messageWindow,'TextSize',11)
                                            blockMessage = sprintf('End of Block %d of 10 blocks.',block);
                                            Width1=Screen(messageWindow,'TextBounds',blockMessage);
                                            Screen('DrawText', messageWindow,blockMessage,centerX-(round(Width1(3)/2)),centerY-100, black);
                                            Width=Screen(messageWindow,'TextBounds','Press Space Bar to Continue');
                                            Screen('DrawText',messageWindow,'Press Space Bar to Continue',centerX-(round(Width(3)/2)),centerY+50, white);
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
                                            Screen(messageWindow,'TextSize',11)
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
                    % EXIT EXPERIMENT (PRESS Q KEY DURING TRIAL)
                    %------------------------------------------------------------
                    
                    if Detec_key_pressed ==20
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
