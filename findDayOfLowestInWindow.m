function dayNumber = findDayOfLowestInWindow(series, windowSize)
% findDayOfLowestInWindow Finds a low that is significant and recent.
%
% SYNTAX:
%   dayNumber = findDayOfLowestInWindow(series, windowSize)
%
% DESCRIPTION:
%   This function first identifies the lowest value within a longer "search
%   period" of (2 * windowSize). It then checks if this absolute low occurred
%   within the more recent "reporting period" of (windowSize).
%
%   If the low occurred within the recent period, its day number is returned
%   (1 = today, 2 = yesterday, etc.). If the low occurred in the older half
%   of the search period, the function returns 0.
%
%   This is useful for identifying lows that are both recent and significant
%   over a longer lookback.
%
% INPUTS:
%   series      - A numerical row or column vector.
%   windowSize  - A positive integer. The reporting period and half the search period.
%
% OUTPUT:
%   dayNumber   - An integer day number if the low is significant and recent.
%                 Returns 0 otherwise, or if the series is too short
%                 (length < 2 * windowSize), empty, or contains only NaNs.
%
% EXAMPLES:
%   % Low (5) is in the older period, so it's not reported.
%   s = [50, 60, 5, 30, 10, 20, 40, 15];
%   findDayOfLowestInWindow(s, 4)  % returns 0
%
%   % Low (10) is in the recent period (day 4), so it's reported.
%   s = [50, 60, 30, 40, 10, 20, 40, 15];
%   findDayOfLowestInWindow(s, 4)  % returns 4
%

% --- Input Validation & Setup ---
if nargin < 2 || ~isnumeric(windowSize) || ~isscalar(windowSize) || windowSize < 1
    error('windowSize must be a positive scalar integer.');
end

searchPeriodSize = 2 * windowSize;

% --- Edge Case: Series is too short or empty ---
if length(series) < searchPeriodSize
    dayNumber = 0;
    return;
end

% --- Core Logic ---
% 1. Define the search window (2x the windowSize).
startIndex = length(series) - searchPeriodSize + 1;
searchWindow = series(startIndex:end);

% 2. Handle a window containing only NaNs.
if all(isnan(searchWindow))
    dayNumber = 0;
    return;
end

% 3. Find the min value and its location within the 2x search window.
minValue = min(searchWindow, [], 'omitnan');
localIndex = find(searchWindow == minValue, 1, 'last');

% 4. Check if the low occurred in the recent half (the reporting period).
% The reporting period corresponds to indices > windowSize within the searchWindow.
if localIndex > windowSize
    % Convert the index to be relative to the reporting period (1x windowSize)
    reportingIndex = localIndex - windowSize;
    % Convert the relative index to a "day number"
    dayNumber = windowSize - reportingIndex + 1;
else
    % The low was in the older half of the search period, so ignore it.
    dayNumber = 0;
end

end