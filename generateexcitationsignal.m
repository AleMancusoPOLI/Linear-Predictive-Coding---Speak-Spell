function excite = generateexcitationsignal(voicedIdx, gains, pitch, winLen)
% generateexcitationsignal(voicedIdx, gains, pitch, winLen)
% This function generates the excitation signal for LPC-10 coding that
% depends on voiced (train of pulses) or unvoiced (random noise) signals
% Arguments:
%   - voicedIdx
%   - gains
%   - pitch
%   - winLen
%
% Outputs
%   - excite
%
% DAAP HW1 2025
% Mirco Pezzoli

% Starting from voicedIdx length we can 
% establish the number of frames to visit
nFrames = length(voicedIdx);

% We create an excitation signal starting 
% from a vector of zeros of lenght nFrames * winLen 
excite = zeros(nFrames * winLen, 1);

% Iterating on all Frames
for i = 1:nFrames
    % Start and stop indexes for each iteration
    startIdx = (i-1) * winLen + 1;
    endIdx = startIdx + winLen - 1;
    
    % If the frame is Voiced
    if voicedIdx(i) == 1  
        % Retrieving the information on pitch, from the pitch array
        T = pitch(i);
        % Defining a train of pulses, each one spaced by T samples
        pulseTrain = zeros(winLen, 1);
        pulseIdx = 1:T:winLen;
        pulseTrain(pulseIdx) = 1;
        % Scaling everything by the gain factor according to theory
        excite(startIdx:endIdx) = gains(i) * pulseTrain;
    else  % If the frame is Unvoiced 
        % White gaussian noise
        excite(startIdx:endIdx) = gains(i) * (randn(winLen, 1));
    end
end

end