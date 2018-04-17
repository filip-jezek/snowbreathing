function newData = avgDownsample(data,n)
  %replace n consequent data samples by their average
  newData = [];
  nCols = size(data,2);
  row = zeros(1,nCols);
  iNew = 0;
  for i = 1:size(data,1)
    row = row + data(i,:);
    if mod(i,n) == 0
      newData = [newData; row/n];
      row = zeros(1,nCols);
    endif;
  end;
end;
