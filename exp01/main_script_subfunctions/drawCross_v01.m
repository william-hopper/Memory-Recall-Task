function [T]= drawCross_v01(cfg)
% draw fixation cross
% 
% Taken from peterscarfe.com
%
% Created by: William Hopper
% 03/02/2020

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 40;
lineWidthPix = 4;
% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Draw the fixation cross in white, set it to the center of our screen and
% set good quality antialiasing
Screen('DrawLines', cfg.ptb.PTBwindow, allCoords,...
    lineWidthPix, cfg.ptb.white, [cfg.ptb.xCentre cfg.ptb.yCentre], 2);

% Flip to the screen
T = Screen('Flip', cfg.ptb.PTBwindow);

end