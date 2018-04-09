function flowr = repairFlowData2(flow2, doPlot) 
%% Head
% pkg load signal

    N = length(flow2);
    X = 1:N;
    
    vol = cumsum(flow2);
    [p, s, mu] = polyfit(X, vol, 6);
    tt = polyval(p,X,[],mu);

    volr = vol - tt;

    flowr = [0, diff(volr)];

    % reconstructed volume - just for check
    rvol = cumsum(flowr);
    if (doPlot)
        figure; hold on;
        plot(X, vol, 'b')
        plot(X, tt, 'k')

        plot(X, flow2*50, 'b')
        plot(X, flowr*50, 'r')

        plot(X, rvol, 'm')
        legend('volume', 'vol_fit','flow','flowr','volr')
    endif;














