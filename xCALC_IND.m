function OutputStruct=processAndExportIndicators(ma_period_days, ma_streak_length_ending_today, gap_percentage, gap_lookback_days, data_path, refname, fstr1, sold, fstr2, enew)
% processAndExportIndicators processes stock data to calculate MA and Gap indicators,
% saves selected results to a .mat file, and exports specific indicators to an Excel file.
%
% Args:
%   ma_period_days (double): Period for moving average (e.g., 31).
%   ma_streak_length_ending_today (double): Required length of consecutive days
%                                           above MA, ending on the most recent day (e.g., 52).
%   gap_percentage (double): Gap percentage threshold (e.g., 0.20 for 20%).
%   gap_lookback_days (double): Lookback window for gap indicator (e.g., 45 days).
%   data_path (char): Path to the database folder (e.g., 'C:\101510\database\').
%   refname (char): Reference name for the file (e.g., 'MACRO', 'LEADERS').
%   fstr1, sold, fstr2, enew (char): Parts for filename construction.

    fprintf('--- Starting Indicator Processing ---\n');
%     fprintf('Parameters:\n');
%     fprintf('  MA Period: %d days\n', ma_period_days);
%     fprintf('  MA Streak Length (ending today): >= %d days for binary indicator\n', ma_streak_length_ending_today);
%     fprintf('  Gap Percentage: %.2f%%\n', gap_percentage * 100);
%     fprintf('  Gap Lookback: %d days\n', gap_lookback_days);
%     fprintf('  Data Path: %s\n', data_path);
%     fprintf('  Refname: %s, StartDate: %s, EndDate: %s\n', refname, sold, enew);

    % --- 1. Construct File Paths ---
    input_filename_stem = sprintf('%s%s%s%s%s', refname, fstr1, sold, fstr2, enew);
    full_input_mat_path = fullfile(data_path, [input_filename_stem, '.mat']);

%     output_filename_stem = sprintf('%s%s', 'indicators', refname);
%     full_output_mat_path = fullfile(data_path, [output_filename_stem, '.mat']);
    
%     excel_export_base_folder = 'C:\101510\';
%     if ~exist(excel_export_base_folder, 'dir')
%         fprintf('Creating Excel export directory: %s\n', excel_export_base_folder);
%         try mkdir(excel_export_base_folder); 
%         catch ME_mkdir
%             fprintf('FATAL ERROR: Could not create directory %s: %s\n', excel_export_base_folder, ME_mkdir.message);
%             return; 
%         end
%     end
%     full_output_excel_path = fullfile(excel_export_base_folder, [output_filename_stem, '.xlsx']);

%     fprintf('Input MAT file: %s\n', full_input_mat_path);
%     fprintf('Output MAT file: %s\n', full_output_mat_path);
%     fprintf('Output Excel file: %s\n', full_output_excel_path);

    % --- 2. Load Data ---
    fprintf('Attempting to load data from: %s\n', full_input_mat_path);
    if ~exist(full_input_mat_path, 'file')
        fprintf('FATAL ERROR: Input MAT file not found at: %s\n', full_input_mat_path);
        return;
    end

    try
        loaded_data_struct = load(full_input_mat_path);
    catch ME_load
        fprintf('FATAL ERROR loading MAT file %s: %s\n', full_input_mat_path, ME_load.message);
        return;
    end

    if ~isfield(loaded_data_struct, 'BBGDATA') || ~isfield(loaded_data_struct, 'StockNames')
        fprintf('FATAL ERROR: Required fields BBGDATA or StockNames not found in %s.\n', full_input_mat_path);
        fprintf('Available fields were: %s\n', strjoin(fieldnames(loaded_data_struct), ', '));
        return;
    end
    
    BBGDATA = loaded_data_struct.BBGDATA;
    StockNames_loaded = loaded_data_struct.StockNames; 
    
    if ~iscell(BBGDATA) || isempty(BBGDATA) || ~iscell(StockNames_loaded) || isempty(StockNames_loaded) || length(BBGDATA) ~= length(StockNames_loaded)
        fprintf('FATAL ERROR: BBGDATA or StockNames is invalid or lengths mismatch.\n'); return;
    end

    num_stocks = length(BBGDATA);
    fprintf('Data loaded successfully. Number of stocks: %d\n', num_stocks);

    % --- 3. Calculate Indicators ---
    [maBinaryIndicator, daysAboveMA] = local_calculateMAIndicator(BBGDATA, ma_period_days, ma_streak_length_ending_today);
    gapIndicatorOutput = local_calculateGapIndicator(BBGDATA, gap_percentage, gap_lookback_days);
    fprintf('Indicators calculated.\n');

%     % --- 4. Save Results to .mat file ---
%     % This will include StockNames and the three indicators.
%     fprintf('Saving indicators to %s...\n', full_output_mat_path);
%     try
OutputStruct = struct();
OutputStruct.StockNames = StockNames_loaded(:); % Keeping StockNames in MAT file
OutputStruct.Days_Above_MA = daysAboveMA; % Using a more generic field name
OutputStruct.MA_Indicator = maBinaryIndicator; 
OutputStruct.GAP_Indicator = gapIndicatorOutput;
%         
%         save(full_output_mat_path, '-struct', 'OutputStruct');
%         fprintf('.mat file saved successfully.\n');
%     catch ME_save
%         fprintf('Error saving output MAT file %s: %s\n', full_output_mat_path, ME_save.message);
%     end

%     % --- 5. Export Specified Indicators to Excel ---
%     excel_sheet_name = 'indicators';
%     
%     % Create a new struct specifically for Excel export with only the desired columns
%     results_for_excel = struct();
%     results_for_excel.Days_Above_31D_MA_Col = daysAboveMA; % Temp valid field name
%     results_for_excel.MA_31D_Indicator_Col = maBinaryIndicator;
%     results_for_excel.GAP_Indicator_Col = gapIndicatorOutput;
% 
%     desired_excel_headers = {['Number_of_Days_Above_' num2str(ma_period_days) 'D_MA'], ...
%                              ['MA_' num2str(ma_period_days) 'D_Indicator'], ...
%                              'GAP_Indicator'};
%     
%     fprintf('Exporting specified indicators to Excel file %s...\n', full_output_excel_path);
%     try
%         T_results_excel = struct2table(results_for_excel);
%         
%         if width(T_results_excel) == length(desired_excel_headers)
%             T_results_excel.Properties.VariableNames = desired_excel_headers;
%         else
%             fprintf('Warning: Column count mismatch for Excel headers. Using default struct field names.\n');
%         end
% 
%         if exist(full_output_excel_path, 'file')
%             delete(full_output_excel_path);
%         end
%         writetable(T_results_excel, full_output_excel_path, 'Sheet', excel_sheet_name, 'WriteVariableNames', true);
%         fprintf('Excel file exported successfully.\n');
%     catch ME_excel
%         fprintf('Error exporting to Excel file %s: %s (%s)\n', full_output_excel_path, ME_excel.message, ME_excel.identifier);
%     end
%     
%     fprintf('--- Indicator Processing Finished ---\n');
  end

% ====== MODIFIED local_calculateMAIndicator ======
function [binaryIndicator, currentDaysAboveMA] = local_calculateMAIndicator(priceDataCell, maPeriod, requiredStreakLengthForIndicator)
% Calculates:
%   1. binaryIndicator: 1 if stock has been above maPeriod-day MA for AT LEAST 
%      requiredStreakLengthForIndicator consecutive days, up to and including the most recent day.
%   2. currentDaysAboveMA: The count of consecutive days the stock is *currently* above its MA.

    numStocks = length(priceDataCell);
    binaryIndicator = zeros(numStocks, 1);
    currentDaysAboveMA = zeros(numStocks, 1); 

    % fprintf('Calculating MA Indicators (streak >= %d days for binary; current days above MA) for %d stocks...\n', ...
    %     requiredStreakLengthForIndicator, numStocks); % Less verbose

    for i = 1:numStocks
        stockData = priceDataCell{i};
        binaryIndicator(i) = 0;
        currentDaysAboveMA(i) = 0; 

        if isempty(stockData) || size(stockData,2) < 2 || size(stockData,1) < maPeriod
            continue; 
        end
        prices = stockData(:, 2); 

        movingAvg = movmean(prices, [maPeriod-1, 0], 'omitnan', 'Endpoints', 'discard');
        validPrices = prices(maPeriod:end); 
            
        numComparablePoints = min(length(validPrices), length(movingAvg));
        
        if numComparablePoints < 1 
            continue; 
        end
        
        validPrices = validPrices(1:numComparablePoints);
        movingAvg = movingAvg(1:numComparablePoints);

        if isempty(validPrices) || isempty(movingAvg) 
            continue;
        end

        priceAboveMA_series = validPrices > movingAvg;
        
        countCurrentStreak = 0;
        if ~isempty(priceAboveMA_series) && priceAboveMA_series(end) == 1 % Only count if currently above
            for k = length(priceAboveMA_series):-1:1
                if priceAboveMA_series(k) == 1 
                    countCurrentStreak = countCurrentStreak + 1;
                else 
                    break; 
                end
            end
        end % if not currently above, countCurrentStreak remains 0
        currentDaysAboveMA(i) = countCurrentStreak;
        
        if countCurrentStreak >= requiredStreakLengthForIndicator
            binaryIndicator(i) = 1;
        end % else binaryIndicator(i) remains 0
    end
    % fprintf('MA Indicator calculation complete.\n'); % Less verbose
end

% ====== UNCHANGED local_calculateGapIndicator ======
function gapIndicatorResult = local_calculateGapIndicator(priceDataCell, gapPercentage, lookbackWindowDays)
% Calculates Gap UP indicator: 1 if stock opened >= gapPercentage UP
% from the previous close within the last lookbackWindowDays of the series.

    numStocks = length(priceDataCell);
    gapIndicatorResult = zeros(numStocks, 1);

    for i = 1:numStocks
        stockData = priceDataCell{i};
        gapIndicatorResult(i) = 0; % Default for current stock

        % Need Open (col 6), Close (col 2), and at least 2 data points
        if isempty(stockData) || size(stockData,2) < 6 || size(stockData,1) < 2
            continue;
        end
        
        closePrices = stockData(:, 2);
        openPrices  = stockData(:, 6);
        numDataPoints = length(openPrices); % Same as length(closePrices) due to previous check

        % Define the window to check for gaps: the last 'lookbackWindowDays'
        % The loop for checking gaps will go from day 2 to numDataPoints.
        % Gaps occur *on* these days, relative to the day before.
        startDayForCheckInWindow = max(2, numDataPoints - lookbackWindowDays + 1);
        
        stockHadQualifyingGapUp = false; % Flag for the current stock

        for d = startDayForCheckInWindow:numDataPoints 
            currentOpen = openPrices(d);
            previousClose = closePrices(d-1); % Close price of the day before currentOpen

            % Ensure previousClose is positive to avoid division by zero or nonsensical percentages
            % AND explicitly check for a gap UP (currentOpen > previousClose)
            if previousClose > 0 && currentOpen > previousClose
                gap = (currentOpen - previousClose) / previousClose;
                
                % Check if this UP gap meets the threshold
                if gap >= gapPercentage 
                    stockHadQualifyingGapUp = true;
                    break; % Found a qualifying gap up in the window for this stock
                end
            end
        end
        
        if stockHadQualifyingGapUp
            gapIndicatorResult(i) = 1;
        end
    end
    % fprintf('Gap UP Indicator calculation complete.\n'); % Optional verbose
end