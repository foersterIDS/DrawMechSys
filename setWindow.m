%% Info:
%
%   M.Sc. Alwin Förster
%   Institut für Dynamik und Schwingungen
%   Leibniz Universität Hannover
%   Kontakt: foerster@ids.uni-hannover.de
%            +49-511-762-5381
%   Änderungsdatum: 21.11.2018
%   Geändert durch: foerster
%
function [out] = setWindow(varargin)
    %% Init:
    out = 1;
    stdinp = 0;
    isFig = 0;
    isSub = 0;
    gridon = 0;
    gridcolor = 233/255*[1,1,1];
    gridx = 1;
    gridy = 1;
    glw = 2;
    backcolor = [1,1,1];
    xmin = 0;
    xmax = 10;
    ymin = 0;
    ymax = 10;
    isAxis = 0;
    x_axis = [xmin,xmax,ymin,ymax];
    h = 720;
    b = h;
    setPixel = 0;
    %% Input:
    if nargin>stdinp
        i = 1;
        while i<=nargin-stdinp
            switch lower(varargin{i})
                case 'axis'
                    isAxis = 1;
                    x_axis = varargin{i+1};
                    xmin = x_axis(1);
                    xmax = x_axis(2);
                    ymin = x_axis(3);
                    ymax = x_axis(4);
                    i = i+1;
                case 'grid'
                    if strcmp(varargin{i+1},'on')
                        gridon = 1;
                    elseif strcmp(varargin{i+1},'off')
                        gridon = 0;
                    else
                        error('No such option for grid!');
                    end
                    i = i+1;
                case 'gridcolor'
                    gridon = 1;
                    gridcolor = varargin{i+1};
                    i = i+1;
                case 'gridx'
                    gridon = 1;
                    gridx = varargin{i+1};
                    i = i+1;
                case 'gridy'
                    gridon = 1;
                    gridy = varargin{i+1};
                    i = i+1;
                case 'backcolor'
                    backcolor = varargin{i+1};
                    i = i+1;
                case 'figure'
                    isFig = 1;
                    nfig = varargin{i+1};
                    i = i+1;
                case 'gridlinewidth'
                    gridon = 1;
                    glw = varargin{i+1};
                    i = i+1;
                case 'pixel'
                    setPixel = 1;
                    h = varargin{i+1};
                    i = i+1;
                otherwise
                    error('No such element: %s',varargin{i});
            end
            i = i+1;
        end
    end
    if ~isAxis
        error('axis must be set! [setWindow("axis",[xmin,xmax,ymin,ymax])]');
    end
    if setPixel
        b = h*(xmax-xmin)/(ymax-ymin);
    end
    %% Figure:
    if isFig
        figure(nfig);
    end
    if isSub
        subplot(nsub(1),nsub(2),nsub(3));
    end
    %% Background:
    axes('Box', 'off', 'Units', 'normalized', 'Position', [0 0 1 1]);
    set(gcf,'Color',backcolor,'Position',[100,100,b,h]);
    hold on;
    fill([xmin,xmax,xmax,xmin,xmin],[ymin,ymin,ymax,ymax,ymin],backcolor,'FaceColor',backcolor,'EdgeColor',backcolor-1/255);
    axis([xmin,xmax,ymin,ymax]);
    axis off;
    axis equal;
    %% Grid:
    if gridon
        hold on;
        if mod((xmax-xmin),gridx)~=0
            error('gridx must fit xmax-xmin!');
        end
        if mod((ymax-ymin),gridy)~=0
            error('gridy must fit ymax-ymin!');
        end
        xgrid = [kron(xmin:gridx:xmax,[1,1,NaN]),kron(ones(1,round((ymax-ymin)/gridy+1)),[xmin,xmax,NaN])];
        ygrid = [kron(ones(1,round((xmax-xmin)/gridx+1)),[ymin,ymax,NaN]),kron(ymin:gridy:ymax,[1,1,NaN])];
        plot(xgrid,ygrid,'-','Color',gridcolor,'LineWidth',glw);
    end
end