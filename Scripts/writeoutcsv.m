function writeoutcsv(fn,matrix,type)

if type=='block',
    rownames = {'cuestarttime' 'cuetimedur' 'blockdur' 'blocktotaltime'};
end;

if type=='photo',
    rownames=cell(1,8);
    for i = 1:8,
        rownames{i} = strcat('photo', num2str(i));
    end;
end;
commaHeader = [rownames;repmat({','},1,numel(rownames))]; 
commaHeader = commaHeader(:)';
textHeader = cell2mat(commaHeader);

fid = fopen(fn,'w'); 
fprintf(fid,'%s\n',textHeader);
fclose(fid);

dlmwrite(fn,matrix,'-append');