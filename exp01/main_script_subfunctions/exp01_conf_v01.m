function [conf] = exp01_conf_v01(cfg,type, nTrial)
%
% This function asks for participant's confidence about how many
% associations they will remember
% 
% Uses the Likert function from the CogToolbox from the MAPLE lab:
% www.lrdc.pitt.edu/maplelab/cogtoolbox.html
%
% Author:   William Hopper
% Original: 29/01/2020


% change question text depending on which stage of trial (pre-first flip or
% pre-testing)
se_num = 1:8;

switch type
    case 'flip'
        question = [cfg.ptb.instructions.conf_pre_flip num2str(se_num(nTrial))];
    case 'SE'
        question = cfg.ptb.instructions.conf_SE;
    case 'test'
        question = cfg.ptb.instructions.conf_pre_test;
    case 'training1'
        question = cfg.ptb.instructions.conf_training1;
    case 'training2'
        question = cfg.ptb.instructions.conf_training2;
end


conf = Likert_v02(cfg.ptb.PTBwindow, cfg.ptb.conf.text_colour, question,...
    cfg.ptb.conf.label(1), cfg.ptb.conf.label(3), cfg.ptb.conf.confirmcolor,...
    cfg.ptb.conf.numchoices, cfg.ptb.conf.label(2), cfg.ptb.conf.numcolors);




end