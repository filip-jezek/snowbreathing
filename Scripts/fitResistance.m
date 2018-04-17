
%% fit PQ resistance
figure;
clf; hold on;
plot(X, flowr, 'r');
plot(X, pressr*10, 'b')
% plot(co2*10, 'k')


% 8S2000
%rng = {1900:2222, 5900:6290, 7200:7600, 11640:11960};

% 11m2000
% rng = {7400:7800, 9700:10200, 10500:10800,14350:14600};

rng = {10576:10853, 13576:13911};
size(rng{1})
f1 = 122;
f2 = 121;
figure();
clf;
subplot(f1); hold on; plot(co2, 'k');
subplot(f2); hold on;
graphStyle = {'xb', 'om', '-xr', 'og'};
previewStyle = {'b', 'm', 'r', 'g'};

for i = 1:length(rng)
  secs = [false(1, rng{i}(1)-1), (rng{i} > 0), false(1, N-rng{i}(end))];
  subplot(f2); plot(press(secs), flow2(secs), graphStyle{i});
%  plot(pressavg(secs), flowavg(secs), graphStyle{i});
  subplot(f1); plot(X(secs), co2(secs), previewStyle{i}); 
end


%% linear fit
csvwrite('pq1.csv', [press(secs); flow2(secs)]);


%% prepare positive quadrants
secs = 1:length(pressr);
PQ = [pressr(secs); flowr(secs)];
poslines = pressr(secs) > 0 & flowr(secs) > 0;
neglines = pressr(secs) < 0 & flowr(secs) < 0;
%% filter out half-negatives
%outlines = (press(secs) > 0 & flow2(secs) < 0) | (press(secs) < 0 & flow2(secs) > 0);
PQp = PQ(:, poslines );
PQn = PQ(:, neglines );
figure(); 
clf; hold on;
plot(PQp(1, :), PQp(2, :), 'bo');
plot(-PQn(1, :), -PQn(2, :), 'm*');
x = (0:0.1:18);

PQ1Sided = [PQp, -PQn];
pfit = PQ1Sided(1, :);
ffit = PQ1Sided(2, :);

% observe fit
plot(x, 11.49*x, 'k--', 'linewidth', 4;
plot(x, 30.28*x.^0.5459, 'k-', 'linewidth', 4);
legend('exhale', 'inhale', 'lin fit', 'power fit')

PQ1Sided = [PQp, -PQn];
% csvwrite('pq1sided.csv', PQ1Sided);

%% reconstruct the flow
frfp = 30.28*(data(:, 4)).^0.5459; 

pos = press >= 0;
flowrfp(pos) = 30.28*press(pos).^0.5459;
flowrfp(~pos) = -30.28*(-press(~pos)).^0.5459;


figure;
clf;hold on;
plot(flow*50, 'k');
plot(flow, 'k');
plot(flowrfp);

plot(cumsum(flow));
figure;
plot(cumsum(flowrfpnorm), 'b');

flowrfpnorm = repairFlowData22(flowrfp, true);
plot(flowrfp, 'b', 'Linewidth', 1);
plot(flowrfpnorm, 'r', 'Linewidth', 2);
figure;
plot(co2)

csvwrite('flow-c13-001m200.csv', [flowrfpnorm',  flow']);
%% For c013-001m2000
% General model Power1:
%      f(x) = a*x^b
% Coefficients (with 95% confidence bounds):
%        a =       30.28  (28.34, 32.22)
%        b =      0.5459  (0.52, 0.5718)
% 
% Goodness of fit:
%   SSE: 5.207e+04
%   R-square: 0.8666
%   Adjusted R-square: 0.8663
%   RMSE: 11.17

%Linear model:
%     f(x) = a*x
%Coefficients (with 95% confidence bounds):
%       a =       11.49  (11.27, 11.71)
%
%Goodness of fit:
%  SSE: 7.023e+04
%  R-square: 0.6792
%  Adjusted R-square: 0.6792
%  RMSE: 14.59

%General model Power1:
%     f(x) = a*x^b
%Coefficients (with 95% confidence bounds):
%       a =       28.16  (26.89, 29.44)
%       b =      0.5739  (0.5518, 0.596)
%
%Goodness of fit:
%  SSE: 1.52e+04
%  R-square: 0.9306
%  Adjusted R-square: 0.9303
%  RMSE: 6.798


%% reconstruct flow from pressures
% linear
flowrfpl = 11.49*press;

% nonlin
pos = press >= 0;
flowrfp(pos) = 28.16*press(pos).^0.5739;
flowrfp(~pos) = -28.16*(-press(~pos)).^0.5739;

figure;
clf;hold on;
plot(flowr, 'b');
plot(flowrfpl, 'm');
plot(flowrfp, 'r');
plot(cumsum(flowrfp), 'k');
legend('original [repaired] flow', 'reconstructed linear', ...
  'reconstructed power', 'cummulative volume for nonlin');