%% Initialize 
clear; close all; clc
run('C:\Program Files\DIPimage 2.9\dipstart.m')
global templates numTemplates;
load('Templates.mat')

%% Load test image
image = imread('Test Images\test001.png');

%% Show image
imshow(image);
title('Test image');

%% Recognize text
text = readLicensePlate(image);

disp(text);