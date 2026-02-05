function dayNumber = findDayOfHighestInWindow(series, windowSize)
% findDayOfHighestInWindow Finds a high that is significant and recent.
%
% SYNTAX:
%   dayNumber = findDayOfHighestInWindow(series, windowSize)
%
% DESCRIPTION:
%   This function first identifies the highest value within a longer "search
%   period" of (2 * windowSize). It then checks if this absolute high occurred
%   within the more recent "reporting period" of (windowSize).
%
%   If the high occurred within the recent period, its day number is returned
%   (1 = today, 2 = yesterday, etc.). If the high occurred in the older half
%   of the search period, the function returns 0.
%
%   This is useful for identifying highs that are both recent and significant
%   over a longer lookback.
%
% INPUTS:
%   series      - A numerical row or column vector.
%   windowSize  - A positive integer. The reporting period and half the search period.
%
% OUTPUT:
%   dayNumber   - An integer day number if the high is significant and recent.
%                 Returns 0 otherwise, or if the series is too short
%                 (length < 2 * windowSize), empty, or contains only NaNs.
%
% EXAMPLES:
%   % High (100) is in the older period, so it's not reported.
%   s = [10, 20, 100, 30, 80, 70, 60, 50];
%   findDayOfHighestInWindow(s, 4)  % returns 0
%
%   % High (90) is in the recent period (day 4), so it's reported.
%   s = [10, 20, 30, 40, 90, 70, 60, 50];
%   findDayOfHighestInWindow(s, 4)  % returns 4
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

% 3. Find the max value and its location within the 2x search window.
maxValue = max(searchWindow, [], 'omitnan');
localIndex = find(searchWindow == maxValue, 1, 'last');

% 4. Check if the high occurred in the recent half (the reporting period).
% The reporting period corresponds to indices > windowSize within the searchWindow.
if localIndex > windowSize
    % Convert the index to be relative to the reporting period (1x windowSize)
    reportingIndex = localIndex - windowSize;
    % Convert the relative index to a "day number"
    dayNumber = windowSize - reportingIndex + 1;
else
    % The high was in the older half of the search period, so ignore it.
    dayNumber = 0;
end

end