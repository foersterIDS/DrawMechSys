function ax = DMSAxes(xLimits,yLimits,NameValueArgs)
    %DMSAxes(xLimits,yLimits,NameValueArgs)
    % creates blank axis
    %% Arguments:
    arguments
        xLimits (1,2) double
        yLimits (1,2) double
        NameValueArgs.grid (1,:) char {mustBeMember(NameValueArgs.grid,{'on','off'})} = 'off'
        NameValueArgs.gridcolor (1,:) = 233/255*[1,1,1]
        NameValueArgs.gridx (1,1) double = 1
        NameValueArgs.gridy (1,1) double = 1
        NameValueArgs.backcolor (1,:) = [1,1,1]
        NameValueArgs.gridlinewidth (1,1) double {mustBePositive} = 2
    end
    %% Init.:
    xLimits = sort(xLimits);
    yLimits = sort(yLimits);
    gridon = strcmp(NameValueArgs.grid,'on');
    gridcolor = getRGB(NameValueArgs.gridcolor);
    gridx = NameValueArgs.gridx;
    gridy = NameValueArgs.gridy;
    glw = NameValueArgs.gridlinewidth;
    backcolor = getRGB(NameValueArgs.backcolor);
    %% create axes
    ax = axes;
    set(ax,'Color',backcolor);
    axis off;
    axis equal;
    hold on;
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
end