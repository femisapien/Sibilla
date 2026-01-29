function out=INDICATORS(update,join,indicators,ipath,sectype,sold,eold,snew,enew,listname,updq,type, ...
    ma_p, ma_consecutive, gap_pct, gap_lookback, db_path, f1, f2)


ifile=sprintf('-START%s-END',sold);
% if isempty(strfind(sectype,'ROtherSecs'))~=1,ifile='-START01-Jan-2008-END';else,ifile='-START01-Jan-2008-END';end
ifile=strcat(sectype,ifile);
upto=enew;
if isempty(strfind(sectype,'Stocks'))~=1,fix=1;else fix=0;end
seclistpath=strcat(ipath,'lists/');
seclistpath=strcat(seclistpath,listname);
savepath=strcat(ipath,sectype);


%% UPDATE
if update==1&&join==0
fields={'PX_LAST','PX_VOLUME','PX_HIGH','PX_LOW','PX_OPEN'};
period={'daily','calendar'};
sdate=sold;
edate=enew;
out=xRDD(sdate,edate,fields,period,listname,type,sectype)
% out=xRDD(sdate,edate,fields,period,listname,type)

elseif update==1&&join==1
fields={'PX_LAST','PX_VOLUME','PX_HIGH','PX_LOW','PX_OPEN'};
period={'daily','calendar'};
sdate=snew;
edate=enew;

out=xRDD(sdate,edate,fields,period,listname,type,sectype)
% out=xRDD(sdate,edate,fields,period,listname,type)
else
     disp('UPDATE not selected')
end

%% JOIN
if join==1
if updq==1
out=AJ(sectype,sold,eold,snew,enew,fix);
disp('Database Update: Done!')

else
disp('No Database Update Required')
end
else
     disp('JOIN not selected')
end


%% CALCULATE MA 31D AND GAP INDICATORS
oStruct=xCALC_IND(ma_p, ma_consecutive, gap_pct, gap_lookback, db_path, sectype, f1, sold, f2, enew);

disp('MA 31D and GAP Indicators: Done')

%% LOAD DATA
input_filename_stem = sprintf('%s%s%s%s%s', sectype, f1, sold, f2, enew);
full_input_mat_path = fullfile(db_path, [input_filename_stem, '.mat']);
output_filename_stem = sprintf('%s%s', 'indicators', sectype);
full_output_mat_path = fullfile(db_path, [output_filename_stem, '.mat']);

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

    disp('Data loaded')

%% CALCULATE RETRACEMENT INDICATOR

[L_DROP, ~]=xRSIreport(BBGDATA);

disp('RETRACEMENT Indicator: Done')

%% CALCULATE BREAKOUT 260 DAYS INDICATOR
upto=enew;
D_BREAKS=[BreaksReport2(BBGDATA,360) BreaksReport2(BBGDATA,120)];


D_BREAKS(:,[2 4 6 8])=[];
breakpoints=double(ismember(D_BREAKS,[(datenum(upto)-693960)-4,datenum(upto-693960)]));

disp('Breakout Indicator: Done')

%% CALCULATE BREAKOUT 260 DAYS INDICATOR RELATIVE TO SPX
for i=1:size(BBGDATA,2)
    spx=BBGDATA{1,1};
    temp=BBGDATA{1,i};
    [dlist, indp, tempp]=intersect(spx(:,1),temp(:,1));%equalizes dates with index, since difference is required
    temp=temp(tempp,:);%load security data in common dates
    spx=spx(indp,:);%the same for index data
    BBGDATAr{1,i}=[dlist temp(:,2:end)./spx(:,2:end)];
    
    disp(i)
end
clear i spx temp tempp

N_BREAKSr=[BreaksReport2(BBGDATAr,360) BreaksReport2(BBGDATAr,120)];

N_BREAKSr(:,[2 4 6 8])=[];
breakpoints=double(ismember(N_BREAKSr,[(datenum(upto)-693960)-4,datenum(upto-693960)]));

disp('Breakout Indicator Relative to SPX: Done')

%% SAVE TO .mat FILE

% This will include the 6 indicators.
fprintf('Saving indicators to %s...\n', full_output_mat_path);
try
    OutputStruct = struct();
    OutputStruct.Days_Above_MA = oStruct.Days_Above_MA;
    OutputStruct.MA_Indicator = oStruct.MA_Indicator;
    OutputStruct.GAP_Indicator = oStruct.GAP_Indicator;
    OutputStruct.Retracement = L_DROP(:,2);
    OutputStruct.Breakout = D_BREAKS(:,1);
    OutputStruct.BreakoutSPX = N_BREAKSr(:,1);

    save(full_output_mat_path, '-struct', 'OutputStruct');
    fprintf('.mat file saved successfully.\n');
