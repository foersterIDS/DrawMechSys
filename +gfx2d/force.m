classdef force < gfx2d.DrawMechSysObject
    
    properties
        window
        id
        p1
        vector
        fsw
        b
        handl
    end
    properties (Dependent)
        p2
        color
    end
    properties (Access=private)
        arrowFilled
        arrowRounded
        arrowRoundness = 0.2;
    end

    methods
        function obj = force(X,Y,b,vector,varargin)
            %% Init:
            stdinp = 4;
            color = [0,0,0];
            lw = 3;
            ms = 1*lw;
            obj.fsw = 20*(2*pi/360); % Pfeilspitzenwinkel (einseitig)
            obj.b = b;
            obj.p1 = [X;Y];
            obj.vector = vector;
            obj.arrowRounded = false;
            obj.arrowFilled = false;
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
                        case 'markersize'
                            ms = varargin{i+1};
                            i = i+1;
                        case 'window'
                            obj.window = varargin{i+1};
                            obj.id = varargin{i+2};
                            i = i+2;
                        case 'filled'
                            if strcmpi(varargin{i+1},'on')
                                obj.arrowFilled = true;
                            elseif strcmpi(varargin{i+1},'off')
                                obj.arrowFilled = false;
                            end
                            i = i+1;
                        case 'rounded'
                            if strcmpi(varargin{i+1},'on')
                                obj.arrowRounded = true;
                            elseif strcmpi(varargin{i+1},'off')
                                obj.arrowRounded = false;
                            end
                            i = i+1;
                        otherwise
                            error('No such element: %s',varargin{i});
                    end
                    i = i+1;
                end
            end
            %% Calc:
            l = sqrt(obj.vector(1)^2+obj.vector(2)^2);
            alpha = atan2(obj.vector(2),obj.vector(1));
            % Referenzpfeil:
            xsr1 = [0,0.9*l];
            ysr1 = [0,0];
            arrHeadLenMax = obj.b/(2*tan(obj.fsw));
            arrHeadLenReal = min([arrHeadLenMax,l]);
            if arrHeadLenReal < arrHeadLenMax
                bReal = 2 * arrHeadLenReal * tan(obj.fsw);
            else
                bReal = obj.b;
            end
            if obj.arrowFilled
                if obj.arrowRounded
                    N = max(bReal*30,30);
                    yr = linspace(bReal/2,-bReal/2,N);
                    ysr2 = [0, yr, 0];
                else
                    ysr2 = [0,+bReal/2,-bReal/2,0];
                end
            else
                ysr2 = [0,0,+bReal/2,NaN,-bReal/2,0];
            end
            if obj.arrowFilled
                if obj.arrowRounded
                    xMiddle = l-(1-obj.arrowRoundness)*arrHeadLenReal;
                    xEnd = l-arrHeadLenReal;
                    
                    xr = (xEnd - xMiddle)/(bReal/2)^2*yr.^2 + xMiddle;
                    xsr2 = [l, xr, l];
                else
                    xsr2 = [l,l-arrHeadLenReal,l-arrHeadLenReal,l];
                end
            else
                xsr2 = [0.9*l,l,l-arrHeadLenReal,NaN,l-arrHeadLenReal,l];
            end
            % Transformation:
            xs1 = X+xsr1*cos(alpha)+ysr1*sin(alpha);
            ys1 = Y+xsr1*sin(alpha)-ysr1*cos(alpha);
            xs2 = X+xsr2*cos(alpha)+ysr2*sin(alpha);
            ys2 = Y+xsr2*sin(alpha)-ysr2*cos(alpha);
            %% Plot:
            obj.handl = cell(2,1);
            obj.handl{1} = plot(xs1,ys1,'-','Color',color,'LineWidth',lw,'MarkerSize',ms,'MarkerIndices',1,'buttondownfcn',{@Mouse_Callback,'drag',obj});
            if obj.arrowFilled
                obj.handl{2} = fill(xs2,ys2,color,'LineStyle','-','FaceColor',color,'EdgeColor','none',...
                    'LineJoin','miter','LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'down',obj});
            else
                obj.handl{2} = plot(xs2,ys2,'-','Color',color,'LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'down',obj});
                obj.handl{4} = scatter(xs2,ys2,ms,color,"filled","MarkerEdgeColor",'none',"MarkerFaceColor",color,"LineWidth",lw,'buttondownfcn',{@Mouse_Callback,'down',obj});
            end
            obj.handl{3} = scatter(xs1,ys1,ms,color,"filled","MarkerEdgeColor",'none',"MarkerFaceColor",color,"LineWidth",lw,'buttondownfcn',{@Mouse_Callback,'down',obj});
            
            %% Callback function:
            function Mouse_Callback(hObj,~,action,sObj)
                persistent curobj xdata ydata ind xdatarel ydatarel vectorrel
                pos = get(gca,'CurrentPoint');
                switch action
                    case 'down'
                        curobj = sObj;
                        xdata = curobj.p1(1);
                        ydata = curobj.p1(2);
                        vectorrel = [pos(1)-xdata;pos(3)-ydata];
                        set(gcf,...
                            'WindowButtonMotionFcn',  {@Mouse_Callback,'move'},...
                            'WindowButtonUpFcn',      {@Mouse_Callback,'up'});
                    case 'move'
                        vectorrel = [pos(1)-xdata;pos(3)-ydata];
                        % update
                        curobj.setPosition(xdata,ydata,vectorrel);
                    case 'drag'
                        curobj = sObj;
                        xdatarel = curobj.p1(1)-pos(1);
                        ydatarel = curobj.p1(2)-pos(3);
                        vectorrel = curobj.p2-curobj.p1;
                        set(gcf,...
                            'WindowButtonMotionFcn',  {@Mouse_Callback,'dodrag'},...
                            'WindowButtonUpFcn',      {@Mouse_Callback,'up'});
                    case 'dodrag'
                        % update
                        curobj.setPosition(xdatarel+pos(1),ydatarel+pos(3),vectorrel);
                    case 'up'
                        set(gcf,...
                            'WindowButtonMotionFcn',  '',...
                            'WindowButtonUpFcn',      '');
                end
            end
            
            %% Context menus:
            try
                % m:
                plmcontext = uicontextmenu;
                obj.handl{2}.UIContextMenu = plmcontext;
                plmcontext1 = uimenu(plmcontext,'Label','change color');
                plmcontext1_1 = uimenu('Parent',plmcontext1,'Label','blue','Callback',{@ct_setcolor,obj});
                plmcontext1_2 = uimenu('Parent',plmcontext1,'Label','red','Callback',{@ct_setcolor,obj});
                plmcontext1_3 = uimenu('Parent',plmcontext1,'Label','magenta','Callback',{@ct_setcolor,obj});
                plmcontext1_4 = uimenu('Parent',plmcontext1,'Label','green','Callback',{@ct_setcolor,obj});
                plmcontext1_5 = uimenu('Parent',plmcontext1,'Label','yellow','Callback',{@ct_setcolor,obj});
                plmcontext1_6 = uimenu('Parent',plmcontext1,'Label','black','Callback',{@ct_setcolor,obj});
                plmcontext1_7 = uimenu('Parent',plmcontext1,'Label','white','Callback',{@ct_setcolor,obj});
                plmcontext1_8 = uimenu('Parent',plmcontext1,'Label','random','Callback',{@ct_setcolor,obj});
                pllcontext2 = uimenu(plmcontext,'Label','set vector','Callback',{@ct_setvecotr,obj,1});
                plmcontext3 = uimenu(plmcontext,'Label','delete','Callback',{@ct_delete,obj});
                % l:
                pllcontext = uicontextmenu;
                obj.handl{1}.UIContextMenu = pllcontext;
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
                pllcontext4 = uimenu(pllcontext,'Label','set vector','Callback',{@ct_setvecotr,obj,1});
                pllcontext3 = uimenu(pllcontext,'Label','delete','Callback',{@ct_delete,obj});
                
                sclcontext = uicontextmenu;
                obj.handl{3}.UIContextMenu = sclcontext;
                sclcontext1 = uimenu(sclcontext,'Label','change color');
                sclcontext1_1 = uimenu('Parent',sclcontext1,'Label','blue','Callback',{@ct_setcolor,obj});
                sclcontext1_2 = uimenu('Parent',sclcontext1,'Label','red','Callback',{@ct_setcolor,obj});
                sclcontext1_3 = uimenu('Parent',sclcontext1,'Label','magenta','Callback',{@ct_setcolor,obj});
                sclcontext1_4 = uimenu('Parent',sclcontext1,'Label','green','Callback',{@ct_setcolor,obj});
                sclcontext1_5 = uimenu('Parent',sclcontext1,'Label','yellow','Callback',{@ct_setcolor,obj});
                sclcontext1_6 = uimenu('Parent',sclcontext1,'Label','black','Callback',{@ct_setcolor,obj});
                sclcontext1_7 = uimenu('Parent',sclcontext1,'Label','white','Callback',{@ct_setcolor,obj});
                sclcontext1_8 = uimenu('Parent',sclcontext1,'Label','random','Callback',{@ct_setcolor,obj});
                sclcontext2 = uimenu(sclcontext,'Label','bind','Callback',{@ct_bind,obj,1});
                sclcontext3 = uimenu(sclcontext,'Label','set position','Callback',{@ct_setposition,obj,1});
                sclcontext4 = uimenu(sclcontext,'Label','set vector','Callback',{@ct_setvecotr,obj,1});
                sclcontext3 = uimenu(sclcontext,'Label','delete','Callback',{@ct_delete,obj});
                
                if ~ obj.arrowFilled
                    scrcontext = uicontextmenu;
                    obj.handl{4}.UIContextMenu = scrcontext;
                    scrcontext1 = uimenu(scrcontext,'Label','change color');
                    scrcontext1_1 = uimenu('Parent',scrcontext1,'Label','blue','Callback',{@ct_setcolor,obj});
                    scrcontext1_2 = uimenu('Parent',scrcontext1,'Label','red','Callback',{@ct_setcolor,obj});
                    scrcontext1_3 = uimenu('Parent',scrcontext1,'Label','magenta','Callback',{@ct_setcolor,obj});
                    scrcontext1_4 = uimenu('Parent',scrcontext1,'Label','green','Callback',{@ct_setcolor,obj});
                    scrcontext1_5 = uimenu('Parent',scrcontext1,'Label','yellow','Callback',{@ct_setcolor,obj});
                    scrcontext1_6 = uimenu('Parent',scrcontext1,'Label','black','Callback',{@ct_setcolor,obj});
                    scrcontext1_7 = uimenu('Parent',scrcontext1,'Label','white','Callback',{@ct_setcolor,obj});
                    scrcontext1_8 = uimenu('Parent',scrcontext1,'Label','random','Callback',{@ct_setcolor,obj});
                    scrcontext2 = uimenu(scrcontext,'Label','bind','Callback',{@ct_bind,obj,1});
                    scrcontext3 = uimenu(scrcontext,'Label','set position','Callback',{@ct_setposition,obj,1});
                    scrcontext4 = uimenu(scrcontext,'Label','set vector','Callback',{@ct_setvecotr,obj,1});
                    scrcontext3 = uimenu(scrcontext,'Label','delete','Callback',{@ct_delete,obj});
                end
            catch
                
            end
            
            %% Context functions:
            function ct_setcolor(src,event,curobj)
                curobj.color = systemColors(src.Label);
            end
            
            function ct_bind(src,event,obj,index)
                warning('"bind" is not functional yet!');
                xx = obj.p1(1);
                yy = obj.p1(2);
                obj.setPosition(xx,yy);
            end
            
            function ct_setposition(src,event,obj,index)
                warning('"set position" is not functional yet!');
                xx = obj.p1(1);
                yy = obj.p1(2);
                obj.setPosition(xx,yy);
            end
            
            function ct_setvector(src,event,obj,index)
                warning('"set position" is not functional yet!');
                xx = obj.p1(1);
                yy = obj.p1(2);
                obj.setPosition(xx,yy);
            end
            
            function ct_delete(src,event,obj)
                obj.delete()
            end
        end
        
        
        function setPosition(obj,X,Y,varargin)
            if nargin==4
                obj.vector = varargin{1};
            end
            %% Calc:
            l = sqrt(obj.vector(1)^2+obj.vector(2)^2);
            alpha = atan2(obj.vector(2),obj.vector(1));
            % Referenzpfeil:
            xsr1 = [0,0.9*l];
            ysr1 = [0,0];
            arrHeadLenMax = obj.b/(2*tan(obj.fsw));
            arrHeadLenReal = min([arrHeadLenMax,l]);
            if arrHeadLenReal < arrHeadLenMax
                bReal = 2 * arrHeadLenReal * tan(obj.fsw);
            else
                bReal = obj.b;
            end
            if obj.arrowFilled
                if obj.arrowRounded
                    N = max(bReal*30,30);
                    yr = linspace(bReal/2,-bReal/2,N);
                    ysr2 = [0, yr, 0];
                else
                    ysr2 = [0,+bReal/2,-bReal/2,0];
                end
            else
                ysr2 = [0,0,+bReal/2,NaN,-bReal/2,0];
            end
            if obj.arrowFilled
                if obj.arrowRounded
                    xMiddle = l-(1-obj.arrowRoundness)*arrHeadLenReal;
                    xEnd = l-arrHeadLenReal;
                    
                    xr = (xEnd - xMiddle)/(bReal/2)^2*yr.^2 + xMiddle;
                    xsr2 = [l, xr, l];
                else
                    xsr2 = [l,l-arrHeadLenReal,l-arrHeadLenReal,l];
                end
            else
                xsr2 = [0.9*l,l,l-arrHeadLenReal,NaN,l-arrHeadLenReal,l];
            end
            % Transformation:
            xs1 = X+xsr1*cos(alpha)+ysr1*sin(alpha);
            ys1 = Y+xsr1*sin(alpha)-ysr1*cos(alpha);
            xs2 = X+xsr2*cos(alpha)+ysr2*sin(alpha);
            ys2 = Y+xsr2*sin(alpha)-ysr2*cos(alpha);
            %% Update:
            obj.handl{1}.XData = xs1;
            obj.handl{1}.YData = ys1;
            obj.handl{2}.XData = xs2;
            obj.handl{2}.YData = ys2;
            obj.handl{3}.XData = xs1;
            obj.handl{3}.YData = ys1;
            if ~obj.arrowFilled
                obj.handl{4}.XData = xs2;
                obj.handl{4}.YData = ys2;
            end
            obj.p1 = [X;Y];
        end
        
        function delete(obj)
            delete(obj.handl{1});
            delete(obj.handl{2});
            delete(obj.handl{3});
            if ~obj.arrowFilled
                delete(obj.handl{4});
            end
            try
                obj.window.deleteObject(obj.id);
            catch
            end
        end
        
        function set.color(obj,newcolor)
            obj.handl{1}.Color = newcolor;
            obj.handl{2}.Color = newcolor;
            obj.handl{3}.MarkerEdgeColor = newcolor;
            obj.handl{3}.MarkerFaceColor = newcolor;
            if ~obj.arrowFilled
                obj.handl{4}.MarkerEdgeColor = newcolor;
                obj.handl{4}.MarkerFaceColor = newcolor;
            end
        end
        
        function col = get.color(obj)
            col = obj.handl{1}.Color;
        end
                
        function p2 = get.p2(obj)
            p2 = obj.p1 + obj.vector;
        end

        function set.p2(obj,p2)
            obj.vector = p2 - obj.p1;
        end
    end
end