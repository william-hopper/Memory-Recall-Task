function [rand_Std, Tar, Swi] = gen_st_RSVP(MAX_ST_LENGTH, symbols, difficulty)
%% generate the string required for each different stream
% Stream:
% MAX_ST_LENGTH = maximum number of characters to show per difficulty step
% symbols = list of symbols to be displayed i.e. a:z & A:Z
% difficulty = number of switches in difficulty step



% non-target streams
Std = '';
rand_Std = '';
for i = 1:7
    nums = randi([8 numel(symbols)-7],[1 MAX_ST_LENGTH]); % character-number mapping
    Std(i,:) = symbols(nums); % generate character string
    rand_Std(i,:) = randsample(Std(i,:),length(Std(1,:))); % randomise string
end

% target streams
Tar = [];
% for the number of targets to respond to i.e. 5
for i = 1:5
    nums = randi([8 numel(symbols)-7],[1 randi([3,floor(MAX_ST_LENGTH/5)])]); % generate a sequence of character-number codes 3 to 8 characters long
    Tar = [Tar nums 7]; % adjoin this to the previous loop with a 7 at the end
end
Tar(end+1:MAX_ST_LENGTH) = randi([8 numel(symbols)-7], [1 MAX_ST_LENGTH-length(Tar)]); % fill in the remaining (to MAX_ST_LENGTH) characters
if length(Tar)>MAX_ST_LENGTH % if longer than MAX_ST_LENGTH, remove end
    Tar = Tar(1:MAX_ST_LENGTH);
    Tar(MAX_ST_LENGTH-1) = 7; % removing will delete one 7, so make the penultimate character 7
end
if Tar(MAX_ST_LENGTH) == 7
    Tar([MAX_ST_LENGTH MAX_ST_LENGTH-1]) = Tar([MAX_ST_LENGTH-1 MAX_ST_LENGTH]);
end
Tar = symbols(Tar); % convert from numbers to characters
Tar(Tar == '<') = '7'; % due to character-number mapping, need to change 7s specifically

% switch streams
if difficulty ~= 10
    Swi_min = 3;
else
    Swi_min = 2;
end
Swi = [];
for i = 1:difficulty
    nums = randi([8 numel(symbols)-7],[1 randi([Swi_min,(floor((MAX_ST_LENGTH-6)/difficulty))])]);
    Swi = [Swi nums 3];
end
Swi(end+1:MAX_ST_LENGTH) = randi([8 numel(symbols)-7], [1 MAX_ST_LENGTH-length(Swi)]);
if length(Swi)>MAX_ST_LENGTH
    Swi = Swi(1:MAX_ST_LENGTH);
    Swi(MAX_ST_LENGTH-3) = 3;
end
Swi = symbols(Swi);
Swi(Swi == '<') = '3';

%% check if any switches overlap targets and if they do, move the switch 
t = find(Tar == '7');
s = find(Swi == '3');
mat = abs(bsxfun(@minus,t(:).',s(:)));
match_idx = any(mat == 0, 2);
if any(match_idx)
    match = true;
else
    match = false;
end

while match
    Swi_match_idx = find(match_idx);
    Swi([s(Swi_match_idx) s(Swi_match_idx)+1]) = Swi([s(Swi_match_idx)+1 s(Swi_match_idx)]);
    s_2 = find(Swi == '3');
    mat = abs(bsxfun(@minus,t(:).',s_2(:)));
    match_idx = any(mat == 0, 2);
    
    if ~any(match_idx)
        match = false;
    end
end
