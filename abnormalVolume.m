function [obsDate, obsValue] = abnormalVolume(dates, series)
% findBreakoutCandidate Identifies the date of a recent breakout observation.
%
% SYNTAX:
%   [obsDate, obsValue] = findBreakoutCandidate(dates, series)
%
% DESCRIPTION:
%   This function checks if any of the last 10 observations of a time series
%   is greater than or equal to 2.5 times the 50-period simple moving average.
%   If multiple observations meet this criterion, the one with the highest
%   value is selected.
%
%   The function is robust to short series and missing data (NaNs). It will
%   only perform the calculation if the series contains at least 15 valid
%   (non-NaN) data points.
%
% INPUTS:
%   dates  - A vector of dates corresponding to the series data. Can be
%            MATLAB datetime objects or numeric serial dates (Excel format).
%   series - A numerical row or column vector (double).
%
% OUTPUTS:
%   obsDate  - The date of the identified observation in numeric format
%              (serial date number, compatible with Excel). Returns 0 if
%              no observation qualifies.
%   obsValue - The value of the identified observation. Returns 0 if none
%              qualifies.
%
% MATLAB Version: R2018b compatible
%

% --- 1. Define Parameters & Validate Inputs ---
LOOKBACK = 10;
MA_PERIOD = 50;
MULTIPLIER = 2.5;
MIN_VALID_POINTS = 15;

% Critical: Ensure date and series vectors match in size.
if numel(dates) ~= numel(series)
    error('Input vectors ''dates'' and ''series'' must have the same number of elements.');
end

% A single, robust check for both series length and missing data.
if sum(~isnan(series)) < MIN_VALID_POINTS
    obsDate = 0;
    obsValue = 0;
    return;
end

% Ensure dates are in numeric format for Excel compatibility.
if isdatetime(dates)
    dates = datenum(dates);
end

% --- 2. Calculate Threshold ---
% Calculate the 50-period moving average. The indexing is robust; it
% automatically handles series with fewer than 50 points.
ma_window = series(max(1, end - MA_PERIOD + 1):end);
ma_val = mean(ma_window, 'omitnan');
threshold = ma_val * MULTIPLIER;

% --- 3. Find Candidate Observations ---
% Isolate the last 10 observations, again using robust indexing.
lookback_start_idx = max(1, length(series) - LOOKBACK + 1);
lookback_window = series(lookback_start_idx:end);

% Find indices *within the lookback window* that meet the criterion.
candidate_local_indices = find(lookback_window >= threshold);

% --- 4. Identify the Winner ---
if isempty(candidate_local_indices)
    % No observation met the criteria.
    obsDate = 0;
    obsValue = 0;
else
    % If there are multiple candidates, find the one with the max value.
    candidate_values = lookback_window(candidate_local_indices);
    [obsValue, idx_in_candidates] = max(candidate_values);
    
    % Get the winner's index relative to the lookback window...
    winner_local_idx = candidate_local_indices(idx_in_candidates);
    
    % ...convert it to the absolute index in the original series...
    obsIndex = lookback_start_idx + winner_local_idx - 1;
    
    % ...and find the corresponding date, then convert to Excel format.
    matlabDateNum = dates(obsIndex);
    
    % Convert MATLAB serial date to Excel serial date by adjusting the epoch.
    % Excel's epoch is 1-Jan-1900, but it incorrectly treats 1900 as a leap year.
    % The correct offset for modern dates is 693960.
    obsDate = matlabDateNum - 693960;
end

end

