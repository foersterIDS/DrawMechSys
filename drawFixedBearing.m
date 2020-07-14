%% Info:
%
%   M.Sc. Alwin Förster
%   Institut für Dynamik und Schwingungen
%   Leibniz Universität Hannover
%   Kontakt: foerster@ids.uni-hannover.de
%            +49-511-762-5381
%   Änderungsdatum: 23.10.2018
%   Geändert durch: foerster
%
function [out_info] = drawFixedBearing(X,Y,b,orientation,varargin)
    %% Init:
    stdinp = 4;
    color = [0,0,0];
    facecolor = [1,1,1];
    isFig = 0;
    isSub = 0;
    lw = 1;
    ms = 5*lw;
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
                otherwise
                    error('No such element: %s',varargin{i});
            end
            i = i+1;
        end
    end
    %% Calc:
    skal = 6;
    r = b/skal;
    Nr = 50;
    % Referenzlager:
    xsr1 = [+b/2,-b/2,...
            r*cos(linspace(3*pi/2-atan(1/2),3*pi/2+atan(1/2),Nr)),...
            +b/2];
    ysr1 = [-b,-b,...
            r*sin(linspace(3*pi/2-atan(1/2),3*pi/2+atan(1/2),Nr)),...
            -b];
    xsr2 = r*cos(linspace(0,2*pi,Nr));
    ysr2 = r*sin(linspace(0,2*pi,Nr));
    xsr3 = [];
    ysr3 = [];
    for i=1:skal
        xsr3 = [xsr3,NaN,-b/2+r*(i-1),-b/2+r*i];
        ysr3 = [ysr3,NaN,-b-r,-b];
    end
    % Transformation:
    alpha = atan2(orientation(1),orientation(2));
    xs1 = X+(-xsr1*cos(alpha)+ysr1*sin(alpha));
    ys1 = Y+(xsr1*sin(alpha)+ysr1*cos(alpha));
    xs2 = X+(-xsr2*cos(alpha)+ysr2*sin(alpha));
    ys2 = Y+(xsr2*sin(alpha)+ysr2*cos(alpha));
    xs3 = X+(-xsr3*cos(alpha)+ysr3*sin(alpha));
    ys3 = Y+(xsr3*sin(alpha)+ysr3*cos(alpha));
    %% Plot:
    if isFig
        figure(nfig);
    end
    if isSub
        subplot(nsub(1),nsub(2),nsub(3));
    end
    hold on;
    fill(xs1,ys1,'','FaceColor',facecolor,'EdgeColor',color,'LineWidth',lw);
    fill(xs2,ys2,'','FaceColor',facecolor,'EdgeColor',color,'LineWidth',lw);
    plot(xs3,ys3,'Color',color,'LineWidth',lw);
    %% Out:
    out_info = 1;
end