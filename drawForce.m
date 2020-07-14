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
function [out_info] = drawForce(X,Y,b,vector,varargin)
    %% Init:
    stdinp = 4;
    color = [0,0,0];
    isFig = 0;
    isSub = 0;
    lw = 1;
    ms = 10;
    fsw = 20*(2*pi/360); % Pfeilspitzenwinkel (einseitig)
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
                case 'markersize'
                    ms = varargin{i+1};
                    i = i+1;
                otherwise
                    error('No such element: %s',varargin{i});
            end
            i = i+1;
        end
    end
    %% Calc:
    l = sqrt(vector(1)^2+vector(2)^2);
    alpha = atan2(vector(2),vector(1));
    % Referenzpfeil:
    xsr = [0,l,max([0,l-b/(2*tan(fsw))]),NaN,max([0,l-b/(2*tan(fsw))]),l];
    ysr = [0,0,+b/2,NaN,-b/2,0];
    % Transformation:
    xs = X+xsr*cos(alpha)+ysr*sin(alpha);
    ys = Y+xsr*sin(alpha)-ysr*cos(alpha);
    %% Plot:
    if isFig
        figure(nfig);
    end
    if isSub
        subplot(nsub(1),nsub(2),nsub(3));
    end
    hold on;
    plot(xs,ys,'-',X,Y,'.','Color',color,'LineWidth',lw,'MarkerSize',ms);
    %% Out:
    out_info = 1;
end