clear; close all; clc;

%% Mass 3D
widthMass = 2;
heightMass = 1;
depthMass = 3;

figure('Color',[1,1,1]); clf;
axis equal;
axis([-2 2 -2 2 -4 4]); hold on;
view(30,30);
set(gca,'Visible','off');

pMass = drawMass([],0,0,0,widthMass,heightMass,depthMass,[0,0,0]*pi/180);

points = [-widthMass/2,-depthMass/2,-heightMass/2;
          widthMass/2,-depthMass/2,-heightMass/2
          -widthMass/2,depthMass/2,-heightMass/2
          widthMass/2,depthMass/2,-heightMass/2];

for kk = 1:4
    pld1{kk} = plot3([points(kk,1), points(kk,1)],[points(kk,2), points(kk,2)],[points(kk,3), points(kk,3)-0.1],'k-');
    pld2{kk} = plot3([points(kk,1)-0.2, points(kk,1)+0.2],[points(kk,2), points(kk,2)],[points(kk,3)-0.1, points(kk,3)-0.1],'k-');
    pld3{kk} = plot3([points(kk,1), points(kk,1)],[points(kk,2), points(kk,2)],[points(kk,3)-1, points(kk,3)-1+0.1],'k-');
    pld4{kk} = plot3([points(kk,1)-0.2, points(kk,1)+0.2],[points(kk,2), points(kk,2)],[points(kk,3)-1+0.1, points(kk,3)-1+0.1],'k-');
    
    xStart = [points(kk,1)-0.2,-points(kk,2),points(kk,3)-0.1].';
    xEnd =   [points(kk,1)-0.2,-points(kk,2),points(kk,3)-1+0.1].';

    pSpring{kk} = drawSpring([],xStart,xEnd,0.1,10);

    xStart = [points(kk,1)+0.2,-points(kk,2),points(kk,3)-0.1].';
    xEnd =   [points(kk,1)+0.2,-points(kk,2),points(kk,3)-1+0.1].';
    pDamper{kk} = drawDamper([],xStart,xEnd,0.1);
end

phi = 5 * sin(linspace(0,2,100)*2*pi);

for jj = 1:100
    phid = phi(jj) * pi / 180;
    pMass = drawMass(pMass,0,0,0,widthMass,heightMass,depthMass,[0,0,phid]);
    for kk = 1:4
        if kk < 3
            s = -1;
        else
            s = 1;
        end
        pld1{kk}.XData = [points(kk,1), points(kk,1)];
        pld1{kk}.YData = [points(kk,2), points(kk,2)];
        pld1{kk}.ZData = [points(kk,3), points(kk,3)-0.1]+s*depthMass/2*sin(phid);
        pld2{kk}.XData = [points(kk,1)-0.2, points(kk,1)+0.2];
        pld2{kk}.YData = [points(kk,2), points(kk,2)];
        pld2{kk}.ZData = [points(kk,3)-0.1, points(kk,3)-0.1]+s*depthMass/2*sin(phid);
        pld3{kk}.XData = [points(kk,1), points(kk,1)];
        pld3{kk}.YData = [points(kk,2), points(kk,2)];
        pld3{kk}.ZData = [points(kk,3)-1, points(kk,3)-1+0.1];
        pld4{kk}.XData = [points(kk,1)-0.2, points(kk,1)+0.2];
        pld4{kk}.YData = [points(kk,2), points(kk,2)];
        pld4{kk}.ZData = [points(kk,3)-1+0.1, points(kk,3)-1+0.1];
        
        xStart = [points(kk,1)-0.2,-points(kk,2),points(kk,3)-0.1-s*depthMass/2*sin(phid)].';
        xEnd =   [points(kk,1)-0.2,-points(kk,2),points(kk,3)-1+0.1].';
    
        pSpring{kk} = drawSpring(pSpring{kk},xStart,xEnd,0.1,10);
    
        xStart = [points(kk,1)+0.2,-points(kk,2),points(kk,3)-0.1-s*depthMass/2*sin(phid)].';
        xEnd =   [points(kk,1)+0.2,-points(kk,2),points(kk,3)-1+0.1].';
        pDamper{kk} = drawDamper(pDamper{kk},xStart,xEnd,0.1);
    end
    drawnow;
