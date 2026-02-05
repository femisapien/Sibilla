% 1. Define Entry Points (Targeted Active Files)
entryPoints = [...
    "xRunSibillaTasks202602.m"; 
    "xINDICATORS.m";
    "xM12026.m";
    "xMRC.m";
    "xMRC2026.m";
    "xRDD.m";
    "xMakeReportsLite.m"]; 

% 2. Identify Active Files & Dependencies
activeFiles = string.empty(0,1); 
for i = 1:numel(entryPoints)
    if exist(entryPoints(i), 'file')
        [list, ~] = matlab.codetools.requiredFilesAndProducts(entryPoints(i));
        activeFiles = [activeFiles; string(list(:))]; 
    end
end
activeFiles = unique(activeFiles(~startsWith(activeFiles, matlabroot)));
numActive = numel(activeFiles);

fileData = table(activeFiles, 'VariableNames', {'Path'});
fileData.Tier = zeros(numActive, 1);
fileData.Dependencies = cell(numActive, 1);
fileData.Foundational_Tier0_Deps = strings(numActive, 1);

for i = 1:numActive
    [dList, ~] = matlab.codetools.requiredFilesAndProducts(activeFiles(i));
    dList = string(dList(:));
    activeDeps = dList(ismember(dList, activeFiles) & ~strcmp(dList, activeFiles(i)));
    fileData.Dependencies{i} = activeDeps;
end

% 3. Calculate Tiers (Hierarchy Depth)
for iter = 1:15 
    for i = 1:numActive
        deps = fileData.Dependencies{i};
        if ~isempty(deps)
            depIndices = ismember(fileData.Path, deps);
            if any(depIndices)
                fileData.Tier(i) = max(fileData.Tier(depIndices)) + 1;
            end
        end
    end
end

% 4. Trace Foundations (Mapping to Tier 0)
tier0Paths = fileData.Path(fileData.Tier == 0);
for i = 1:numActive
    if fileData.Tier(i) > 0
        [fullList, ~] = matlab.codetools.requiredFilesAndProducts(fileData.Path(i));
        fullList = string(fullList(:));
        foundational = intersect(fullList, tier0Paths);
        
        if isempty(foundational)
            fileData.Foundational_Tier0_Deps(i) = "None (Internal only)";
        else
            t0Names = strings(size(foundational));
            for k = 1:numel(foundational)
                [~, t0Names(k), ~] = fileparts(foundational(k));
            end
            fileData.Foundational_Tier0_Deps(i) = strjoin(t0Names, ', ');
        end
    else
        fileData.Foundational_Tier0_Deps(i) = "N/A (Self-Foundation)";
    end
end

% 5. Format, Deduplicate, and Export
fileData = sortrows(fileData, 'Tier');
[~, names, exts] = cellfun(@fileparts, cellstr(fileData.Path), 'UniformOutput', false);
fileData.FileName = strcat(string(names), string(exts));
finalTable = fileData(:, {'Tier', 'FileName', 'Foundational_Tier0_Deps', 'Path'});

% 6. Create Unique 2-Column List and Export
% Deduplicate based on name to ensure each function appears only once
[~, uniqueIdx] = unique(finalTable.FileName, 'stable');
simpleChecklist = finalTable(uniqueIdx, {'Tier', 'FileName'});

% Rename the column for the final Excel output
simpleChecklist.Properties.VariableNames{'FileName'} = 'Function_Name';

% Save the final 2-column checklist
writetable(simpleChecklist, 'Sibilla_Simple_Migration_List.xlsx');

% Display the first few rows in the Command Window for confirmation
disp('--- Final Migration List Preview ---');
disp(head(simpleChecklist, 10)); 
fprintf('Success! %d unique functions saved to Sibilla_Simple_Migration_List.xlsx.\n', height(simpleChecklist));