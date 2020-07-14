%% Info:
%
%   M.Sc. Alwin Förster
%   Institut für Dynamik und Schwingungen
%   Leibniz Universität Hannover
%   Kontakt: foerster@ids.uni-hannover.de
%            +49-511-762-5381
%   Änderungsdatum: 24.10.2018
%   geändert durch: foerster
%
%% gifmaker:
%
%   Erzeugt GIF-Datei im Verzeichnis der Quelldateien
%   Quelldateien haben das Namesformat: 'name_i.jpg' mit i=1:di:N
%   Ausgabedatei hat das Namensformat: 'name.gif'
%
%% Dateiname:
path = 'A:\PFAD\BILDER\'; % Pfad der Quell- und Ausgabedatei
name = 'bild'; % Name für Quell- und Ausgabedatei (Name der Einzelbilder: 'bild_12')
format = 'png'; % Dateinamenerweiterung der Einzelbilder
filename = [path,name,'.gif'];
%% Optionen:
i0 = 1; % erster Zähler hinter 'name_'
N = 60; % Anzahl der Quellbilder
di = 1; % Jedes wie vielte Bild soll verwendet werden?
dt = 1/60; % Anzeigedauer pro Bild; 0.04 entspricht 25 fps
dtstart = dt; % Anzeigedauer des ersten Bildes
dtend = dt; % Anzeigedauer des letzten Bildes
loops = inf; % Anzahl Schleifendurchläufe; 0 entspricht einem Durchlauf; inf führt zu Dauerschleife
%% GIF erstellen:
tgif = tic;
for i=i0:di:N
    %% neues JPG einlesen:
    im = imread([path,name,'_',num2str(i),'.',format]);
    %% Farbkorrektur:
    [d1,d2,d3] = size(im);
    if d3==1
        temp = uint8(zeros(d1,d2,3));
        temp(:,:,1) = im;
        temp(:,:,2) = im;
        temp(:,:,3) = im;
        im = temp;
    end
    [imind,cm] = rgb2ind(im,256);
    %% neues Frame in Datei schreiben:
    if i==i0
        % DelayTime: Zeit bevor Animation startet
        imwrite(imind,cm,filename,'gif', 'DelayTime',dtstart,'Loopcount',loops);
    elseif i==N
        % DelayTime: Zeit die das letzte Bild angezeigt wird
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',dtend);
    else
        % DelayTime: Zeit pro Frame
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',dt);
    end
    %% Fortschrittsanzeige:
    if i==N
        fprintf('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n');
        fprintf('| GIF-Erstellung abgeschlossen: 100.00%%  ||  Gesamtdauer: %.2es |\n',toc(tgif));
        fprintf('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n');
    else
        fprintf('GIF erstellen: %.2f%%  |  %.2fs\n',100*i/N,((1-i/N)/(1-(1-i/N)))*toc(tgif));
    end
end