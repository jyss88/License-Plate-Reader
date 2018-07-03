function [ text ] = readLicensePlate( image )
%readLicensePlate: Reads license plate number of a car in image
%   INPUT
%   image: rgb image of car with plate
%
%   OUTPUT
%   text: translated text off plate
%   If no plate detected, function will return -1.

%% Crop out plate
croppedPlate = cropPlate(image);
numPlates = size(croppedPlate, 1);

text = cell(numPlates, 1);

for i = 1:numPlates
    %% Extract letters
    if iscell(croppedPlate)
        letterImages = extractLetters(croppedPlate{i});

        %% Translate to text
        text{i} = recognizeText(letterImages);
    else
        text{i} = -1;
    end
end
end

