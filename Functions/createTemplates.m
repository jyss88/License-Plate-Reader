%% Create templates2
run('C:\Program Files\DIPimage 2.9\dipstart.m')
%% Constants
xEdge = 2;
yEdge = 2;

%% Load image
fontMaster = ~im2bw(imread('Kentenken Font\Font Master.png'));

%% Label 
[labelled, numTemplates] = bwlabel(fontMaster);

%% Extract images
templates = cell(numTemplates, 1);
xCoords = zeros([numTemplates, 1]);
yCoords = zeros([numTemplates, 1]);

for i = 1:numTemplates
    letter = labelled == i;
    
    % Measure
    msr = measure(letter,[],{'CartesianBox','Center'},[],Inf,0,0);
    cBox = msr.CartesianBox;
    center = msr.Center;
    x = [center(1) - (cBox(1)/2), center(1) + (cBox(1)/2)];
    y = [center(2) - (cBox(2)/2), center(2) + (cBox(2)/2)];

    boxX = [x(1), x(2), x(2), x(1)];
    boxY = [y(1), y(1), y(2), y(2)];
    
    % Compute rectangle information
    maxX = round(max(boxX));
    minX = round(min(boxX));
    deltaX = maxX - minX;
    xCoords(i) = minX;
    
    maxY = round(max(boxY));
    minY = round(min(boxY));
    deltaY = maxY - minY;
    yCoords(i) = minY;
    
    % crop image
    templates{i} = imcrop(fontMaster, [minX - xEdge, minY - yEdge, deltaX + 2*xEdge, deltaY + 2*yEdge]);
end

%% Sort by y Coords
[~, yIndexes] = sort(yCoords);
sortedLettersY = cell(numTemplates, 1);
sortedxCoords = xCoords;

for i = 1:numTemplates
    j = yIndexes(i, 1);
    sortedLettersY{i} = templates{j};
    sortedxCoords(i) = xCoords(j);
end

%% Sort by x Coords
sortedLettersYX = cell(numTemplates, 1);
row = cell(6, 1);
rowX = zeros([6, 1]);
figure;
count = 1;

for i = 0:5
%    figure;
    for j = 1:6
        row{j} = sortedLettersY{j + 6*i};
        rowX(j) = sortedxCoords(j + 6*i);
%         subplot(2, 3, j);
%         imshow(row{j});
    end
    
    [~, xIndexes] = sort(rowX);
    
%    figure;
    for j = 1:6
        k = xIndexes(j, 1);
        sortedLettersYX{count} = row{k};
%        subplot(2, 3, j);
%        imshow(sortedLettersYX{count});
        count = count + 1;
    end
end

templates = sortedLettersYX;
numTemplates = size(templates, 1);

%% Plot
figure;
for i = 1:numTemplates
    subplot(6, 6, i);
    imshow(~sortedLettersYX{i});
    title(i);
end

%% Save variables
save ('Templates', 'templates', 'numTemplates')
clear all