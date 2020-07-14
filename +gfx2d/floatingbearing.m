classdef floatingbearing < gfx2d.RigidBody
    
    % TODO: fix rotation error + wposition
    
    properties
        window
        id
        Nr = 50;
        b
        npl
        wposition
        position0
        direction
        plotHandle
    end
    properties (Dependent)
        color
        facecolor
    end
    
    methods
        function obj = floatingbearing(X,Y,b,X0,Y0,orientation,varargin)
            %% Init:
            stdinp = 6;
            color = [0,0,0];
            facecolor = [1,1,1];
            lw = 3;
            obj.b = b;
            obj.npl = 6/obj.b;
            if length(orientation)==1
                obj.angle = orientation;
            else
                obj.angle = atan2(orientation(2),orientation(1));
            end
            k = (X-X0)*cos(obj.angle)+(Y-Y0)*sin(obj.angle);
            XX = [X0;Y0]+[cos(obj.angle);sin(obj.angle)]*k;
            X = XX(1);
            Y = XX(2);
            obj.position = [X;Y];
            obj.position0 = [X0;Y0];
            obj.wposition = [cos(obj.angle),sin(obj.angle);-sin(obj.angle),cos(obj.angle)]*[obj.b*[-1/2,+1/2];(-obj.b)*[1,1]];
            %% Input:
            if nargin>stdinp
                i = 1;
                while i<=nargin-stdinp
                    switch lower(varargin{i})
                        case 'color'
                            color = varargin{i+1};
                            i = i+1;
                        case 'facecolor'
                            facecolor = varargin{i+1};
                            i = i+1;
                        case 'linewidth'
                            lw = varargin{i+1};
                            i = i+1;
