classdef lumpedmass < gfx2d.PointObject
    
    properties
        window
        id
        d
        Nu = 100;
        plotHandle
    end
    properties (Dependent)
        color
    end
    
    methods
        function obj = lumpedmass(x,y,d,varargin)
            obj.d = d;
            %% Init:
            stdinp = 3;
            color = [0,0,0];
            %% Input:
            if nargin>stdinp
                i = 1;
                while i<=nargin-stdinp
                    switch lower(varargin{i})
                        case 'color'
                            color = varargin{i+1};
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
            xs = obj.d/2*cos(linspace(0,2*pi,obj.Nu));
            ys = obj.d/2*sin(linspace(0,2*pi,obj.Nu));
            %% Plot:
            obj.hgTransformHandle = hgtransform();
            setPosition(obj,x,y);
            
            obj.plotHandle = fill(xs,ys,'','facecolor',color,'edgecolor',color,'linewidth',10^-10,'buttondownfcn',{@Mouse_Callback,'drag',obj},'Parent',obj.hgTransformHandle);
            
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
                        curobj.setPosition(xx,yy);
                    case 'drag'
                        curobj = sObj;
                        xdatarel = curobj.position(1)-pos(1);
                        ydatarel = curobj.position(2)-pos(3);
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
            handlcontext = uicontextmenu;
            obj.plotHandle.UIContextMenu = handlcontext;
            handlcontext1 = uimenu(handlcontext,'Label','change color');
            handlcontext1_1 = uimenu('Parent',handlcontext1,'Label','blue','Callback',{@ct_setcolor,obj});
            handlcontext1_2 = uimenu('Parent',handlcontext1,'Label','red','Callback',{@ct_setcolor,obj});
            handlcontext1_3 = uimenu('Parent',handlcontext1,'Label','magenta','Callback',{@ct_setcolor,obj});
            handlcontext1_4 = uimenu('Parent',handlcontext1,'Label','green','Callback',{@ct_setcolor,obj});
            handlcontext1_5 = uimenu('Parent',handlcontext1,'Label','yellow','Callback',{@ct_setcolor,obj});
            handlcontext1_6 = uimenu('Parent',handlcontext1,'Label','black','Callback',{@ct_setcolor,obj});
            handlcontext1_7 = uimenu('Parent',handlcontext1,'Label','white','Callback',{@ct_setcolor,obj});
            handlcontext1_8 = uimenu('Parent',handlcontext1,'Label','random','Callback',{@ct_setcolor,obj});
            handlcontext3 = uimenu(handlcontext,'Label','delete','Callback',{@ct_delete,obj});
            
            %% Context functions:
            function ct_setcolor(src,event,curobj)
                curobj.color = systemColors(src.Label);
            end
            
            function ct_bind(src,event,obj,index)
                warning('"bind" is not functional yet!');
                xx = obj.position(1);
                yy = obj.position(2);
                xx(index) = 10*rand;
                yy(index) = 10*rand;
                obj.setPosition(xx,yy);
            end
            
            function ct_setposition(src,event,obj,index)
                warning('"set position" is not functional yet!');
                xx = obj.position(1);
                yy = obj.position(2);
                xx(index) = 10*rand;
                yy(index) = 10*rand;
                obj.setPosition(xx,yy);
            end
            
            function ct_delete(src,event,obj)
                obj.window.deleteObject(obj.id);
                delete(obj.plotHandle);
            end
        end
        
        function set.color(obj,newcolor)
            obj.plotHandle.EdgeColor = newcolor;
            obj.plotHandle.FaceColor = newcolor;
        end
        
        function col = get.color(obj)
            col = obj.plotHandle.EdgeColor;
        end
                
    end
end