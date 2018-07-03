function [ croppedPlate ] = cropPlate( image )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Mask license plate
[~, maskedImage] = maskLicensePlate(image);
    
if ~iscell(maskedImage) 
    croppedPlate = -1;
else   
numPlates = size(maskedImage, 1);
croppedPlate = cell(numPlates, 1);
    
for i = 1:numPlates
    %% Rotate image
    msr = regionprops(double(~maskedImage{i}), 'orientation');
    
    if ~isempty(msr)
    theta = msr.Orientation;
    
    rotatedImage = imrotate(image, -theta);
    rotatedMask = dip_image(~imrotate(double(~maskedImage{i}), -theta));
    
    %% More measuring
    msr = measure(~rotatedMask,[],{'CartesianBox','Center'},[],Inf,0,0);
    cBox = msr.CartesianBox;
    center = msr.Center;
    x = [center(1) - (cBox(1)/2), center(1) + (cBox(1)/2)];
    y = [center(2) - (cBox(2)/2), center(2) + (cBox(2)/2)];

    boxX = [x(1), x(2), x(2), x(1)];
    boxY = [y(1), y(1), y(2), y(2)];
    
    %% Crop picture around plate

    % Compute rectangle information
    maxX = round(max(boxX));
    minX = round(min(boxX));
    deltaX = maxX - minX;

    maxY = round(max(boxY));
    minY = round(min(boxY));
    deltaY = maxY - minY;

    croppedPlate{i} = imcrop(rotatedImage, [minX, minY, deltaX, deltaY]);
    else
        croppedPlate{i} = -1;
    end
end
end
end

