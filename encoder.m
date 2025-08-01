function encoder(filename, doPlot, applyLPF)
%% LPC-encode
% Encodes the given audio file and saves in a .m file all parameters
% needed for the decoding.
% Arguments
%  - filename
%
% Outputs
%  - none, but a file is created to store all the values of interest:
%       - a: LPC coefficients
%       - gains, pitch, voicedIDx: to create of the excitation signal
%       - winLen, hopSize, Fs: to properly reconstruct the audio signal
%
% DAAP course 2025
% Mirco Pezzoli

close all

%% Define parameters
% Reading input audio signal
[s, fs] = audioread(filename);

% Impose a 8kHz sampling rate
Fs = 8000;

% If necessary, since we're imposing a specific sampling frequency
% it would be better to resample the signal. In this case the function
% y = resample(x, p, q) resamples at a frequency equals to p/q of the
% original sampling frequency
s = resample(s, Fs, fs);

% Convert the signal to mono by taking just one of ethe two channels
s = s(:,1);

% Normalize the signal with respect to peak value
s = s / max(abs(s));

% Apply a pre-emphasis filter as highpass filter
b = [1, -0.975];

% Pre-emphasis filtering using the filter function with
% given coefficients
s = filter(b,1,s);   

% To play the audio and check if it is alright we can use:
% soundsc(s, Fs);

% STFT Parameters
% suggested parameters 256-sample window length and hopsize,
% hamming window

% Following the above suggestions we define:
winLen = 256;
hopSize = 256;
win = hamming(winLen);
sLen = length(s);

% Number of frames that we're going to consider
nFrame = floor((sLen - winLen) / hopSize ) + 1;

% LPC-10 parameters

% LPC Order, 10 for voiced (pitched sounds) frames, 
% 4 for unvoiced ones

% Cell array to be adjusted with the right LPC order 
% during coefficient computation
a = cell(nFrame, 1); 

% Similar for the prediction error, in this case dimensions are different
eFrames = zeros(winLen, nFrame);

% Vector of gains for the excitement signals
gains = zeros(nFrame, 1);

% Vector for the values of the MSE
power = zeros(nFrame, 1);

% Vector of the pitch estimation parameters
pitch = zeros(nFrame, 1);

% Optionally low pass the prediction error with FIR filter with cut off at
% 800 Hz
cutoffHz = 800;   
firOrder = 10;    

% We used the fir1 function to build a lowpass (default option)
% with a normalized frequency with respect to Fs, the /2 is 
% required for the Matlab cutoff frequency syntax
b_filt = fir1(firOrder, cutoffHz/(Fs/2));

%% Estimate voiced frame
% Using the specific function we can estimate voiced frames from the audio;
% we can discard the zero crossing since we don't need it
[voicedIdx, ~] = voicedframedetection(s, win, hopSize);

%% Estimate LPC filters

for ii = 1:nFrame

    % Extract a frame from the signal (windowing it)
    idx = (1:winLen) + (ii-1)*hopSize;
    sn = s(idx) .* win;
    
     % Set LPC order for current frame
    if voicedIdx(ii) == 1
        orderLPC = 10;
    else
        orderLPC = 4;
    end

    % Compute autocorrelation
    [r, rlags] = xcorr(sn, 'biased');
    % Considering correlation only for positive lags, including the 0
    % Since it is a symmetric function
    rpos = r(rlags >= 0);
    
    % Compute the whitening filter parameters using the function levinson
    % (see doc levinson)

    % Using the Levinson-Durbin algorithm, as suggested, with the 
    % built-in Matlab function
    aTemp = levinson(rpos, orderLPC);
    
    % Alternative solution use lpc
    % a(ii, 1:orderLPC+1) = lpc(sn.*win, orderLPC);

    % Avoid NaNs & Compute the prediction error using filter

    % We do so with a simple if clause, putting the row to 
    % zero if we get a NaN (except for the first coefficient)
    if isempty(aTemp) || length(aTemp) ~= orderLPC + 1 || any(isnan(aTemp))
        a{ii} = [1, zeros(1, orderLPC)];
    else
        a{ii} = aTemp;
    end
    
    % Compute the prediction error
    e = filter(a{ii}, 1, sn);

    % We assign the frame to the specific column
    eFrames(:,ii) = e;
   
    % Compute MSE for the frame
    power(ii) = mean(e.^2);

    % Plot the Magnitude of the signal spectrum, and on the same graph, the
    % the LPC spectrum estimation (remember the definition of |E(omega)|)
    if doPlot
        
        N = 256;
        % Compute the shaping filter H using freqz function
        [H, w] = freqz(1, a{ii}, N, Fs);
        
        % Frequency axis,
        % we take the one provided by the freqz function
        % to plot everything
        
        % Compute the DFT of the original signal

        % FFT of the signal
        S = fft(sn, N);
        
        figure(1), clf
        subplot(4,1,1)

        % Plot of the FFT of the original signal
        plot(w, db(abs(S)), 'b');
        hold on;
        % Spectral matching of the filter
        plot(w, db(abs(H)), 'r');
        title('Original spectrum (blue) vs LPC estimate (red)');
        xlabel('Frequency [Hz]');
        ylabel('Magnitude [dB]');
        hold off

        subplot(4,1,2), hold on
       
        % Plot prediction error (time domain)
        % Of course we have to define a suitable time axis
        t = (0:winLen-1) / Fs * 1000;
        plot(t, e)
        xlabel('Time [ms]');
        title('Prediction error (time domain)');

        % Plot the prediction error magnitude spectrum
        E = fft(e, N);                      
        subplot(4,1,3)
        plot(w, db(abs(E)))
        % Plot prediction error (frequency domain)
        title ('Prediction error spectrum');
        xlabel('Frequency [Hz]');
        ylabel('Magnitude [dB]');
  
    end

    % Pitch estimation for voiced signals
    if voicedIdx(ii) == 1

        % Optionally low pass the error

        % If the doFilter value is true we lowpass the prediction error
        if applyLPF
             e = filter(b_filt, 1, e);
             % Plot the predition error e in time
             if doPlot
                 subplot(4,1,4)
                 plot(t, e)
                 xlabel('Time [ms]');
                 title('Filtered Prediction error (time domain)');
             end
        end
        pitch(ii) = pitchdetectionamdf(e);
    end

    % Computing gains

    if voicedIdx(ii) == 1
        % Compute the gain for a pitched sound
        lim = floor(winLen./pitch(ii)).*pitch(ii);
        %{
        % Additional check could be:
        if lim ~= 0
            power(ii) = 0;
            gain(ii) = 0;
        % Followed by else to
        % avoid dividing by zero in the next lines
        %}
        power(ii) = (1/lim).*(e(1:lim)'*e(1:lim));
        gains(ii) = sqrt(power(ii)*pitch(ii));
    else
        % Compute the gain for unvoiced sounds
        power(ii) = mean(e.^2);
        gains(ii) = sqrt(power(ii));    
    end
end

%% Save encoded data
% Extracting the file name without path and extension
[~, nameTrimmed, ~] = fileparts(filename);
% Saving and checking if the folder exists
if not(isfolder("encoded"))
    mkdir("encoded");
end
save(sprintf('encoded/%s_encoded.mat', nameTrimmed), 'a', 'gains', 'pitch', 'voicedIdx', 'winLen', 'hopSize', 'Fs');
