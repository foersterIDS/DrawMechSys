%% Info:
%
%   M.Sc. Alwin Förster
%   Institut für Dynamik und Schwingungen
%   Leibniz Universität Hannover
%   Kontakt: foerster@ids.uni-hannover.de
%            +49-511-762-5381
%   Änderungsdatum: 25.10.2018
%   Geändert durch: foerster
%
function [out_info] = drawSphere(X,Y,d,varargin)
    %% Init:
    stdinp = 3;
    color = [0,0,0];
    facecolor = [1,1,1];
    isFig = 0;
    isSub = 0;
    lw = 1;
    Nu = 100;
    nr = 5;
    amin = pi/2+1*pi/16;
    amax = pi/2+5*pi/16;
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
    phi = linspace(0,2*pi,Nu);
    phir = linspace(amin,amax,round(Nu/4));
    xs1 = X+d/2*cos(phi);
    ys1 = Y+d/2*sin(phi);
    xs2 = X+[d/2*(nr)/(nr+1)*cos(phir),NaN,d/2*(nr-1)/(nr+1)*cos(phir)];
    ys2 = Y+[d/2*(nr)/(nr+1)*sin(phir),NaN,d/2*(nr-1)/(nr+1)*sin(phir)];
    %% Plot:
    if isFig
        figure(nfig);
    end
    if isSub
        subplot(nsub(1),nsub(2),nsub(3));
    end
    hold on;
    fill(xs1,ys1,'','FaceColor',facecolor,'EdgeColor',color,'LineWidth',lw);
    plot(xs2,ys2,'Color',color,'LineWidth',lw);
    %% Out:
    out_info = 1;
end