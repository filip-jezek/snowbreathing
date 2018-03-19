%% Head

  data_dir = 'c004-8S2000';
  file = ["..\\Data\\" data_dir "\\" data_dir 'wavesDots.asc'];
  rowsW = [1, 2, 3, 4, 5];
  fs = 25;

%% load data - pCO2, pO2, Flow
  data_raw_read = importdata(file,"\t",3).data(:,rowsW);
  
  % crop to 8k to 24k5
  data = data_raw_read(8000:24500, :);
%  data = data_raw_read(14000:24500, :);

  N = length(data);
  co2 = data(:, 1).';
  o2 = data(:, 2).';
  press = data(:, 3).';  
  flow = data(:, 4).';
  vol = data(:, 5).';

%% filter the singal by moving average
filt_L = 8;
sl_av = ones(1, filt_L)/filt_L;
co2avg = shift(filter(sl_av, 1, co2), -ceil(filt_L/2 - 1));  
o2avg = shift(filter(sl_av, 1, o2), -ceil(filt_L/2 - 1));  
pressavg = shift(filter(sl_av, 1, press), -ceil(filt_L/2 - 1));  

%figure(1);clf;hold on; plot(co2, 'r');plot(co2avg, 'g')  ;

%% get the breath durations
% get derivative and filter it
co2d = co2avg(1:N-1) - co2avg(2:N);
co2davg = shift(filter(sl_av, 1, co2d), -ceil(filt_L/2 - 1));
% crop the negatives and find peaks
co2davgpos = zeros(1, N); co2davgpos(co2davg > 0) = co2davg(co2davg >0);
[x, ploc] = findpeaks(co2davgpos, "MinPeakDistance",60, "MinPeakHeight", 0.01);

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
plot(ploc, BL, '-og');plot(co2avg);
%}

%% get mass flow - o2, co2
flowavg = shift(filter(sl_av, 1, flow), -ceil(filt_L/2 - 1));
% figure();hold on; plot(flow);plot(flowavg);
  % we assume the same place of measurement
  co2mass = co2avg.*flowavg;
  o2mass = o2avg.*  flowavg;
% figure();
clf;hold on; plot(co2avg);plot(flowavg);plot(co2mass);plot(zeros(1, N));
clf;hold on; plot(o2avg);plot(flowavg);plot(o2mass);plot(zeros(1, N));
clf;hold on; plot(co2mass);plot(o2mass);

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
 flow2 = [vol(2:end) - vol(1:end - 1) 0]; 
 
% clf;hold on; plot(flow);plot(flow2);
validity = abs(flowavg) > 5;
f = flowavg(validity)
res = pressavg(validity) ./ flowavg(validity);
x = 1:length(validity);
x = x(validity);
res(abs(res) > .5) = 0;
resavg = shift(filter(sl_av, 1, res), -ceil(filt_L/2 - 1));


figure(3);clf;hold on; plot(co2avg, 'k');
figure(2); clf; hold on;

rng = 1900:2222; secs = [false(1, rng(1)-1) validity(rng) false(1, N-rng(end))];
plot(pressavg(secs), flowavg(secs), 'xb');
figure(3); plot((1:N)(secs), co2avg(secs), 'b'); figure(2);

rng = 5900:6290; secs = [false(1, rng(1)-1) validity(rng) false(1, N-rng(end))];
plot(pressavg(secs), flowavg(secs), 'om');
figure(3); plot((1:N)(secs), co2avg(secs), 'm'); figure(2);

rng = 7200:7600; secs = [false(1, rng(1)-1) validity(rng) false(1, N-rng(end))];
plot(pressavg(secs), flowavg(secs), 'xr');
figure(3); plot((1:N)(secs), co2avg(secs), 'r'); figure(2);

rng = 11640:11960; secs = [false(1, rng(1)-1) validity(rng) false(1, N-rng(end))];
plot(pressavg(secs), flowavg(secs), 'og');
figure(3); plot((1:N)(secs), co2avg(secs), 'g'); figure(2);



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

