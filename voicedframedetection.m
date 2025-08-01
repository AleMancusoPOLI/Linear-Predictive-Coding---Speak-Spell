function [voicedIdx, zc] = voicedframedetection(s,win,hopsize)
%% voicedframedetection(s,win,hopsize)
% Estimate if a frame is voiced or unvoiced based on zerocrossing rate.
% Arguments
%   - s
%   - win
%   - hopsize
%
% Outputs
%   - voicedIdx
%   - zc
%
% DAAP HW1 2025
% Mirco Pezzoli

winLen = length(win);
sLen = length(s);

% Total number of frames that we're going to analyze
nFrame = floor((sLen - winLen) / hopsize ) + 1;

% We initialize it as an array of zeros of length nFrame
% The estimation has to be done on each frame
voicedIdx = zeros(nFrame, 1);

% Inizialization of Zero Crossing same as voicedIdx
zc = voicedIdx;

for ii = 1:nFrame
    % We define an index axis to which constraint our signal
    % to match the window length
    % And then we mulptiply the cropped portion with our window
    fIdx = (ii-1) * hopsize + 1 : (ii-1) * hopsize + winLen;
    sn = s(fIdx).*win;

    % We evaluate the difference in sign, the function returns only 0,-1,+1
    % and then we assign it to the zc of this specific frame (zc can only
    % be positive)
    for j = 2:winLen
        temp(j-1) = abs(sign(sn(j))-sign(sn(j-1))); % > 0 if the signal has crosses
    end
    zc(ii)=sum(temp);
end

% Estimation of the Voiced/Unvoiced Index
for ii = 1:nFrame
    fIdx = (ii-1)*hopsize+1 : (ii-1)*hopsize+winLen;
    sn = s(fIdx).*win;
    if (zc(ii)>mean(zc))                      % Detecting Zero crossing
        voicedIdx(ii)=0;
    % This is done to check if the frame has a noisy behavior or 
    % has a really low energy
    elseif  (sum(sn(:).^2)<0.001)
        voicedIdx(ii) = 0;
    % If the conditions above are not met then we have a voiced frame
    else
        voicedIdx(ii)=1;
    end
end