catch ME_save
    fprintf('Error saving output MAT file %s: %s\n', full_output_mat_path, ME_save.message);
end


%% WRITE TO EXCEL (Corrected)

% --- 1. Data Collection & Normalization ---
% Collect all indicator data into a cell array to easily manage them.
% This makes it simpler to loop through and check properties like size.
indicator_data = {
    oStruct.Days_Above_MA, ...
    oStruct.MA_Indicator, ...
    oStruct.GAP_Indicator, ...
    L_DROP(:,2), ...
    D_BREAKS(:,1), ...
    N_BREAKSr(:,1)
};

% Ensure all data arrays are column vectors for consistency.
for k = 1:length(indicator_data)
    if isrow(indicator_data{k})
        indicator_data{k} = indicator_data{k}'; % Transpose if it's a row vector
    end
end

% --- 2. Create a Uniform Matrix by Padding ---
% Determine the maximum number of rows from all indicator arrays.
% This will be the size of our final table.
max_rows = 0;
for k = 1:length(indicator_data)
    max_rows = max(max_rows, size(indicator_data{k}, 1));
end

% Create a matrix filled with NaN of the required size (max_rows x num_indicators).
% NaN is a standard placeholder for missing data in MATLAB.
padded_matrix = NaN(max_rows, numel(indicator_data));

% Populate the matrix. Shorter vectors will be padded with NaNs at the end.
for k = 1:length(indicator_data)
    current_vector = indicator_data{k};
    padded_matrix(1:size(current_vector, 1), k) = current_vector;
end

% --- 3. Table Creation and Header Assignment ---
% Define the headers for the Excel file.
desired_excel_headers = {['Number_Days_Above_' num2str(ma_p) 'D_MA'], ...
                         ['MA_' num2str(ma_p) 'D_Indicator'], ...
                         'GAP_Indicator', ...
                         'Retracement_Indicator', ...
                         'Breakout', ...
                         'Breakout_SPX'};

% Convert the padded numeric matrix directly to a table.
T_results_excel = array2table(padded_matrix, 'VariableNames', desired_excel_headers);

% (Optional but Recommended) Add StockNames as the first column for context.
if ~isempty(StockNames_loaded)
    % Create a cell array for stock names padded with empty cells if needed.
    padded_stock_names = cell(max_rows, 1);
    num_stocks = size(StockNames_loaded, 1);
    padded_stock_names(1:num_stocks) = StockNames_loaded;
    
    % Add the padded stock names as the first variable (column) in the table.
    T_results_excel = addvars(T_results_excel, padded_stock_names, 'Before', 1, 'NewVariableNames', 'Ticker');
else
    fprintf('Warning: StockNames_loaded is empty. Not adding Ticker column.\n');
end

% --- 4. File Path and Directory Setup ---
excel_export_base_folder = 'C:\101510\'; % Define base output folder
output_filename_stem = sprintf('%s%s', 'indicators', sectype);
full_output_excel_path = fullfile(excel_export_base_folder, [output_filename_stem, '.xlsx']);
excel_sheet_name = 'indicators';

% Create the output directory if it doesn't exist.
if ~exist(excel_export_base_folder, 'dir')
    try
        mkdir(excel_export_base_folder);
    catch ME_mkdir
        fprintf('FATAL ERROR: Could not create directory %s: %s\n', excel_export_base_folder, ME_mkdir.message);
        return;
    end
end

% --- 5. Export the Table to Excel ---
fprintf('Exporting indicators to Excel file: %s\n', full_output_excel_path);
try
    % Delete the old file to ensure a clean write.
    if exist(full_output_excel_path, 'file')
        delete(full_output_excel_path);
    end

    % Write the final table to the Excel file.
    writetable(T_results_excel, full_output_excel_path, 'Sheet', excel_sheet_name, 'WriteVariableNames', true);
    fprintf('Excel file exported successfully. ?\n');
catch ME_excel
    fprintf('Error exporting to Excel file %s: %s (%s)\n', full_output_excel_path, ME_excel.message, ME_excel.identifier);
end

fprintf('--- Indicator Processing Finished ---\n');

out='Done!';