function varargout = GUI(varargin)
% Begin initialization code - DO NOT EDIT

% Set this to 0, otherwise can only have one instance of GUI
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% varargin contains the input arguments
% Choose default command line output for GUI
handles.output = hObject;

% set image to axes
handles.input1 = varargin{1};

handles.purpleCell = varargin{3};
handles.brownCell = varargin{4};
% set file name in textbox
set(handles.text4,'String', varargin{2});
% Update handles structure
guidata(hObject, handles);

imshow(varargin{1}, 'Parent', handles.axes1);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% This function will display the original input image
set(handles.text17,'String','');
imshow(handles.input1, 'Parent', handles.axes1);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% This function displays dark brown cells
% If the option is checked, program will return all brown cells
value = get(handles.checkbox1, 'Value');

if value == 1
    countAllBrownCells(hObject, handles);
else
countDarkBrownCells(hObject, handles);
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% This function displays purple cells
countPurpleCell(hObject, handles);

function [fig] = countDarkBrownCells(hObject, handles)
% This function will return a count of all (approx) dark brown cells in an
% image
im = handles.input1;
% run pre-processing on the image
%imAdjusted = imsharpen(imAdjusted);

% create a mask using colour thresholding
mask = darkBrownMask(im);

mask = bwareaopen(mask, 10);
se = strel('disk',7);
se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);
% apply morphological processing 
mask = imerode(mask, [se90 se0]);
mask = imopen(mask, se);
cc = bwconncomp(mask);
% get the regions
stats = regionprops(cc, 'Centroid', 'Area', 'Perimeter');

% make note of the centroid locations
centroids = cat(1, stats.Centroid);

% number of objects is the number of "brown cells"
number = cc.NumObjects;

% plot the coordinates of the centroids over the original image
darkBrownCells = [int2str(number), "dark brown cells identified."];
darkBrownCells = join(darkBrownCells);
% plot the coordinates of the centroids over the original image
figure('visible', 'off');
imshow(im);
hold(imgca,'on')
plot(imgca,centroids(:,1), centroids(:,2), 'r*')
hold(imgca,'off')
set(gca,'position',[0 0 1 1],'units','normalized')
F = getframe(gcf);
[X, Map] = frame2im(F);
imshow([X, Map], 'Parent', handles.axes1);
set(handles.text17,'String', darkBrownCells);
guidata(hObject, handles);

function [fig] = countPurpleCell(hObject, handles)
% This function will return a count of all (approx) purple cells in an
% image

im = handles.input1;
% run pre-processing on the image
imAdjusted = processPurpleImage(im);

% remove noise from each layer w/ median filter
for layer = 1:3
    imAdjusted(:,:,layer) = wiener2(imAdjusted(:,:,layer), [5 5]);
end

% create a mask using colour thresholding
mask = purpleCellMaskHSV(imAdjusted);
mask = bwareaopen(mask, 10);
se = strel('disk',8);
mask = imopen(mask, se);
mask = imfill(mask, 'holes');
cc = bwconncomp(mask);

% get the regions
stats = regionprops(cc, 'Area');

L = labelmatrix(cc);
maskArea = ismember(L, find([stats.Area] >= 100));
maskArea = imfill(maskArea, 'holes');
D = -bwdist(~maskArea);
maskmask = imextendedmin(D,2);
D2 = imimposemin(D,maskmask);
Ld2 = watershed(D2);
bw3 = maskArea;
bw3(Ld2 == 0) = 0;
bw3 = bwareaopen(bw3, 40);
cc2 = bwconncomp(bw3);

stats2 = regionprops(cc2, 'Centroid');
% make note of the centroid locations
centroids = cat(1, stats2.Centroid);

% number of objects is the number of "purple cells"
number2 = cc2.NumObjects;

purpleCells = [int2str(number2), "purple cells identified."];
purpleCells = join(purpleCells);
% plot the coordinates of the centroids over the original image
figure('visible', 'off');
imshow(im);
hold(imgca,'on')
plot(imgca,centroids(:,1), centroids(:,2), 'r*')
hold(imgca,'off')
set(gca,'position',[0 0 1 1],'units','normalized')
F = getframe(gcf);
[X, Map] = frame2im(F);
imshow([X, Map], 'Parent', handles.axes1);
set(handles.text17,'String', purpleCells);
guidata(hObject, handles);

function [fig] = countAllBrownCells(hObject, handles)
% This function will return a count of all (approx) brown cells in an image

im = handles.input1;
% run pre-processing on the image
imAdjusted = processImage(im);

% remove noise from each layer w/ median filter
for layer = 1:3
    imAdjusted(:,:,layer) = wiener2(imAdjusted(:,:,layer), [5 5]);
end
% create a mask using colour thresholding
mask = cellMask(imAdjusted);
mask = bwareaopen(mask, 10);

se = strel('disk',7);
se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);

% apply morphological processing 
mask = imdilate(mask, [se90 se0]);
mask = imopen(mask, se);

D = -bwdist(~mask);
Ld = watershed(D);
maskmask = imextendedmin(D,2);

D2 = imimposemin(D,maskmask);
Ld2 = watershed(D2);
bw3 = mask;
bw3(Ld2 == 0) = 0;

L = bwlabel(bw3);
cc = bwconncomp(bw3);

% get the regions
stats = regionprops(cc, 'Centroid', 'Area', 'Perimeter');

% make note of the centroid locations
centroids = [stats.Centroid];

