function allcoords = coordgenerater_vid(res_width, res_height, buffer)

wsections = ((res_width-(2*buffer))/6);
hsections = ((res_height-(2*buffer))/4);

xes ={};
ys= {};
coordstmp ={};

for n=1:2:5;xes = [xes, (wsections*n)+buffer];end;
for n=1:2:3;ys = [ys, (hsections*n)+buffer];end;

for n = 1:length(xes)
    for m = 1:length(ys)
        coordstmp=[coordstmp; [xes(n) ys(m)]];
    end;
end;
coordstmp = cell2mat(coordstmp);
coordstmp(5:6,1) = coordstmp(5:6,1) - (1/2)*wsections;
allcoords= coordstmp;