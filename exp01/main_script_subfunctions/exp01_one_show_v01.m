function [rec] = exp01_one_show_v01(cfg)
%
% This function includes one full trial of the experiment.
%
% Author:   William Hopper
% Original: 10/01/2020

rec.start_time = GetSecs;  % when did the show start
rec.scriptname = mfilename('fullpath');  % save the name of this script


    
    
Screen('FrameRect', cfg.ptb.PTBwindow, cfg.ptb.white,...
    cfg.ptb.grid);

Screen('Flip', cfg.ptb.PTBwindow);

end


