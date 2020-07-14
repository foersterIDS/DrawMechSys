
%% Fenster und Objekte erzeugen
f = createWindow([-5 5],[-5 4],480);

m1 = gfx2d.mass(-2,0,3,2,[0,0]);
m2 = gfx2d.mass(2,1,3,2,[0,0]);

w = gfx2d.wall([-4 4], [-4 -4], 3, false);
s1 = gfx2d.spring([-2 -2],[-1 -4], 0.5, 0.5);
s2 = gfx2d.spring([0 0],[-1 -4], 0.5, 0.5);

s1.bind(m1,[0 -1],true);
s2.bind(m1,[1 1],false);
s2.bind(m2,[-1 -1],true);

%% Zeitvektor erstellen
fps = 30;
T = 0:1/fps:5;

%% Animationsschleife 
for ti = T    

    y1 = sin(ti*(2*pi))-1;
    x2 = cos(ti*(3*pi))+2;
    y2 = sin(ti*(3*pi))+2;

    m1.setPosition(-2,y1,[0 0]);
    m2.setPosition(x2,y2,ti*pi);

    pause(1/fps)
end
