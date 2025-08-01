function pitch = pitchdetectionamdf(e)
%pitchdetectionamdf
% This function find the pitch of a frame, using the Average Magnitude
% Difference Function AMDF.
% Arguments
%   - e
%
% Output
%   - pitch
%
% Based on AMDF see https://www.researchgate.net/publication/
% 228854783_Pitch_detection_algorithm_autocorrelation_method_and_AMDF
%
% DAAP HW1 2025
% Mirco Pezzoli

% Starting from a frame we extract some useful 
% parameters such as the window length (length of the frame),
% the number of lags and initialize the amd vector

winLen = length(e);
len = length(e);
lags = winLen;
amd = zeros(1,lags);
e = [e; zeros(lags,1)];

% Implementing the equation (6) as explained in the given paper
for k=1:lags
    % Delaying e of k-1 samples and memorizing it in an auxiliary variable
    % We start from 0 to lags-1 according to the paper
    e_shifted = circshift(e, k-1);
    for j=1:len
        % At each iteration we change the sample "n" and sum the partial result
        amd(k) = amd(k) + abs(e(j) - e_shifted(j));
    end
    % Then normalize the result dividing by the length of the frame 
    % for each lag "m"
    amd(k) = (1/len) * amd(k);
end
% In the end we estimate the pitch vector as the one containing 
% all the minimum in the amd function in a restricted range
pitch = find(amd == min(amd(25:80)));
end


