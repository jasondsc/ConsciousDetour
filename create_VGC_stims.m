

function create_VGC_stims

    %% read in mazes from json file and seperate them into workable cell arrays
    % this snippet of code reads in the mazes
    fileName = './mazes/mazes_Lateralized.json'; % filename in JSON extension
    str = fileread(fileName); % dedicated for reading files as text
    data = jsondecode(str); % Using the jsondecode function to parse JSON from string
    data=struct2cell(data);
    mazes_lateralized= cellfun(@cell2mat, data, 'UniformOutput', false);

    % which ones are left  3, 4, 5, 6, 9, 12, 13, 14, 16, 17, 18, 23

    % seperate out left right lateralized
    left_mazes= mazes_lateralized;
    right_mazes= mazes_lateralized;

    right_mazes([3, 4, 5, 6, 9, 12, 13, 14, 16, 17, 18, 23])= cellfun(@fliplr, mazes_lateralized([3, 4, 5, 6, 9, 12, 13, 14, 16, 17, 18, 23]), 'UniformOutput', false);
    left_mazes([3, 4, 5, 6, 9, 12, 13, 14, 16, 17, 18, 23])= cellfun(@fliplr, mazes_lateralized([3, 4, 5, 6, 9, 12, 13, 14, 16, 17, 18, 23]), 'UniformOutput', false);
    left_mazes= cellfun(@fliplr, left_mazes, 'UniformOutput', false);

    right_mazes_ud= cellfun(@flipud, right_mazes, 'UniformOutput', false);
    left_mazes_ud= cellfun(@flipud, left_mazes, 'UniformOutput', false);

    right_mazes_lat= [right_mazes;right_mazes_ud];

    left_mazes_lat =[left_mazes_ud; left_mazes];


    % repreat for non-lateralized maze
    fileName = './mazes/mazes_Nonlateralized.json'; % filename in JSON extension
    str = fileread(fileName); % dedicated for reading files as text
    data = jsondecode(str); % Using the jsondecode function to parse JSON from string
    data=struct2cell(data);
    mazes_nonlateralized= cellfun(@cell2mat, data, 'UniformOutput', false);


    flipped= cellfun(@flipud, mazes_nonlateralized, 'UniformOutput', false);
    mazes_ud= cellfun(@flipud, mazes_nonlateralized, 'UniformOutput', false);
    flipped_mazes_ud= cellfun(@flipud, flipped, 'UniformOutput', false);

    orig_mazes_nonlat= [mazes_nonlateralized;mazes_ud];
    flipped_mazes_nonlat= [flipped; flipped_mazes_ud];


    %% convert mazes to RGB

    for i=1:48

        temp=right_mazes_lat{i};
        tempint= cell(11,11);
        tempint(temp == '.') = {[1,1,1]};
        tempint(temp == '#') = {[0,0,0]};
        tempint(temp == 'G') = {[0,1,0]};
        tempint(temp == 'S') = {[0,1,1]};
        tempint(cellfun(@isempty, tempint)) = {[0,0,1]};

        stim_right_mazes_lat{i,1} = tempint;


        temp=left_mazes_lat{i};
        tempint= cell(11,11);
        tempint(temp == '.') = {[1,1,1]};
        tempint(temp == '#') = {[0,0,0]};
        tempint(temp == 'G') = {[0,1,0]};
        tempint(temp == 'S') = {[0,1,1]};
        tempint(cellfun(@isempty, tempint)) = {[0,0,1]};

        stim_left_mazes_lat{i,1} = tempint;

        temp=orig_mazes_nonlat{i};
        tempint= cell(11,11);
        tempint(temp == '.') = {[1,1,1]};
        tempint(temp == '#') = {[0,0,0]};
        tempint(temp == 'G') = {[0,1,0]};
        tempint(temp == 'S') = {[0,1,1]};
        tempint(cellfun(@isempty, tempint)) = {[0,0,1]};

        stim_orig_mazes_nonlat{i,1} = tempint;

        temp=flipped_mazes_nonlat{i};
        tempint= cell(11,11);
        tempint(temp == '.') = {[1,1,1]};
        tempint(temp == '#') = {[0,0,0]};
        tempint(temp == 'G') = {[0,1,0]};
        tempint(temp == 'S') = {[0,1,1]};
        tempint(cellfun(@isempty, tempint)) = {[0,0,1]};

        stim_flipped_mazes_nonlat{i,1} = tempint;

    end
    
    save('./StimMazes_RGB_4_Matlab.mat', ...
        'stim_flipped_mazes_nonlat',  'stim_left_mazes_lat', 'stim_orig_mazes_nonlat', 'stim_right_mazes_lat',...
        'flipped_mazes_nonlat',  'left_mazes_lat', 'orig_mazes_nonlat', 'right_mazes_lat' )

end