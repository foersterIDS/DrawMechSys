function cS = createCoordinateSystem(x,y,ex,ey,b,NameValueArgs)
    arguments
        x (1,1) double
        y (1,1) double
        ex (2,1) double
        ey (2,1) double
        b (1,1) double
        NameValueArgs.showZ (1,1) logical = false;
        NameValueArgs.r (1,1) double
        NameValueArgs.LineWidth (1,1) double = 2;
    end

    cS.xArrow = gfx2d.force(x,y,b,ex,'LineWidth',NameValueArgs.LineWidth);
    cS.yArrow = gfx2d.force(x,y,b,ey,'LineWidth',NameValueArgs.LineWidth);
    rU = 0.05*max(vecnorm([ex,ey]));
    cS.Circle = gfx2d.joint(x,y,2*rU,'Facecolor','k','LineWidth',NameValueArgs.LineWidth);
    
    if NameValueArgs.showZ
        if isfield(NameValueArgs,'r')
            rZ = NameValueArgs.r;
        else
            rZ = 0.2*max(vecnorm([ex,ey]));
        end
        cS.CircleZ = gfx2d.joint(x,y,2*rZ,'Facecolor','none','LineWidth',NameValueArgs.LineWidth);
    end
end