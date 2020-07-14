classdef coordinatesystem < handle
    
    properties
        window
        id
        position
        angle = 0;
        z = +1;
        showZ = true;
        ax
        ay
        az
        tx
        ty
        tz
        xplz
        yplz
        xplzmp
        yplzmp
        xplzmn
        yplzmn
        fs
        l = 1;
        b = 0.1;
        lw = 3;
        Nu = 100;
        col
        offset1
        offset2
        offset3
        r
        phi
        str = {'x','y','z'};
        objectIDs = 1:5;
    end
    properties (Dependent)
        color
    end
    
    methods
        function obj = coordinatesystem(x,y,angle,varargin)
            %% Init:
            stdinp = 3;
            obj.col = [0,0,0];
            obj.fs = 28;
            obj.position = [x;y];
            %% Input:
            if nargin>stdinp
                i = 1;
                while i<=nargin-stdinp
                    switch lower(varargin{i})
                        case 'color'
                            obj.col = varargin{i+1};
                            i = i+1;
                        case 'fonsize'
                            obj.fs = varargin{i+1};
                            i = i+1;
                        case 'axes'
                            obj.str = varargin{i+1};
                            i = i+1;
                        case 'showz'
                            obj.showZ = varargin{i+1};
                            i = i+1;
                        case 'z'
                            obj.z = varargin{i+1};
                            i = i+1;
                        case 'length'
                            obj.l = varargin{i+1};
                            i = i+1;
                        case 'width'
                            obj.b = varargin{i+1};
                            i = i+1;
                        case 'linewidth'
                            obj.lw = varargin{i+1};
                            i = i+1;
                        case 'orientation'
                            in = varargin{i+1};
                            if length(in)==2
                                obj.angle = atan2(in(2),in(1));
                            else
                                obj.angle = in;
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
            %% Referenz
            obj.ax = gfx2d.force(0,0,obj.b,[obj.l;0],'Color',obj.color,'LineWidth',obj.lw,'window',obj,1);
            obj.ay = gfx2d.force(0,0,sign(obj.z)*obj.b,[0;obj.l],'Color',obj.color,'LineWidth',obj.lw,'window',obj,2);
            obj.phi = linspace(0,2*pi,obj.Nu);
            obj.r = obj.l/5;
            obj.xplz = obj.r*cos(obj.phi);
            obj.yplz = obj.r*sin(obj.phi);
            obj.az = cell(2,1);
            obj.az{1} = plot(obj.xplz,obj.yplz,'Color',obj.color,'LineWidth',obj.lw,'buttondownfcn',{@Mouse_Callback,'drag',obj});
            hold on;
            obj.xplzmp = obj.r/3*cos(obj.phi);
            obj.yplzmp = obj.r/3*sin(obj.phi);
            obj.az{2} = fill(obj.xplzmp,obj.yplzmp,'','EdgeColor',obj.color,'FaceColor',obj.color,'LineWidth',obj.lw,'buttondownfcn',{@Mouse_Callback,'drag',obj});
            obj.xplzmn = obj.r*cos([1,5,NaN,3,7]*pi/4);
            obj.yplzmn = obj.r*sin([1,5,NaN,3,7]*pi/4);
            obj.az{3} = plot(obj.xplzmn,obj.yplzmn,'Color',obj.color,'LineWidth',obj.lw,'buttondownfcn',{@Mouse_Callback,'drag',obj});
            if obj.z>=0
                obj.az{2}.Visible = true;
                obj.az{3}.Visible = false;
            else
                obj.az{2}.Visible = false;
                obj.az{3}.Visible = true;
            end
            obj.az{1}.Visible = obj.showZ;
            obj.az{2}.Visible = obj.showZ;
            obj.offset1 = 0.9*obj.l;
            obj.offset2 = 3*obj.b;
            obj.offset3 = 1.5*obj.r;
            obj.tx = gfx2d.word(obj.offset1,-sign(obj.z)*obj.offset2,obj.str{1},'color',obj.color,'fonsize',obj.fs,'window',obj,3);
            obj.ty = gfx2d.word(-obj.offset2,sign(obj.z)*obj.offset1,obj.str{2},'color',obj.color,'fonsize',obj.fs,'window',obj,4);
            obj.tz = gfx2d.word(-obj.offset3,-sign(obj.z)*obj.offset3,obj.str{3},'color',obj.color,'fonsize',obj.fs,'window',obj,5);
            %% Transform:
            obj.setPosition(x,y,angle);
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
            obj.az{1}.UIContextMenu = plcontext;
            obj.az{2}.UIContextMenu = plcontext;
            plcontext1 = uimenu(plcontext,'Label','change color');
            plcontext1_1 = uimenu('Parent',plcontext1,'Label','blue','Callback',{@ct_setcolor,obj});
            plcontext1_2 = uimenu('Parent',plcontext1,'Label','red','Callback',{@ct_setcolor,obj});
            plcontext1_3 = uimenu('Parent',plcontext1,'Label','magenta','Callback',{@ct_setcolor,obj});
            plcontext1_4 = uimenu('Parent',plcontext1,'Label','green','Callback',{@ct_setcolor,obj});
            plcontext1_5 = uimenu('Parent',plcontext1,'Label','yellow','Callback',{@ct_setcolor,obj});
            plcontext1_6 = uimenu('Parent',plcontext1,'Label','black','Callback',{@ct_setcolor,obj});
            plcontext1_7 = uimenu('Parent',plcontext1,'Label','white','Callback',{@ct_setcolor,obj});
            plcontext1_8 = uimenu('Parent',plcontext1,'Label','random','Callback',{@ct_setcolor,obj});
            plcontext2 = uimenu(plcontext,'Label','rotate x','Callback',{@ct_rotateX,obj});
            plcontext3 = uimenu(plcontext,'Label','rotate','Callback',{@ct_rotate,obj});
            plcontext4 = uimenu(plcontext,'Label','freeze rotation','Callback',{@ct_freezerotation,obj});
            plcontext5 = uimenu(plcontext,'Label','delete','Callback',{@ct_delete,obj});
            
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
            
            function ct_rotateX(src,event,obj)
                obj.rotateX();
            end
        end
        
        function setPosition(obj,X,Y,angle)
            obj.position(1) = X;
            obj.position(2) = Y;
            if nargin==4
                obj.angle = angle;
            end
            if sum(obj.objectIDs==1)
                obj.ax.setPosition(X,Y,obj.l*[cos(angle);sin(angle)]);
            end
            if sum(obj.objectIDs==2)
                obj.ay.setPosition(X,Y,sign(obj.z)*obj.l*[-sin(angle);cos(angle)]);
            end
            if obj.z>=0
                obj.az{2}.Visible = true;
                obj.az{3}.Visible = false;
            else
                obj.az{2}.Visible = false;
                obj.az{3}.Visible = true;
            end
            obj.az{1}.XData = obj.xplz+X;
            obj.az{1}.YData = obj.yplz+Y;
            obj.az{2}.XData = X+obj.xplzmp*cos(angle)-obj.yplzmp*sin(angle);
            obj.az{2}.YData = Y+obj.xplzmp*sin(angle)+obj.yplzmp*cos(angle);
            obj.az{3}.XData = X+obj.xplzmn*cos(angle)-obj.yplzmn*sin(angle);
            obj.az{3}.YData = Y+obj.xplzmn*sin(angle)+obj.yplzmn*cos(angle);
            if obj.z>=0
                obj.az{2}.Visible = true;
                obj.az{3}.Visible = false;
            else
                obj.az{2}.Visible = false;
                obj.az{3}.Visible = true;
            end
            posx = [X;Y]+[cos(angle),-sin(angle);sin(angle),cos(angle)]*[obj.offset1;-sign(obj.z)*obj.offset2];
            posy = [X;Y]+[cos(angle),-sin(angle);sin(angle),cos(angle)]*[-obj.offset2;sign(obj.z)*obj.offset1];
            posz = [X;Y]+[cos(angle),-sin(angle);sin(angle),cos(angle)]*[-obj.offset3;-sign(obj.z)*obj.offset3];
            if sum(obj.objectIDs==3)
                obj.tx.setPosition(posx(1),posx(2),angle);
            end
            if sum(obj.objectIDs==4)
                obj.ty.setPosition(posy(1),posy(2),angle);
            end
            if sum(obj.objectIDs==5)
                obj.tz.setPosition(posz(1),posz(2),angle);
            end
        end
        
        function delete(obj)
            try
                obj.ax.delete();
            catch
            end
            try
                obj.ay.delete();
            catch
            end
            try
                delete(obj.az{1});
            catch
            end
            try
                delete(obj.az{2});
            catch
            end
            try
                delete(obj.az{3});
            catch
            end
            try
                obj.tx.delete();
            catch
            end
            try
                obj.ty.delete();
            catch
            end
            try
                obj.tz.delete();
            catch
            end
            try
                obj.window.deleteObject(obj.id);
            catch
            end
        end
        
        function rotateX(obj)
            obj.z = -obj.z;
            obj.setPosition(obj.position(1),obj.position(2),obj.angle);
        end
        
        function deleteObject(obj,id)
            pos = 1;
            arr = ones(1,length(obj.objectIDs)-1);
            for i=1:length(obj.objectIDs)
                if obj.objectIDs(i)==id
                    % Objekt auslassen
                else
                    arr(pos) = obj.objectIDs(i);
                    pos = pos+1;
                end
            end
            arre = ones(1,pos-1);
            for i=1:pos-1
                arre(i) = arr(i);
            end
            obj.objectIDs = arre;
        end
        
        function globalLocation = local2global(obj,localLocation)
            ca = cos(obj.angle);
            sa = sin(obj.angle);
            dXdY = [ca -sa;sa ca]*(0.5*[obj.b;obj.h].*localLocation(:));
            
            globalLocation = obj.position +dXdY;            
        end
        
        function set.color(obj,newcolor)
            obj.col = newcolor;
%             obj.ax.color = newcolor;
%             obj.ay.color = newcolor;
            obj.az{1}.Color = newcolor;
            obj.az{2}.EdgeColor = newcolor;
            obj.az{2}.FaceColor = newcolor;
            obj.az{3}.Color = newcolor;
%             obj.tx.color = newcolor;
%             obj.ty.color = newcolor;
%             obj.tz.color = newcolor;
        end
        
        function col = get.color(obj)
            col = obj.col;
        end
    end
end