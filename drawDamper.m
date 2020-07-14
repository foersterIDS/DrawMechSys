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
function [out_info] = drawDamper(X,Y,b,lmin,varargin)
    %% Init:
    stdinp = 4;
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
                case 'markersize'
                    ms = varargin{i+1};
                    i = i+1;
                otherwise
                    error('No such element: %s',varargin{i});
            end
            i = i+1;
        end
    end
    if lmin<0
        error('lmin must be lmin>=0');
    elseif sqrt((X(2)-X(1))^2+(Y(2)-Y(1))^2)<lmin
        error('Distance smaller than lmin!');
    end
    %% Calc:
    xa = X(1);
    ya = Y(1);
    xe = X(2);
    ye = Y(2);
    l = sqrt((xe-xa)^2+(ye-ya)^2);
    % Referenzdaempfer:
    xsr = [0,lmin/3,NaN,...
           lmin/3,lmin/3,l-lmin/3,NaN,...
           lmin/3,l-lmin/3,NaN,...
           l-2*lmin/3,l-2*lmin/3,NaN,...
           l-2*lmin/3,l];
    ysr = [0,0,NaN,...
           -b/2,+b/2,+b/2,NaN,...
           -b/2,-b/2,NaN,...
           -b/4,+b/4,NaN,...
           0,0];
    % Transformation:
    alpha = atan((ye-ya)/(xe-xa));
    xs = xa+sgn(xe-xa)*(xsr*cos(alpha)+ysr*sin(alpha));
    ys = ya+sgn(xe-xa)*(xsr*sin(alpha)-ysr*cos(alpha));
    %% Plot:
    if isFig
        figure(nfig);
    end
    if isSub
        subplot(nsub(1),nsub(2),nsub(3));
    end
    hold on;
    plot(xs,ys,'-',[xa,xe],[ya,ye],'.','MarkerSize',ms,'Color',color,'LineWidth',lw);
    %% Out:
    out_info = 1;
end