function flowr = adjustVolumeTrend(flow2, doPlot) 
% repairs the volume drift from the flow signal

%% Head
% pkg load signal
%low-pass filter design:
    N = length(flow2);
    X = (1:N)';
    vol = cumsum(flow2);


    order = 5;
    cutoff = 0.008;
    [b,a] = butter(order, cutoff);
    tt = filter(b,a,vol);
 %   tt2 = sgolayfilt(vol,4, 311);
   
   % manually estimated shift
   ls = 126;
   tts = tt;
   tts(1:end - ls) = tt(1+ls:end);

    volr = vol - tts;

    flowr = [0; diff(volr)];

    % reconstructed volume - just for check
    
    if (doPlot)
        figure(102); 
        clf;hold on;
        plot(X, vol, 'b')
        plot(X, tts, 'k', 'linewidth', 2)

        plot(X, flow2*50, 'b')
        plot(X, flowr*50, 'r')

        rvol = cumsum(flowr);
        plot(X, rvol, 'g')
        legend('volume', 'vol_fit','flow*50','flowr*50','volr')
        title('Volume drift correction');
    end;
    
%%% get spectrum
%%    volf = vol(7000:17000);
%    volf = volr(7000:17000);
%    Fs = 100;
%    L = length(volf);
%    Y = fft(volf);
%    P2 = abs(Y/L);
%    P1 = P2(1:L/2+1);
%    P1(2:end-1) = 2*P1(2:end-1);
%    f = Fs*(0:(L/2))/L;
%%    figure;
%%    clf; hold on;
%    plot(f,P1)     
%    title('Single-Sided Amplitude Spectrum of X(t)')
%xlabel('f (Hz)')
%ylabel('|P1(f)|')