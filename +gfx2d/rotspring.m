classdef rotspring < handle
    
    properties
        window
        id
        n
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
        vis = 0.3;
        visOn = 0;
        plmcontext
        pllcontext
        plrcontext
    end
    properties (Dependent)
        color
    end
    
    methods
        function obj = rotspring(X,Y,b,lmin,center,varargin)
            %% Init:
            stdinp = 5;
            co = [0,0,0];
            obj.n = 4;
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
                        case 'n'
                            obj.n = varargin{i+1};
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
            dl = (l-obj.lmin)/obj.n;
            if obj.lmin<0
                error('lmin must be lmin>=0');
            elseif l<obj.lmin
                error('Distance smaller than lmin!');
            elseif obj.n<2
                error('n must be at least 2');
            elseif round(sqrt((X(1)-obj.center(1))^2+(Y(1)-obj.center(2))^2),8)~=round(sqrt((X(2)-obj.center(1))^2+(Y(2)-obj.center(2))^2),8)
                error('The connection points do not have the same radius to the center point.');
            end
            % Referenzfeder:
            xsr1 = [0,obj.lmin/2];
            ysr1 = [0,0];
            xsrMid = obj.lmin/2;
            ysrMid = 0;
            for w=1:obj.n
                xsrMid = [xsrMid,obj.lmin/2+dl*(w-1)+1/4*dl,obj.lmin/2+dl*(w-1)+3/4*dl];
                ysrMid = [ysrMid,+obj.b/2,-obj.b/2];
            end
            xsrMid = [xsrMid,l-obj.lmin/2];
            ysrMid = [ysrMid,0];
            xsr2 = [l-obj.lmin/2,l];
            ysr2 = [0,0];
            % Transformation:
            xs1 = obj.center(1)+(obj.radius+ysr1).*cos(alpha0+xsr1./(2*obj.radius));
            ys1 = obj.center(2)+(obj.radius+ysr1).*sin(alpha0+xsr1./(2*obj.radius));
            xsMid = obj.center(1)+(obj.radius+ysrMid).*cos(alpha0+xsrMid./(2*obj.radius));
            ysMid = obj.center(2)+(obj.radius+ysrMid).*sin(alpha0+xsrMid./(2*obj.radius));
            xs2 = obj.center(1)+(obj.radius+ysr2).*cos(alpha0+xsr2./(2*obj.radius));
            ys2 = obj.center(2)+(obj.radius+ysr2).*sin(alpha0+xsr2./(2*obj.radius));
            %% Plot:
            obj.plm = plot(xsMid,ysMid,'-','Color',co,'LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'downm',obj});
            obj.pll = plot(xs1,ys1,'.-','MarkerSize',ms,'Color',co,'LineWidth',lw,'MarkerIndices',1,'buttondownfcn',{@Mouse_Callback,'down',obj});
            obj.plr = plot(xs2,ys2,'.-','MarkerSize',ms,'Color',co,'LineWidth',lw,'MarkerIndices',2,'buttondownfcn',{@Mouse_Callback,'down',obj});
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
            plmcontext2 = uimenu(plmcontext,'Label','change numer of windings','Callback',{@ct_windings,obj});
            plmcontext3 = uimenu(plmcontext,'Label','change width','Callback',{@ct_width,obj});
            plmcontext4 = uimenu(plmcontext,'Label','delete','Callback',{@ct_delete,obj});
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

            obj.plmcontext = plmcontext;
            obj.pllcontext = pllcontext;
            obj.plrcontext = plrcontext;
            
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
            
            function ct_windings(src,event,obj,index)
                fprintf('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n');
                fprintf('Neue Windungszahl (aktuell: %d):\n', obj.n);
                obj.n = str2double(benutzereingabe( 'Neue Windungszahl:', @(n) (rem(str2double(n),1) == 0) & (str2double(n) > 0) ));
                % update:
                xx = [obj.p1(1),obj.p2(1)];
                yy = [obj.p1(2),obj.p2(2)];
                obj.setPosition(xx,yy);
            end
            
            function ct_width(src,event,obj,index)
                fprintf('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n');
                fprintf('Neue Breite (aktuell: %.2f):\n', obj.b);
                obj.b = str2double(benutzereingabe( 'Neue Breite:', @(n) (str2double(n) > 0)));
                % update:
                xx = [obj.p1(1),obj.p2(1)];
                yy = [obj.p1(2),obj.p2(2)];
                obj.setPosition(xx,yy);
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
            alphaa = atan2(Y(1)-obj.center(2),X(1)-obj.center(1));
            alphae = atan2(Y(2)-obj.center(2),X(2)-obj.center(1));
            if alphae<alphaa
                alpha = 2*pi+(alphae-alphaa);
            else
                alpha = alphae-alphaa;
            end
            alpha0 = atan2((Y(1)-obj.center(2)),(X(1)-obj.center(1)));
            l = 2*alpha*obj.radius;
            dl = (l-obj.lmin)/obj.n;
            if obj.lmin<0
                error('lmin must be lmin>=0');
            elseif l<obj.lmin
                error('Distance smaller than lmin!');
            elseif obj.n<2
                error('n must be at least 2');
            elseif round(sqrt((X(1)-obj.center(1))^2+(Y(1)-obj.center(2))^2),8)~=round(sqrt((X(2)-obj.center(1))^2+(Y(2)-obj.center(2))^2),8)
                error('The connection points do not have the same radius to the center point.');
            end
            % Referenzfeder:
            xsr1 = [0,obj.lmin/2];
            ysr1 = [0,0];
            xsrMid = obj.lmin/2;
            ysrMid = 0;
            for w=1:obj.n
                xsrMid = [xsrMid,obj.lmin/2+dl*(w-1)+1/4*dl,obj.lmin/2+dl*(w-1)+3/4*dl];
                ysrMid = [ysrMid,+obj.b/2,-obj.b/2];
            end
            xsrMid = [xsrMid,l-obj.lmin/2];
            ysrMid = [ysrMid,0];
            xsr2 = [l-obj.lmin/2,l];
            ysr2 = [0,0];
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