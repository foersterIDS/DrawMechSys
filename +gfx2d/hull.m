classdef hull < gfx2d.RigidBody
    
    properties
        window
        id
        b
        l
        pl
    end
    properties (Dependent)
        xcon
        ycon
        color
    end
    
    methods
        function obj = hull(x,y,b,l,orientation,varargin)
            %% Init:
            stdinp = 5;
            color = [0,0,0];
            lw = 3;
            obj.b = b;
            obj.l = l;
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
            % Referenzfeder:
            xsr = [-obj.b/2,-obj.b/2,-obj.b/2,NaN,+obj.b/2,+obj.b/2,+obj.b/2];
            ysr = [-obj.l/2,0,+obj.l/2,NaN,-obj.l/2,0,+obj.l/2];
            %% Plot:
            obj.hgTransformHandle = hgtransform();
            obj.setPosition(x,y,orientation);
            
            obj.pl = plot(xsr,ysr,'Color',color,'LineWidth',lw,'Parent',obj.hgTransformHandle,'buttondownfcn',{@Mouse_Callback,'drag',obj});
            
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
            obj.pl.UIContextMenu = plcontext;
            plcontext1 = uimenu(plcontext,'Label','change color');
            plcontext1_1 = uimenu('Parent',plcontext1,'Label','blue','Callback',{@ct_setcolor,obj});
            plcontext1_2 = uimenu('Parent',plcontext1,'Label','red','Callback',{@ct_setcolor,obj});
            plcontext1_3 = uimenu('Parent',plcontext1,'Label','magenta','Callback',{@ct_setcolor,obj});
            plcontext1_4 = uimenu('Parent',plcontext1,'Label','green','Callback',{@ct_setcolor,obj});
            plcontext1_5 = uimenu('Parent',plcontext1,'Label','yellow','Callback',{@ct_setcolor,obj});
            plcontext1_6 = uimenu('Parent',plcontext1,'Label','black','Callback',{@ct_setcolor,obj});
            plcontext1_7 = uimenu('Parent',plcontext1,'Label','white','Callback',{@ct_setcolor,obj});
            plcontext1_8 = uimenu('Parent',plcontext1,'Label','random','Callback',{@ct_setcolor,obj});
            plcontext2 = uimenu(plcontext,'Label','rotate','Callback',{@ct_rotate,obj});
            plcontext3 = uimenu(plcontext,'Label','freeze rotation','Callback',{@ct_freezerotation,obj});
            plcontext4 = uimenu(plcontext,'Label','delete','Callback',{@ct_delete,obj});
            
            %% Context functions:
            function ct_setcolor(src,event,curobj)
                curobj.color = systemColors(src.Label);
            end
            
            function ct_bind(src,event,obj,index)
                warning('"bind" is not functional yet!');
                xx = obj.X;
                yy = obj.Y;
                xx(index) = 10*rand;
                yy(index) = 10*rand;
                obj.setPosition(xx,yy,obj.orientation);
            end
            
            function ct_setposition(src,event,obj,index)
                warning('"set position" is not functional yet!');
                xx = obj.X;
                yy = obj.Y;
                xx(index) = 10*rand;
                yy(index) = 10*rand;
                obj.setPosition(xx,yy,obj.orientation);
            end
            
            function ct_rotate(src,event,obj)
                set(obj.window.fig,'windowscrollWheelFcn',@(src,callbackdata) obj.setPosition(obj.position(1),obj.position(2),obj.angle+sign(callbackdata.VerticalScrollCount)*obj.window.delta_angle));
            end
            
            function ct_freezerotation(src,event,obj)
                set(obj.window.fig,'windowscrollWheelFcn',@(src,callbackdata) 1);
            end
            
            function ct_delete(src,event,obj)
                obj.delete();
            end
        end
        
        
        
        function xcon = get.xcon(obj)
            loc1 = local2global(obj,[-1 0]);
            loc2 = local2global(obj,[1 0]);
            xcon = [loc1(1) loc2(1)];
        end
        function ycon = get.ycon(obj)
            loc1 = local2global(obj,[-1 0]);
            loc2 = local2global(obj,[1 0]);
            ycon = [loc1(2) loc2(2)];
        end
        
        function globalLocation = local2global(obj,localLocation)
            ca = cos(obj.angle);
            sa = sin(obj.angle);
            dXdY = [ca -sa;sa ca]*(0.5*[obj.b;obj.l].*localLocation(:));
            
            globalLocation = obj.position +dXdY;
        end
        
        function delete(obj)
            delete(obj.pl);
            obj.window.deleteObject(obj.id);
        end
        
        function set.color(obj,newcolor)
            obj.pl.Color = newcolor;
        end
        
        function col = get.color(obj)
            col = obj.pl.Color;
        end
        
    end
end