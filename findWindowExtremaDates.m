function [dateOfHigh, dateOfLow] = findWindowExtremaDates(dates, highPrices, lowPrices, w)
%findWindowExtremaDates Finds the dates of the highest high and lowest low in a trailing window.
%
%   SYNTAX:
%   [dateOfHigh, dateOfLow] = findWindowExtremaDates(dates, highPrices, lowPrices, w)
%
%   DESCRIPTION:
%   This function analyzes the data corresponding to a window of 'w'
%   *calendar days* ending on the last date in the 'dates' vector.
%   It finds the maximum value within the 'highPrices' series and the minimum
%   value within the 'lowPrices' series over that date-based window.
%   It then returns the corresponding dates for these extrema, converted to
%   Excel's date serial number format.
%
%   This function correctly handles time series with gaps (e.g., weekends,
%   holidays).
%
%   INPUTS:
%   dates       - A column vector of dates in MATLAB's serial date format (double).
%                 This vector *must* be sorted in ascending order.
%   highPrices  - A column vector of high prices (double).
%   lowPrices   - A column vector of low prices (double).
%   w           - The lookback window size in *calendar days* (integer).
%
%   OUTPUTS:
%   dateOfHigh  - The date of the highest high in the window, as an Excel
%                 date number. Returns 0 on error.
%   dateOfLow   - The date of the lowest low in the window, as an Excel
%                 date number. Returns 0 on error.
%
%   EXAMPLE:
%   % Generate sample data for 100 trading days (approx 140 calendar days)
%   allDates = (today-139:today)';
%   % Remove weekends (days 1 and 7)
%   isWeekend = (weekday(allDates) == 1 | weekday(allDates) == 7);
%   tradeDates = allDates(~isWeekend);
%   n = length(tradeDates); % n will be approx 100
%   highs = 100 + cumsum(randn(n, 1)) + 5*sin((1:n)'/10);
%   lows = highs - (1 + rand(n, 1)*2);
%
%   % Find the high and low dates over the last 60 *calendar days*
%   [excelDateH, excelDateL] = findWindowExtremaDates(tradeDates, highs, lows, 60);
%   fprintf('Excel date of high: %f\n', excelDateH);
%   fprintf('Excel date of low: %f\n', excelDateL);
%
%   % Convert back to see the dates in MATLAB
%   disp(['Date of High: ', datestr(excelDateH + 693960)])
%   disp(['Date of Low:  ', datestr(excelDateL + 693960)])

%% 1. Input Validation and Error Handling

% Ensure the function returns 0 in case of an error
dateOfHigh = 0;
dateOfLow = 0;

n = length(dates);

% Error Case 1: Not enough data
if n == 0
    warning('Input time series are empty.');
    return;
end

% Error Case 2: Time series length is shorter than the window
% This is just a basic check; the real check is if data exists in the window.
if n < w && w > 0
    % This is not a fatal error if the data spans w days, but good to check.
    % We let the date-based logic handle it.
end

% Check for consistent vector lengths
if n ~= length(highPrices) || n ~= length(lowPrices)
    warning('Input vectors (dates, highPrices, lowPrices) must be of the same length.');
    return;
end

% NEW: Check if dates are sorted (critical for this logic)
if any(diff(dates) < 0) % Allow diff == 0 for same-day entries, but < 0 is a problem
    warning('Input ''dates'' vector is not monotonically increasing. Results may be incorrect.');
    return;
end


%% 2. Define Window Based on *Calendar Days* and Check for NaNs

% --- MODIFIED LOGIC ---
% The window is defined by *calendar days*, not element count.
endDate = dates(n);
startDate = endDate - w + 1; % w=1 means just endDate. w=2 means endDate and endDate-1.

% Find the indices of the dates that fall within this calendar window.
% This correctly handles gaps like weekends/holidays.
windowIndices = find(dates >= startDate & dates <= endDate);

% Error Case 3: No data in the window.
% This can happen if w is small and there are large gaps in the data.
if isempty(windowIndices)
    warning('No data found in the specified date window (from %s to %s).', datestr(startDate), datestr(endDate));
    return; % Exit function, returning [0, 0]
end
% --- END MODIFIED LOGIC ---


% Extract the data for this specific window
windowDates = dates(windowIndices);
windowHighs = highPrices(windowIndices);
windowLows = lowPrices(windowIndices);

% Error Case 4: NaNs are present in the relevant data window
if any(isnan(windowDates)) || any(isnan(windowHighs)) || any(isnan(windowLows))
    warning('NaN values detected within the lookback window (from %s to %s).', datestr(startDate), datestr(endDate));
    return; % Exit function, returning [0, 0]
end

%% 3. Core Logic: Find Extrema

% Find the index of the maximum high in the window.
% The first output of max/min is the value, the second is the index.
% We use '~' to ignore the value, as we only need the index.
[~, idxMax] = max(windowHighs);

% Find the index of the minimum low in the window.
[~, idxMin] = min(windowLows);

% Note: If multiple identical max/min values exist, MATLAB's max/min
% functions return the index of the *first* occurrence found in the window.

%% 4. Retrieve Dates and Convert to Excel Format

% Get the MATLAB date number using the index found in the previous step
matlabDateHigh = windowDates(idxMax);
matlabDateLow = windowDates(idxMin);

% Convert from MATLAB date number to Excel date number.
% Excel's date system starts on 1-Jan-1900 (and incorrectly assumes
% 1900 was a leap year), while MATLAB's starts on 0-Jan-0000.
% The offset is 693960.
excel_date_offset = 693960; % datenum('30-Dec-1899')

dateOfHigh = matlabDateHigh - excel_date_offset;
dateOfLow = matlabDateLow - excel_date_offset;

end
