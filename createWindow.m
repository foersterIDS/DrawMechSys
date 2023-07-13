function f = createWindow(xLimits,yLimits,yResolution,NameValueArgs)
    %CREATEWINDOW(xLimits,yLimits,yResolution)
    % creates blank window
    %% Arguments:
    arguments
        xLimits (1,2) double
        yLimits (1,2) double
        yResolution (1,1) double {mustBeInteger,mustBeGreaterThan(yResolution,0)}
        NameValueArgs.grid (1,:) char {mustBeMember(NameValueArgs.grid,{'on','off'})} = 'off'
        NameValueArgs.gridcolor (1,3) double = 233/255*[1,1,1]
        NameValueArgs.gridx (1,1) double = 1
        NameValueArgs.gridy (1,1) double = 1
        NameValueArgs.backcolor (1,3) double = [1,1,1]
        NameValueArgs.figure (1,1) double {mustBeInteger,mustBeGreaterThan(NameValueArgs.figure,0)}
        NameValueArgs.gridlinewidth (1,1) double {mustBePositive} = 2
    end
    %% Init.:
    xLimits = sort(xLimits);
    yLimits = sort(yLimits);
    isFig = isfield(NameValueArgs,'figure');
    if isFig
        nfig = NameValueArgs.figure;
    end
    gridon = strcmp(NameValueArgs.grid,'on');
    gridcolor = NameValueArgs.gridcolor;
    gridx = NameValueArgs.gridx;
    gridy = NameValueArgs.gridy;
    glw = NameValueArgs.gridlinewidth;
    backcolor = NameValueArgs.backcolor;
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
    set(f,'Color',backcolor);
    set(f,'Position',fPosition);
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