end

function pMass = drawMass(pMass,x0,y0,z0,w,h,d,angles)
    t = [x0;y0;z0];
    
    R = eul2rotm(angles);

    xVHOU = (w/2)*[-1,1,1,-1];
    yVH = (d/2)*[1,1,1,1];
    zVH = (h/2)*[-1,-1,1,1];
    yOU = (d/2)*[-1,-1,1,1];
    zOU = (h/2)*[1,1,1,1];
    xLR = (w/2)*[1,1,1,1];
    yLR = (d/2)*[-1,1,1,-1];

    points{1} = [xVHOU;yVH;zVH];
    points{2} = [xVHOU;-yVH;zVH];
    points{3} = [xVHOU;yOU;zOU];
    points{4} = [xVHOU;yOU;-zOU];
    points{5} = [xLR;yLR;zVH];
    points{6} = [-xLR;yLR;zVH];

    if isempty(pMass)
        flag = true;
    else
        flag = false;
    end

    for kk = 1:length(points)
        points{kk} = R * points{kk} + t;
        if flag
            pMass{kk} = patch('XData',points{kk}(1,:),'YData',points{kk}(2,:),'ZData',points{kk}(3,:),'FaceColor',0.5*[1,1,1],'FaceAlpha',0.4);
        else
            pMass{kk}.XData = points{kk}(1,:);
            pMass{kk}.YData = points{kk}(2,:);
            pMass{kk}.ZData = points{kk}(3,:);
        end
    end
end

function plSpring = drawSpring(plSpring,xStart,xEnd,radius,n)
    l = norm(xEnd-xStart);
    v = (xEnd-xStart)/l;
    lmin = 0.1;
    r = radius;
    
    phi = linspace(0, 2*pi*n, 100);
    xr = r * cos(phi);
    yr = r * sin(phi);
    zr = linspace(-(l/2-lmin),l/2 - lmin,100);
    
    R = calcRotationOfVector([0;0;1],v);
    
    pr = [xr;yr;zr];
    pr = R * pr;
    
    xr = pr(1,:);
    yr = pr(2,:);
    zr = pr(3,:);
    
    xr = xr + xStart(1);
    yr = yr + xStart(2);
    zr = zr + xStart(3);
    
    xr = xr + (l/2)*v(1);
    yr = yr + (l/2)*v(2);
    zr = zr + (l/2)*v(3);
    if isempty(plSpring)
        plSpring{1} = plot3([xStart(1),xStart(1)+v(1)*lmin],[xStart(2),xStart(2)+v(2)*lmin],[xStart(3),xStart(3)+v(3)*lmin],'k-');
        plSpring{2} = plot3([xEnd(1),xEnd(1)-v(1)*lmin],[xEnd(2),xEnd(2)-v(2)*lmin],[xEnd(3),xEnd(3)-v(3)*lmin],'k-');
        plSpring{3} = plot3([xStart(1)+v(1)*lmin, xr(1)], [xStart(2)+v(2)*lmin, yr(1)], [xStart(3)+v(3)*lmin, zr(1)], 'k-');
        plSpring{4} = plot3([xEnd(1)-v(1)*lmin, xr(end)], [xEnd(2)-v(2)*lmin, yr(end)], [xEnd(3)-v(3)*lmin, zr(end)], 'k-');
        plSpring{5} = plot3(xr,yr,zr,'k-');
    else
        plSpring{1}.XData = [xStart(1),xStart(1)+v(1)*lmin];
        plSpring{1}.YData = [xStart(2),xStart(2)+v(2)*lmin];
        plSpring{1}.ZData = [xStart(3),xStart(3)+v(3)*lmin];

        plSpring{2}.XData = [xEnd(1),xEnd(1)-v(1)*lmin];
        plSpring{2}.YData = [xEnd(2),xEnd(2)-v(2)*lmin];
        plSpring{2}.ZData = [xEnd(3),xEnd(3)-v(3)*lmin];

        plSpring{3}.XData = [xStart(1)+v(1)*lmin, xr(1)];
        plSpring{3}.YData = [xStart(2)+v(2)*lmin, yr(1)];
        plSpring{3}.ZData = [xStart(3)+v(3)*lmin, zr(1)];

        plSpring{4}.XData = [xEnd(1)-v(1)*lmin, xr(end)];
        plSpring{4}.YData = [xEnd(2)-v(2)*lmin, yr(end)];
        plSpring{4}.ZData = [xEnd(3)-v(3)*lmin, zr(end)];

        plSpring{5}.XData = xr;
        plSpring{5}.YData = yr;
        plSpring{5}.ZData = zr;
    end
