%To find and set prope crop times and the time, when cone was disconnected
% - comment out all but one calls of processOne
% - consecutively uncomment particular sections in processOne find the 
%         values and write them to data_info.m
clear all;

%dir = 'c004-8S2000';
%dir = 'c004-4m2000';
%dir = 'c004-11m2000';
%dir = 'c013-001m2000'; %hotovo i grad
%dir = 'c013-12m2000'; %hotovo i grad
dir = 'c013-12s2000'; %hotovo i grad
%  allData(dir);
setupFile = 0;
plotGrad = 0;
plotRepairFlow = 0;
inputData(dir,setupFile,plotGrad,plotRepairFlow);