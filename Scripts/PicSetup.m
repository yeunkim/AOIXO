%% 'Final 2.0' Show Pics
runtype = 'pseudorandom'; % 'pseudorandom', 'fixed'

%% initialize loop variables
iteration = 0;
abort = 0;
count = 1;
info = [];

%Grasp Pictures
cd('~/Documents/MATLAB/AOIXI/grasppics/'); %Change the directory if necessary
file_ext = '*.png';
grasp_pics=dir(file_ext); %loads stuff 
for i=1:size(grasp_pics,1) % dir cmd cl 1 = file name 
    grasp_pics(i).name = [pwd filesep grasp_pics(i).name];
end

%Point Pictures
cd('~/Documents/MATLAB/AOIXI/pointpics/'); %Change the directory if necessary
point_pics=dir(file_ext);
for i=1:size(point_pics,1)
    point_pics(i).name = [pwd filesep point_pics(i).name];
end

%% Counterbalancing

%Grasp
grasp_pics = {grasp_pics.name}; %Convert to cell array each gpic name can be diff length
switch runtype
    case 'random',
        % randomize
        grasp_pics = grasp_pics(randperm(12)); %Shuffle 4 cells
    case 'fixed',
        % repeat same for testing script
        grasp_pics = grasp_pics(ones(1,12)); %Shuffle 4 cells
    case 'pseudorandom'
        tmp = [10,4,5,2,9,7,3,11,5,12,1,8];
        grasp_pics = grasp_pics(tmp); %Shuffle 4 cells
    otherwise
        disp('I don''t know what runtype this is');
        sca
end
grasp_pics = grasp_pics(tmp);
grasp_pic_blocks = {grasp_pics{1:4}; grasp_pics{5:8}; grasp_pics{9:12}};

grasp_pics = grasp_pics(tmp);
grasp_pic_blocks2 = {grasp_pics{1:4}; grasp_pics{5:8}; grasp_pics{9:12}};

grasp_pics = grasp_pics(randperm(12));
grasp_pic_blocks3 = {grasp_pics{1:4}; grasp_pics{5:8}; grasp_pics{9:12}};

grasp_pics = grasp_pics(randperm(12));
grasp_pic_blocks4 = {grasp_pics{1:4}; grasp_pics{5:8}; grasp_pics{9:12}};

grasp_pic_blocks = [grasp_pic_blocks; grasp_pic_blocks2; grasp_pic_blocks3; grasp_pic_blocks4];

for i=1:12
    grasp_pic_blocks{i,5} = 'grasp';
    
    if i < 7
        grasp_pic_blocks{i,6} = 'green';
    else
        grasp_pic_blocks{i,6} = 'violet';
    end
end

%Point
point_pics = {point_pics.name}; %Convert to cell array
point_pics = point_pics(randperm(12)); %Shuffle 4 cells
point_pic_blocks = {point_pics{1:4}; point_pics{5:8}; point_pics{9:12}};

point_pics = point_pics(randperm(12));
point_pic_blocks2 = {point_pics{1:4}; point_pics{5:8}; point_pics{9:12}};

point_pics = point_pics(randperm(12));
point_pic_blocks3 = {point_pics{1:4}; point_pics{5:8}; point_pics{9:12}};

point_pics = point_pics(randperm(12));
point_pic_blocks4 = {point_pics{1:4}; point_pics{5:8}; point_pics{9:12}};

point_pic_blocks = [point_pic_blocks; point_pic_blocks2; point_pic_blocks3; point_pic_blocks4];

for i=1:12
    point_pic_blocks{i,5} = 'point';
    
    if i < 7
        point_pic_blocks{i,6} = 'green';
    else
        point_pic_blocks{i,6} = 'violet';
    end  
end


blocks = [grasp_pic_blocks; point_pic_blocks];
%blocks = blocks(randperm(24),:);
%blocks = blocks(randperm(24),:);


%% Display Pics
for blockno = 1:24

    %Frame color
    col = eval(blocks{blockno,6});
    
    %Picture File Names
    picfiles = blocks(blockno,1:4);
    
    %display a block of 3 pictures
    ShowPics;
    
    %Wait 10 seconds
    then = GetSecs;
    wait = 0;
    while wait < 10
        [HitKey secs KeyCode] = KbCheck;
        if KeyCode(esc)
            ListenChar(0);
            sca;
        end
        wait = GetSecs-then;
    end  
end

ListenChar(0);


