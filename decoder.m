function decoder(encodedFilename)
%% LPC decoder
% Decodes an audio signal that was previously encoded through LPC.
% Arguments
% - name of the .m file created by the encoder
%
% Outputs
% - none, but the function plays the decoded version of the encoded audio

close all

%% Load the encoded data
load(encodedFilename, 'a', 'gains', 'pitch', 'voicedIdx', 'winLen', 'hopSize', 'Fs')

% Generating the excitation signal
excite = generateexcitationsignal(voicedIdx, gains, pitch, winLen);

% Initializing the reconstructed signal
nFrames = length(voicedIdx);
lenExcite = nFrames * hopSize + winLen;
sRec = zeros(lenExcite, 1);

% Reconstructing the signal through Overlap and Add framework
for ii = 1:nFrames

    idx = (1:winLen) + (ii-1)*hopSize;
    exciteFrame = excite(idx);
   
    sFrame = filter(1, a{ii}, exciteFrame);
   
    sRec(idx) = sRec(idx) + sFrame;
end

% Apply de-emphasis filter
b = abs([1, -0.975]);
sRec = filter(b, 1, sRec);

% Play a normalized version of the reconstructed signal
soundsc(sRec, Fs);