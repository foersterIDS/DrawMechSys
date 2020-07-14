classdef rotwall < handle
    
    properties
        window
        id
        position
        angle
        radius
        b
        orientation
        direction = 1;
        Nu = 100;
        npl
        vis = 0.3;
        visOn = 0;
        handl
    end
    properties (Dependent)
        color
    end
    
    methods
        function obj = rotwall(center,radius,angle,b,npl,orientation,varargin)
            %% Init:
            stdinp = 6;
            Color = [0,0,0];
            lw = 3;
            obj.position = center;
            obj.angle = angle;
            obj.radius = radius;
            obj.npl = npl;
            obj.b = b;
            if orientation>=0
                obj.orientation = +1;
            else
                obj.orientation = -1;
            end
            %% Input:
            if nargin>stdinp
                i = 1;
                while i<=nargin-stdinp
                    switch lower(varargin{i})
                        case 'color'
                            obj.color = varargin{i+1};
                            i = i+1;
                        case 'linewidth'
                            lw = varargin{i+1};
                            i = i+1;
                        case 'direction'
                            obj.direction = sgn(varargin{i+1});
                            i = i+1;
                        case 'markervisibility'
                            if strcmpi(varargin{i+1},'on')
                                obj.visOn = 1;
                            elseif strcmpi(varargin{i+1},'off')
                                obj.visOn = 0;
                            end
                            i = i+1;
                        case 'window'
                            obj.window = varargin{i+1};
                            obj.id = varargin{i+2};
                            i = i+2;
                        otherwise
                            error('No such element: %s',varargin{i});
                    end
                    i = i+1;
                end
            end
            %% Calc:
            while obj.angle(1)>obj.angle(2)
                obj.angle(2) = obj.angle(2)+2*pi;
            end
            while obj.angle(1)<-pi
                obj.angle = obj.angle+2*pi;
            end
            da = (obj.angle(2)-obj.angle(1))/10;
            xsr1 = obj.radius*cos(linspace(obj.angle(1),obj.angle(1)+da,obj.Nu));
            ysr1 = obj.radius*sin(linspace(obj.angle(1),obj.angle(1)+da,obj.Nu));
            xsr2 = obj.radius*cos(linspace(obj.angle(2)-da,obj.angle(2),obj.Nu));
            ysr2 = obj.radius*sin(linspace(obj.angle(2)-da,obj.angle(2),obj.Nu));
            xsr3 = obj.radius*cos(linspace(obj.angle(1)+da,obj.angle(2)-da,obj.Nu));
            ysr3 = obj.radius*sin(linspace(obj.angle(1)+da,obj.angle(2)-da,obj.Nu));
            R = max([obj.radius,obj.radius+obj.orientation*obj.b]);
            r = min([obj.radius,obj.radius+obj.orientation*obj.b]);
            im = round(2/sqrt(2)*R*obj.npl-0.5);
            fi = @(x,i) obj.direction*(x-i/obj.npl);
            xsr4 = NaN;
            ysr4 = NaN;
            for i=-im:1:im
                xr1 = (obj.direction^2*i-sqrt(-obj.direction^2*i^2+obj.npl^2*r^2+obj.direction^2*obj.npl^2*r^2))/(obj.npl+obj.direction^2*obj.npl);
                xr2 = (obj.direction^2*i+sqrt(-obj.direction^2*i^2+obj.npl^2*r^2+obj.direction^2*obj.npl^2*r^2))/(obj.npl+obj.direction^2*obj.npl);
                yr1 = fi(xr1,i);
                yr2 = fi(xr2,i);
                xR1 = (obj.direction^2*i-sqrt(-obj.direction^2*i^2+obj.npl^2*R^2+obj.direction^2*obj.npl^2*R^2))/(obj.npl+obj.direction^2*obj.npl);
                xR2 = (obj.direction^2*i+sqrt(-obj.direction^2*i^2+obj.npl^2*R^2+obj.direction^2*obj.npl^2*R^2))/(obj.npl+obj.direction^2*obj.npl);
                yR1 = fi(xR1,i);
                yR2 = fi(xR2,i);
                if imag(xr1)==0 && imag(xR1)==0
                    [xx1,yy1] = obj.anglecorrection([xr1,xR1],[yr1,yR1],angle);
                    [xx2,yy2] = obj.anglecorrection([xr2,xR2],[yr2,yR2],angle);
                    xsr4 = [xsr4,xx1,NaN,xx2,NaN];
                    ysr4 = [ysr4,yy1,NaN,yy2,NaN];
                else
                    [xx,yy] = obj.anglecorrection([xR1,xR2],[yR1,yR2],angle);
                    xsr4 = [xsr4,xx,NaN];
                    ysr4 = [ysr4,yy,NaN];
                end
            end
            %% Transformation:
            xs1 = obj.position(1)+xsr1;
            ys1 = obj.position(2)+ysr1;
            xs2 = obj.position(1)+xsr2;
            ys2 = obj.position(2)+ysr2;
            xs3 = obj.position(1)+xsr3;
            ys3 = obj.position(2)+ysr3;
            xs4 = obj.position(1)+xsr4;
            ys4 = obj.position(2)+ysr4;
            %% Plot:
            obj.handl = cell(5,1);
            obj.handl{4} = plot(xs4,ys4,'Color',Color,'LineWidth',lw/2,'buttondownfcn',{@Mouse_Callback,'downm',obj}); % Schrafur
            obj.handl{1} = plot(xs1,ys1,'Color',Color,'LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'down',obj}); % links
            obj.handl{2} = plot(xs2,ys2,'Color',Color,'LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'down',obj}); % rechts
            obj.handl{3} = plot(xs3,ys3,'Color',Color,'LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'downm',obj}); % mitte
            obj.handl{5} = scatter(obj.position(1),obj.position(2),'o','MarkerFaceColor','m','MarkerEdgeColor','m','LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'drag',obj}); % centerpunkt
            obj.handl{5}.MarkerFaceAlpha = 0;
            obj.handl{5}.MarkerEdgeAlpha = obj.visOn*obj.vis;
            
            %% Callback function:
            function Mouse_Callback(hObj,~,action,sObj)
                persistent curobj xdata ydata ind xdatarel ydatarel cen
                pos = get(gca,'CurrentPoint');
                switch action
                    case 'down'
                        curobj = sObj;
                        xdata = curobj.position(1)+curobj.radius*cos(curobj.angle);
                        ydata = curobj.position(2)+curobj.radius*sin(curobj.angle);
                        [~,ind] = min(sum((xdata-pos(1)).^2+(ydata-pos(3)).^2,1));
                        set(gcf,...
                            'WindowButtonMotionFcn',  {@Mouse_Callback,'move'},...
                            'WindowButtonUpFcn',      {@Mouse_Callback,'up'});
                    case 'move'
                        ang = curobj.angle;
                        ang(ind) = atan2(pos(3)-curobj.position(2),pos(1)-curobj.position(1));
%                         rad = sqrt((pos(3)-curobj.position(2)).^2+(pos(1)-curobj.position(1)).^2);
                        rad = curobj.radius;
                        % update
                        curobj.setPosition(curobj.position,rad,ang);
                    case 'downm'
                        curobj = sObj;
                        cen = curobj.position;
                        set(gcf,...
                            'WindowButtonMotionFcn',  {@Mouse_Callback,'movem'},...
                            'WindowButtonUpFcn',      {@Mouse_Callback,'up'});
                    case 'movem'
                        rad = sqrt((pos(3)-cen(2))^2+(pos(1)-cen(1))^2);
                        % update
                        curobj.setPosition(curobj.position,rad,curobj.angle);
                    case 'drag'
                        curobj = sObj;
                        xdatarel = curobj.position(1)-pos(1);
                        ydatarel = curobj.position(2)-pos(3);
                        set(gcf,...
                            'WindowButtonMotionFcn',  {@Mouse_Callback,'dodrag'},...
                            'WindowButtonUpFcn',      {@Mouse_Callback,'up'});
                    case 'dodrag'
                        % update
                        curobj.setPosition([xdatarel+pos(1),ydatarel+pos(3)],curobj.radius,curobj.angle);
                    case 'up'
                        set(gcf,...
                            'WindowButtonMotionFcn',  '',...
                            'WindowButtonUpFcn',      '');
                end
            end
            
            %% Context menus:
            % m:
            plmcontext = uicontextmenu;
            obj.handl{3}.UIContextMenu = plmcontext;
            obj.handl{4}.UIContextMenu = plmcontext;
            plmcontext1 = uimenu(plmcontext,'Label','change color');
            plmcontext1_1 = uimenu('Parent',plmcontext1,'Label','blue','Callback',{@ct_setcolor,obj});
            plmcontext1_2 = uimenu('Parent',plmcontext1,'Label','red','Callback',{@ct_setcolor,obj});
            plmcontext1_3 = uimenu('Parent',plmcontext1,'Label','magenta','Callback',{@ct_setcolor,obj});
            plmcontext1_4 = uimenu('Parent',plmcontext1,'Label','green','Callback',{@ct_setcolor,obj});
            plmcontext1_5 = uimenu('Parent',plmcontext1,'Label','yellow','Callback',{@ct_setcolor,obj});
            plmcontext1_6 = uimenu('Parent',plmcontext1,'Label','black','Callback',{@ct_setcolor,obj});
            plmcontext1_7 = uimenu('Parent',plmcontext1,'Label','white','Callback',{@ct_setcolor,obj});
            plmcontext1_8 = uimenu('Parent',plmcontext1,'Label','random','Callback',{@ct_setcolor,obj});
            plmcontext2 = uimenu(plmcontext,'Label','change direction','Callback',{@ct_changeDirection,obj});
            plmcontext3 = uimenu(plmcontext,'Label','change orientation','Callback',{@ct_changeOrientation,obj});
            plmcontext4 = uimenu(plmcontext,'Label','delete','Callback',{@ct_delete,obj});
            % l:
            pllcontext = uicontextmenu;
            obj.handl{1}.UIContextMenu = pllcontext;
            pllcontext1 = uimenu(pllcontext,'Label','change color');
            pllcontext1_1 = uimenu('Parent',pllcontext1,'Label','blue','Callback',{@ct_setcolor,obj});
            pllcontext1_2 = uimenu('Parent',pllcontext1,'Label','red','Callback',{@ct_setcolor,obj});
            pllcontext1_3 = uimenu('Parent',pllcontext1,'Label','magenta','Callback',{@ct_setcolor,obj});
            pllcontext1_4 = uimenu('Parent',pllcontext1,'Label','green','Callback',{@ct_setcolor,obj});
            pllcontext1_5 = uimenu('Parent',pllcontext1,'Label','yellow','Callback',{@ct_setcolor,obj});
            pllcontext1_6 = uimenu('Parent',pllcontext1,'Label','black','Callback',{@ct_setcolor,obj});
            pllcontext1_7 = uimenu('Parent',pllcontext1,'Label','white','Callback',{@ct_setcolor,obj});
            pllcontext1_8 = uimenu('Parent',pllcontext1,'Label','random','Callback',{@ct_setcolor,obj});
            pllcontext2 = uimenu(pllcontext,'Label','bind','Callback',{@ct_bind,obj,1});
            pllcontext3 = uimenu(pllcontext,'Label','set position','Callback',{@ct_setposition,obj,1});
            pllcontext4 = uimenu(pllcontext,'Label','change direction','Callback',{@ct_changeDirection,obj});
            pllcontext5 = uimenu(pllcontext,'Label','change orientation','Callback',{@ct_changeOrientation,obj});
            pllcontext6 = uimenu(pllcontext,'Label','delete','Callback',{@ct_delete,obj});
            % r:
            plrcontext = uicontextmenu;
            obj.handl{2}.UIContextMenu = plrcontext;
            plrcontext1 = uimenu(plrcontext,'Label','change color');
            plrcontext1_1 = uimenu('Parent',plrcontext1,'Label','blue','Callback',{@ct_setcolor,obj});
            plrcontext1_2 = uimenu('Parent',plrcontext1,'Label','red','Callback',{@ct_setcolor,obj});
            plrcontext1_3 = uimenu('Parent',plrcontext1,'Label','magenta','Callback',{@ct_setcolor,obj});
            plrcontext1_4 = uimenu('Parent',plrcontext1,'Label','green','Callback',{@ct_setcolor,obj});
            plrcontext1_5 = uimenu('Parent',plrcontext1,'Label','yellow','Callback',{@ct_setcolor,obj});
            plrcontext1_6 = uimenu('Parent',plrcontext1,'Label','black','Callback',{@ct_setcolor,obj});
            plrcontext1_7 = uimenu('Parent',plrcontext1,'Label','white','Callback',{@ct_setcolor,obj});
            plrcontext1_8 = uimenu('Parent',plrcontext1,'Label','random','Callback',{@ct_setcolor,obj});
            plrcontext2 = uimenu(plrcontext,'Label','bind','Callback',{@ct_bind,obj,2});
            plrcontext3 = uimenu(plrcontext,'Label','set position','Callback',{@ct_setposition,obj,2});
            plrcontext4 = uimenu(plrcontext,'Label','change direction','Callback',{@ct_changeDirection,obj});
            plrcontext5 = uimenu(plrcontext,'Label','change orientation','Callback',{@ct_changeOrientation,obj});
            plrcontext6 = uimenu(plrcontext,'Label','delete','Callback',{@ct_delete,obj});
            % c:
            plccontext = uicontextmenu;
            obj.handl{5}.UIContextMenu = plccontext;
            plccontext1 = uimenu(plccontext,'Label','change color');
            plccontext1_1 = uimenu('Parent',plccontext1,'Label','blue','Callback',{@ct_setcolor,obj});
            plccontext1_2 = uimenu('Parent',plccontext1,'Label','red','Callback',{@ct_setcolor,obj});
            plccontext1_3 = uimenu('Parent',plccontext1,'Label','magenta','Callback',{@ct_setcolor,obj});
            plccontext1_4 = uimenu('Parent',plccontext1,'Label','green','Callback',{@ct_setcolor,obj});
            plccontext1_5 = uimenu('Parent',plccontext1,'Label','yellow','Callback',{@ct_setcolor,obj});
            plccontext1_6 = uimenu('Parent',plccontext1,'Label','black','Callback',{@ct_setcolor,obj});
            plccontext1_7 = uimenu('Parent',plccontext1,'Label','white','Callback',{@ct_setcolor,obj});
            plccontext1_8 = uimenu('Parent',plccontext1,'Label','random','Callback',{@ct_setcolor,obj});
            plccontext2 = uimenu(plccontext,'Label','bind','Callback',{@ct_bind,obj,2});
            plccontext3 = uimenu(plccontext,'Label','set position','Callback',{@ct_setposition,obj,2});
            plccontext4 = uimenu(plccontext,'Label','change direction','Callback',{@ct_changeDirection,obj});
            plccontext5 = uimenu(plccontext,'Label','change orientation','Callback',{@ct_changeOrientation,obj});
            plccontext6 = uimenu(plccontext,'Label','change visibility','Callback',{@ct_changeVisibility,obj});
            plccontext7 = uimenu(plccontext,'Label','delete','Callback',{@ct_delete,obj});
            
            %% Context functions:
            function ct_setcolor(src,event,curobj)
                curobj.color = systemColors(src.Label);
            end
            
            function ct_bind(src,event,obj,index)
                warning('"bind" is not functional yet!');
            end
            
            function ct_setposition(src,event,obj,index)
                warning('"set position" is not functional yet!');
            end
            
            function ct_delete(src,event,obj)
                obj.delete();
            end
            
            function ct_changeDirection(src,event,obj)
                obj.changeDirection();
            end
            
            function ct_changeVisibility(src,event,obj)
                obj.changeVisibility();
            end
            
            function ct_changeOrientation(src,event,obj)
                obj.changeOrientation();
            end
        end
        
        function setPosition(obj,center,radius,angle)
            obj.position = center;
            obj.angle = angle;
            obj.radius = radius;
            %% Calc:
            while obj.angle(1)>obj.angle(2)
                obj.angle(2) = obj.angle(2)+2*pi;
            end
            while obj.angle(1)<-pi
                obj.angle = obj.angle+2*pi;
            end
            da = (obj.angle(2)-obj.angle(1))/10;
            xsr1 = obj.radius*cos(linspace(obj.angle(1),obj.angle(1)+da,obj.Nu));
            ysr1 = obj.radius*sin(linspace(obj.angle(1),obj.angle(1)+da,obj.Nu));
            xsr2 = obj.radius*cos(linspace(obj.angle(2)-da,obj.angle(2),obj.Nu));
            ysr2 = obj.radius*sin(linspace(obj.angle(2)-da,obj.angle(2),obj.Nu));
            xsr3 = obj.radius*cos(linspace(obj.angle(1)+da,obj.angle(2)-da,obj.Nu));
            ysr3 = obj.radius*sin(linspace(obj.angle(1)+da,obj.angle(2)-da,obj.Nu));
            R = max([obj.radius,obj.radius+obj.orientation*obj.b]);
            r = min([obj.radius,obj.radius+obj.orientation*obj.b]);
            im = round(2/sqrt(2)*R*obj.npl-0.5);
            fi = @(x,i) obj.direction*(x-i/obj.npl);
            xsr4 = NaN;
            ysr4 = NaN;
            for i=-im:1:im
                xr1 = (obj.direction^2*i-sqrt(-obj.direction^2*i^2+obj.npl^2*r^2+obj.direction^2*obj.npl^2*r^2))/(obj.npl+obj.direction^2*obj.npl);
                xr2 = (obj.direction^2*i+sqrt(-obj.direction^2*i^2+obj.npl^2*r^2+obj.direction^2*obj.npl^2*r^2))/(obj.npl+obj.direction^2*obj.npl);
                yr1 = fi(xr1,i);
                yr2 = fi(xr2,i);
                xR1 = (obj.direction^2*i-sqrt(-obj.direction^2*i^2+obj.npl^2*R^2+obj.direction^2*obj.npl^2*R^2))/(obj.npl+obj.direction^2*obj.npl);
                xR2 = (obj.direction^2*i+sqrt(-obj.direction^2*i^2+obj.npl^2*R^2+obj.direction^2*obj.npl^2*R^2))/(obj.npl+obj.direction^2*obj.npl);
                yR1 = fi(xR1,i);
                yR2 = fi(xR2,i);
                if imag(xr1)==0 && imag(xR1)==0
                    [xx1,yy1] = obj.anglecorrection([xr1,xR1],[yr1,yR1],angle);
                    [xx2,yy2] = obj.anglecorrection([xr2,xR2],[yr2,yR2],angle);
                    xsr4 = [xsr4,xx1,NaN,xx2,NaN];
                    ysr4 = [ysr4,yy1,NaN,yy2,NaN];
                else
                    [xx,yy] = obj.anglecorrection([xR1,xR2],[yR1,yR2],angle);
                    xsr4 = [xsr4,xx,NaN];
                    ysr4 = [ysr4,yy,NaN];
                end
            end
            %% Transformation:
            xs1 = obj.position(1)+xsr1;
            ys1 = obj.position(2)+ysr1;
            xs2 = obj.position(1)+xsr2;
            ys2 = obj.position(2)+ysr2;
            xs3 = obj.position(1)+xsr3;
            ys3 = obj.position(2)+ysr3;
            xs4 = obj.position(1)+xsr4;
            ys4 = obj.position(2)+ysr4;
            %% Plot:
            obj.handl{4}.XData = xs4;
            obj.handl{4}.YData = ys4;
            obj.handl{1}.XData = xs1;
            obj.handl{1}.YData = ys1;
            obj.handl{2}.XData = xs2;
            obj.handl{2}.YData = ys2;
            obj.handl{3}.XData = xs3;
            obj.handl{3}.YData = ys3;
            obj.handl{5}.XData = obj.position(1);
            obj.handl{5}.YData = obj.position(2);
        end
        
        function [XX,YY] = anglecorrection(obj,X,Y,angle)
            f = @(x) (Y(2)-Y(1))/(X(2)-X(1))*x+(Y(1)-(Y(2)-Y(1))/(X(2)-X(1))*X(1));
            while angle(1)>angle(2)
                angle(2) = angle(2)+2*pi;
            end
            while angle(1)<-pi
                angle = angle+2*pi;
            end
            Nl = 100;
            XX_ = linspace(X(1),X(2),Nl);
            YY_ = f(XX_);
            XX = [];
            YY = [];
            for k=1:Nl
                a = atan2(YY_(k),XX_(k));
                while a<angle(1)
                    a = a+2*pi;
                end
                if a<=angle(2)
                    XX = [XX,XX_(k)];
                    YY = [YY,YY_(k)];
                else
                    if ~isempty(XX)
                        if ~isnan(XX(end))
                            XX = [XX,NaN];
                            YY = [YY,NaN];
                        end
                    end
                end
            end
        end
        
        function delete(obj)
            delete(obj.handl{1});
            delete(obj.handl{2});
            delete(obj.handl{3});
            delete(obj.handl{4});
            delete(obj.handl{5});
            obj.window.deleteObject(obj.id);
        end
        
        function changeDirection(obj)
            obj.direction = -1*obj.direction;
            obj.setPosition(obj.position,obj.radius,obj.angle);
        end
        
        function changeOrientation(obj)
            obj.orientation = -1*obj.orientation;
            obj.setPosition(obj.position,obj.radius,obj.angle);
        end
        
        function changeVisibility(obj)
            if obj.visOn
                obj.handl{5}.MarkerEdgeAlpha = 0;
                obj.visOn = 0;
            else
                obj.handl{5}.MarkerEdgeAlpha = obj.vis;
                obj.visOn = 1;
            end
        end
        
        function set.color(obj,newcolor)
            obj.handl{1}.Color = newcolor;
            obj.handl{2}.Color = newcolor;
            obj.handl{3}.Color = newcolor;
            obj.handl{4}.Color = newcolor;
        end
        
        function col = get.color(obj)
            col = obj.handl{1}.Color;
        end
    end
end