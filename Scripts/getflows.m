%% Head
% pkg load signal

% data_dir = 'c004-3m0200';
%  data_dir = 'c004-4m2000';
%  data_dir = 'c004-8S2000';
data_dir = 'c004-11m2000';
  file = ['../Data/' data_dir '/' data_dir 'wavesDots.asc'];
%  rowsW = [1, 2, 3, 4, 5];
  rowsW = [1, 2, 3, 4];
  fs = 25;

%% load data - pCO2, pO2, Flow

  data_raw_read_d = importdata(file,'\t',3);
  data_raw_read = data_raw_read_d.data(:,rowsW);
  
  % crop to 8k to 24k5
% data = data_raw_read(8000:24500, :);
  data = data_raw_read;

  N = length(data);
  co2 = data(:, 1).';
  o2 = data(:, 2).';
  press = data(:, 3).';  
  flow = data(:, 4).';
%   vol = data(:, 5).';

  
 % dataset c004-11m2000
%flow2 = repairFlowData(flow, [8030:8040,16387:16394, 16539:16552], [-0.1, -0.2, -0.2], [-110, 40, 20], true);

 % dataset c004-8S2000
%flow2 = repairFlowData(flow, [19545:19547], [-0.1, -0.2, -0.2], [-90, 40, 40], true);

 % dataset c004-4m2000
% flow2 = repairFlowData(flow, [7020:7076, 8700:8753, 13701:13754, 21542:21558, 22112:22121], [-0.1, -0.2, -0.2], [-90, 40, 30], true);

 % dataset c004-3m0200
 flow2 = repairFlowData(flow, [16873:16876, 12920:12929, 10827:10874, 7868:7917, 1696:1704],[0, -0.2, -0.2], [-60, 40, 30], true);

 
 %% Test the volume  - cummulative sum of the flow
 volf = cumsum(flow2);
 
X = 1:N;

pp = splinefit(X, volf, 1);
tt = ppval(pp, X);

figure(3); clf; hold on;
plot(flow2*50, 'r');
plot(volf, 'b');
plot(tt, 'k', 'LineWidth', 2);

[X] = detrend(volf, 4);
plot(X);


plot(flow2r, 'b');
plot(flow2, 'r');

% filter out volume changes by interpolation over some value?
satu = flow2 < 120 & flow2 > -114;
X = (1:N);
flow2r = interp1(X(satu), flow2(satu), 1:N, 'spline');


%% filter out peaks and its neighbours
%sat_locn = [true, sat_loc(1:end-2) | sat_loc(2: end-1) | sat_loc(3: end), true];
%flowvalid(sat_loc) = false;
%flowv2 = interp1((1:N)(flowvalid), flow(flowvalid), 1:N);


%{
figure(1)
clf;hold on; plot(flow); plot(flowv); plot(flowv2);plot(flowvdif2, 'm'); 
plot((1:N)(!flowvalid),flowv2(!flowvalid), 'g*');

plot((1:N)(sat_locn),ones(1,N)(sat_locn), 'go');
%}

%% scan again


%figure(1)
%clf;hold on; plot(flow); plot(flowv); plot(flowvdif2); 
%plot((1:N)(sat_loc),flowvdif2(sat_loc), '*');
%
%clf;hold on;plot(xflowvalid, flowv, '-');plot(xflowvalid, flowvdif, '-d');plot(xflowvalid,flowvdif2, '-ms');
%plot(xflowvalid(sat_loc), 0, 'rx');
%figure;
%
%%% find consecutive peaks
%clf;hold on;plot(flowvalid, 'r')
%flowvalid(sat_loc) = false;
%
%kern = [1 1 1];
%flowc = conv(flowvalid, [1/4, 1/4, 1/4, 1/4], 'same');


% find peak, which has distance to next peak at least 6 and at most 

% TODO filter the saturation
% get negative peaks under 60, wait for positive peak over 60 - invalidate data inbetween
% interpolate
%flowrepaired = interp1(xflowvalid, flowv, 1:N);
%clf;hold on;plot(flowrepaired, '-');plot(flowv, '-');

%% filter the singal by moving average
filt_L = 8;
sl_av = ones(1, filt_L)/filt_L;
co2avg = shift(filter(sl_av, 1, co2), -ceil(filt_L/2 - 1));  
o2avg = shift(filter(sl_av, 1, o2), -ceil(filt_L/2 - 1));  
pressavg = shift(filter(sl_av, 1, press), -ceil(filt_L/2 - 1));  
flowavg = shift(filter(sl_av, 1, flow), -ceil(filt_L/2 - 1));
volavg = shift(filter(sl_av, 1, vol), -ceil(filt_L/2 - 1));

%figure(1);clf;hold on; plot(co2, 'r');plot(co2avg, 'g')  ;

%% get the breath durations
% get derivative and filter it
co2d = co2avg(1:N-1) - co2avg(2:N);
co2davg = shift(filter(sl_av, 1, co2d), -ceil(filt_L/2 - 1));
% crop the negatives and find peaks
co2davgpos = zeros(1, N); co2davgpos(co2davg > 0) = co2davg(co2davg >0);
[x, ploc] = findpeaks(co2davgpos, 'MinPeakDistance',60, 'MinPeakHeight', 0.01);

