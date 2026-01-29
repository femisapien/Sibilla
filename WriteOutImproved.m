function status = WriteOutImproved(input_dir, report_type, date_str, output_name_stem)
%WriteOutImproved Writes technical report data from a .mat file to TWO XLSX files.
%
%   MODIFIED: Removed 'H_M2' (Model 2) entries from the export list.
%
%   status = WriteOutImproved(input_dir, report_type, date_str, output_name_stem)
%   loads data from a .mat file and writes the data to two identical,
%   formatted XLSX files with multiple sheets:
%     1. A file named using the date (e.g., '2025-10-17.xlsx')
%     2. A file named using the stem and "REPORTS" (e.g., 'my-analysis-REPORTS.xlsx')
%
%   Each sheet includes a 'StockName' column (Column A) and a header row.
%
%   INPUTS:
%   input_dir        - Directory containing the source .mat file (e.g., 'C:\Reports').
%                      This MUST be a string or character vector.
%   report_type      - The type of report, used to find the .mat file
%                      (e.g., 'stocks', 'forex').
%   date_str         - The date string for the report (e.g., '2025-10-17').
%   output_name_stem - The base name for the second output file (e.g., 'stocks2', 'my-analysis').
%
%   OUTPUT:
%   status           - Returns 1 on success (both files written), 0 on failure (one or more failed).

disp('Writing excel files...')

% --- 0. Input Validation ---
if ~ischar(input_dir) && ~isstring(input_dir)
    fprintf('Error: The first input, input_dir, must be a string or character vector representing a path.\n');
    fprintf('          You provided a variable of type: %s\n', class(input_dir));
    fprintf('Correct Example: WriteOutImproved(''C:\\data'', ''stocks'', ...)\n');
    status = 0;
    return;
end

% --- 1. Define Data Structure for Reports ---
% This cell array centralizes all information about the reports to be written.
% {variable name in .mat file, desired Excel sheet name, {cell array of column headers}}
reports_to_write = {
    {'A_WEEKLY', 'weekly', {'MA13W_CROSS_DATE', 'MA13W_CROSS_SIGN', 'MA13W_CROSS_DIRECTION','MA30W_CROSS_DATE', 'MA30W_CROSS_SIGN', 'MA30W_CROSS_DIRECTION'}}, ...
    {'LONG_LINE', 'fast_drop_hot_long', {'FD_INDICATOR', 'FD_DATE','HL_DATE','TODAY_RSI'}}, ...
    {'SHORT_LINE', 'short_rise_hot_short', {'FR_INDICATOR', 'FR_DATE','HS_DATE','TODAY_RSI', 'DIFF_RSI_SECURITY_WEAKER_INDEX'}}, ...
    {'D_BREAKS', 'breaks', {'BREAKOUT_260D', 'BREAKDOWN_260D', 'BREAKOUT_80D', 'BREAKDOWN_80D'}}, ...
    {'E_BREAKSr', 'breaksr', {'BREAKOUT_SPX_260D', 'BREAKDOWN_SPX_260D', 'BREAKOUT_SPX_80D', 'BREAKDOWN_SPX_80D', 'NARROW_RANGE_7D', 'WIDE_RANGE_30D', 'LAST_VOL_GT_2_5x_50DMA', 'VOLUME', 'HIGH_LAST_4D', 'LOW_LAST_4D', 'HIGH_DT_3M','LOW_DT_3M','HIGH_DT_1M','LOW_DT_1M'}}, ...
    {'G_AD', 'acc_dist', {'NUM_ORIGINAL_ACCUMMULATION', 'NUM_INTRADAY_ACCUMULATION', 'NUM_ORIGINAL_DISTRIBUTION', 'NUM_INTRADAY_DISTRIBUTION'}}, ...
    {'I_MA_SIG', 'MA_50D_SIG', {'RATIO_SEC_INDEX_SIGNAL'}} ...
};

% --- 2. Construct Input File Path and Validate ---
input_fname = sprintf('%s-Reports-for-%s.mat', report_type, date_str);
input_fpath = fullfile(input_dir, input_fname);

if exist(input_fpath, 'file') ~= 2
    fprintf('Error: Input file not found at:\n%s\n', input_fpath);
    status = 0;
    return;
end

% --- 3. Construct Output File Paths ---
% NOTE: The output directory is still hardcoded.
% For better design, this could be passed as an argument.
output_dir = 'C:\101510';

% File 1: Named with the date
output_fname_1 = sprintf('%s.xlsx', date_str);
output_fpath_1 = fullfile(output_dir, output_fname_1);

