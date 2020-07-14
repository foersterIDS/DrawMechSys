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
function [out_info] = drawWall(X,Y,b,n,orientation,varargin)
    %% Init:
    stdinp = 5;
    color = [0,0,0];
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
    xa = X(1);
    ya = Y(1);
    xe = X(2);
    ye = Y(2);
    l = sqrt((xe-xa)^2+(ye-ya)^2);
    r = l/n;
    % Referenzlager:
    xsr = [0,l,NaN];
    ysr = [0,0,NaN];
    for i=1:n
        xsr = [xsr,NaN,r*(i-1),r*i];
        ysr = [ysr,NaN,0-sgn(orientation)*b,0];
    end
    % Transformation:
    alpha = atan2((ye-ya),(xe-xa));
    xs = xa+sgn(xe-xa)*(+xsr*cos(alpha)+ysr*sin(alpha));
    ys = ya+sgn(xe-xa)*(xsr*sin(alpha)-ysr*cos(alpha));
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
end