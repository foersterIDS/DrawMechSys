%% Info:
%
%   M.Sc. Alwin Förster
%   Institut für Dynamik und Schwingungen
%   Leibniz Universität Hannover
%   Kontakt: foerster@ids.uni-hannover.de
%            +49-511-762-5381
%   Änderungsdatum: 22.10.2018
%   Geändert durch: foerster
%
function [out_info,xcon,ycon] = drawHull(X,Y,b,l,orientation,varargin)
    %% Init:
    stdinp = 5;
    color = [0,0,0];
    isFig = 0;
    isSub = 0;
    lw = 1;
    %% Input:
    if nargin>stdinp
        i = 1;
        while i<=nargin-stdinp
            switch lower(varargin{i})
                case 'color'
                    color = varargin{i+1};
                    i = i+1;
                case 'figure'
                    isFig = 1;
                    nfig = varargin{i+1};
                    i = i+1;
                case 'subplot'
                    isSub = 1;
                    nsub = varargin{i+1};
                    i = i+1;
                case 'linewidth'
                    lw = varargin{i+1};
                    i = i+1;
                otherwise
                    error('No such element: %s',varargin{i});
            end
            i = i+1;
        end
    end
    %% Calc:
    % Referenzfeder:
    xsr = [-l/2,0,+l/2,NaN,-l/2,0,+l/2];
    ysr = [-b/2,-b/2,-b/2,NaN,+b/2,+b/2,+b/2];
    % Transformation:
    alpha = atan2(orientation(2),orientation(1));
    xs = X+(xsr*cos(alpha)+ysr*sin(alpha));
    ys = Y+(xsr*sin(alpha)-ysr*cos(alpha));
    %% Plot:
    if isFig
        figure(nfig);
    end
    if isSub
        subplot(nsub(1),nsub(2),nsub(3));
    end
    hold on;
    plot(xs,ys,'Color',color,'LineWidth',lw);
    %% Out:
    out_info = 1;
    xcon = [xs(2),xs(6)]; % x-Koordinaten der Verbindungspunkte
    ycon = [ys(2),ys(6)]; % y-Koordinaten der Verbindungspunkte
end