function [ sortedLetters ] = extractLetters( croppedPlate )
%extractLetters Extracts letters from a cropped image of license plate
%   Input: cropped image of a license plate
%   Output: Cell array containing binary images of letters.
%   Returns -1 if input image is not valid.

%% Constants
area = size(croppedPlate,1) * size(croppedPlate, 2);
length = size(croppedPlate, 1);
minObjectSize = round(area * (100/8820));
%xEdge = round(length * (4/74));

%% Check if plate cropped out successfully
if ~isa(croppedPlate, 'uint8')
    sortedLetters = -1;
else
%% Mask image
level = graythresh(croppedPlate);
BW = im2bw(croppedPlate, level);
BW = medfilt2(BW); % Filter image

%% Detect objects
dipObject = dip_image(~BW, 'bin'); % Convert to dipImage
labelledImage = label(dipObject, inf, minObjectSize, 0);

%% Extract into cells
noLetters = max(labelledImage);
letterImages = cell(noLetters, 1); % Create cell for letters
xCoords = zeros([noLetters, 1]);

for i = 1:noLetters
    letter = labelledImage == i;
    
    % Crop around letters
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
    xCoords(i) = minX; % Store top left corner (will be used for sorting) 

    maxY = round(max(boxY));
    minY = round(min(boxY));
    deltaY = maxY - minY;
    
    aspectRatio = deltaX/deltaY;

    if(aspectRatio < 1 && aspectRatio > 0.1)
        letterImages{i} = imcrop(BW, [minX, minY, deltaX, deltaY]);
    else
        letterImages{i} = -1;
    end
end

%% Sort by xCoords
[~, indexes] = sort(xCoords);
sortedLetters = cell(noLetters, 1);

for i = 1:noLetters
    j = indexes(i, 1);
    sortedLetters{i} = letterImages{j};
end

end

end

