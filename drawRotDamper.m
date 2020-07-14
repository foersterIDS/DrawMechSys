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
function [out_info] = drawRotDamper(X,Y,b,lmin,center,varargin)
    %% Init:
    stdinp = 5;
    color = [0,0,0];
    isFig = 0;
    isSub = 0;
    lw = 1;
    ms = 5*lw;
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
    xa = X(1);
    ya = Y(1);
    xe = X(2);
    ye = Y(2);
    radius = sqrt((xa-center(1))^2+(ya-center(2))^2);
    alphaa = atan2(ya-center(2),xa-center(1));
    alphae = atan2(ye-center(2),xe-center(1));
    if alphae<alphaa
        alpha = 2*pi+(alphae-alphaa);
    else
        alpha = alphae-alphaa;
    end
    alpha0 = atan2((ya-center(2)),(xa-center(1)));
    l = 2*alpha*radius;
    if lmin<0
        error('lmin must be lmin>=0');
    elseif l<lmin
        error('Distance smaller than lmin!');
    elseif round(sqrt((xa-center(1))^2+(ya-center(2))^2),8)~=round(sqrt((xe-center(1))^2+(ye-center(2))^2),8)
        error('The connection points do not have the same radius to the center point.');
    end
    % Referenzdaempfer:
    xsr = [linspace(0,lmin/3,Nu),NaN,...
           lmin/3,...
           linspace(lmin/3,l-lmin/3,Nu),NaN,...
           linspace(lmin/3,l-lmin/3,Nu),NaN,...
           l-2*lmin/3,l-2*lmin/3,NaN,...
           linspace(l-2*lmin/3,l,Nu)];
    ysr = [linspace(0,0,Nu),NaN,...
           -b/2,...
           linspace(+b/2,+b/2,Nu),NaN,...
           linspace(-b/2,-b/2,Nu),NaN,...
           -b/4,+b/4,NaN,...
           linspace(0,0,Nu)];
    % Transformation:
    xs = center(1)+(radius+ysr).*cos(alpha0+xsr./(2*radius));
    ys = center(2)+(radius+ysr).*sin(alpha0+xsr./(2*radius));
    if round(xs(end),6)~=round(xe,6) || round(ys(end),6)~=round(ye,6)
        xs = center(1)+(radius+ysr).*cos(alpha0-xsr./(2*radius));
        ys = center(2)+(radius+ysr).*sin(alpha0-xsr./(2*radius));
    end
    if round(xs(end),6)~=round(xe,6) || round(ys(end),6)~=round(ye,6)
        xs = center(1)+(radius+ysr).*cos(alpha0+xsr./(2*radius)-pi);
        ys = center(2)+(radius+ysr).*sin(alpha0+xsr./(2*radius)-pi);
    end
    if round(xs(end),6)~=round(xe,6) || round(ys(end),6)~=round(ye,6)
        xs = center(1)+(radius+ysr).*cos(alpha0-xsr./(2*radius)-pi);
        ys = center(2)+(radius+ysr).*sin(alpha0-xsr./(2*radius)-pi);
    end
    %% Plot:
    if isFig
        figure(nfig);
    end
    if isSub
        subplot(nsub(1),nsub(2),nsub(3));
    end
    hold on;
    plot(xs,ys,'-',[xa,xe],[ya,ye],'.','Color',color,'LineWidth',lw,'MarkerSize',ms);
    %% Out:
    out_info = 1;
end