% Processing the google speech commands dataset.
%
%   This script concatenate ten digists audio files, computing the
%   mel frequency cepstral coefficients (MFCCs) from a speech signal
%   using the MFCC routine.
%
%   See also MFCC, COMPARE.

%   Author: Tung Doan, Feb 26 2021


    % Clean-up MATLAB's environment
    clear all; close all; clc;  

    % Read ten files
    digit = {'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'};
    audio = [];
    for i=1:length(digit)
        wav_file = strcat('./sound/google/',digit{i},'.wav');
        [signal, fs] = audioread(wav_file);
        audio = [audio; signal];
    end    
    
    % Define variables
    Tw = 25;                % analysis frame duration (ms)
    Ts = 10;                % analysis frame shift (ms)
    alpha = 0.97;           % preemphasis coefficient
    M = 20;                 % number of filterbank channels 
    C = 12;                 % number of cepstral coefficients
    L = 22;                 % cepstral sine lifter parameter
    LF = 300;               % lower frequency limit (Hz)
    HF = 3700;              % upper frequency limit (Hz)


    % Feature extraction (feature vectors as columns)
    [ MFCCs, FBEs, frames ] = ...
                    mfcc( audio, fs, Tw, Ts, alpha, @hamming, [LF HF], M, C+1, L );


    % Generate data needed for plotting 
    [ Nw, NF ] = size( frames );                % frame length and number of frames
    time_frames = [0:NF-1]*Ts*0.001+0.5*Nw/fs;  % time vector (s) for frames 
    time = [ 0:length(audio)-1 ]/fs;           % time vector (s) for signal samples 
    logFBEs = 20*log10( FBEs );                 % compute log FBEs for plotting
    logFBEs_floor = max(logFBEs(:))-50;         % get logFBE floor 50 dB below max
    logFBEs( logFBEs<logFBEs_floor ) = logFBEs_floor; % limit logFBE dynamic range


    % Generate plots
    figure('Position', [30 30 800 600], 'PaperPositionMode', 'auto', ... 
              'color', 'w', 'PaperOrientation', 'landscape', 'Visible', 'on' ); 

    subplot( 311 );
    plot( time, audio, 'k' );
    xlim( [ min(time_frames) max(time_frames) ] );
    xlabel( 'Time (s)' ); 
    ylabel( 'Amplitude' ); 
    title( 'audio waveform'); 

    subplot( 312 );
    imagesc( time_frames, [1:M], logFBEs ); 
    axis( 'xy' );
    xlim( [ min(time_frames) max(time_frames) ] );
    xlabel( 'Time (s)' ); 
    ylabel( 'Channel index' ); 
    title( 'Log (mel) filterbank energies'); 

    subplot( 313 );
    imagesc( time_frames, [1:C], MFCCs(2:end,:) ); % HTK's TARGETKIND: MFCC
    %imagesc( time_frames, [1:C+1], MFCCs );       % HTK's TARGETKIND: MFCC_0
    axis( 'xy' );
    xlim( [ min(time_frames) max(time_frames) ] );
    xlabel( 'Time (s)' ); 
    ylabel( 'Cepstrum index' );
    title( 'Mel frequency cepstrum' );

    % Set color map to grayscale
    colormap( 1-colormap('gray') ); 

    % Print figure to pdf and png files
    print('-dpdf', sprintf('%s.pdf', mfilename)); 
    print('-dpng', sprintf('%s.png', mfilename)); 

    save('digist.mat','audio','logFBEs','MFCCs','time_frames','time','M','C');
% EOF