% File 2: Named with the stem and "REPORTS"
output_fname_2 = sprintf('%s-REPORTS.xlsx', output_name_stem);
output_fpath_2 = fullfile(output_dir, output_fname_2);

% --- 4. Load Data ---
fprintf('Loading data from: %s\n', input_fpath);
try
    data_struct = load(input_fpath);
catch ME
    fprintf('Error: Could not load the MAT file.\n');
    fprintf('MATLAB error: %s\n', ME.message);
    status = 0;
    return;
end

% --- 4.5. Validate and Extract StockNames (MODIFICATION) ---
if ~isfield(data_struct, 'StockNames')
    fprintf('Error: The loaded MAT file is missing the required "StockNames" variable.\n');
    fprintf('        Cannot proceed with writing Column A.\n');
    status = 0;
    return;
end

% Extract stock names and ensure it's a column vector
stockNames_col = data_struct.StockNames;
if size(stockNames_col, 2) > 1
    stockNames_col = stockNames_col'; % Transpose if it's a row vector
end
fprintf('Found StockNames variable with %d entries.\n', size(stockNames_col, 1));


% --- 5. Write Data to Both Excel Files ---
% We call our local helper function twice, now passing stockNames_col.
% We track the success of both writes.
status_1 = writeSingleExcelFile(output_fpath_1, data_struct, reports_to_write, stockNames_col);
status_2 = writeSingleExcelFile(output_fpath_2, data_struct, reports_to_write, stockNames_col);

% Final status is 1 only if BOTH files were written successfully.
status = status_1 && status_2;

if status
    fprintf('Finished writing all reports to both files successfully.\n');
else
    fprintf('One or more files failed to write. Please check the errors above.\n');
end

end


% --- Local Helper Function ---
function write_status = writeSingleExcelFile(output_fpath, data_struct, reports_to_write, stockNames_col)
% This function contains the logic to write one complete Excel file.
% MODIFIED: It now accepts stockNames_col and prepends it to each sheet.
% It returns 1 on success, 0 on failure.

fprintf('--- Writing data to: %s ---\n', output_fpath);
write_status = 1; % Assume success until an error occurs
num_stocks = size(stockNames_col, 1); % Get the expected number of rows

for i = 1:length(reports_to_write)
    % Extract info for the current report
    var_name   = reports_to_write{i}{1};
    sheet_name = reports_to_write{i}{2};
    headers    = reports_to_write{i}{3};

    % Check if the variable exists in the loaded data struct
    if isfield(data_struct, var_name)
        data_matrix = data_struct.(var_name);

        % --- MODIFICATION: Check row count consistency ---
        if size(data_matrix, 1) ~= num_stocks
             fprintf('\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
             fprintf('CRITICAL ERROR: Row count mismatch for sheet "%s".\n', sheet_name);
             fprintf('                StockNames has %d rows, but data ("%s") has %d rows.\n', ...
                      num_stocks, var_name, size(data_matrix, 1));
             fprintf('                Cannot reliably join data. Stopping write to this file.\n');
             fprintf('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
             write_status = 0; % Mark as failure
             return; % Stop writing this file, as it's a fundamental data mismatch
        end

        % --- MODIFICATION: Create tables and combine ---
        % 1. Create the StockName table
        StockNames_Table = table(stockNames_col, 'VariableNames', {'StockName'});

        % 2. Convert the raw data matrix to a table with named columns
        Data_Table = array2table(data_matrix, 'VariableNames', headers);

        % 3. Combine tables (StockName table comes first)
        T = [StockNames_Table, Data_Table];
        % --- End Modification ---

        % Write the combined table to the specified sheet.
        try
            writetable(T, output_fpath, 'Sheet', sheet_name);
            fprintf('... successfully wrote sheet: %s\n', sheet_name);
        catch ME
            % --- Enhanced Error Reporting ---
            % This block now clearly states which file and sheet failed.
            fprintf('\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
            fprintf('CRITICAL ERROR: Failed to write to file:\n%s\n', output_fpath);
            fprintf('Attempting to write sheet: %s\n', sheet_name);
            fprintf('REASON: %s\n', ME.message);
            fprintf('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n');
            
            % Check for common permission error
            if strcmp(ME.identifier, 'MATLAB:table:write:FileOpenInAnotherProcess')
                fprintf('HINT: The file might be open in Excel. Close it and try again.\n');
            end
            
            write_status = 0; % Mark this file-write as a failure
            return; % Stop writing to this file
        end
    else
        % Warn the user if a variable is missing from the .mat file
        fprintf('Warning: Variable "%s" not found in the MAT file. Skipping sheet "%s".\n', var_name, sheet_name);
    end
end

fprintf('--- Successfully finished writing file: %s ---\n', output_fpath);

end