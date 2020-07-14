%% Info:
%
%   M.Sc. Alwin Förster
%   Institut für Dynamik und Schwingungen
%   Leibniz Universität Hannover
%   Kontakt: foerster@ids.uni-hannover.de
%            +49-511-762-5381
%   Änderungsdatum: 21.11.2018
%   Geändert durch: foerster
%
function [out_info] = drawRoll(X,Y,d,varargin)
    %% Init:
    stdinp = 3;
    color = [0,0,0];
    facecolor = [1,1,1];
    isFig = 0;
    isSub = 0;
    lw = 1;
    Nu = 100;
    isOri = 0;
    %% Input:
    if nargin>stdinp
        i = 1;
        while i<=nargin-stdinp
            switch lower(varargin{i})
                case 'color'
                    color = varargin{i+1};
                    i = i+1;
                case 'facecolor'
                    facecolor = varargin{i+1};
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
                case 'orientation'
                    isOri = 1;
                    orientation = varargin{i+1};
                    i = i+1;
                otherwise
                    error('No such element: %s',varargin{i});
            end
            i = i+1;
        end
    end
    %% Calc:
    phi = linspace(0,2*pi,Nu);
    xs = X+d/2*cos(phi);
    ys = Y+d/2*sin(phi);
    if isOri
        alpha = atan2(orientation(1),orientation(2));
        phio = alpha+linspace(0,4*pi,2*Nu);
        ro = d/2*0.8*linspace(1,0,2*Nu);
        xso = X+ro.*cos(phio);
        yso = Y+ro.*sin(phio);
    end
    %% Plot:
    if isFig
        figure(nfig);
    end
    if isSub
        subplot(nsub(1),nsub(2),nsub(3));
    end
    hold on;
    fill(xs,ys,'','FaceColor',facecolor,'EdgeColor',color,'LineWidth',lw);
    if isOri
        plot(xso,yso,'Color',color,'LineWidth',lw);
    end
    %% Out:
    out_info = 1;
end