%                         case 'wposition'
%                             obj.wposition = sort(-varargin{i+1});
%                             i = i+1;
                        case 'npl'
                            obj.npl = varargin{i+1};
                            i = i+1;
                        case 'direction'
                            obj.direction = sgn(varargin{i+1});
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
            r = obj.b/6;
            rs = 1/obj.npl;
            n = round(obj.npl*sqrt((obj.wposition(:,2)-obj.wposition(:,1))'*(obj.wposition(:,2)-obj.wposition(:,1)))-0.5);
            % Referenzlager:
            % Los:
            xsr1 = [-obj.b/2+r/2,r*cos(linspace(3*pi/2-atan(1/2),3*pi/2+atan(1/2),obj.Nr)),+obj.b/2-r/2,-obj.b/2+r/2];
            ysr1 = [+2*(-obj.b/2+r/2),r*sin(linspace(3*pi/2-atan(1/2),3*pi/2+atan(1/2),obj.Nr)),-2*(+obj.b/2-r/2),+2*(-obj.b/2+r/2)];
            xsr2 = [-obj.b/2,+obj.b/2];
            ysr2 = [-obj.b+r,-obj.b+r];
            xsr3 = r*cos(linspace(0,2*pi,obj.Nr));
            ysr3 = r*sin(linspace(0,2*pi,obj.Nr));
            % Wand:
            l = (obj.position0(2)-obj.position(2))*sin(obj.angle)+(obj.position0(1)-obj.position(1))*cos(obj.angle);
            DX0 = l*cos(obj.angle);
            DY0 = l*sin(obj.angle);
            xsr4 = NaN;
            ysr4 = NaN;
            for i=1:n
                xsr4 = [xsr4,NaN,DX0+obj.wposition(1,1)+rs*(i-1),DX0+obj.wposition(1,1)+rs*i];
                if obj.direction>=0
                    ysr4 = [ysr4,NaN,DY0-obj.b,DY0-obj.b-rs];
                else
                    ysr4 = [ysr4,NaN,DY0-obj.b-rs,DY0-obj.b];
                end
            end
            lmnr = sqrt((obj.wposition(:,2)-obj.wposition(:,1))'*(obj.wposition(:,2)-obj.wposition(:,1)))-n*rs;
            xsr4 = [xsr4,NaN,DX0+obj.wposition(1,1)+rs*n,DX0+obj.wposition(1,2)];
            if obj.direction>=0
                ysr4 = [ysr4,NaN,DY0-obj.b,DY0-obj.b-lmnr];
            else
                ysr4 = [ysr4,NaN,DY0-obj.b-rs,DY0-obj.b-(rs-lmnr)];
            end
            br = sqrt((obj.wposition(:,2)-obj.wposition(:,1))'*(obj.wposition(:,2)-obj.wposition(:,1)))/10;
            xsr5 = [DX0+obj.wposition(1,1)+br,DX0+obj.wposition(1,2)-br];
            ysr5 = [DY0-obj.b,DY0-obj.b];
            xsr6 = [DX0+obj.wposition(1,1),DX0+obj.wposition(1,1)+br];
            ysr6 = DY0-obj.b*[1,1];
            xsr7 = [DX0+obj.wposition(1,2)-br,DX0+obj.wposition(1,2)];
            ysr7 = DY0-obj.b*[1,1];
            % Transformation:
            alpha = obj.angle;
            xs1 = obj.position(1)+(xsr1*cos(alpha)+ysr1*sin(alpha));
            ys1 = obj.position(2)+(-xsr1*sin(alpha)+ysr1*cos(alpha));
            xs2 = obj.position(1)+(xsr2*cos(alpha)+ysr2*sin(alpha));
            ys2 = obj.position(2)+(-xsr2*sin(alpha)+ysr2*cos(alpha));
            xs3 = obj.position(1)+(xsr3*cos(alpha)+ysr3*sin(alpha));
            ys3 = obj.position(2)+(-xsr3*sin(alpha)+ysr3*cos(alpha));
            xs4 = obj.position(1)+(xsr4*cos(alpha)+ysr4*sin(alpha));
            ys4 = obj.position(2)+(-xsr4*sin(alpha)+ysr4*cos(alpha));
            xs5 = obj.position(1)+(xsr5*cos(alpha)+ysr5*sin(alpha));
            ys5 = obj.position(2)+(-xsr5*sin(alpha)+ysr5*cos(alpha));
            xs6 = obj.position(1)+(xsr6*cos(alpha)+ysr6*sin(alpha));
            ys6 = obj.position(2)+(-xsr6*sin(alpha)+ysr6*cos(alpha));
            xs7 = obj.position(1)+(xsr7*cos(alpha)+ysr7*sin(alpha));
            ys7 = obj.position(2)+(-xsr7*sin(alpha)+ysr7*cos(alpha));
            %% Plot:
            obj.plotHandle = cell(4,1);
            obj.plotHandle{1} = fill(xs1,ys1,'','FaceColor',facecolor,'EdgeColor',color,'LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'drag',obj});
            obj.plotHandle{2} = fill(xs3,ys3,'','FaceColor',facecolor,'EdgeColor',color,'LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'drag',obj});
            obj.plotHandle{3} = plot(xs2,ys2,'Color',color,'LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'drag',obj});
            obj.plotHandle{4} = plot(xs4,ys4,'Color',color,'LineWidth',lw/2,'buttondownfcn',{@Mouse_Callback,'dragwall',obj}); % Schraf.
            obj.plotHandle{5} = plot(xs5,ys5,'Color',color,'LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'dragwall',obj}); % Mitte
            obj.plotHandle{6} = plot(xs6,ys6,'Color',color,'LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'dragwall',obj});%,'buttondownfcn',{@Mouse_Callback,'downl',obj}); % Rand links
            obj.plotHandle{7} = plot(xs7,ys7,'Color',color,'LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'dragwall',obj});%,'buttondownfcn',{@Mouse_Callback,'downr',obj}); % Rand rechts
            
            %% Callback function:
            function Mouse_Callback(hObj,~,action,sObj)
                persistent curobj xdata ydata ind xdatarel ydatarel phi walls
                pos = get(gca,'CurrentPoint');
                switch action
%                     case 'downl'
%                         curobj = sObj;
%                         phi = curobj.angle;
%                         ind = 1;
%                         walls = curobj.wposition;
%                         set(gcf,...
%                             'WindowButtonMotionFcn',  {@Mouse_Callback,'move'},...
%                             'WindowButtonUpFcn',      {@Mouse_Callback,'up'});
%                     case 'downr'
%                         curobj = sObj;
%                         phi = curobj.angle;
%                         ind = 2;
%                         walls = curobj.wposition;
%                         set(gcf,...
%                             'WindowButtonMotionFcn',  {@Mouse_Callback,'move'},...
%                             'WindowButtonUpFcn',      {@Mouse_Callback,'up'});
%                     case 'move'
%                         if mod(phi,2*pi)==pi/2 || mod(phi,2*pi)==3*pi/2
%                             f = @(x) [walls(1,ind);x(2)];
%                         else
%                             f = @(x) [x(1);tan(phi)*(x(1)-walls(1,ind)+walls(2,ind)*cot(phi)-curobj.b*csc(phi))];
%                         end
%                         xx = f([pos(1);pos(3)]);
%                         walls(:,ind) = (2*(ind-1.5))*xx;
%                         obj.wposition = walls;
%                         % update
%                         curobj.setPosition(curobj.position(1),curobj.position(2),curobj.angle);
                    case 'dragwall'
                        curobj = sObj;
                        xdatarel = curobj.position0(1)-pos(1);
                        ydatarel = curobj.position0(2)-pos(3);
                        set(gcf,...
                            'WindowButtonMotionFcn',  {@Mouse_Callback,'dodragwall'},...
                            'WindowButtonUpFcn',      {@Mouse_Callback,'up'});
                    case 'dodragwall'
                        curobj.setPosition0(xdatarel+pos(1),ydatarel+pos(3));
                    case 'drag'
                        curobj = sObj;
                        xdatarel = curobj.position(1)-pos(1);
                        ydatarel = curobj.position(2)-pos(3);
                        set(gcf,...
                            'WindowButtonMotionFcn',  {@Mouse_Callback,'dodrag'},...
                            'WindowButtonUpFcn',      {@Mouse_Callback,'up'});
                    case 'dodrag'
                        % update
                        curobj.setPosition(xdatarel+pos(1),ydatarel+pos(3),curobj.angle);
                    case 'up'
                        set(gcf,...
                            'WindowButtonMotionFcn',  '',...
                            'WindowButtonUpFcn',      '');
                end
            end
            
            %% Context menus:
            plcontext = uicontextmenu;
            obj.plotHandle{1}.UIContextMenu = plcontext;
            obj.plotHandle{2}.UIContextMenu = plcontext;
            obj.plotHandle{3}.UIContextMenu = plcontext;
            obj.plotHandle{4}.UIContextMenu = plcontext;
            obj.plotHandle{5}.UIContextMenu = plcontext;
            obj.plotHandle{6}.UIContextMenu = plcontext;
            obj.plotHandle{7}.UIContextMenu = plcontext;
            plcontext1 = uimenu(plcontext,'Label','change color');
            plcontext1_1 = uimenu('Parent',plcontext1,'Label','blue','Callback',{@ct_setcolor,obj});
            plcontext1_2 = uimenu('Parent',plcontext1,'Label','red','Callback',{@ct_setcolor,obj});
            plcontext1_3 = uimenu('Parent',plcontext1,'Label','magenta','Callback',{@ct_setcolor,obj});
            plcontext1_4 = uimenu('Parent',plcontext1,'Label','green','Callback',{@ct_setcolor,obj});
            plcontext1_5 = uimenu('Parent',plcontext1,'Label','yellow','Callback',{@ct_setcolor,obj});
            plcontext1_6 = uimenu('Parent',plcontext1,'Label','black','Callback',{@ct_setcolor,obj});
            plcontext1_7 = uimenu('Parent',plcontext1,'Label','white','Callback',{@ct_setcolor,obj});
            plcontext1_8 = uimenu('Parent',plcontext1,'Label','random','Callback',{@ct_setcolor,obj});
            plcontext2 = uimenu(plcontext,'Label','change face color');
            plcontext2_1 = uimenu('Parent',plcontext2,'Label','blue','Callback',{@ct_setfacecolor,obj});
            plcontext2_2 = uimenu('Parent',plcontext2,'Label','red','Callback',{@ct_setfacecolor,obj});
            plcontext2_3 = uimenu('Parent',plcontext2,'Label','magenta','Callback',{@ct_setfacecolor,obj});
            plcontext2_4 = uimenu('Parent',plcontext2,'Label','green','Callback',{@ct_setfacecolor,obj});
            plcontext2_5 = uimenu('Parent',plcontext2,'Label','yellow','Callback',{@ct_setfacecolor,obj});
            plcontext2_6 = uimenu('Parent',plcontext2,'Label','black','Callback',{@ct_setfacecolor,obj});
            plcontext2_7 = uimenu('Parent',plcontext2,'Label','white','Callback',{@ct_setfacecolor,obj});
            plcontext2_8 = uimenu('Parent',plcontext2,'Label','random','Callback',{@ct_setfacecolor,obj});
            plcontext3 = uimenu(plcontext,'Label','rotate','Callback',{@ct_rotate,obj});
            plcontext4 = uimenu(plcontext,'Label','freeze rotation','Callback',{@ct_freezerotation,obj});
            plcontext5 = uimenu(plcontext,'Label','change direction','Callback',{@ct_changeDirection,obj});
            plcontext6 = uimenu(plcontext,'Label','delete','Callback',{@ct_delete,obj});
            
            %% Context functions:
            function ct_setcolor(src,event,curobj)
                curobj.color = systemColors(src.Label);
            end
            
            function ct_setfacecolor(src,event,curobj)
                curobj.facecolor = systemColors(src.Label);
            end
            
            function ct_rotate(src,event,obj)
                set(obj.window.fig,'windowscrollWheelFcn',@(src,callbackdata) obj.setPosition(obj.position(1),obj.position(2),obj.angle+sign(callbackdata.VerticalScrollCount)*obj.window.delta_angle));
            end
            
            function ct_freezerotation(src,event,obj)
                set(obj.window.fig,'windowscrollWheelFcn',@(src,callbackdata) 1);
            end
            
            function ct_changeDirection(src,event,obj)
                obj.changeDirection();
            end
            
            function ct_delete(src,event,obj)
                obj.delete();
            end
        end
        
        
        function [X,Y] = setPosition(obj,X,Y,orientation)
            if nargin==4
                if length(orientation)==2
                    alpha = atan2(orientation(2),orientation(1));
                else
                    alpha = orientation;
                end
                if obj.angle~=alpha
                    da = alpha-obj.angle;
                    obj.position0 = obj.position+[cos(da),-sin(da);sin(da),cos(da)]*(obj.position0-obj.position);
                end
                obj.angle = alpha;
            end
            k = (X-obj.position0(1))*cos(obj.angle)+(Y-obj.position0(2))*sin(obj.angle);
            XX = obj.position0+[cos(obj.angle);sin(obj.angle)]*k;
            X = XX(1);
            Y = XX(2);
            %% Calc:
            r = obj.b/6;
            rs = 1/obj.npl;
            n = round(obj.npl*sqrt((obj.wposition(:,2)-obj.wposition(:,1))'*(obj.wposition(:,2)-obj.wposition(:,1)))-0.5);
            % Referenzlager:
            % Los:
            xsr1 = [-obj.b/2+r/2,r*cos(linspace(3*pi/2-atan(1/2),3*pi/2+atan(1/2),obj.Nr)),+obj.b/2-r/2,-obj.b/2+r/2];
            ysr1 = [+2*(-obj.b/2+r/2),r*sin(linspace(3*pi/2-atan(1/2),3*pi/2+atan(1/2),obj.Nr)),-2*(+obj.b/2-r/2),+2*(-obj.b/2+r/2)];
            xsr2 = [-obj.b/2,+obj.b/2];
            ysr2 = [-obj.b+r,-obj.b+r];
            xsr3 = r*cos(linspace(0,2*pi,obj.Nr));
            ysr3 = r*sin(linspace(0,2*pi,obj.Nr));
            % Wand:
            l = (obj.position0(2)-Y)*sin(obj.angle)+(obj.position0(1)-X)*cos(obj.angle);
            DX0 = l;
            DY0 = 0;
            xsr4 = NaN;
            ysr4 = NaN;
            for i=1:n
                xsr4 = [xsr4,NaN,DX0+obj.wposition(1,1)+rs*(i-1),DX0+obj.wposition(1,1)+rs*i];
                if obj.direction>=0
                    ysr4 = [ysr4,NaN,DY0-obj.b,DY0-obj.b-rs];
                else
                    ysr4 = [ysr4,NaN,DY0-obj.b-rs,DY0-obj.b];
                end
            end
            lmnr = sqrt((obj.wposition(:,2)-obj.wposition(:,1))'*(obj.wposition(:,2)-obj.wposition(:,1)))-n*rs;
            xsr4 = [xsr4,NaN,DX0+obj.wposition(1,1)+rs*n,DX0+obj.wposition(1,2)];
            if obj.direction>=0
                ysr4 = [ysr4,NaN,DY0-obj.b,DY0-obj.b-lmnr];
            else
                ysr4 = [ysr4,NaN,DY0-obj.b-rs,DY0-obj.b-(rs-lmnr)];
            end
            br = sqrt((obj.wposition(:,2)-obj.wposition(:,1))'*(obj.wposition(:,2)-obj.wposition(:,1)))/10;
            xsr5 = [DX0+obj.wposition(1,1)+br,DX0+obj.wposition(1,2)-br];
            ysr5 = [DY0-obj.b,DY0-obj.b];
            xsr6 = [DX0+obj.wposition(1,1),DX0+obj.wposition(1,1)+br];
            ysr6 = DY0-obj.b*[1,1];
            xsr7 = [DX0+obj.wposition(1,2)-br,DX0+obj.wposition(1,2)];
            ysr7 = DY0-obj.b*[1,1];
            % Transformation:
            alpha = obj.angle;
            xs1 = X+(xsr1*cos(alpha)+ysr1*sin(alpha));
            ys1 = Y+(-xsr1*sin(alpha)+ysr1*cos(alpha));
            xs2 = X+(xsr2*cos(alpha)+ysr2*sin(alpha));
            ys2 = Y+(-xsr2*sin(alpha)+ysr2*cos(alpha));
            xs3 = X+(xsr3*cos(alpha)+ysr3*sin(alpha));
            ys3 = Y+(-xsr3*sin(alpha)+ysr3*cos(alpha));
            xs4 = X+(xsr4*cos(alpha)+ysr4*sin(alpha));
            ys4 = Y+(-xsr4*sin(alpha)+ysr4*cos(alpha));
            xs5 = X+(xsr5*cos(alpha)+ysr5*sin(alpha));
            ys5 = Y+(-xsr5*sin(alpha)+ysr5*cos(alpha));
            xs6 = X+(xsr6*cos(alpha)+ysr6*sin(alpha));
            ys6 = Y+(-xsr6*sin(alpha)+ysr6*cos(alpha));
            xs7 = X+(xsr7*cos(alpha)+ysr7*sin(alpha));
            ys7 = Y+(-xsr7*sin(alpha)+ysr7*cos(alpha));
            %% Update:
            obj.plotHandle{1}.XData = xs1;
            obj.plotHandle{1}.YData = ys1;
            obj.plotHandle{2}.XData = xs3;
            obj.plotHandle{2}.YData = ys3;
            obj.plotHandle{3}.XData = xs2;
            obj.plotHandle{3}.YData = ys2;
            obj.plotHandle{4}.XData = xs4;
            obj.plotHandle{4}.YData = ys4;
            obj.plotHandle{5}.XData = xs5;
            obj.plotHandle{5}.YData = ys5;
            obj.plotHandle{6}.XData = xs6;
            obj.plotHandle{6}.YData = ys6;
            obj.plotHandle{7}.XData = xs7;
            obj.plotHandle{7}.YData = ys7;
            
            obj.position = [X; Y];
            notify(obj,'changedPosition');
        end
        
        function setPosition0(obj,X0,Y0)
            DX = obj.position-obj.position0;
            obj.position0(1) = X0;
            obj.position0(2) = Y0;
            obj.position(1) = X0+DX(1);
            obj.position(2) = Y0+DX(2);
            obj.setPosition(obj.position(1),obj.position(2),obj.angle);
        end
        
        function changeDirection(obj)
            obj.direction = -obj.direction;
            obj.setPosition(obj.position(1),obj.position(2),obj.angle);
        end
        
        function globalLocation = local2global(obj,localLocation)
            ca = cos(obj.angle);
            sa = sin(obj.angle);
            dXdY = [ca -sa;sa ca]*localLocation(:);
            
            globalLocation = obj.position +dXdY;            
        end
        
        function delete(obj)
            delete(obj.plotHandle{1});
            delete(obj.plotHandle{2});
            delete(obj.plotHandle{3});
            delete(obj.plotHandle{4});
            delete(obj.plotHandle{5});
            delete(obj.plotHandle{6});
            delete(obj.plotHandle{7});
            obj.window.deleteObject(obj.id);
        end
        
        function set.color(obj,newcolor)
            obj.plotHandle{1}.EdgeColor = newcolor;
            obj.plotHandle{2}.EdgeColor = newcolor;
            obj.plotHandle{3}.Color = newcolor;
            obj.plotHandle{4}.Color = newcolor;
            obj.plotHandle{5}.Color = newcolor;
            obj.plotHandle{6}.Color = newcolor;
            obj.plotHandle{7}.Color = newcolor;
        end
        
        function col = get.color(obj)
            col = obj.plotHandle{1}.EdgeColor;
        end
        
        function set.facecolor(obj,newcolor)
            obj.plotHandle{1}.FaceColor = newcolor;
            obj.plotHandle{2}.FaceColor = newcolor;
        end
        
        function col = get.facecolor(obj)
            col = obj.plotHandle{1}.FaceColor;
        end
        
    end
end