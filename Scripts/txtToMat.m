function [] = txtToMat(file)
    pathfile = ['../Data/' file '/' file '_grad'];
    fprintf(['opening ' pathfile '.txt\n']);
    dataComplet = importdata([pathfile '.txt'],'\t',2);
    data = dataComplet.data;
    size(data);
    r = data(:,1);
    t = data(:,2);
    CO2 = data(:,3);
    O2 = data(:,4);
    save('-v4',[pathfile '.mat'], 'r', 't', 'CO2', 'O2');
    fig = figure;
    hold on;
    plot(r,CO2);
    plot(r,O2, 'r');
    legend({'CO2', 'O2'})
    saveas(fig,[pathfile '.png']);
end