x = centroids(1:2:end-1)';
y = centroids(2:2:end)';

% number of objects is the number of "brown cells"
number3 = cc.NumObjects;

% plot the coordinates of the centroids over the original image
allBrownCells = [int2str(number3), "brown cells identified."];
allBrownCells = join(allBrownCells);
% plot the coordinates of the centroids over the original image
figure('visible', 'off');
imshow(im);
hold(imgca,'on')
plot(imgca,centroids(:,1), centroids(:,2), 'r*')
hold(imgca,'off')
set(gca,'position',[0 0 1 1],'units','normalized')
F = getframe(gcf);
[X, Map] = frame2im(F);
imshow([X, Map], 'Parent', handles.axes1);
set(handles.text17,'String', allBrownCells);
guidata(hObject, handles);

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% change checkbox state
guidata(hObject, handles)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
startingFolder = userpath;
% File type blank so user can specify the type they want
% Defaults to png
defaultFileName = fullfile(startingFolder, '*.*');
[baseFileName, folder] = uiputfile(defaultFileName, 'Export Current Image');
if baseFileName == 0
	% User cancelled.
	return;
end
fullFileName = fullfile(folder, baseFileName);
export_fig(handles.axes1, fullFileName);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
countNormalCell(hObject, handles);
guidata(hObject, handles);

function [fig] = countNormalCell(hObject, handles)
% This function will return a count of all (approx) purple cells in an
% image
tic
im = handles.input1;
% run pre-processing on the image
imAdjusted = processPurpleImage(im);

% remove noise from each layer w/ median filter
for layer = 1:3
    imAdjusted(:,:,layer) = wiener2(imAdjusted(:,:,layer), [5 5]);
end
% create a mask using colour thresholding
mask = purpleCellMaskHSV(imAdjusted);

mask = bwareaopen(mask, 10);
se = strel('disk',8);
mask = imopen(mask, se);
mask = imfill(mask, 'holes');

cc = bwconncomp(mask);

% get the regions
stats = regionprops(cc, 'Area');

L = labelmatrix(cc);
maskArea = ismember(L, find([stats.Area] >= 100));

maskArea = imfill(maskArea, 'holes');

D = -bwdist(~maskArea);
Ld = watershed(D);
maskmask = imextendedmin(D,2);
D2 = imimposemin(D,maskmask);
Ld2 = watershed(D2);
bw3 = maskArea;
bw3(Ld2 == 0) = 0;
purpleMask = bwareaopen(bw3, 40);

cc2 = bwconncomp(purpleMask);

stats2 = regionprops(cc2, 'Centroid');
% make note of the centroid locations
centroids = cat(1, stats2.Centroid);

% number of objects is the number of "purple cells"
purpleCells = cc2.NumObjects;

im = handles.input1;
% run pre-processing on the image
imAdjusted = processImage(im);

% remove noise from each layer w/ median filter
for layer = 1:3
    imAdjusted(:,:,layer) = wiener2(imAdjusted(:,:,layer), [5 5]);
end

% create a mask using colour thresholding
mask = cellMask(imAdjusted);
mask = bwareaopen(mask, 10);
se = strel('disk',7);

se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);

% apply morphological processing 
mask = imdilate(mask, [se90 se0]);
mask = imopen(mask, se);
D = -bwdist(~mask);
Ld = watershed(D);
maskmask = imextendedmin(D,2);
D2 = imimposemin(D,maskmask);
Ld2 = watershed(D2);
normalMask = mask;
normalMask(Ld2 == 0) = 0;

cc = bwconncomp(normalMask);

% get the regions
stats = regionprops(cc, 'Centroid', 'Area', 'Perimeter');

% make note of the centroid locations
centroids = [stats.Centroid];

% number of objects is the number of "brown cells"
allBrownCells = cc.NumObjects;

% This function will return a count of all (approx) dark brown cells in an
% image
im = handles.input1;
% run pre-processing on the image
%imAdjusted = processImage(im);

% remove noise from each layer w/ median filter
for layer = 1:3
   imAdjusted(:,:,layer) = wiener2(imAdjusted(:,:,layer), [5 5]);
end

% create a mask using colour thresholding
mask = darkBrownMask(im);
mask = bwareaopen(mask, 10);

se = strel('disk',7);
se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);

% apply morphological processing 
mask = imerode(mask, [se90 se0]);
mask = imopen(mask, se);
cc = bwconncomp(mask);

% get the regions
stats = regionprops(cc, 'Centroid', 'Area', 'Perimeter');

% make note of the centroid locations
centroids = cat(1, stats.Centroid);

darkBrownCells = cc.NumObjects;
allCells = (darkBrownCells + purpleCells + allBrownCells) - darkBrownCells;
normalCells = (allBrownCells + purpleCells) - darkBrownCells;

percentage = (darkBrownCells / allCells) * 100;

CellRatio = [int2str(darkBrownCells),":",int2str(normalCells),"" + newline + newline, "Dark Brown Percentage:" + newline + newline,num2str(percentage, 3),"%"];

CellRatio = join(CellRatio);
cellInfo = [int2str(allCells),"cells indentified." + newline,
    int2str(darkBrownCells),"classified as dark brown." + newline,
    int2str(normalCells),"classified as purple/light brown."];
cellInfo = join(cellInfo);
set(handles.text9,'String', CellRatio);
set(handles.text14,'String', cellInfo);
timeElapsed = toc
guidata(hObject, handles);
