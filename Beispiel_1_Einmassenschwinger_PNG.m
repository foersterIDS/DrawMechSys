%% Draw Mech Sys 2: Beispiel 1
%Mit Draw Mech Sys 2 lassen sich einfach Bilder und Animationen von mechanischen Systemen erstellen:

%% Fenster mit 400 Pixel Höhe und dem gewünschten Bildausschnitt erzeugen.
% createWindow(xLimits,yLimits,yResolution)
f = createWindow([-4 4],[-5 3],400);

%% 3x2 große Masse im Ursprung erzeugen.
% gfx2d.mass(X,Y,b,h,orientation)
m = gfx2d.mass(0,0,3,2,[0,0]);

%% Feste Wand bei y = -4.
% gfx2d.wall([xStart xEnd],[yStart yEnd], numHatches, isHatchOnRightSide)
w = gfx2d.wall([-4 4], [-4 -4], 3, false);

%% Feder zwischen Masse und Wand.
% gfx2d.spring([xStart xEnd], [yStart yEnd], width, minLength)
s = gfx2d.spring([0 0],[-1 -4], 0.5, 0.5);

%% Bild als PNG abspeichern
F = getframe();
imwrite(F.cdata,'Beispiel_1.png');