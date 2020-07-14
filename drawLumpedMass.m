%% Info:
%
%   M.Sc. Alwin Förster
%   Institut für Dynamik und Schwingungen
%   Leibniz Universität Hannover
%   Kontakt: foerster@ids.uni-hannover.de
%            +49-511-762-5381
%   Änderungsdatum: 24.10.2018
%   Geändert durch: foerster
%
function [out_info] = drawLumpedMass(X,Y,d,varargin)
    %% Init:
    stdinp = 3;
    color = [0,0,0];
    isFig = 0;
    isSub = 0;
    Nu = 100;
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
                otherwise
                    error('No such element: %s',varargin{i});
            end
            i = i+1;
        end
    end
    %% Calc:
    xs = X+d/2*cos(linspace(0,2*pi,Nu));
    ys = Y+d/2*sin(linspace(0,2*pi,Nu));
    %% Plot:
    if isFig
        figure(nfig);
    end
    if isSub
        subplot(nsub(1),nsub(2),nsub(3));
    end
    hold on;
    fill(xs,ys,'','facecolor',color,'edgecolor',color,'linewidth',10^-10);
    %% Out:
    out_info = 1;
end