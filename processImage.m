function [im] = processImage(im)
% pre-process the image

%apply a linear contrast stretch
im = imadjust(im,stretchlim(im),[]);

% Isolate the colour channels
red = im(:, :, 1);
green = im(:, :, 2);
blue = im(:, :, 3);

% Get the averages of each channel
meanR = mean2(red);
meanG = mean2(green);
meanB = mean2(blue);

% Compute desired mean
newMean = mean([meanR, meanG, meanB]);

% Compute white balance offsets
offsetCorrectionR = newMean / meanR;
offsetCorrectionG = newMean / meanG;
offsetCorrectionB = newMean / meanB;

% And apply them to the colour channels
redNew = uint8(single(red) * offsetCorrectionR);
greenNew = uint8(single(green) * offsetCorrectionG);
blueNew = uint8(single(blue) * offsetCorrectionB);

% Rebuild the image
newRGB = cat(3, redNew, greenNew, blueNew);

im = newRGB;

results.Normalised  = im;

%--------------------------------------------------------------------------
