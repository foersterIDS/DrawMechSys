classdef torque < handle
    
    properties
        window
        id
        position
        Nu = 100;
        alpha0
        dAlphaMax
        value
        maxvalue
        fsw
        b
        r
        handl
        plm
        pll
        plr
        vis = 0.3;
        visOn = 0;
    end
    properties (Dependent)
        color
    end
    properties (Access=private)
        arrowFilled
        arrowRounded
        arrowRoundness = 0.2;
    end
    
    methods
        function obj = torque(X,Y,b,r,value,maxvalue,varargin)
            %% Init:
            stdinp = 6;
            co = [0,0,0];
            lw = 3;
            obj.fsw = 20*(2*pi/360); % Pfeilspitzenwinkel (einseitig)
            obj.alpha0 = 0;
            obj.dAlphaMax = 2*pi;
            obj.value = value;
            obj.maxvalue = maxvalue;
            obj.r = r;
            obj.b = b;
            obj.position = [X,Y];
            obj.arrowRounded = false;
            obj.arrowFilled = false;
            %% Input:
            if nargin>stdinp
                i = 1;
                while i<=nargin-stdinp
                    switch lower(varargin{i})
                        case 'color'
                            co = varargin{i+1};
                            i = i+1;
                        case 'linewidth'
                            lw = varargin{i+1};
                            i = i+1;
                        case 'alpha_0'
                            obj.alpha0 = varargin{i+1};
                            i = i+1;
                        case 'delta_alpha_max'
                            obj.dAlphaMax = varargin{i+1};
                            i = i+1;
                        case 'markervisibility'
                            if strcmpi(varargin{i+1},'on')
                                obj.visOn = 1;
                            elseif strcmpi(varargin{i+1},'off')
                                obj.visOn = 0;
                            end
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
            dalpha = obj.dAlphaMax*sgn(obj.value)*abs(obj.value/obj.maxvalue);
            l = abs(2*dalpha*obj.r);
            arrHeadLenMax = obj.b/(2*tan(obj.fsw));
            arrHeadLenReal = min([arrHeadLenMax,l]);
            if arrHeadLenReal < arrHeadLenMax
                bReal = 2 * arrHeadLenReal * tan(obj.fsw);
            else
                bReal = obj.b;
            end
            % Referenzpfeil:
%             xsr = sign(dalpha)*[linspace(0,l,obj.Nu),linspace(l,max([0,l-obj.b/(2*tan(obj.fsw))]),obj.Nu),NaN,linspace(max([0,l-obj.b/(2*tan(obj.fsw))]),l,obj.Nu)];
%             ysr = [linspace(0,0,obj.Nu),linspace(0,+obj.b/2,obj.Nu),NaN,linspace(-obj.b/2,0,obj.Nu)];
            xsr1 = sign(dalpha)*linspace(0,l*0.1,obj.Nu);
            ysr1 = linspace(0,0,obj.Nu);
            xsrMid = sign(dalpha)*linspace(l*0.1,l*0.9,obj.Nu);
            ysrMid = linspace(0,0,obj.Nu);
            if obj.arrowFilled
                if obj.arrowRounded
                    yr = linspace(bReal/2,-bReal/2,obj.Nu);
                    xMiddle = l-(1-obj.arrowRoundness)*arrHeadLenReal;
                    xEnd = l-arrHeadLenReal;
                    xr = (xEnd - xMiddle)/(bReal/2)^2*yr.^2 + xMiddle;
                    ysr2 = [linspace(0,+bReal/2,obj.Nu), yr(2:end-1), linspace(-bReal/2,0,obj.Nu)];
                    xsr2 = sign(dalpha)*[linspace(l,max([0,l-bReal/(2*tan(obj.fsw))]),obj.Nu), xr(2:end-1), linspace(max([0,l-bReal/(2*tan(obj.fsw))]),l,obj.Nu)];
                else
                    xsr2 = sign(dalpha)*[linspace(l,max([0,l-bReal/(2*tan(obj.fsw))]),obj.Nu),linspace(max([0,l-bReal/(2*tan(obj.fsw))]),l,obj.Nu)];
                    ysr2 = [linspace(0,+bReal/2,obj.Nu),linspace(-bReal/2,0,obj.Nu)];
                end
            else
                xsr2 = sign(dalpha)*[linspace(l*0.9,l,obj.Nu),linspace(l,max([0,l-bReal/(2*tan(obj.fsw))]),obj.Nu),NaN,linspace(max([0,l-bReal/(2*tan(obj.fsw))]),l,obj.Nu)];
                ysr2 = [linspace(0,0,obj.Nu),linspace(0,+bReal/2,obj.Nu),NaN,linspace(-bReal/2,0,obj.Nu)];
            end
            % Transformation:
