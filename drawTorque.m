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
function [out_info] = drawTorque(X,Y,b,r,value,maxvalue,varargin)
    %% Init:
    stdinp = 6;
    color = [0,0,0];
    isFig = 0;
    isSub = 0;
    lw = 1;
    fsw = 20*(2*pi/360); % Pfeilspitzenwinkel (einseitig)
    alpha0 = 0;
    dAlphaMax = 2*pi;
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
                case 'linewidth'
                    lw = varargin{i+1};
                    i = i+1;
                case 'alpha_0'
                    alpha0 = varargin{i+1};
                    i = i+1;
                case 'delta_alpha_max'
                    dAlphaMax = varargin{i+1};
                    i = i+1;
                otherwise
                    error('No such element: %s',varargin{i});
            end
            i = i+1;
        end
    end
    %% Calc:
    dalpha = dAlphaMax*sgn(value)*abs(value/maxvalue);
    l = abs(2*dalpha*r);
    % Referenzpfeil:
    xsr = sign(dalpha)*[linspace(0,l,Nu),linspace(l,max([0,l-b/(2*tan(fsw))]),Nu),NaN,linspace(max([0,l-b/(2*tan(fsw))]),l,Nu)];
    ysr = [linspace(0,0,Nu),linspace(0,+b/2,Nu),NaN,linspace(-b/2,0,Nu)];
    % Transformation:
    xs = X+(r+ysr).*cos(alpha0+xsr./(2*r));
    ys = Y+(r+ysr).*sin(alpha0+xsr./(2*r));
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