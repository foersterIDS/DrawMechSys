classdef wall < gfx2d.LineObject
    
    properties
        window
        id
        npl
        direction = 1;
        orientation = 1;
        plotHandle
    end
    properties (Dependent)
        color
    end
    
    methods
        function obj = wall(X,Y,npl,orientation,varargin)
           
            obj@gfx2d.LineObject([X(1); Y(1)], [X(2); Y(2)])
            
            %% Init:      
            stdinp = 4;
            color = [0,0,0];
            lw = 3;
            obj.npl = npl;
            b = 1/obj.npl;
            if islogical(orientation)
                if orientation
                    obj.orientation = +1;
                else
                    obj.orientation = -1;
                end
            else
                obj.orientation = sgn(orientation);
            end
            %% Input:
            if nargin>stdinp
                i = 1;
                while i<=nargin-stdinp
                    switch lower(varargin{i})
                        case 'color'
                            color = varargin{i+1};
                            i = i+1;
                        case 'linewidth'
                            lw = varargin{i+1};
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
            l = sqrt((obj.p2(1)-obj.p1(1))^2+(obj.p2(2)-obj.p1(2))^2);
            n = round(l*obj.npl-0.5);
            r = 1/obj.npl;
            % Referenzlager:
            xsr1 = [0,l/10];
            ysr1 = [0,0];
            xsr2 = [9*l/10,l];
            ysr2 = [0,0];
            xsr3 = NaN;
            ysr3 = NaN;
            for i=1:n
                xsr3 = [xsr3,NaN,r*(i-1),r*i];
                if obj.direction>=0
                    ysr3 = [ysr3,NaN,0,0-sgn(obj.orientation)*b];
                else
                    ysr3 = [ysr3,NaN,0-sgn(obj.orientation)*b,0];
                end
            end
            lmnr = l-n*r;
            xsr3 = [xsr3,NaN,r*n,l];
            if obj.direction>=0
                ysr3 = [ysr3,NaN,0,0-sgn(obj.orientation)*lmnr];
            else
                ysr3 = [ysr3,NaN,-sgn(obj.orientation)*b,-sgn(obj.orientation)*(b-lmnr)];
            end
            xsr4 = [l/10,9*l/10];
            ysr4 = [0,0];
            % Transformation:
            alpha = atan2((obj.p2(2)-obj.p1(2)),(obj.p2(1)-obj.p1(1)));
            xs1 = obj.p1(1)+(+xsr1*cos(alpha)+ysr1*sin(alpha));
            ys1 = obj.p1(2)+(+xsr1*sin(alpha)-ysr1*cos(alpha));
            xs2 = obj.p1(1)+(+xsr2*cos(alpha)+ysr2*sin(alpha));
            ys2 = obj.p1(2)+(+xsr2*sin(alpha)-ysr2*cos(alpha));
            xs3 = obj.p1(1)+(+xsr3*cos(alpha)+ysr3*sin(alpha));
            ys3 = obj.p1(2)+(+xsr3*sin(alpha)-ysr3*cos(alpha));
            xs4 = obj.p1(1)+(+xsr4*cos(alpha)+ysr4*sin(alpha));
            ys4 = obj.p1(2)+(+xsr4*sin(alpha)-ysr4*cos(alpha));
            %% Plot:
            obj.plotHandle = cell(2,1);
            obj.plotHandle{3} = plot(xs3,ys3,'Color',color,'LineWidth',lw/2,'buttondownfcn',{@Mouse_Callback,'drag',obj});
            obj.plotHandle{4} = plot(xs4,ys4,'Color',color,'LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'drag',obj});
            obj.plotHandle{1} = plot(xs1,ys1,'Color',color,'LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'down',obj});
            obj.plotHandle{2} = plot(xs2,ys2,'Color',color,'LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'down',obj});
            
            %% Callback function:
            function Mouse_Callback(hObj,~,action,sObj)
                persistent curobj xdata ydata ind xdatarel ydatarel
                pos = get(gca,'CurrentPoint');
                switch action
                    case 'down'
                        curobj = sObj;
                        xdata = [curobj.p1(1),curobj.p2(1)];
                        ydata = [curobj.p1(2),curobj.p2(2)];
                        [~,ind] = min(sum((xdata-pos(1)).^2+(ydata-pos(3)).^2,1));
                        set(gcf,...
                            'WindowButtonMotionFcn',  {@Mouse_Callback,'move'},...
                            'WindowButtonUpFcn',      {@Mouse_Callback,'up'});
                    case 'move'
                        xx = [curobj.p1(1),curobj.p2(1)];
                        yy = [curobj.p1(2),curobj.p2(2)];
                        % horizontal move
                        xx(ind) = pos(1);
                        % vertical move
                        yy(ind) = pos(3);
                        % update
                        curobj.setPosition(xx,yy);
                    case 'drag'
                        curobj = sObj;
                        xdatarel = [curobj.p1(1),curobj.p2(1)]-pos(1);
                        ydatarel = [curobj.p1(2),curobj.p2(2)]-pos(3);
                        set(gcf,...
                            'WindowButtonMotionFcn',  {@Mouse_Callback,'dodrag'},...
                            'WindowButtonUpFcn',      {@Mouse_Callback,'up'});
                    case 'dodrag'
                        % update
                        curobj.setPosition(xdatarel+pos(1),ydatarel+pos(3));
                    case 'up'
                        set(gcf,...
                            'WindowButtonMotionFcn',  '',...
                            'WindowButtonUpFcn',      '');
                end
            end
            
            %% Context menus:
            % m:
            plmcontext = uicontextmenu;
            obj.plotHandle{3}.UIContextMenu = plmcontext;
            obj.plotHandle{4}.UIContextMenu = plmcontext;
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
            obj.plotHandle{1}.UIContextMenu = pllcontext;
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
            obj.plotHandle{2}.UIContextMenu = plrcontext;
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
            
            %% Context functions:
            function ct_setcolor(src,event,curobj)
                curobj.color = systemColors(src.Label);
            end
            
            function ct_bind(src,event,obj,index)
                warning('"bind" is not functional yet!');
                xx = [obj.p1(1),obj.p2(1)];
                yy = [obj.p1(2),obj.p2(2)];
                xx(index) = 10*rand;
                yy(index) = 10*rand;
                obj.setPosition(xx,yy);
            end
            
            function ct_setposition(src,event,obj,index)
                warning('"set position" is not functional yet!');
                xx = [obj.p1(1),obj.p2(1)];
                yy = [obj.p1(2),obj.p2(2)];
                xx(index) = 10*rand;
                yy(index) = 10*rand;
                obj.setPosition(xx,yy);
            end
            
            function ct_delete(src,event,obj)
                obj.delete();
            end
            
            function ct_changeDirection(src,event,obj)
                obj.changeDirection();
            end
            
            function ct_changeOrientation(src,event,obj)
                obj.changeOrientation();
            end
        end
        
        
        function setPosition(obj,X,Y)
            obj.p1 = [X(1);Y(1)];
            obj.p2 = [X(2);Y(2)];
            %% Calc:
            b = 1/obj.npl;
            l = sqrt((obj.p2(1)-obj.p1(1))^2+(obj.p2(2)-obj.p1(2))^2);
            n = round(l*obj.npl-0.5);
            r = 1/obj.npl;
            % Referenzlager:
            xsr1 = [0,l/10];
            ysr1 = [0,0];
            xsr2 = [9*l/10,l];
            ysr2 = [0,0];
            xsr3 = NaN;
            ysr3 = NaN;
            for i=1:n
                xsr3 = [xsr3,NaN,r*(i-1),r*i];
                if obj.direction>=0
                    ysr3 = [ysr3,NaN,0,0-sgn(obj.orientation)*b];
                else
                    ysr3 = [ysr3,NaN,0-sgn(obj.orientation)*b,0];
                end
            end
            lmnr = l-n*r;
            xsr3 = [xsr3,NaN,r*n,l];
            if obj.direction>=0
                ysr3 = [ysr3,NaN,0,0-sgn(obj.orientation)*lmnr];
            else
                ysr3 = [ysr3,NaN,-sgn(obj.orientation)*b,-sgn(obj.orientation)*(b-lmnr)];
            end
            xsr4 = [l/10,9*l/10];
            ysr4 = [0,0];
            % Transformation:
            alpha = atan2((obj.p2(2)-obj.p1(2)),(obj.p2(1)-obj.p1(1)));
            xs1 = obj.p1(1)+(+xsr1*cos(alpha)+ysr1*sin(alpha));
            ys1 = obj.p1(2)+(+xsr1*sin(alpha)-ysr1*cos(alpha));
            xs2 = obj.p1(1)+(+xsr2*cos(alpha)+ysr2*sin(alpha));
            ys2 = obj.p1(2)+(+xsr2*sin(alpha)-ysr2*cos(alpha));
            xs3 = obj.p1(1)+(+xsr3*cos(alpha)+ysr3*sin(alpha));
            ys3 = obj.p1(2)+(+xsr3*sin(alpha)-ysr3*cos(alpha));
            xs4 = obj.p1(1)+(+xsr4*cos(alpha)+ysr4*sin(alpha));
            ys4 = obj.p1(2)+(+xsr4*sin(alpha)-ysr4*cos(alpha));
            %% Update:
            obj.plotHandle{1}.XData = xs1;
            obj.plotHandle{1}.YData = ys1;
            obj.plotHandle{2}.XData = xs2;
            obj.plotHandle{2}.YData = ys2;
            obj.plotHandle{3}.XData = xs3;
            obj.plotHandle{3}.YData = ys3;
            obj.plotHandle{4}.XData = xs4;
            obj.plotHandle{4}.YData = ys4;
        end
        
        function delete(obj)
            delete(obj.plotHandle{1});
            delete(obj.plotHandle{2});
            delete(obj.plotHandle{3});
            delete(obj.plotHandle{4});
            if ~isempty(obj.window)
                obj.window.deleteObject(obj.id);
            end
        end
        
        function changeDirection(obj)
            obj.direction = -1*obj.direction;
            obj.setPosition([obj.p1(1),obj.p2(1)],[obj.p1(2),obj.p2(2)]);
        end
        
        function changeOrientation(obj)
            obj.orientation = -1*obj.orientation;
            obj.setPosition([obj.p1(1),obj.p2(1)],[obj.p1(2),obj.p2(2)]);
        end
        
        function set.color(obj,newcolor)
            obj.plotHandle{1}.Color = newcolor;
            obj.plotHandle{2}.Color = newcolor;
            obj.plotHandle{3}.Color = newcolor;
            obj.plotHandle{4}.Color = newcolor;
        end
        
        function col = get.color(obj)
            col = obj.plotHandle{1}.Color;
        end
    end
end