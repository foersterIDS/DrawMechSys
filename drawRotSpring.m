%% Info:
%
%   M.Sc. Alwin F�rster
%   Institut f�r Dynamik und Schwingungen
%   Leibniz Universit�t Hannover
%   Kontakt: foerster@ids.uni-hannover.de
%            +49-511-762-5381
%   �nderungsdatum: 22.10.2018
%   Ge�ndert durch: foerster
%
function [out_info] = drawRotSpring(X,Y,b,lmin,center,varargin)
    %% Init:
    stdinp = 5;
    color = [0,0,0];
    isFig = 0;
    isSub = 0;
    n = 4;
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
                case 'n'
                    n = varargin{i+1};
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
    dl = (l-lmin)/n;
    if lmin<0
        error('lmin must be lmin>=0');
    elseif l<lmin
        error('Distance smaller than lmin!');
    elseif n<2
        error('n must be at least 2');
    elseif round(sqrt((xa-center(1))^2+(ya-center(2))^2),8)~=round(sqrt((xe-center(1))^2+(ye-center(2))^2),8)
        error('The connection points do not have the same radius to the center point.');
    end
    % Referenzfeder:
    xsr = [0,lmin/2];
    ysr = [0,0];
    for w=1:n
        xsr = [xsr,lmin/2+dl*(w-1)+1/4*dl,lmin/2+dl*(w-1)+3/4*dl];
        ysr = [ysr,+b/2,-b/2];
    end
    xsr = [xsr,l-lmin/2,l];
    ysr = [ysr,0,0];
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
    plot(xs,ys,'-',[xa,xe],[ya,ye],'.','MarkerSize',ms,'Color',color,'LineWidth',lw);
    %% Out:
    out_info = 1;
end