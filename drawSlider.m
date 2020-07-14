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
function [out_info,xcon,ycon] = drawSlider(X,Y,b,orientation,varargin)
    %% Init:
    stdinp = 4;
    color = [0,0,0];
    facecolor = [1,1,1];
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
    % Referenz-Slider:
    % Los:
    xsr = [0,+b/2,-b/2,0];
    ysr = [0,sqrt(3)*b/2,sqrt(3)*b/2,0];
    % Transformation:
    alpha = atan2(orientation(1),orientation(2));
    xs = X+(-xsr*cos(alpha)+ysr*sin(alpha));
    ys = Y+(xsr*sin(alpha)+ysr*cos(alpha));
    %% Plot:
    if isFig
        figure(nfig);
    end
    if isSub
        subplot(nsub(1),nsub(2),nsub(3));
    end
    hold on;
    fill(xs,ys,'','FaceColor',facecolor,'EdgeColor',color,'LineWidth',lw);
    %% Out:
    out_info = 1;
    xcon = xs(2:3);
    ycon = ys(2:3);
end