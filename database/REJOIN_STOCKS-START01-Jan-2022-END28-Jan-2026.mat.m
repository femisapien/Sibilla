%% Rejoin BBG parts into full dataset
clear; clc;

% Initialize empty cells
StockNames = {};
BBGDATA    = {};

% Load and concatenate all 4 parts
for k = 1:4
    partFile = sprintf('BBG_part%d.mat', k);
    if ~exist(partFile, 'file')
        error('Missing part file: %s', partFile);
    end
    
    load(partFile);  % loads StockNames_part, BBGDATA_part
    
    StockNames = [StockNames; StockNames_part];
    BBGDATA    = [BBGDATA, BBGDATA_part];
    
    % Clean up part variables
    clear StockNames_part BBGDATA_part;
end

% Save full dataset
save('BBG_full_rejoined.mat', 'StockNames', 'BBGDATA', '-v7');

fprintf('Rejoined %d stocks\n', numel(StockNames));
fprintf('StockNames: %dx%d cell\n', size(StockNames));
fprintf('BBGDATA: %dx%d cell\n', size(BBGDATA));

% Verify first few entries match expected pattern
fprintf('\nFirst 3 stock names:\n');
disp(StockNames(1:3));