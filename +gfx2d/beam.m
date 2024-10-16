classdef beam < gfx2d.RigidBody
    
    properties
        window
        id
        pl
        plF = [];
        xPoints
        yPoints
        width
        type (1,:) char {mustBeMember(type,{'linearized','realistic'})} = 'realistic'
        length0
        showNeutralFibre (1,1) logical
    end
    properties (Dependent)
        color
        facecolor
    end
    
    methods
        function obj = beam(x0,y0,xPoints,yPoints,length0,width,orientation,varargin)
            %% Init:
            obj.xPoints = xPoints;
            obj.yPoints = yPoints;
            obj.length0 = length0;
            obj.width = width;
            stdinp = 7;
            obj.color = [0,0,0];
            obj.facecolor = [1,1,1]*0.8;
            obj.type = 'realistic';
            obj.showNeutralFibre = false;
            phi0 = 0;
            lw = 2;
            %% Input:
            if nargin>stdinp
                i = 1;
                while i<=nargin-stdinp
                    switch lower(varargin{i})
                        case 'color'
                            obj.color = varargin{i+1};
                            i = i+1;
                        case 'facecolor'
                            obj.facecolor = varargin{i+1};
                            i = i+1;
                        case 'linewidth'
                            lw = varargin{i+1};
                            i = i+1;
                        case 'window'
                            obj.window = varargin{i+1};
                            obj.id = varargin{i+2};
                            i = i+2;
                        case 'phi0'
                            phi0 = varargin{i+1};
                            i = i+1;
                        case 'type'
                            obj.type = varargin{i+1};
                            i = i+1;
                        case 'showneutralfibre'
                            obj.showNeutralFibre = varargin{i+1};
                            i = i+1;
                        otherwise
                            error('No such element: %s',varargin{i});
                    end
                    i = i+1;
                end
            end

            [xF,yF,xNF,yNF] = calculateBeamPoints(xPoints,yPoints,obj.width,phi0,obj.type,obj.length0);
            
            obj.hgTransformHandle = hgtransform();
            obj.setPosition(x0,y0,orientation);
            obj.pl = fill(xF,yF,'','FaceColor',obj.facecolor,'EdgeColor',obj.color,'LineWidth',lw,'Parent',obj.hgTransformHandle,'buttondownfcn',{@Mouse_Callback,'drag',obj});
            
            if obj.showNeutralFibre
                obj.plF = plot(xNF,yNF,'--','LineWidth',lw,'Color',obj.color,'Parent',obj.hgTransformHandle,'buttondownfcn',{@Mouse_Callback,'drag',obj});
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
            plcontext5 = uimenu(plcontext,'Label','delete','Callback',{@ct_delete,obj});
            
            %% Context functions:
            function ct_setcolor(src,event,curobj)
                curobj.color = systemColors(src.Label);
            end
            
            function ct_setfacecolor(src,event,curobj)
                curobj.facecolor = systemColors(src.Label);
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
        
        function updatePoints(obj,xPoints,yPoints,phi0)
            if nargin == 3
                phi0 = 0;
            end
            [xF,yF,xNF,yNF] = calculateBeamPoints(xPoints,yPoints,obj.width,phi0,obj.type,obj.length0);
            obj.pl.XData = xF;
            obj.pl.YData = yF;
            if obj.showNeutralFibre
                obj.plF.XData = xNF;
                obj.plF.YData = yNF;
            end
        end        

        function globalLocation = local2global(obj,localLocation)
            ca = cos(obj.angle);
            sa = sin(obj.angle);
            dXdY = [ca -sa;sa ca]*(0.5*[obj.l;obj.b].*localLocation(:));
            
            globalLocation = obj.position +dXdY;            
        end
        
        function delete(obj)
            delete(obj.pl);
            if ~isempty(obj.plF)
                delete(obj.plF);
            end
            if ~isempty(obj.window)
                obj.window.deleteObject(obj.id);
            end
        end
        
        function set.color(obj,newcolor)
            obj.pl.EdgeColor = newcolor;
            if ~isempty(obj.plF)
                obj.plF.EdgeColor = newcolor;
            end
        end
        
        function col = get.color(obj)
            col = obj.pl.EdgeColor;
        end
        
        function set.facecolor(obj,newcolor)
            obj.pl.FaceColor = newcolor;
        end
        
        function col = get.facecolor(obj)
            col = obj.pl.FaceColor;
        end
    end
end

function [xF,yF,xI,yI] = calculateBeamPoints(xPoints,yPoints,lWidth,phi0,type,l0)
    s = [0,cumsum(sqrt(sum(diff([xPoints;yPoints],[],2).^2)))];
    sI = linspace(0,s(end),max(100, length(s)));
    for kk = 1:3
        xI = interp1(s,xPoints,sI,"spline");
        yI = interp1(s,yPoints,sI,"spline");
        sI = [0,cumsum(sqrt(sum(diff([xI;yI],[],2).^2)))];
    end
    
    if strcmp(type,'linear') 
        xI = xI * l0/xI(end);
    end

    phis = [phi0, zeros(1,length(sI)-2), NaN];

    for kk = 2:length(sI)-1
        phis(kk) = atan((yI(kk+1)-yI(kk))/(xI(kk+1)-xI(kk)));
    end

    if strcmp(type,'linearized') 
        phis(end) = 0;
    else
        phis(end) = phis(end-1);
    end

    xF = [];
    yF = [];
    for kk = 1:length(sI)
        xF = [xF, xI(kk) - lWidth/2 * sin(phis(kk))];
        yF = [yF, yI(kk) + lWidth/2 * cos(phis(kk))];
    end

    for kk = 1:length(sI)
        xF = [xF, xI(end+1-kk) + lWidth/2 * sin(phis(end+1-kk))];
        yF = [yF, yI(end+1-kk) - lWidth/2 * cos(phis(end+1-kk))];
    end

    xF = [xF, xF(1)];
    yF = [yF, yF(1)];

    if strcmp(type,'linearized') 
        xF(xF>l0) = l0;
    end
end
