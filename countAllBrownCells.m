function [fig] = countAllBrownCells(im)
% This function will return a count of all (approx) brown cells in an image

% run pre-processing on the image
imAdjusted = processImage(im);

% remove noise from each layer w/ median filter
for layer = 1:3
    imAdjusted(:,:,layer) = wiener2(imAdjusted(:,:,layer), [5 5]);
end

%imAdjusted = imsharpen(imAdjusted);

% create a mask using colour thresholding
mask = cellMask(imAdjusted);

mask = bwareaopen(mask, 10);
%imshow(mask);
se = strel('disk',7);

se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);

% apply morphological processing 
mask = imdilate(mask, [se90 se0]);

mask = imopen(mask, se);

D = -bwdist(~mask);

Ld = watershed(D);


mask2 = mask;
mask2(Ld == 0) = 0;

maskmask = imextendedmin(D,2);

D2 = imimposemin(D,maskmask);
Ld2 = watershed(D2);
bw3 = mask;
bw3(Ld2 == 0) = 0;
%imshow(bw3)

L = bwlabel(bw3);
cc = bwconncomp(bw3);

% get the regions
stats = regionprops(cc, 'Centroid', 'Area', 'Perimeter');

% make note of the centroid locations
centroids = [stats.Centroid];

x = centroids(1:2:end-1)';
y = centroids(2:2:end)';

% number of objects is the number of "brown cells"
number = cc.NumObjects;

% plot the coordinates of the centroids over the original image
figure;
imshow(im);
hold on;
plot(x,y, 'or')
title(sprintf('This image contains approximately %i brown cells', number));

bw3 = bwperim(bw3);
overlay1 = imoverlay(im, bw3, 'g');

results.number = number;

%--------------------------------------------------------------------------
