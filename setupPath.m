function setupPath()
%SETUPPATH Put every folder this project needs on the MATLAB path.
%   Run once per MATLAB session, from the repo root:
%       >> setupPath
%   Then run the scripts in the order given in README.md.
%
%   Adds folders for this session only — nothing is written to your MATLAB
%   installation, so this cannot affect any other project.

root = fileparts(mfilename('fullpath'));

folders = { ...
    'data'                          % raw inputs (spreadsheets)
    fullfile('data','fullModel_data')
    fullfile('data','eqProbModel_data')
    fullfile('data','randProbModel_data')
    fullfile('data','randTopModel_data')
    'setup'
    'models'
    fullfile('models','lib')        % createTransitionMatrices, runSimulation, randomizeA
    'analysis'
    'results'
    };

for i = 1:numel(folders)
    f = fullfile(root, folders{i});
    if ~isfolder(f)
        error('setupPath:missingFolder', 'Expected folder not found: %s', f);
    end
    addpath(f);
end

% The pipeline loads these by bare name, so two copies on the path would mean
% MATLAB silently picking one. Catch that here rather than in the results.
dataFiles = ["diaries.mat" "diary_data.mat" "master_list.mat" ...
             "CID_building.mat" "edgeDictionary.mat"];
for n = dataFiles
    hits = which(n, '-all');
    if numel(hits) > 1
        warning('setupPath:shadowed', ...
            '%s exists in %d places on the path; the first wins:\n  %s', ...
            n, numel(hits), strjoin(string(hits), '\n  '));
    end
end

fprintf('Project path set (%d folders under %s).\n', numel(folders), root);
end