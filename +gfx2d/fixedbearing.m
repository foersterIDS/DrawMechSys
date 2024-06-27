classdef fixedbearing < gfx2d.RigidBody
    
    properties
        window
        id
        Nr = 50;
        radius
        b
        npl
        lmin
        direction = +1;
        handl
    end
    properties (Dependent)
        color
        facecolor
    end
    
    methods
        function obj = fixedbearing(x,y,b,orientation,varargin)
            %% Init:
            stdinp = 4;
            color = [0,0,0];
            facecolor = [1,1,1];
            lw = 3;
            obj.position = [x,y];
            obj.b = b;
            if length(orientation)>1
                obj.angle = atan2(orientation(2),orientation(1));
            else
                obj.angle = orientation;
            end
            obj.npl = 6/obj.b;
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
            n = round(obj.npl*obj.b-0.5);
            % Referenzlager:
            xsr1 = [+obj.b/2,-obj.b/2,...
                r*cos(linspace(3*pi/2-atan(1/2),3*pi/2+atan(1/2),obj.Nr)),...
                +obj.b/2];
            ysr1 = [-obj.b,-obj.b,...
                r*sin(linspace(3*pi/2-atan(1/2),3*pi/2+atan(1/2),obj.Nr)),...
                -obj.b];
            xsr2 = r*cos(linspace(0,2*pi,obj.Nr));
            ysr2 = r*sin(linspace(0,2*pi,obj.Nr));
            xsr3 = NaN;
            ysr3 = NaN;
            for i=1:n
                xsr3 = [xsr3,NaN,-obj.b/2+rs*(i-1),-obj.b/2+rs*i];
                if obj.direction>=0
                    ysr3 = [ysr3,NaN,-obj.b,-obj.b-rs];
                else
                    ysr3 = [ysr3,NaN,-obj.b-rs,-obj.b];
                end
            end
            lmnr = obj.b-n*rs;
            xsr3 = [xsr3,NaN,-obj.b/2+rs*n,obj.b/2];
            if obj.direction>=0
                ysr3 = [ysr3,NaN,-obj.b,-obj.b-lmnr];
            else
                ysr3 = [ysr3,NaN,-obj.b-rs,-obj.b-(rs-lmnr)];
            end
%             xsr3 = [];
%             ysr3 = [];
%             for i=1:n
%                 xsr3 = [xsr3,NaN,-obj.b/2+rs*(i-1),-obj.b/2+rs*i];
%                 ysr3 = [ysr3,NaN,-obj.b-rs,-obj.b];
%             end
            
            %% Plot:
            obj.hgTransformHandle = hgtransform();
            obj.setPosition(x,y,orientation);
            
            obj.handl = cell(3,1);
            obj.handl{1} = fill(xsr1,ysr1,'','FaceColor',facecolor,'EdgeColor',color,'LineWidth',lw,'Parent',obj.hgTransformHandle,'buttondownfcn',{@Mouse_Callback,'drag',obj});
            obj.handl{2} = fill(xsr2,ysr2,'','FaceColor',facecolor,'EdgeColor',color,'LineWidth',lw,'Parent',obj.hgTransformHandle,'buttondownfcn',{@Mouse_Callback,'drag',obj});
            obj.handl{3} = plot(xsr3,ysr3,'Color',color,'LineWidth',lw/2,'Parent',obj.hgTransformHandle,'buttondownfcn',{@Mouse_Callback,'drag',obj});
            
            %% Callback function:
            function Mouse_Callback(hObj,~,action,sObj)
                persistent curobj xdata ydata ind xdatarel ydatarel
                pos = get(gca,'CurrentPoint');
                switch action
                    case 'down'
                        curobj = sObj;
                        xdata = curobj.position(1);
                        ydata = curobj.position(2);
                        [~,ind] = min(sum((xdata-pos(1)).^2+(ydata-pos(3)).^2,1));
                        set(gcf,...
                            'WindowButtonMotionFcn',  {@Mouse_Callback,'move'},...
                            'WindowButtonUpFcn',      {@Mouse_Callback,'up'});
                    case 'move'
                        xx = curobj.position(1);
                        yy = curobj.position(2);
                        % horizontal move
                        xx(ind) = pos(1);
                        % vertical move
                        yy(ind) = pos(3);
                        % update
                        curobj.setPosition(xx,yy,curobj.orientation);
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
            obj.handl{1}.UIContextMenu = plcontext;
            obj.handl{2}.UIContextMenu = plcontext;
            obj.handl{3}.UIContextMenu = plcontext;
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
        
        function delete(obj)
            delete(obj.handl{1});
            delete(obj.handl{2});
            delete(obj.handl{3});
            if ~isempty(obj.window)
                obj.window.deleteObject(obj.id);
            end
        end
        
        function changeDirection(obj)
            obj.direction = -1*obj.direction;
            r = obj.b/6;
            rs = 1/obj.npl;
            n = round(obj.npl*obj.b-0.5);
            % Referenzlager:
            xsr1 = [+obj.b/2,-obj.b/2,...
                r*cos(linspace(3*pi/2-atan(1/2),3*pi/2+atan(1/2),obj.Nr)),...
                +obj.b/2];
            ysr1 = [-obj.b,-obj.b,...
                r*sin(linspace(3*pi/2-atan(1/2),3*pi/2+atan(1/2),obj.Nr)),...
                -obj.b];
            xsr2 = r*cos(linspace(0,2*pi,obj.Nr));
            ysr2 = r*sin(linspace(0,2*pi,obj.Nr));
            xsr3 = NaN;
            ysr3 = NaN;
            for i=1:n
                xsr3 = [xsr3,NaN,-obj.b/2+rs*(i-1),-obj.b/2+rs*i];
                if obj.direction>=0
                    ysr3 = [ysr3,NaN,-obj.b,-obj.b-rs];
                else
                    ysr3 = [ysr3,NaN,-obj.b-rs,-obj.b];
                end
            end
            lmnr = obj.b-n*rs;
            xsr3 = [xsr3,NaN,-obj.b/2+rs*n,obj.b/2];
            if obj.direction>=0
                ysr3 = [ysr3,NaN,-obj.b,-obj.b-lmnr];
            else
                ysr3 = [ysr3,NaN,-obj.b-rs,-obj.b-(rs-lmnr)];
            end
            obj.handl{1}.XData = xsr1;
            obj.handl{1}.YData = ysr1;
            obj.handl{2}.XData = xsr2;
            obj.handl{2}.YData = ysr2;
            obj.handl{3}.XData = xsr3;
            obj.handl{3}.YData = ysr3;
            obj.setPosition(obj.position(1),obj.position(2),obj.angle);
        end
        
        function set.color(obj,newcolor)
            obj.handl{1}.EdgeColor = newcolor;
            obj.handl{2}.EdgeColor = newcolor;
            obj.handl{3}.Color = newcolor;
        end
        
        function col = get.color(obj)
            col = obj.handl{1}.EdgeColor;
        end
        
        function set.facecolor(obj,newcolor)
            obj.handl{1}.FaceColor = newcolor;
            obj.handl{2}.FaceColor = newcolor;
        end
        
        function col = get.facecolor(obj)
            col = obj.handl{1}.FaceColor;
        end
    end
end