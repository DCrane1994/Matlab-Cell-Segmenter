function [fig] = countPurpleCell(im)
% This function will return a count of all (approx) purple cells in an
% image

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

se90 = strel('line', 3, 90);
se0 = strel('line', 3, 0);

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

mask2 = maskArea;
mask2(Ld == 0) = 0;

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

% plot the coordinates of the centroids over the original image
figure;
imshow(im);
hold(imgca,'on')
plot(imgca,centroids(:,1), centroids(:,2), 'or')
hold(imgca,'off')
title(sprintf('This image contains approximately %i purple cells', number2));
F = getframe(gcf);
[X, Map] = frame2im(F);
imshow([X, Map], 'Parent', handles.axes1);


%--------------------------------------------------------------------------
