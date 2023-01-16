classdef roll < gfx2d.RigidBody
    
    properties
        window
        id
        pf
        pl
        showOrientation
        Nu = 100;
        phi
        d
        handl
    end
    properties (Dependent)
        color
        facecolor
        orientationColor
    end
    
    methods
        function obj = roll(x,y,d,varargin)
            %% Init:
            stdinp = 3;
            color = [0,0,0];
            facecolor = [1,1,1];
            lw = 3;
            obj.d = d;
            obj.showOrientation = 0;
            orientation = 0;
            orientationColor = color;
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
                        case 'orientation'
                            obj.showOrientation = 1;
                            obj.angle = varargin{i+1};
                            i = i+1;
                        case 'orientationcolor'
                            orientationColor = varargin{i+1};
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
            obj.phi = linspace(0,2*pi,obj.Nu);
            xs = obj.d/2*cos(obj.phi);
            ys = obj.d/2*sin(obj.phi);
            
            phio = linspace(0,4*pi,2*obj.Nu);
            ro = obj.d/2*0.8*linspace(1,0,2*obj.Nu);
            xso = ro.*cos(phio);
            yso = ro.*sin(phio);
            
            %% Plot:
            obj.hgTransformHandle = hgtransform();
            setPosition(obj,x,y,orientation)
            
            obj.pf = fill(xs,ys,'','FaceColor',facecolor,'EdgeColor',color,'LineWidth',lw,'Parent',obj.hgTransformHandle,'buttondownfcn',{@Mouse_Callback,'drag',obj});
            obj.pl = plot(xso,yso,'Color',orientationColor,'LineWidth',lw,'Parent',obj.hgTransformHandle,'buttondownfcn',{@Mouse_Callback,'drag',obj});
            if obj.showOrientation
                obj.pl.Visible = true;
            else
                obj.pl.Visible = false;
            end
            
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
            % pf:
            pfcontext = uicontextmenu;
            obj.pf.UIContextMenu = pfcontext;
            pfcontext1 = uimenu(pfcontext,'Label','change color');
            pfcontext1_1 = uimenu('Parent',pfcontext1,'Label','blue','Callback',{@ct_setcolor,obj});
            pfcontext1_2 = uimenu('Parent',pfcontext1,'Label','red','Callback',{@ct_setcolor,obj});
            pfcontext1_3 = uimenu('Parent',pfcontext1,'Label','magenta','Callback',{@ct_setcolor,obj});
            pfcontext1_4 = uimenu('Parent',pfcontext1,'Label','green','Callback',{@ct_setcolor,obj});
            pfcontext1_5 = uimenu('Parent',pfcontext1,'Label','yellow','Callback',{@ct_setcolor,obj});
            pfcontext1_6 = uimenu('Parent',pfcontext1,'Label','black','Callback',{@ct_setcolor,obj});
            pfcontext1_7 = uimenu('Parent',pfcontext1,'Label','white','Callback',{@ct_setcolor,obj});
            pfcontext1_8 = uimenu('Parent',pfcontext1,'Label','random','Callback',{@ct_setcolor,obj});
            pfcontext2 = uimenu(pfcontext,'Label','change face color');
            pfcontext2_1 = uimenu('Parent',pfcontext2,'Label','blue','Callback',{@ct_setfacecolor,obj});
            pfcontext2_2 = uimenu('Parent',pfcontext2,'Label','red','Callback',{@ct_setfacecolor,obj});
            pfcontext2_3 = uimenu('Parent',pfcontext2,'Label','magenta','Callback',{@ct_setfacecolor,obj});
            pfcontext2_4 = uimenu('Parent',pfcontext2,'Label','green','Callback',{@ct_setfacecolor,obj});
            pfcontext2_5 = uimenu('Parent',pfcontext2,'Label','yellow','Callback',{@ct_setfacecolor,obj});
            pfcontext2_6 = uimenu('Parent',pfcontext2,'Label','black','Callback',{@ct_setfacecolor,obj});
            pfcontext2_7 = uimenu('Parent',pfcontext2,'Label','white','Callback',{@ct_setfacecolor,obj});
            pfcontext2_8 = uimenu('Parent',pfcontext2,'Label','random','Callback',{@ct_setfacecolor,obj});
            pfcontext3 = uimenu(pfcontext,'Label','show orientation','Callback',{@ct_showorientation,obj});
            pfcontext4 = uimenu(pfcontext,'Label','rotate','Callback',{@ct_rotate,obj});
            pfcontext5 = uimenu(pfcontext,'Label','freeze rotation','Callback',{@ct_freezerotation,obj});
            pfcontext6 = uimenu(pfcontext,'Label','delete','Callback',{@ct_delete,obj});
            % pl:
            obj.pl.UIContextMenu = pfcontext;
            
            %% Context functions:
            function ct_setcolor(src,event,curobj)
                curobj.color = systemColors(src.Label);
            end
            
            function ct_setfacecolor(src,event,curobj)
                curobj.facecolor = systemColors(src.Label);
            end
            
            function ct_bind(src,event,obj)
                warning('"bind" is not functional yet!');
                xx = 10*rand;
                yy = 10*rand;
                obj.setPosition(xx,yy,obj.orientation);
            end
            
            function ct_setposition(src,event,obj)
                warning('"set position" is not functional yet!');
                xx = 10*rand;
                yy = 10*rand;
                obj.setPosition(xx,yy,obj.orientation);
            end
            
            function ct_rotate(src,event,obj)
                set(obj.window.fig,'windowscrollWheelFcn',@(src,callbackdata) obj.setPosition(obj.position(1),obj.position(2),obj.angle+sign(callbackdata.VerticalScrollCount)*obj.window.delta_angle));
            end
            
            function ct_freezerotation(src,event,obj)
                set(obj.window.fig,'windowscrollWheelFcn',@(src,callbackdata) 1);
            end
            
            function ct_showorientation(src,event,obj)
                if obj.showOrientation
                    obj.showOrientation = 0;
                    obj.pl.Visible = false;
                else
                    obj.showOrientation = 1;
                    obj.pl.Visible = true;
                end
            end
            
            function ct_delete(src,event,obj)
                obj.window.deleteObject(obj.id);
                delete(obj.pf);
                delete(obj.pl);
            end
        end
        
        function set.color(obj,newcolor)
            obj.pf.EdgeColor = newcolor;
        end
        
        function col = get.color(obj)
            col = obj.pf.EdgeColor;
        end
        
        function set.facecolor(obj,newcolor)
            obj.pf.FaceColor = newcolor;
        end
        
        function col = get.facecolor(obj)
            col = obj.pf.FaceColor;
        end

        function set.orientationColor(obj,newColor)
            obj.pl.Color = newColor;
        end

        function col = get.orientationColor(obj)
            col = obj.pl.Color;
        end
        
        function globalLocation = local2global(obj,localLocation)
            [dx, dy] = pol2cart(localLocation(2)+obj.angle,obj.d/2 * localLocation(1));
            globalLocation = obj.position + [dx;dy];            
        end
    end
end