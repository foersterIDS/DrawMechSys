classdef rotdamper < gfx2d.DrawMechSysObject
    
    properties
        window
        id
        Nu = 100;
        radius
        b
        lmin
        center
        p1
        p2
        handl
        plm
        pll
        plr
        scl
        scr
        vis = 0.3;
        visOn = 0;
    end
    properties (Dependent)
        color
    end
    
    methods
        function obj = rotdamper(X,Y,b,lmin,center,varargin)
            %% Init:
            stdinp = 5;
            co = [0,0,0];
            lw = 3;
            ms = 1*lw;
            obj.b = b;
            obj.lmin = lmin;
            obj.center = center;
            obj.p1 = [X(1);Y(1)];
            obj.p2 = [X(2);Y(2)];
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
                        case 'markersize'
                            ms = varargin{i+1};
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
                        otherwise
                            error('No such element: %s',varargin{i});
                    end
                    i = i+1;
                end
            end
            %% Calc:
            obj.radius = sqrt((X(1)-obj.center(1))^2+(Y(1)-obj.center(2))^2);
            alphaa = atan2(Y(1)-obj.center(2),X(1)-obj.center(1));
            alphae = atan2(Y(2)-obj.center(2),X(2)-obj.center(1));
            if alphae<alphaa
                alpha = 2*pi+(alphae-alphaa);
            else
                alpha = alphae-alphaa;
            end
            alpha0 = atan2((Y(1)-obj.center(2)),(X(1)-obj.center(1)));
            l = 2*alpha*obj.radius;
            if obj.lmin<0
                error('lmin must be lmin>=0');
            elseif l<obj.lmin
                error('Distance smaller than lmin!');
            elseif round(sqrt((X(1)-obj.center(1))^2+(Y(1)-obj.center(2))^2),8)~=round(sqrt((X(2)-obj.center(1))^2+(Y(2)-obj.center(2))^2),8)
                error('The connection points do not have the same radius to the center point.');
            end
            % Referenzdaempfer:
            xsr1 = linspace(0,obj.lmin/3,obj.Nu);
            ysr1 = linspace(0,0,obj.Nu);
            xsrMid = [obj.lmin/3,...
                linspace(obj.lmin/3,l-obj.lmin/3,obj.Nu),NaN,...
                linspace(obj.lmin/3,l-obj.lmin/3,obj.Nu),NaN,...
                l-2*obj.lmin/3,l-2*obj.lmin/3];
            ysrMid = [-obj.b/2,...
                linspace(+obj.b/2,+obj.b/2,obj.Nu),NaN,...
                linspace(-obj.b/2,-obj.b/2,obj.Nu),NaN,...
                -obj.b/4,+obj.b/4];
            xsr2 = linspace(l-2*obj.lmin/3,l,obj.Nu);
            ysr2 = linspace(0,0,obj.Nu);
            % Transformation:
            xs1 = obj.center(1)+(obj.radius+ysr1).*cos(alpha0+xsr1./(2*obj.radius));
            ys1 = obj.center(2)+(obj.radius+ysr1).*sin(alpha0+xsr1./(2*obj.radius));
            xsMid = obj.center(1)+(obj.radius+ysrMid).*cos(alpha0+xsrMid./(2*obj.radius));
            ysMid = obj.center(2)+(obj.radius+ysrMid).*sin(alpha0+xsrMid./(2*obj.radius));
            xs2 = obj.center(1)+(obj.radius+ysr2).*cos(alpha0+xsr2./(2*obj.radius));
            ys2 = obj.center(2)+(obj.radius+ysr2).*sin(alpha0+xsr2./(2*obj.radius));
            %% Plot:
            obj.plm = plot(xsMid,ysMid,'-','Color',co,'LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'downm',obj});
            obj.pll = plot(xs1,ys1,'-','MarkerSize',ms,'Color',co,'LineWidth',lw,'MarkerIndices',1,'buttondownfcn',{@Mouse_Callback,'down',obj});
            obj.plr = plot(xs2,ys2,'-','MarkerSize',ms,'Color',co,'LineWidth',lw,'MarkerIndices',obj.Nu,'buttondownfcn',{@Mouse_Callback,'down',obj});
            obj.scl = scatter(xsr1,ysr1,ms,co,"filled","MarkerEdgeColor",'none',"MarkerFaceColor",co,"LineWidth",lw,'buttondownfcn',{@Mouse_Callback,'down',obj});
            obj.scr = scatter(xsr2,ysr2,ms,co,"filled","MarkerEdgeColor",'none',"MarkerFaceColor",co,"LineWidth",lw,'buttondownfcn',{@Mouse_Callback,'down',obj});
            
            obj.handl = scatter(obj.center(1),obj.center(2),'o','MarkerFaceColor','m','MarkerEdgeColor','m','LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'drag',obj}); % centerpunkt
            obj.handl.MarkerFaceAlpha = 0;
            obj.handl.MarkerEdgeAlpha = obj.visOn*obj.vis;
            
            %% Callback function:
            function Mouse_Callback(hObj,~,action,sObj)
                persistent curobj xdata ydata ind xdatarel ydatarel centerrel cen alpha1 alpha2
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
                        indb = -(ind-3);
                        alphaa = atan2(pos(3)-curobj.center(2),pos(1)-curobj.center(1));
                        alphab = atan2(yy(indb)-curobj.center(2),xx(indb)-curobj.center(1));
                        rad = obj.radius;
                        % horizontal move
                        xx(ind) = curobj.center(1)+rad*cos(alphaa);
                        xx(indb) = curobj.center(1)+rad*cos(alphab);
                        % vertical move
                        yy(ind) = curobj.center(2)+rad*sin(alphaa);
                        yy(indb) = curobj.center(2)+rad*sin(alphab);
                        % update
                        curobj.setPosition(xx,yy,curobj.center);
                    case 'downm'
                        curobj = sObj;
                        cen = curobj.center;
                        alpha1 = atan2(curobj.p1(2)-cen(2),curobj.p1(1)-cen(1));
                        alpha2 = atan2(curobj.p2(2)-cen(2),curobj.p2(1)-cen(1));
                        set(gcf,...
                            'WindowButtonMotionFcn',  {@Mouse_Callback,'movem'},...
                            'WindowButtonUpFcn',      {@Mouse_Callback,'up'});
                    case 'movem'
                        rad = sqrt((pos(3)-cen(2))^2+(pos(1)-cen(1))^2);
                        xx = cen(1)+rad*cos([alpha1,alpha2]);
                        yy = cen(2)+rad*sin([alpha1,alpha2]);
                        % update
                        curobj.setPosition(xx,yy,cen);
                    case 'drag'
                        curobj = sObj;
                        xdatarel = [curobj.p1(1),curobj.p2(1)]-pos(1);
                        ydatarel = [curobj.p1(2),curobj.p2(2)]-pos(3);
                        centerrel = curobj.center-[pos(1);pos(3)];
                        set(gcf,...
                            'WindowButtonMotionFcn',  {@Mouse_Callback,'dodrag'},...
                            'WindowButtonUpFcn',      {@Mouse_Callback,'up'});
                    case 'dodrag'
                        % update
                        curobj.setPosition(xdatarel+pos(1),ydatarel+pos(3),centerrel+[pos(1);pos(3)]);
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
            % l:
            sclcontext = uicontextmenu;
            obj.scl.UIContextMenu = sclcontext;
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
            sclcontext4 = uimenu(sclcontext,'Label','delete','Callback',{@ct_delete,obj});
            % r:
            scrcontext = uicontextmenu;
            obj.scr.UIContextMenu = scrcontext;
            plrcontext1 = uimenu(scrcontext,'Label','change color');
            scrcontext1_1 = uimenu('Parent',scrcontext1,'Label','blue','Callback',{@ct_setcolor,obj});
            scrcontext1_2 = uimenu('Parent',scrcontext1,'Label','red','Callback',{@ct_setcolor,obj});
            scrcontext1_3 = uimenu('Parent',scrcontext1,'Label','magenta','Callback',{@ct_setcolor,obj});
            scrcontext1_4 = uimenu('Parent',scrcontext1,'Label','green','Callback',{@ct_setcolor,obj});
            scrcontext1_5 = uimenu('Parent',scrcontext1,'Label','yellow','Callback',{@ct_setcolor,obj});
            scrcontext1_6 = uimenu('Parent',scrcontext1,'Label','black','Callback',{@ct_setcolor,obj});
            scrcontext1_7 = uimenu('Parent',scrcontext1,'Label','white','Callback',{@ct_setcolor,obj});
            scrcontext1_8 = uimenu('Parent',scrcontext1,'Label','random','Callback',{@ct_setcolor,obj});
            scrcontext2 = uimenu(scrcontext,'Label','bind','Callback',{@ct_bind,obj,2});
            scrcontext3 = uimenu(scrcontext,'Label','set position','Callback',{@ct_setposition,obj,2});
            scrcontext4 = uimenu(scrcontext,'Label','delete','Callback',{@ct_delete,obj});
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
            obj.p1 = [X(1);Y(1)];
            obj.p2 = [X(2);Y(2)];
            if nargin==4
                obj.center = varargin{1};
                obj.radius = sqrt((X(1)-obj.center(1))^2+(Y(1)-obj.center(2))^2);
            end
            %% Calc:
            obj.radius = sqrt((X(1)-obj.center(1))^2+(Y(1)-obj.center(2))^2);
            alphaa = atan2(Y(1)-obj.center(2),X(1)-obj.center(1));
            alphae = atan2(Y(2)-obj.center(2),X(2)-obj.center(1));
            if alphae<alphaa
                alpha = 2*pi+(alphae-alphaa);
            else
                alpha = alphae-alphaa;
            end
            alpha0 = atan2((Y(1)-obj.center(2)),(X(1)-obj.center(1)));
            l = 2*alpha*obj.radius;
            if obj.lmin<0
                error('lmin must be lmin>=0');
            elseif l<obj.lmin
                error('Distance smaller than lmin!');
            elseif round(sqrt((X(1)-obj.center(1))^2+(Y(1)-obj.center(2))^2),8)~=round(sqrt((X(2)-obj.center(1))^2+(Y(2)-obj.center(2))^2),8)
                error('The connection points do not have the same radius to the center point.');
            end
            % Referenzdaempfer:
            xsr1 = linspace(0,obj.lmin/3,obj.Nu);
            ysr1 = linspace(0,0,obj.Nu);
            xsrMid = [obj.lmin/3,...
                linspace(obj.lmin/3,l-obj.lmin/3,obj.Nu),NaN,...
                linspace(obj.lmin/3,l-obj.lmin/3,obj.Nu),NaN,...
                l-2*obj.lmin/3,l-2*obj.lmin/3];
            ysrMid = [-obj.b/2,...
                linspace(+obj.b/2,+obj.b/2,obj.Nu),NaN,...
                linspace(-obj.b/2,-obj.b/2,obj.Nu),NaN,...
                -obj.b/4,+obj.b/4];
            xsr2 = linspace(l-2*obj.lmin/3,l,obj.Nu);
            ysr2 = linspace(0,0,obj.Nu);
            % Transformation:
            xs1 = obj.center(1)+(obj.radius+ysr1).*cos(alpha0+xsr1./(2*obj.radius));
            ys1 = obj.center(2)+(obj.radius+ysr1).*sin(alpha0+xsr1./(2*obj.radius));
            xsMid = obj.center(1)+(obj.radius+ysrMid).*cos(alpha0+xsrMid./(2*obj.radius));
            ysMid = obj.center(2)+(obj.radius+ysrMid).*sin(alpha0+xsrMid./(2*obj.radius));
            xs2 = obj.center(1)+(obj.radius+ysr2).*cos(alpha0+xsr2./(2*obj.radius));
            ys2 = obj.center(2)+(obj.radius+ysr2).*sin(alpha0+xsr2./(2*obj.radius));
            %% Update:
            obj.plm.XData = xsMid;
            obj.plm.YData = ysMid;
            obj.pll.XData = xs1;
            obj.pll.YData = ys1;
            obj.plr.XData = xs2;
            obj.plr.YData = ys2;
            obj.scl.XData = xs1;
            obj.scl.YData = ys1;
            obj.scr.XData = xs2;
            obj.scr.YData = ys2;
            obj.handl.XData = obj.center(1);
            obj.handl.YData = obj.center(2);
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
            delete(obj.scl);
            delete(obj.scr);
            delete(obj.handl);
            obj.window.deleteObject(obj.id);
        end
        
        function set.color(obj,newcolor)
            obj.pll.Color = newcolor;
            obj.plm.Color = newcolor;
            obj.plr.Color = newcolor;
            obj.scl.MarkerEdgeColor = newcolor;
            obj.scl.MarkerFaceColor = newcolor;
            obj.scr.MarkerEdgeColor = newcolor;
            obj.scr.MarkerFaceColor = newcolor;
        end
        
        function col = get.color(obj)
            col = obj.plm.Color;
        end
    end
end