%             xs = X+(obj.r+ysr).*cos(obj.alpha0+xsr./(2*obj.r));
%             ys = Y+(obj.r+ysr).*sin(obj.alpha0+xsr./(2*obj.r));
            xs1 = X+(obj.r+ysr1).*cos(obj.alpha0+xsr1./(2*obj.r));
            ys1 = Y+(obj.r+ysr1).*sin(obj.alpha0+xsr1./(2*obj.r));
            xsMid = X+(obj.r+ysrMid).*cos(obj.alpha0+xsrMid./(2*obj.r));
            ysMid = Y+(obj.r+ysrMid).*sin(obj.alpha0+xsrMid./(2*obj.r));
            xs2 = X+(obj.r+ysr2).*cos(obj.alpha0+xsr2./(2*obj.r));
            ys2 = Y+(obj.r+ysr2).*sin(obj.alpha0+xsr2./(2*obj.r));
            %% Plot:
            obj.plm = plot(xsMid,ysMid,'-','Color',co,'LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'downm',obj});
            obj.pll = plot(xs1,ys1,'.-','Color',co,'LineWidth',lw,'MarkerIndices',1,'buttondownfcn',{@Mouse_Callback,'downl',obj});
            if obj.arrowFilled
                obj.plr = fill(xs2,ys2,co,'LineStyle','-','FaceColor',co,'EdgeColor','none',...
                    'LineJoin','miter','LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'down',obj});
            else
                obj.plr = plot(xs2,ys2,'.-','Color',co,'LineWidth',lw,'MarkerIndices',2,'buttondownfcn',{@Mouse_Callback,'downr',obj});
            end
            
            obj.handl = scatter(X,Y,'o','MarkerFaceColor','m','MarkerEdgeColor','m','LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'drag',obj}); % centerpunkt
            obj.handl.MarkerFaceAlpha = 0;
            obj.handl.MarkerEdgeAlpha = obj.visOn*obj.vis;
%             obj.handl = plot(xs,ys,'Color',color,'LineWidth',lw);
            
            %% Callback function:
            function Mouse_Callback(hObj,~,action,sObj)
                persistent curobj xdata ydata ind xdatarel ydatarel centerrel
                pos = get(gca,'CurrentPoint');
                switch action
                    case 'downl'
                        curobj = sObj;
                        xdata = curobj.position(1);
                        ydata = curobj.position(2);
                        set(gcf,...
                            'WindowButtonMotionFcn',  {@Mouse_Callback,'movel'},...
                            'WindowButtonUpFcn',      {@Mouse_Callback,'up'});
                    case 'movel'
                        curobj.alpha0 = atan2(pos(3)-ydata,pos(1)-xdata);
                        % update
                        curobj.setPosition(xdata,ydata);
                    case 'downr'
                        curobj = sObj;
                        xdata = curobj.position(1);
                        ydata = curobj.position(2);
                        set(gcf,...
                            'WindowButtonMotionFcn',  {@Mouse_Callback,'mover'},...
                            'WindowButtonUpFcn',      {@Mouse_Callback,'up'});
                    case 'mover'
                        d_alpha = atan2(pos(3)-ydata,pos(1)-xdata)-curobj.alpha0;
                        curobj.value = d_alpha/curobj.dAlphaMax*curobj.maxvalue;
                        % update
                        curobj.setPosition(xdata,ydata);
                    case 'downm'
                        curobj = sObj;
                        xdata = curobj.position(1);
                        ydata = curobj.position(2);
                        set(gcf,...
                            'WindowButtonMotionFcn',  {@Mouse_Callback,'movem'},...
                            'WindowButtonUpFcn',      {@Mouse_Callback,'up'});
                    case 'movem'
                        obj.r = sqrt((pos(3)-ydata)^2+(pos(1)-xdata)^2);
                        % update
                        curobj.setPosition(xdata,ydata);
                    case 'drag'
                        curobj = sObj;
                        set(gcf,...
                            'WindowButtonMotionFcn',  {@Mouse_Callback,'dodrag'},...
                            'WindowButtonUpFcn',      {@Mouse_Callback,'up'});
                    case 'dodrag'
                        % update
                        curobj.setPosition(pos(1),pos(3));
                    case 'up'
                        set(gcf,...
                            'WindowButtonMotionFcn',  '',...
                            'WindowButtonUpFcn',      '');
                end
            end
            
            %% Context menus:
            % m:
            plmcontext = uicontextmenu;
            obj.plm.UIContextMenu = plmcontext;
            plmcontext1 = uimenu(plmcontext,'Label','change color');
            plmcontext1_1 = uimenu('Parent',plmcontext1,'Label','blue','Callback',{@ct_setcolor,obj});
            plmcontext1_2 = uimenu('Parent',plmcontext1,'Label','red','Callback',{@ct_setcolor,obj});
            plmcontext1_3 = uimenu('Parent',plmcontext1,'Label','magenta','Callback',{@ct_setcolor,obj});
            plmcontext1_4 = uimenu('Parent',plmcontext1,'Label','green','Callback',{@ct_setcolor,obj});
            plmcontext1_5 = uimenu('Parent',plmcontext1,'Label','yellow','Callback',{@ct_setcolor,obj});
            plmcontext1_6 = uimenu('Parent',plmcontext1,'Label','black','Callback',{@ct_setcolor,obj});
            plmcontext1_7 = uimenu('Parent',plmcontext1,'Label','white','Callback',{@ct_setcolor,obj});
            plmcontext1_8 = uimenu('Parent',plmcontext1,'Label','random','Callback',{@ct_setcolor,obj});
            plmcontext2 = uimenu(plmcontext,'Label','delete','Callback',{@ct_delete,obj});
            % l:
            pllcontext = uicontextmenu;
            obj.pll.UIContextMenu = pllcontext;
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
            pllcontext4 = uimenu(pllcontext,'Label','delete','Callback',{@ct_delete,obj});
            % r:
            plrcontext = uicontextmenu;
            obj.plr.UIContextMenu = plrcontext;
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
            plrcontext4 = uimenu(plrcontext,'Label','delete','Callback',{@ct_delete,obj});
            % c:
            handlcontext = uicontextmenu;
            obj.handl.UIContextMenu = handlcontext;
            handlcontext1 = uimenu(handlcontext,'Label','change color');
            handlcontext1_1 = uimenu('Parent',handlcontext1,'Label','blue','Callback',{@ct_setcolor,obj});
            handlcontext1_2 = uimenu('Parent',handlcontext1,'Label','red','Callback',{@ct_setcolor,obj});
            handlcontext1_3 = uimenu('Parent',handlcontext1,'Label','magenta','Callback',{@ct_setcolor,obj});
            handlcontext1_4 = uimenu('Parent',handlcontext1,'Label','green','Callback',{@ct_setcolor,obj});
            handlcontext1_5 = uimenu('Parent',handlcontext1,'Label','yellow','Callback',{@ct_setcolor,obj});
            handlcontext1_6 = uimenu('Parent',handlcontext1,'Label','black','Callback',{@ct_setcolor,obj});
            handlcontext1_7 = uimenu('Parent',handlcontext1,'Label','white','Callback',{@ct_setcolor,obj});
            handlcontext1_8 = uimenu('Parent',handlcontext1,'Label','random','Callback',{@ct_setcolor,obj});
            handlcontext2 = uimenu(handlcontext,'Label','change visibility','Callback',{@ct_changeVisibility,obj});
            handlcontext3 = uimenu(handlcontext,'Label','delete','Callback',{@ct_delete,obj});
            
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
            
            function ct_changeVisibility(src,event,obj)
                obj.changeVisibility();
            end
            
            function ct_delete(src,event,obj)
                obj.delete();
            end
        end
        
        
        function setPosition(obj,X,Y,varargin)
            if nargin>=4
                obj.value = varargin{1};
                if nargin==5
                    obj.maxvalue = varargin{2};
                end
            end
            %% Calc:
            dalpha = obj.dAlphaMax*sgn(obj.value)*abs(obj.value/obj.maxvalue);
            l = abs(2*dalpha*obj.r);
            arrHeadLenMax = obj.b/(2*tan(obj.fsw));
            arrHeadLenReal = min([arrHeadLenMax,l]);
            if arrHeadLenReal < arrHeadLenMax
                bReal = 2 * arrHeadLenReal * tan(obj.fsw);
            else
                bReal = obj.b;
            end
            % Referenzpfeil:
            xsr = sign(dalpha)*[linspace(0,l,obj.Nu),linspace(l,max([0,l-bReal/(2*tan(obj.fsw))]),obj.Nu),NaN,linspace(max([0,l-bReal/(2*tan(obj.fsw))]),l,obj.Nu)];
            ysr = [linspace(0,0,obj.Nu),linspace(0,+bReal/2,obj.Nu),NaN,linspace(-bReal/2,0,obj.Nu)];
            % Transformation:
            xs = X+(obj.r+ysr).*cos(obj.alpha0+xsr./(2*obj.r));
            ys = Y+(obj.r+ysr).*sin(obj.alpha0+xsr./(2*obj.r));
            %% Update:
            obj.handl.XData = xs;
            obj.handl.YData = ys;
            obj.position = [X,Y];
            dalpha = obj.dAlphaMax*sgn(obj.value)*abs(obj.value/obj.maxvalue);
            l = abs(2*dalpha*obj.r);
            %% Referenzpfeil:
%             xsr = sign(dalpha)*[linspace(0,l,obj.Nu),linspace(l,max([0,l-obj.b/(2*tan(obj.fsw))]),obj.Nu),NaN,linspace(max([0,l-obj.b/(2*tan(obj.fsw))]),l,obj.Nu)];
%             ysr = [linspace(0,0,obj.Nu),linspace(0,+obj.b/2,obj.Nu),NaN,linspace(-obj.b/2,0,obj.Nu)];
            xsr1 = sign(dalpha)*linspace(0,l*0.1,obj.Nu);
            ysr1 = linspace(0,0,obj.Nu);
            xsrMid = sign(dalpha)*linspace(l*0.1,l*0.9,obj.Nu);
            ysrMid = linspace(0,0,obj.Nu);
            if obj.arrowFilled
                if obj.arrowRounded
                    yr = linspace(bReal/2,-bReal/2,obj.Nu);
                    xMiddle = l-(1-obj.arrowRoundness)*arrHeadLenReal;
                    xEnd = l-arrHeadLenReal;
                    xr = (xEnd - xMiddle)/(bReal/2)^2*yr.^2 + xMiddle;
                    ysr2 = [linspace(0,+bReal/2,obj.Nu), yr(2:end-1), linspace(-bReal/2,0,obj.Nu)];
                    xsr2 = sign(dalpha)*[linspace(l,max([0,l-bReal/(2*tan(obj.fsw))]),obj.Nu), xr(2:end-1), linspace(max([0,l-bReal/(2*tan(obj.fsw))]),l,obj.Nu)];
                else
                    xsr2 = sign(dalpha)*[linspace(l,max([0,l-bReal/(2*tan(obj.fsw))]),obj.Nu),linspace(max([0,l-bReal/(2*tan(obj.fsw))]),l,obj.Nu)];
                    ysr2 = [linspace(0,+bReal/2,obj.Nu),linspace(-bReal/2,0,obj.Nu)];
                end
            else
                xsr2 = sign(dalpha)*[linspace(l*0.9,l,obj.Nu),linspace(l,max([0,l-bReal/(2*tan(obj.fsw))]),obj.Nu),NaN,linspace(max([0,l-bReal/(2*tan(obj.fsw))]),l,obj.Nu)];
                ysr2 = [linspace(0,0,obj.Nu),linspace(0,+bReal/2,obj.Nu),NaN,linspace(-bReal/2,0,obj.Nu)];
            end
            %% Transformation:
%             xs = X+(obj.r+ysr).*cos(obj.alpha0+xsr./(2*obj.r));
%             ys = Y+(obj.r+ysr).*sin(obj.alpha0+xsr./(2*obj.r));
            xs1 = X+(obj.r+ysr1).*cos(obj.alpha0+xsr1./(2*obj.r));
            ys1 = Y+(obj.r+ysr1).*sin(obj.alpha0+xsr1./(2*obj.r));
            xsMid = X+(obj.r+ysrMid).*cos(obj.alpha0+xsrMid./(2*obj.r));
            ysMid = Y+(obj.r+ysrMid).*sin(obj.alpha0+xsrMid./(2*obj.r));
            xs2 = X+(obj.r+ysr2).*cos(obj.alpha0+xsr2./(2*obj.r));
            ys2 = Y+(obj.r+ysr2).*sin(obj.alpha0+xsr2./(2*obj.r));
            %% Update:
            obj.plm.XData = xsMid;
            obj.plm.YData = ysMid;
            obj.pll.XData = xs1;
            obj.pll.YData = ys1;
            obj.plr.XData = xs2;
            obj.plr.YData = ys2;
            obj.handl.XData = X;
            obj.handl.YData = Y;
        end
        
        function changeVisibility(obj)
            if obj.visOn
                obj.handl.MarkerEdgeAlpha = 0;
                obj.visOn = 0;
            else
                obj.handl.MarkerEdgeAlpha = obj.vis;
                obj.visOn = 1;
            end
        end
        
        function delete(obj)
            delete(obj.pll);
            delete(obj.plm);
            delete(obj.plr);
            delete(obj.handl);
            obj.window.deleteObject(obj.id);
        end
        
        function set.color(obj,newcolor)
            obj.pll.Color = newcolor;
            obj.plm.Color = newcolor;
            obj.plr.Color = newcolor;
        end
        
        function col = get.color(obj)
            col = obj.plm.Color;
        end
    end
end