% plot the breath positions
% plot(ploc, x, 'gx');plot(co2davgpos);
% figure();clf;hold on;plot(ploc, co2(ploc), 'xg');plot(1:N, co2, 'm');

% get breath length in seconds
BL = [0 ploc(2:end) - ploc(1:end - 1)]/fs;
% get breath rate per minute
BR = (ones(size(BL)) ./ BL) * (60);
% plot the filtered
BRf = shift(filter(sl_av, 1, BR), -ceil(filt_L/2 - 1));  
%{ 
figure(); 
clf; hold on;
plot(ploc, BR, 'm');plot(ploc, BRf, 'g');
plot(ploc, co2avg(ploc), '--og');plot(co2avg);
%}

%% get mass flow - o2, co2
% figure();hold on; plot(flow);plot(flowavg);
  % we assume the same place of measurement
  co2mass = co2avg.*flowavg;
  o2mass = o2avg.*  flowavg;
%{
figure();
clf;hold on; plot(co2avg);plot(flowavg);plot(co2mass);plot(zeros(1, N));
clf;hold on; plot(o2avg);plot(flowavg);plot(o2mass);plot(zeros(1, N));
clf;hold on; plot(co2mass);plot(o2mass);
%}

%% get cumulative amount of o2 and co2

  cumo2 = ones(1,N);cumo2(ploc) = 0;
  for i = 2:N
    cumo2(i) = cumo2(i)*(o2mass(i) + cumo2(i-1) - 1);
  endfor  
  o2cumsum = cumo2 (ploc-1) ./ BL;
  o2cumsum(BL == 0) = 0; % get rid of infinity

  cumco2 = ones(1,N);cumco2(ploc) = 0;
  for i = 2:N
    cumco2(i) = cumco2(i)*(co2mass(i) + cumco2(i-1) - 1);
  endfor  
  co2cumsum = cumco2 (ploc-1) ./ BL;
  co2cumsum(BL == 0) = 0; % get rid of infinity


  filt2_L = 8; sl_av2 = ones(1, filt2_L)/filt2_L;
  co2prod = shift(filter(sl_av2, 1, co2cumsum), -ceil(filt2_L/2 - 1));  
  o2cons = - shift(filter(sl_av2, 1, o2cumsum), -ceil(filt2_L/2 - 1));  
   
%{ 
figure();
clf;hold on;plot(ploc-1, cumo2(ploc-1), 'ob');plot(1:N, cumo2, 'm');  
clf;hold on;plot(ploc-1, cumco2(ploc-1), 'ob');plot(1:N, cumco2, 'm');  
clf; hold on; plot(zeros(1, N), '--y'); plot(co2avg*1000, '-k');plot(ploc, co2cumsum, '-ob'); plot(ploc, -o2cumsum, '-xr');
%}
  
%% plot the result - the O2 consumption rise is not measurable and therefore assume constant
figure (1);clf;
subplot(2, 1, 1);
hold on;
plot(zeros(1, N), '--y'); 
%plot(ploc, co2cumsum, '--ob');plot(ploc, -o2cumsum, '--xr');
plot(ploc, co2prod, '-b');plot(ploc, o2cons, '-r');

subplot(2, 1, 2);hold on;
plot(co2avg, '-k');
plot(flowavg/50, '-g');


%% flows and resistances
 
% clf;hold on; plot(flow);plot(flow2);
validity = abs(flowavg) > 5;
f = flowavg(validity);
res = pressavg(validity) ./ flowavg(validity);
x = 1:length(validity);
x = x(validity);
res(abs(res) > .5) = 0;
resavg = shift(filter(sl_av, 1, res), -ceil(filt_L/2 - 1));


% 8S2000
%rng = {1900:2222, 5900:6290, 7200:7600, 11640:11960};

% 11m2000
rng = {7400:7800, 9700:10200, 10500:10800,14350:14600};



f1 = 4;
f2 = 5;
figure(f1);clf;hold on; plot(co2avg, 'k');
figure(f2); clf; hold on;
graphStyle = {'xb', 'om', '-xr', 'og'};
previewStyle = {'b', 'm', 'r', 'g'};

for i = 1:length(rng)
  secs = [false(1, rng{i}(1)-1) validity(rng{i}) false(1, N-rng{i}(end))];
  plot(pressavg(secs), flowavg(secs), graphStyle{i});
  figure(f1); plot(X(secs), co2avg(secs), previewStyle{i}); figure(f2);
endfor

%{
clf; plot(secs);
figure(4);hold on; plot(pressavg(secs), flowavg(secs), 'or');
figure(3); clf; hold on; plot(pressavg/4); plot(flowavg/100);
figure(3); clf; hold on; plot(pressavg(secs)); plot(flowavg(secs));
res = pressavg(secs) ./ flowavg(secs);
clf; plot(flowavg(secs), res, 'x');
plot(ones(N))
% clf; plot(sign(flowavg(validity)))
figure(1);
clf; hold on; plot(x, flowavg(validity), x, flowavg(validity).^2, x, sign(flowavg(validity)).*flowavg(validity).^2); 
hold on; plot(x(validity), res, '-xg'); 
plot(resavg);plot(vol/4000);
%}
