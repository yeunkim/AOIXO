function allcoords = coordgenerator(res_width, res_height, buffer)

% generate coordinates (6 sections)

wsections = ((res_width-(2*buffer))/3);
hsections = ((res_height-(2*buffer))/2);

xes ={};
ys= {};
uppercoords ={};
lowercoords ={};

for n=0:2;xes = [xes, (wsections*n)+buffer];end;
for n=0:1;ys = [ys, (hsections*n)+buffer];end;

for n = 1:length(xes)
    for m = 1:length(ys)
        uppercoords=[uppercoords; [xes(n) ys(m)]];
    end;
end;

xes ={};
ys= {};
for n=1:3;xes = [xes, (wsections*n)];end;
for n=1:2;ys = [ys, (hsections*n)];end;

for n = 1:length(xes)
    for m = 1:length(ys)
        lowercoords=[lowercoords; [xes(n) ys(m)]];
    end;
end;

lowercoords= cell2mat(lowercoords);
uppercoords= cell2mat(uppercoords);
allcoords= [uppercoords lowercoords];


% r=randi(6,48,1);