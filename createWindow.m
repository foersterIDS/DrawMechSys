function f = createWindow(xLimits,yLimits,yResolution,varargin)
    %CREATEWINDOW(xLimits,yLimits,yResolution)
    % creates blank window
    %% Init:
    xLimits = sort(xLimits);
    yLimits = sort(yLimits);
    stdinp = 3;
    isFig = 0;
    gridon = 0;
    gridcolor = 233/255*[1,1,1];
    gridx = 1;
    gridy = 1;
    glw = 2;
    backcolor = [1,1,1];
    %% Input:
    if nargin>stdinp
        i = 1;
        while i<=nargin-stdinp
            switch lower(varargin{i})
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
                    gridcolor = varargin{i+1};
                    i = i+1;
                case 'gridx'
                    gridx = varargin{i+1};
                    i = i+1;
                case 'gridy'
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
                    glw = varargin{i+1};
                    i = i+1;
                otherwise
                    error('No such element: %s',varargin{i});
            end
            i = i+1;
        end
    end
    %% get screen resolution
    mScreenSize = get(groot,'ScreenSize'); % scaled pixels
    jScreenSize = java.awt.Toolkit.getDefaultToolkit.getScreenSize; % actual pixels
    scaleFactor = mScreenSize(3) / jScreenSize.getWidth ;
    %% calculate figure width
    xResolution = yResolution * diff(xLimits) / diff(yLimits);
    if xResolution > jScreenSize.getWidth || yResolution > jScreenSize.getHeight
        error('The requested size is larger than the screen resolution')
    end
    %% place figure in center of screen
    offsetX = (jScreenSize.getWidth - xResolution) / 2;
    offsetY = (jScreenSize.getHeight - yResolution) / 2;
    fPosition = [offsetX offsetY xResolution yResolution]*scaleFactor;
    %% create figure
    if isFig
        f = figure(nfig);
        clf(f,'reset');
    else
        f = figure;
    end
    f.Color = backcolor;
    f.Position = fPosition;
    %% create axes
    ax = axes;
    ax.Position = [0,0,1,1];
    axis off
    hold on
    xlim(xLimits);
    ylim(yLimits);
    %% Grid:
    if gridon
        hold on;
        if mod((xLimits(2)-xLimits(1)),gridx)~=0
            error('gridx must fit xmax-xmin!');
        end
        if mod((yLimits(2)-yLimits(1)),gridy)~=0
            error('gridy must fit ymax-ymin!');
        end
        xgrid = [kron(xLimits(1):gridx:xLimits(2),[1,1,NaN]),kron(ones(1,round((yLimits(2)-yLimits(1))/gridy+1)),[xLimits(1),xLimits(2),NaN])];
        ygrid = [kron(ones(1,round((xLimits(2)-xLimits(1))/gridx+1)),[yLimits(1),yLimits(2),NaN]),kron(yLimits(1):gridy:yLimits(2),[1,1,NaN])];
        plot(xgrid,ygrid,'-','Color',gridcolor,'LineWidth',glw);
    end
    set(f, 'Resize', 'off');
end