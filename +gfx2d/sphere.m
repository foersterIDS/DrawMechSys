classdef sphere < gfx2d.RigidBody
    
    properties
        window
        id
        pf
        pl
        Nu = 100;
        nr = 5;
        amin
        amax
        phi
        phir
        d
        handl
    end
    properties (Dependent)
        color
        facecolor
    end
    
    methods
        function obj = sphere(x,y,d,varargin)
            %% Init:
            stdinp = 3;
            color = [0,0,0];
            facecolor = [1,1,1];
            lw = 3;
            obj.d = d;
            obj.amin = pi/2+1*pi/16;
            obj.amax = pi/2+5*pi/16;
            obj.phi = linspace(0,2*pi,obj.Nu);
            obj.phir = linspace(obj.amin,obj.amax,round(obj.Nu/4));
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
            xs1 = obj.d/2*cos(obj.phi);
            ys1 = obj.d/2*sin(obj.phi);
            xs2 = [obj.d/2*(obj.nr)/(obj.nr+1)*cos(obj.phir),NaN,obj.d/2*(obj.nr-1)/(obj.nr+1)*cos(obj.phir)];
            ys2 = [obj.d/2*(obj.nr)/(obj.nr+1)*sin(obj.phir),NaN,obj.d/2*(obj.nr-1)/(obj.nr+1)*sin(obj.phir)];
            %% Plot:
            obj.hgTransformHandle = hgtransform();
            setPosition(obj,x,y);
            
            obj.pf = fill(xs1,ys1,'','FaceColor',facecolor,'EdgeColor',color,'LineWidth',lw,'Parent',obj.hgTransformHandle,'buttondownfcn',{@Mouse_Callback,'drag',obj});
            obj.pl = plot(xs2,ys2,'Color',color,'LineWidth',lw,'Parent',obj.hgTransformHandle,'buttondownfcn',{@Mouse_Callback,'drag',obj});
            
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
            pfcontext3 = uimenu(pfcontext,'Label','delete','Callback',{@ct_delete,obj});
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
                obj.setPosition(xx,yy);
            end
            
            function ct_setposition(src,event,obj)
                warning('"set position" is not functional yet!');
                xx = 10*rand;
                yy = 10*rand;
                obj.setPosition(xx,yy);
            end
            
            function ct_delete(src,event,obj)
                obj.window.deleteObject(obj.id);
                delete(obj.pf);
                delete(obj.pl);
            end
        end
        
        function set.color(obj,newcolor)
            obj.pf.EdgeColor = newcolor;
            obj.pl.Color = newcolor;
        end
        
        function col = get.color(obj)
            col = obj.pl.Color;
        end
        
        function set.facecolor(obj,newcolor)
            obj.pf.FaceColor = newcolor;
        end
        
        function col = get.facecolor(obj)
            col = obj.pf.FaceColor;
        end
        
        function globalLocation = local2global(obj,localLocation)
            [dx, dy] = pol2cart(localLocation(2)+obj.angle,obj.d/2 * localLocation(1));
            globalLocation = obj.position + [dx;dy];
        end
    end
end