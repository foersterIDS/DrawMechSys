%% Draw Mech Sys 2: Beispiel 3
%Mit Draw Mech Sys 2 lassen sich einfach Bilder und Animationen von mechanischen Systemen erstellen:

%% VideoWriter erstellen:
v = VideoWriter('Beispiel_3','MPEG-4');
v.Quality = 95;
v.FrameRate = 30;
v.open();

%% Fenster und Objekte erzeugen
f = createWindow([-5 5],[-5 3],480);

m = gfx2d.mass(0,0,3,2,[0,0]);
w = gfx2d.wall([-4 4], [-4 -4], 3, false);
s = gfx2d.spring([0 0],[-1 -4], 0.5, 0.5);

%% Zeitvektor erstellen
T = 0:1/v.FrameRate:5;

%% Animationsschleife 
for ti = T    
    % neue Position berechnen
    y = sin(ti*(2*pi));
    
    % Position der Masse und Feder aktualisieren
    m.setPosition(0,y,[0 0]);
    s.setPosition([0 0],[y-1 -4]);
    
    % Bild in Video schreiben
    F = getframe();
    v.writeVideo(F.cdata);
end

%% Video abschlieﬂen
v.close();