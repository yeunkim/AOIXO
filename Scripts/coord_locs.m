%creates coordinates in 12 sections of the screen

wsections = (res.width/8);
hsections = (res.height/6);

xes ={};

for n = 1:2:7
    xes = [xes, (wsections*n)];
end;

ys= {};

for n = 1:2:5
    ys = [ys, (hsections*n)];
end;

coords ={};

for n = 1:length(xes)
    for m = 1:length(ys)
        coords=[coords; [xes(n) ys(m)]];
    end;
end;

r= randi(12,48,1);