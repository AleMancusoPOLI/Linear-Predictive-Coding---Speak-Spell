%% DAAP course 2025 - Homework 1: LPC-based Speak and Spell
% Implement the LPC10 speech encoding used in 1978 Speak and Spell toy by
% Texas Instruments. The TMC0280 chip used to synthesize speech using LPC.
% 
% DAAP HW1 2025
% Mirco Pezzoli
clc
clearvars
close all

%% Choose audio source and encode/decode them
while true
    % Acquiring User Input
    userInput = lower(input('Type 1 to play with letters, 2 to play recordings, "." to exit: ', 's'));

    % Checking exit condition
    if strcmp(userInput, '.')
        disp('Exiting program.');
        break;
    end

    % Validating the input
    if isempty(userInput) || ~ischar(userInput) || length(userInput) ~= 1 || ~ismember(userInput, {'1', '2', '.'})
        disp('Invalid input. Type 1 for playing with letters, 2 for recordings, "." to exit.');
        continue;
    end

    if userInput == '1'
        
        while true
            % Acquiring User input
            userInput = lower(input('Type a word made of max 16 letters [a-z] (a single letter is preferred) or "." to go back: ', 's'));
            inputLen = length(userInput);

            % Check exit condition
            if strcmp(userInput, '.')
                disp('Going back to main.');
                break;
            end
        
            % Validating the input
            if isempty(userInput) || inputLen > 16
                disp('Invalid input. Type a word made of max 16 letters [a-z] or "." to exit');
                continue;
            end
            for i = 1:inputLen
                if ~ismember(userInput(i), 'a':'z')
                    disp('Invalid input. Type a word made of max 16 letters [a-z] or "." to exit');
                    continue;
                end
            end

            % Asking if the user wants to plot results
            plotInput = lower(input('Do you want to plot the results? [y/n]: ', 's'));
            while ~ismember(plotInput, {'y', 'n'})
                plotInput = lower(input('Invalid input. Please type "y" for yes or "n" for no: ', 's'));
            end
            if strcmp(plotInput, 'y')
                doPlot = true;
            else
                doPlot = false;
            end
        
            % Asking if the user wants to lowpass the prediction error or not
            lowpassInput = lower(input('Do you want to lowpass the prediction error? [y/n]: ', 's'));
            while ~ismember(lowpassInput, {'y', 'n'})
                lowpassInput = lower(input('Invalid input. Please type "y" for yes or "n" for no: ', 's'));
            end
            if strcmp(lowpassInput, 'y')
                applyLPF = true;
            else
                applyLPF = false;
            end
                        
            encodedFilenameList = strings(inputLen,1);
            for i = 1:inputLen
                encodedFilenameList(i) = append("encoded/", userInput(i), "_encoded.mat");
                if ~isfile(encodedFilenameList(i))
                    filename = "input/" + userInput(i) + ".mp3";
                    if ~isfile(filename)
                        fprintf('File %s not found.\n', filename);
                        continue;
                    end

                    % Encoding stage if necessary
                    encoder(filename,doPlot,applyLPF);
                end
            end
                   
            for i = 1:inputLen
                decoder(encodedFilenameList(i));
                pause(0.7);
            end
    
        end
    else
        while true
            % Acquiring User input
            userInput = input('Type a the name of a recording or "." to exit: ', 's');

            % Check exit condition
            if strcmp(userInput, '.')
                disp('Going back to main.');
                break;
            end
        
            % Validating the input
            if isempty(userInput) || ~ischar(userInput) || ~ismember(userInput, {'ces', 'Invo', 'alphabet'})
                disp('Invalid input. Type "ces", "Invo", or "alphabet", or "." to exit.');
                continue;
            end

            % Asking if the user wants to plot results
            plotInput = lower(input('Do you want to plot the results? [y/n]: ', 's'));
            while ~ismember(plotInput, {'y', 'n'})
                plotInput = lower(input('Invalid input. Please type "y" for yes or "n" for no: ', 's'));
            end
            if strcmp(plotInput, 'y')
                doPlot = true;
            else
                doPlot = false;
            end
        
            % Asking if the user wants to lowpass the prediction error or not
            lowpassInput = lower(input('Do you want to lowpass the prediction error? [y/n]: ', 's'));
            while ~ismember(lowpassInput, {'y', 'n'})
                lowpassInput = lower(input('Invalid input. Please type "y" for yes or "n" for no: ', 's'));
            end
            if strcmp(lowpassInput, 'y')
                applyLPF = true;
            else
                applyLPF = false;
            end
        
            % Loading the audio path
            encodedFilename = "encoded/" + userInput + "_encoded.mat";
            if ~isfile(encodedFilename)
                filename = "input/" + userInput + ".mp3";
                if ~isfile(filename)
                    filename = "input/" + userInput + ".wav";
                    if ~isfile(filename)
                        fprintf('File %s not found.\n', filename);
                        continue;
                    end
                end
                % Encoding stage if necessary
                disp("Encoding...")
                encoder(filename, doPlot, applyLPF);
            end            
            
            % Decoding stage
            decoder(encodedFilename);
    
        end
    end
end

