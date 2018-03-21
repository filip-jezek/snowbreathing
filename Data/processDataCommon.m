#To find and set prope crop times and the time, when cone was disconnected
# - comment out all but one calls of processOne
# - consecutively uncomment particular sections in processOne find the 
#         values and write them to data_info.m
clear all;

function x2 = createX(data, f1, f2)
  #f1 orig sample f in data
  #f2 new sample f
  rows = size(data)(1);
  endX = (rows-1)/f1;
#  dx1 = 1.0/f1;
  dx2 = 1.0/f2;
  x2 = 0:dx2:endX;
endfunction;

#resample function:
function [x2,dataRe] = resampleX(data,f1,f2)
#  rows = size(data)(1)
#  x1 = 1:1:rows;
  x1 = createX(data,f1,f1);
  x2 = createX(data,f1,f2);
  dataRe = interp1(x1,data,x2,'linear');
endfunction;

function [xOut, dataOut] = cropData(x, data, cropTimes) 
  eps = 1.0e-8;
  cropI1 = find(x>=cropTimes(1)-eps,1,'first');
  cropI2 = find(x<=cropTimes(2)+eps,1,'last');
  xOut = x(cropI1:cropI2);
  dataOut = data(cropI1:cropI2,:);
endfunction;

function xOut = doOffset(x,offset, f)
  #round the offset to multiple of dt
  offsetR = round(offset*f)/f;
  xOut = x - offsetR;
endfunction;

function [x, data] = processOne(file, columns, dir, f1, f2, crop, tEnd, varI, varName)
  #read the data from file:
  data = importdata(["./" dir "/" file],"\t",3).data(:,columns);
  #resample data, return new time grid as well. f1 .. original sample rate, f2 .. new sample rate.
  [x, data] = resampleX(data,f1,f2);
  #------------------ Uncoment to find crop time range (crop_): ----------------------
  #plot(x,data(:,varI));
  #exit("Find the times to crop out the nonsens data on boundaries.")
  #---------------------------------------------------------------------------
  
  #crop the starting and final data with nonsens values
  [x,data] = cropData(x,data,crop);
  
  #----------------- Uncomment to find the time, when cone was disconnected (tEnd_)------
  #plot(x,data(:,varI));
  #exit("Find the time, when cone was disconnected")
  #--------------------------------------------------------------------------------------

  #offset in time so that the zero time is in the end, when snow cpme was dosconnected
  x = doOffset(x,tEnd, f2);
  
  #------------ Uncomment to see the result ----------------------------
  #  plot(x,data(:,varI));
  #  title(file);
  #  xlabel("time [s]");
  #  ylabel(varName(varI));
  #  exit("See one processed dataset");
  #---------------------------------------------------------------------
endfunction;

function [xdataOut] = mergeData(xs, datas)
  if (size(xs) != size(datas))
    error("x and data are of different size in mergeData");
  endif;
  size(xs)
  xL = -inf;
  xR = inf;
  for i = 1:size(xs,2)
    x = xs{i};
    xL = max(xL, x(1));
    indR = size(x,2);
    xR = min(xR, x(indR));
  end;
  [xdataOut, data1] = cropData(xs{1}, datas{1}, [xL,xR] );
  xdataOut = [xdataOut' data1];
  for i = 2:size(xs)(2)
    [_, data1] = cropData(xs{i}, datas{i}, [xL,xR] );
    xdataOut = [xdataOut data1];
  end;
endfunction;

function plotData(xData, varNames, iCol, multiplier)
  if nargin<4 
    multiplier = ones(size(iCol,2));
  end
  for i = 1:size(iCol,2)
    plot(xData(:,1), xData(:,iCol(i)+1)*multiplier(i), num2str(i));
  endfor;
  xlabel("time (s)");
  legend(varNames(iCol));

endfunction;

function writeData(data, header, fileName)
  textHeader = strjoin(header, '\t');
  %write header to file
  fileName
  fid = fopen(fileName,'w')
  fprintf(fid,'%s\n',textHeader)
  fclose(fid)
  %write data to end of file
  dlmwrite(fileName,data,"\t", '-append')
  ["data written to " fileName " file\n"]
endfunction;
  

function processData(dir)
  #read the dataInfo file:
  run(["./" dir "/data_info.m"])

  files = {fileT; fileTD; fileW; fileWD};
  #frequencies:
  f = [fT fTD fW fWD];
  #offsets = [offsetT offsetTD offsetW offsetWD];


  varNameT = {"HR", "SpO2"};
  varNameW = {"CO2", "O2", "Paw", "Flow", "Vol"};
  varNameWD = {"CO2_D", "O2_D"};

  close all;

  #columns plotted to find the offsets:
  varIT = 1;
  varIW = 3;
  varIWD = 1;
  fTarget = 100;
  [xT, dataT] = processOne(fileT, columnT, dir, fT , fTarget, cropT, tEndT, varIT, varNameT);
  #figure;
  [xW, dataW] = processOne(fileW, columnW, dir, fW , fTarget, cropW, tEndW, varIW, varNameW);
  #figure;
  [xWD, dataWD] = processOne(fileWD, columnWD, dir, fWD, fTarget, cropWD, tEndWD, varIWD, varNameWD);

  xdata = mergeData({xT, xW, xWD}, {dataT, dataW, dataWD});
  #xdata = mergeData({xT, xW}, {dataT, dataW});
  #error("debug")
  varNames = [varNameT, varNameW, varNameWD]
  figure;
  hold on;
  plotData(xdata, varNames, [1,3,8], [0.1, 1, 1]);

  writeData(xdata, ["t" varNames], [dir "/" dir "_all.txt"])
  #hold on;
  #plot(xdata(:,1),xdata(:,6))
endfunction;  

#directory with data:
dir = "c004-8S2000";
processData(dir);
