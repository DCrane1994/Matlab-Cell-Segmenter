%Prompt user to select input file(s)
[FileNames,PathName] = uigetfile('*.jpg', 'Select all the images you wish to process:','MultiSelect','on');
nfiles = length(FileNames); 
image_array = {nfiles};

% Loop through files
for i = 1:nfiles
  % This code fixes a problem caused with the
  % the user only selecting a single file
  % and Matlab reading it as char rather than cell
  if isa(FileNames, 'char')
  % There's only one file
    for i = 1:1
  file=fullfile(PathName,FileNames);
  image = imread(file);
  % Insert images into array
  image_array{i} = image;
    end
  end
  % Normal program execution with multiple images
  if isa(FileNames, 'cell')
  file=fullfile(PathName,FileNames{i});
  image = imread(file);
  % Insert images into array
  image_array{i} = image;
  end
end

% Loop through the images in image array, open GUI for each of them
for j = 1:length(image_array)
  % Fix for single file input
  if isa(FileNames, 'char')
  GUI(image_array{j}, FileNames, 0 , 0);
  end
  if isa(FileNames, 'cell')
  GUI(image_array{j}, FileNames{j}, 0 , 0);
  end
end
