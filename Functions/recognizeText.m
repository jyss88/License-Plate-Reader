function [ text ] = recognizeText( letterImages )
%recognizeText: Translates cell array of text images into a string
%   Input: Cell array of letter images. Can be of any dimensions.
%   Output: String of translated text.
%   Returns -1 if input is not valid.
%   Requires templates to be loaded as globals 

global templates numTemplates;

if ~iscell(letterImages)
    text = -1;
else
%% Get some information
numLetters = size(letterImages, 1);

%% Match images to letters
correlation = zeros([numLetters, numTemplates]);
text = [];

for i = 1:numLetters
    if letterImages{i} ~= -1
        for j = 1:numTemplates
            [xSize, ySize] = size(templates{j});
            correlation(i, j) = corr2(templates{j}, imresize(letterImages{i}, [xSize, ySize]));
        end
    
        index = find(abs(correlation(i, :)) == max(abs(correlation(i, :))));
        letter = num2Letter2(index);
        text = strcat(text, letter);
    end
end

end

end

