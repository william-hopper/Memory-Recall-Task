function [conf] = exp02_conf_v01(cfg)
%
% This function asks for participant's confidence about their response
%
% Uses a modified version of the slideScale function created by:
%   Author: Joern Alexander Quent
%   e-mail: Alex.Quent@mrc-cbu.cam.ac.uk
%   github: https://github.com/JAQuent/functions-for-matlab
%
% Author:   William Hopper
% Original: 11/02/2020

% test_window_image = Screen('GetImage', cfg.ptb.PTBoffwindow);

[position, RT, answer] = slideScale_v02(cfg.ptb.PTBwindow,...
    cfg.ptb.conf.question,...
    cfg.ptb.PTBwindowRect,...
    cfg.ptb.conf.endpoints,...
    'range',              cfg.ptb.conf.range,...
    'startposition',      cfg.ptb.conf.startposition,...
    'scalalength',        cfg.ptb.conf.scalalength,...
    'scalaposition',      cfg.ptb.conf.scalaposition,...
    'device',             cfg.ptb.conf.device,...
    'slidercolor',        cfg.ptb.conf.slidercolor,...
    'scalacolor',         cfg.ptb.conf.scalacolor,...
    'displayposition',    cfg.ptb.conf.displayposition);
%     'image',              test_window_image);

conf.position = position;
conf.RT = RT;
conf.answer = answer;




end