end

function plDamper = drawDamper(plDamper,xStart,xEnd,radius)
    l = norm(xEnd-xStart);
    v = (xEnd-xStart)/l;
    lmin = 0.1;
    r = radius;

    [XM,YM,ZM] = cylinder(r);
    ZM = (l - 2*lmin)*ZM - (l - 2*lmin)/2;
    
    R = calcRotationOfVector([0;0;1],v);
    
    pr1 = [XM(1,:);YM(1,:);ZM(1,:)];
    pr2 = [XM(2,:);YM(2,:);ZM(2,:)];
    pr1 = R * pr1;
    pr2 = R * pr2;
    
    XM = [pr1(1,:);pr2(1,:)];
    YM = [pr1(2,:);pr2(2,:)];
    ZM = [pr1(3,:);pr2(3,:)];
    
    XM = XM + xStart(1);
    YM = YM + xStart(2);
    ZM = ZM + xStart(3);
    
    XM = XM + (l/2)*v(1);
    YM = YM + (l/2)*v(2);
    ZM = ZM + (l/2)*v(3);
    
    % top and bottom
    rs = linspace(0,r,100);
    phi = linspace(0,2*pi,100);
    [Rs,Phi] = meshgrid(rs,phi);
    
    XTB = Rs .* cos(Phi);
    YTB = Rs .* sin(Phi);
    ZT = (l/2 - lmin) * ones(size(XTB));
    ZB = -(l/2-lmin) * ones(size(XTB));
    
    pr1 = [XTB(1,:);YTB(1,:);ZT(1,:)];
    pr2 = [XTB(2,:);YTB(2,:);ZT(2,:)];
    pr3 = [XTB(1,:);YTB(1,:);ZB(1,:)];
    pr4 = [XTB(2,:);YTB(2,:);ZB(2,:)];
    
    pr1 = R * pr1;
    pr2 = R * pr2;
    pr3 = R * pr3;
    pr4 = R * pr4;
    
    XT = [pr1(1,:);pr2(1,:)];
    YT = [pr1(2,:);pr2(2,:)];
    ZT = [pr1(3,:);pr2(3,:)];
    XB = [pr3(1,:);pr4(1,:)];
    YB = [pr3(2,:);pr4(2,:)];
    ZB = [pr3(3,:);pr4(3,:)];
    
    XT = XT + xStart(1);
    YT = YT + xStart(2);
    ZT = ZT + xStart(3);
    
    XB = XB + xStart(1);
    YB = YB + xStart(2);
    ZB = ZB + xStart(3);
    
    XT = XT + (l/2)*v(1);
    YT = YT + (l/2)*v(2);
    ZT = ZT + (l/2)*v(3);
    
    XB = XB + (l/2)*v(1);
    YB = YB + (l/2)*v(2);
    ZB = ZB + (l/2)*v(3);
    
    xTB = r .* cos(phi);
    yTB = r .* sin(phi);
    zT = (l/2 - lmin) * ones(size(phi));
    zB = -(l/2-lmin) * ones(size(phi));
    
    pr1 = [xTB;yTB;zT];
    pr2 = [xTB;yTB;zB];
    
    pr1 = R * pr1;
    pr2 = R * pr2;
    
    xT = pr1(1,:);
    yT = pr1(2,:);
    zT = pr1(3,:);
    xB = pr2(1,:);
    yB = pr2(2,:);
    zB = pr2(3,:);
    
    xT = xT + xStart(1);
    yT = yT + xStart(2);
    zT = zT + xStart(3);
    
    xB = xB + xStart(1);
    yB = yB + xStart(2);
    zB = zB + xStart(3);
    
    xT = xT + (l/2)*v(1);
    yT = yT + (l/2)*v(2);
    zT = zT + (l/2)*v(3);
    
    xB = xB + (l/2)*v(1);
    yB = yB + (l/2)*v(2);
    zB = zB + (l/2)*v(3);

    if ~isempty(plDamper)
        plDamper{1}.XData = [xStart(1),xStart(1)+v(1)*lmin];
        plDamper{1}.YData = [xStart(2),xStart(2)+v(2)*lmin];
        plDamper{1}.ZData = [xStart(3),xStart(3)+v(3)*lmin];

        plDamper{2}.XData = [xEnd(1),xEnd(1)-v(1)*lmin];
        plDamper{2}.YData = [xEnd(2),xEnd(2)-v(2)*lmin];
        plDamper{2}.ZData = [xEnd(3),xEnd(3)-v(3)*lmin];

        plDamper{3}.XData = XM;
        plDamper{3}.YData = YM;
        plDamper{3}.ZData = ZM;

        plDamper{4}.XData = XT;
        plDamper{4}.YData = YT;
        plDamper{4}.ZData = ZT;

        plDamper{5}.XData = XB;
        plDamper{5}.YData = YB;
        plDamper{5}.ZData = ZB;

        plDamper{6}.XData = xB;
        plDamper{6}.YData = yB;
        plDamper{6}.ZData = zB;

        plDamper{7}.XData = xT;
        plDamper{7}.YData = yT;
        plDamper{7}.ZData = zT;
    else
        plDamper{1} = plot3([xStart(1),xStart(1)+v(1)*lmin],[xStart(2),xStart(2)+v(2)*lmin],[xStart(3),xStart(3)+v(3)*lmin],'k-');
        plDamper{2} = plot3([xEnd(1),xEnd(1)-v(1)*lmin],[xEnd(2),xEnd(2)-v(2)*lmin],[xEnd(3),xEnd(3)-v(3)*lmin],'k-');
        plDamper{3} = surf(XM,YM,ZM,'EdgeColor','none','FaceColor',0.5*[1,1,1]);
        plDamper{4} = surf(XT,YT,ZT,'EdgeColor','none','FaceColor',0.5*[1,1,1]);
        plDamper{5} = surf(XB,YB,ZB,'EdgeColor','none','FaceColor',0.5*[1,1,1]);
        plDamper{6} = plot3(xB,yB,zB,'k-');
        plDamper{7} = plot3(xT,yT,zT,'k-');
    end
end

function R = calcRotationOfVector(v1,v2)
    if norm(v1-v2) == 0
        R = eye(3);
    elseif norm(v1+v2) == 0
        R = -eye(3);
    else
        % axis of rotation
        u = cross(v1, v2) / norm(cross(v1, v2));
    
        % angle of rotation
        alpha = atan2(norm(cross(v1, v2)), dot(v1, v2));
    
        sa = sin(alpha);
        ca = cos(alpha);
    
        % 3D rotation matrix:
        x  = u(1);
        y  = u(2);
        z  = u(3);
        mc = 1 - ca;
        R  = [ca + x * x * mc,      x * y * mc - z * sa,   x * z * mc + y * sa; ...
              x * y * mc + z * sa,  ca + y * y * mc,       y * z * mc - x * sa; ...
              x * z * mc - y * sa,  y * z * mc + x * sa,   ca + z * z .* mc];
    end
end