classdef nonlinspring < gfx2d.LineObject
    
    properties
        window
        id
        X
        Y
        b
        n
        lmin
        plm
        pll
        plr
        scl
        scr
        plmcontext
        pllcontext
        plrcontext
        sclcontext
        scrcontext
    end
    properties (Dependent)
        color
    end
    
    methods
        function obj = nonlinspring(X,Y,b,lmin,varargin)
            
            obj@gfx2d.LineObject([X(1); Y(1)], [X(2); Y(2)])
            
            obj.b = b;
            obj.lmin = lmin;
            %% Init:
            stdinp = 5;
            color = [0,0,0];
            obj.n = 4;
            lw = 3;
            ms = 1*lw;
            l = sqrt((Y(2)-Y(1))^2+(X(2)-X(1))^2);
            obj.X = X;
            obj.Y = Y;
            %% Input:
            if nargin>stdinp
                i = 1;
                while i<=nargin-stdinp
                    switch lower(varargin{i})
                        case 'color'
                            color = varargin{i+1};
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
            if obj.lmin<0
                error('lmin must be lmin>=0');
            elseif sqrt(l)<obj.lmin
                error('Distance smaller than lmin!');
            elseif obj.n<2
                error('n must be at least 2');
            end
            %% Calc:
            dl = (l-obj.lmin)/obj.n;
            xlg = (dl*l^2+obj.b^2*obj.lmin-2*dl*l*obj.lmin+l^2*obj.lmin+dl*obj.lmin^2-2*l*obj.lmin^2+obj.lmin^3)/(2*(obj.b^2+l^2-2*l*obj.lmin+obj.lmin^2));
            ylg = -((obj.b*(obj.b^2-(l-obj.lmin)*(dl-l+obj.lmin)))/(2*(obj.b^2+(l-obj.lmin)^2)));
            xp1 = obj.lmin/2+1/2*dl;
            yp1 = -obj.b/2;
            xp2 = xp1+2*(xlg-xp1);
            yp2 = yp1+2*(ylg-yp1);
            % Referenzfeder:
            xslr = [obj.lmin/2,0,obj.lmin/2];
            yslr = [0,0,0];
            xsmr = obj.lmin/2;
            ysmr = 0;
            for w=1:obj.n
                xsmr = [xsmr,obj.lmin/2+dl*(w-1)+1/4*dl,obj.lmin/2+dl*(w-1)+3/4*dl];
                ysmr = [ysmr,+obj.b/2,-obj.b/2];
            end
            xsmr = [xsmr,l-obj.lmin/2,NaN,l-obj.lmin/2,obj.lmin/2,xp1,NaN,obj.lmin/2,xp2];
            ysmr = [ysmr,0,NaN,+obj.b/2,-obj.b/2,yp1,NaN,-obj.b/2,yp2];
            xsrr = [l,l-obj.lmin/2,l];
            ysrr = [0,0,0];
            % Transformation:
            alpha = atan((Y(2)-Y(1))/(X(2)-X(1)));
            xsm = X(1)+sgn(X(2)-X(1))*(xsmr*cos(alpha)+ysmr*sin(alpha));
            ysm = Y(1)+sgn(X(2)-X(1))*(xsmr*sin(alpha)-ysmr*cos(alpha));
            xsl = X(1)+sgn(X(2)-X(1))*(xslr*cos(alpha)+yslr*sin(alpha));
            ysl = Y(1)+sgn(X(2)-X(1))*(xslr*sin(alpha)-yslr*cos(alpha));
            xsr = X(1)+sgn(X(2)-X(1))*(xsrr*cos(alpha)+ysrr*sin(alpha));
            ysr = Y(1)+sgn(X(2)-X(1))*(xsrr*sin(alpha)-ysrr*cos(alpha));
            % plot:
            obj.plm = plot(xsm,ysm,'-','Color',color,'LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'drag',obj});
            obj.pll = plot(xsl,ysl,'-','MarkerSize',ms,'Color',color,'LineWidth',lw,'MarkerIndices',2,'buttondownfcn',{@Mouse_Callback,'down',obj});
            obj.scl = scatter(xsl,ysl,ms,color,"filled","MarkerEdgeColor",'none',"MarkerFaceColor",obj.color,"LineWidth",lw,'buttondownfcn',{@Mouse_Callback,'down',obj});
            
            obj.plr = plot(xsr,ysr,'-','MarkerSize',ms,'Color',color,'LineWidth',lw,'MarkerIndices',1,'buttondownfcn',{@Mouse_Callback,'down',obj});
            obj.scr = scatter(xsr,ysr,ms,color,"filled","MarkerEdgeColor",'none',"MarkerFaceColor",obj.color,"LineWidth",lw,'buttondownfcn',{@Mouse_Callback,'down',obj});
            %% Callback function:
            function Mouse_Callback(hObj,~,action,sObj)
                persistent curobj xdata ydata ind xdatarel ydatarel
                pos = get(gca,'CurrentPoint');
                switch action
                    case 'down'
                        curobj = sObj;
                        xdata = curobj.X;
                        ydata = curobj.Y;
                        [~,ind] = min(sum((xdata-pos(1)).^2+(ydata-pos(3)).^2,1));
                        set(gcf,...
                            'WindowButtonMotionFcn',  {@Mouse_Callback,'move'},...
                            'WindowButtonUpFcn',      {@Mouse_Callback,'up'});
                    case 'move'
                        xx = curobj.X;
                        yy = curobj.Y;
                        % horizontal move
                        xx(ind) = pos(1);
                        % vertical move
                        yy(ind) = pos(3);
                        % update
                        curobj.setPosition(xx,yy);
                    case 'drag'
                        curobj = sObj;
                        xdatarel = curobj.X-pos(1);
                        ydatarel = curobj.Y-pos(3);
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
            %l
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
            scrcontext1 = uimenu(scrcontext,'Label','change color');
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

            obj.plmcontext = plmcontext;
            obj.pllcontext = pllcontext;
            obj.plrcontext = plrcontext;
            obj.sclcontext = sclcontext;
            obj.scrcontext = scrcontext;
            
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
                obj.setPosition(xx,yy);
            end
            
            function ct_setposition(src,event,obj,index)
                warning('"set position" is not functional yet!');
                xx = obj.X;
                yy = obj.Y;
                xx(index) = 10*rand;
                yy(index) = 10*rand;
                obj.setPosition(xx,yy);
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
                obj.window.deleteObject(obj.id);
                delete(obj.plm);
                delete(obj.pll);
                delete(obj.plr);
                delete(obj.scl);
                delete(obj.scr);
            end
        end
        
        
        function setPosition(obj,X,Y)
            obj.X = X;
            obj.Y = Y;
            l = sqrt((Y(2)-Y(1))^2+(X(2)-X(1))^2);
            dl = (l-obj.lmin)/obj.n;
            xlg = (dl*l^2+obj.b^2*obj.lmin-2*dl*l*obj.lmin+l^2*obj.lmin+dl*obj.lmin^2-2*l*obj.lmin^2+obj.lmin^3)/(2*(obj.b^2+l^2-2*l*obj.lmin+obj.lmin^2));
            ylg = -((obj.b*(obj.b^2-(l-obj.lmin)*(dl-l+obj.lmin)))/(2*(obj.b^2+(l-obj.lmin)^2)));
            xp1 = obj.lmin/2+1/2*dl;
            yp1 = -obj.b/2;
            xp2 = xp1+2*(xlg-xp1);
            yp2 = yp1+2*(ylg-yp1);
            % Referenzfeder:
            xslr = [obj.lmin/2,0,obj.lmin/2];
            yslr = [0,0,0];
            xsmr = obj.lmin/2;
            ysmr = 0;
            for w=1:obj.n
                xsmr = [xsmr,obj.lmin/2+dl*(w-1)+1/4*dl,obj.lmin/2+dl*(w-1)+3/4*dl];
                ysmr = [ysmr,+obj.b/2,-obj.b/2];
            end
            xsmr = [xsmr,l-obj.lmin/2,NaN,l-obj.lmin/2,obj.lmin/2,xp1,NaN,obj.lmin/2,xp2];
            ysmr = [ysmr,0,NaN,+obj.b/2,-obj.b/2,yp1,NaN,-obj.b/2,yp2];
            xsrr = [l,l-obj.lmin/2,l];
            ysrr = [0,0,0];
            % Transformation:
            alpha = atan((Y(2)-Y(1))/(X(2)-X(1)));
            xsm = X(1)+sgn(X(2)-X(1))*(xsmr*cos(alpha)+ysmr*sin(alpha));
            ysm = Y(1)+sgn(X(2)-X(1))*(xsmr*sin(alpha)-ysmr*cos(alpha));
            xsl = X(1)+sgn(X(2)-X(1))*(xslr*cos(alpha)+yslr*sin(alpha));
            ysl = Y(1)+sgn(X(2)-X(1))*(xslr*sin(alpha)-yslr*cos(alpha));
            xsr = X(1)+sgn(X(2)-X(1))*(xsrr*cos(alpha)+ysrr*sin(alpha));
            ysr = Y(1)+sgn(X(2)-X(1))*(xsrr*sin(alpha)-ysrr*cos(alpha));
            %% Update:
            obj.plm.XData = xsm;
            obj.plm.YData = ysm;
            obj.pll.XData = xsl;
            obj.pll.YData = ysl;
            obj.plr.XData = xsr;
            obj.plr.YData = ysr;
            obj.scl.XData = xsl;
            obj.scl.YData = ysl;
            obj.scr.XData = xsr;
            obj.scr.YData = ysr;
            
            obj.p1 = [X(1);Y(1)];
            obj.p2 = [X(2);Y(2)];
            notify(obj,'changedPosition');
        end
        
        function set.color(obj,newcolor)
            obj.plm.Color = newcolor;
            obj.pll.Color = newcolor;
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