
% Initialization and path folder adition
clear globals
clear java
clear all
close all
addpath(genpath(pwd));
clc

% Show splash image (2 seconds)
show_splash_img('splash_image.png', 2);

% Call the main GUI
DL_RSVP_main