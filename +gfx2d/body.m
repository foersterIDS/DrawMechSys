classdef body < gfx2d.RigidBody
    
    properties
        window
        id
        Xshape
        Yshape
        pltHandle
    end
    properties (Dependent)
        color
        facecolor
    end
    
    methods
        function obj = body(x,y,Xshape,Yshape,orientation,varargin)
            
            obj.hgTransformHandle = hgtransform();
            obj.setPosition(x,y,orientation);
            
            %% Init:
            stdinp = 5;
            color = [0,0,0];
            facecolor = [1,1,1]*0.8;
            lw = 3;
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
            % Referenz-Koerper:
            obj.Xshape = Xshape*cos(obj.angle)-Yshape*sin(obj.angle);
            obj.Yshape = Xshape*sin(obj.angle)+Yshape*cos(obj.angle);
            % Transformation:
            xs = obj.Xshape*cos(obj.angle)+obj.Yshape*sin(obj.angle);
            ys = -obj.Xshape*sin(obj.angle)+obj.Yshape*cos(obj.angle);
            %% Plot:
            obj.pltHandle = fill(xs,ys,'','FaceColor',facecolor,'EdgeColor',color,'LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'drag',obj},'Parent',obj.hgTransformHandle);
            
            %% Callback
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
            handlcontext = uicontextmenu;
            obj.pltHandle.UIContextMenu = handlcontext;
            handlcontext1 = uimenu(handlcontext,'Label','change color');
            handlcontext1_1 = uimenu('Parent',handlcontext1,'Label','blue','Callback',{@ct_setcolor,obj});
            handlcontext1_2 = uimenu('Parent',handlcontext1,'Label','red','Callback',{@ct_setcolor,obj});
            handlcontext1_3 = uimenu('Parent',handlcontext1,'Label','magenta','Callback',{@ct_setcolor,obj});
            handlcontext1_4 = uimenu('Parent',handlcontext1,'Label','green','Callback',{@ct_setcolor,obj});
            handlcontext1_5 = uimenu('Parent',handlcontext1,'Label','yellow','Callback',{@ct_setcolor,obj});
            handlcontext1_6 = uimenu('Parent',handlcontext1,'Label','black','Callback',{@ct_setcolor,obj});
            handlcontext1_7 = uimenu('Parent',handlcontext1,'Label','white','Callback',{@ct_setcolor,obj});
            handlcontext1_8 = uimenu('Parent',handlcontext1,'Label','random','Callback',{@ct_setcolor,obj});
            handlcontext2 = uimenu(handlcontext,'Label','change face color');
            handlcontext2_1 = uimenu('Parent',handlcontext2,'Label','blue','Callback',{@ct_setfacecolor,obj});
            handlcontext2_2 = uimenu('Parent',handlcontext2,'Label','red','Callback',{@ct_setfacecolor,obj});
            handlcontext2_3 = uimenu('Parent',handlcontext2,'Label','magenta','Callback',{@ct_setfacecolor,obj});
            handlcontext2_4 = uimenu('Parent',handlcontext2,'Label','green','Callback',{@ct_setfacecolor,obj});
            handlcontext2_5 = uimenu('Parent',handlcontext2,'Label','yellow','Callback',{@ct_setfacecolor,obj});
            handlcontext2_6 = uimenu('Parent',handlcontext2,'Label','black','Callback',{@ct_setfacecolor,obj});
            handlcontext2_7 = uimenu('Parent',handlcontext2,'Label','white','Callback',{@ct_setfacecolor,obj});
            handlcontext2_8 = uimenu('Parent',handlcontext2,'Label','random','Callback',{@ct_setfacecolor,obj});
            handlcontext3 = uimenu(handlcontext,'Label','rotate','Callback',{@ct_rotate,obj});
            handlcontext4 = uimenu(handlcontext,'Label','freeze rotation','Callback',{@ct_freezerotation,obj});
            handlcontext5 = uimenu(handlcontext,'Label','delete','Callback',{@ct_delete,obj});
            
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
            
            function ct_delete(src,event,obj)
                obj.window.deleteObject(obj.id);
                delete(obj.pltHandle);
            end
        end
        
        
        
        function set.color(obj,newcolor)
            obj.pltHandle.EdgeColor = newcolor;
        end
        
        function col = get.color(obj)
            col = obj.pltHandle.EdgeColor;
        end
        
        function set.facecolor(obj,newcolor)
            obj.pltHandle.FaceColor = newcolor;
        end
        
        function col = get.facecolor(obj)
            col = obj.pltHandle.FaceColor;
        end
        
        function globalLocation = local2global(obj,localLocation)
            ca = cos(obj.angle);
            sa = sin(obj.angle);
            dXdY = [ca -sa;sa ca]*localLocation(:);
            
            globalLocation = obj.position +dXdY;            
        end
        
    end
end