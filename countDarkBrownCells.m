function [fig] = countDarkBrownCells(im)
% This function will return a count of all (approx) dark brown cells in an
% image

% run pre-processing on the image
imAdjusted = processImage(im);

% remove noise from each layer w/ median filter
%for layer = 1:3
   %imAdjusted(:,:,layer) = wiener2(imAdjusted(:,:,layer), [5 5]);
%end

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
figure;
imshow(im);
hold(imgca,'on')
plot(imgca,centroids(:,1), centroids(:,2), 'og')
hold(imgca,'off')
title(sprintf('This image contains approximately %i dark brown cells', number));
fig = gcf;

results.Figure = centroids;
