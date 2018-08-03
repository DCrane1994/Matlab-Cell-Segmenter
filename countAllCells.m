function results = countAllCells(im)

% Count number of brown cells
brownCells = countDarkBrownCells(im);

% Count number of purple cells
purpleCells = countPurpleCell(im);

% All cells = brown + purple
allCells = brownCells + purpleCells;

figure;
imshow(im);
title(sprintf('This image contains approximately %i cells. The ratio of brown to purple is: %d:%g', allCells, brownCells, purpleCells));

results.NumberOfCells = allCells

%--------------------------------------------------------------------------
