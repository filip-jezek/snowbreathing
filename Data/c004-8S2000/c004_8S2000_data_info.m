function di = c004_8S2000_data_info()

    %file names:
    di.baseName = 'c004-8S2000';
    di.W.file = ['waves-' di.baseName '.txt'];
    di.WD.file = ['dutina-waves-' di.baseName '.txt'];

    di.T.varName = {'HR', 'SpO2'};
    di.W.varName = {'CO2', 'O2', 'Paw', 'Flow', 'Vol'};
    di.WD.varName = {'CO2_D', 'O2_D'};

    %column indexes with variables of interest:
    %columnT = [1 30];
    %columnTD = [1 30];
    di.W.column = [1 2 3 4 5];
    di.WD.column = [1:2];

    %columns to plot:
    di.T.varI = 1;
    di.W.varI = [1 2 3];
    di.WD.varI = [1 2];

    %sample frequencies (Hz):
    di.T.f = 1;
    di.TD.f = 1;
    di.W.f = 25;
    di.WD.f = 25;
    di.fTarget = 25;

   %crop times for simulation input data
    di.W.crop = [0 1285];
    di.WD.crop = [220 1367];

    %time when cone was connected
    di.W.tConnected = 599;
    di.WD.tConnected = 676.8 - 1.68 - 1.64;

    %time when the cone was disconnected:
    di.W.tDisconnected = 974;
	
	% repair the flow - if the pc exist,then the rest is not required and vice versa
	di.flowRepair.pc = [21.9101 0.66882];
	% points and spans to be invalidated
	di.flowRepair.manuallyInvalidated = [];
	% set of "bad readings" - these values are discarded
	di.flowRepair.invalidReading = [-0.1, -0.2, -0.2];
	% when the diffbounds are empty, the saturation correction is skipped
	% [min, max, maxwidth] - min peak of diff, max peak of diff and maximal width of sat
	% di.flowRepair.diffBounds = [-90, 40, 30];
end

