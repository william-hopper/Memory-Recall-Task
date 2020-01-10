function create_missing_directories(path)
% function create_missing_directories(path)
%
%   This checks if all directories are existing and creates them empty if
%   not.
%
%   Path has to be a structure of strings.
%
%   Author: Antonius Wiehler <antonius.wiehler@gmail.com>
%   Original: 2017-04-25

path = struct2cell(path);  % convert path structure to cell array

for i_p = 1 : size(path, 1)
    if ~exist(path{i_p}, 'dir')
        mkdir(path{i_p});
        fprintf('Created missing directory %s\n', path{i_p});
    end
end

end