classdef spring < gfx2d.LineObject
    
    properties
        window
        id
        lmin
        n
        b
        lw
        ms
        handlMid % springy section
        handl1
        handl2
        plm
        pll
        plr
        plmcontext
        pllcontext
        plrcontext
        scl
        scr
        sclcontext
        scrcontext
    end
    properties (Dependent)
        color
    end
    
    methods
        function obj = spring(X,Y,b,lmin,varargin)
            
            obj@gfx2d.LineObject([X(1); Y(1)], [X(2); Y(2)])
            
            obj.lmin = lmin;
            %% Init:
            stdinp = 4;
            obj.color = [0,0,0];
            obj.n = 4;
            obj.b = b;
            lw = 3;
            obj.lw = lw;
            ms = 1*lw;
            obj.ms = ms;
            %% Input:
            if nargin>stdinp
                i = 1;
                while i<=nargin-stdinp
                    switch lower(varargin{i})
                        case 'color'
                            obj.color = varargin{i+1};
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
            if lmin<0
                error('lmin must be lmin>=0');
            elseif obj.n<2
                error('n must be at least 2');
            end
            
            % Handles
            obj.handlMid = hgtransform();
            obj.handl1 = hgtransform();
            obj.handl2 = hgtransform();
            
            %% Calc:
            dl = 1/obj.n;
            
            % Referenzfeder (mittlerer Teil):
            xsrMid = [dl/4 0 linspace(dl/4,1-dl/4,2*obj.n) 1 1-dl/4]; % 1. und letzte Punkte zusätzlich, um abgerundete Linie zu bekommen -> keine Lücke zwischen mittlerer Sektion und Endstücken
            ysrMid = [-b 0 repmat([-b b],1,obj.n) 0 b]./2;
            
            obj.setPosition(X,Y);
            obj.plm = plot(xsrMid,ysrMid,'-','Color',obj.color,'LineWidth',lw,'Parent',obj.handlMid,'buttondownfcn',{@Mouse_Callback,'drag',obj});
            
            % Endstücke
            xsr1 = [-lmin, 0, -lmin]/2;
            ysr1 = [0,0,0]; % 3 Punkte, um abgerundete Linie zu bekommen -> keine Lücke zwischen mittlerer Sektion und Endstücken
            
            obj.pll = plot(xsr1,ysr1,'-','MarkerSize',ms,'Color',obj.color,'LineWidth',lw,'MarkerIndices',1,'Parent',obj.handl1,'buttondownfcn',{@Mouse_Callback,'down',obj});
            obj.scl = scatter(xsr1,ysr1,ms,obj.color,"filled","MarkerEdgeColor",'none',"MarkerFaceColor",obj.color,"LineWidth",lw,'Parent',obj.handl1,'buttondownfcn',{@Mouse_Callback,'down',obj});
            
            xsr2 = [lmin, 0, lmin]/2;
            ysr2 = [0,0,0];
            
            obj.plr = plot(xsr2,ysr2,'-','MarkerSize',ms,'Color',obj.color,'LineWidth',lw,'MarkerIndices',1,'Parent',obj.handl2,'buttondownfcn',{@Mouse_Callback,'down',obj});
            obj.scr = scatter(xsr2,ysr2,ms,obj.color,"filled","MarkerEdgeColor",'none',"MarkerFaceColor",obj.color,"LineWidth",lw,'Parent',obj.handl2,'buttondownfcn',{@Mouse_Callback,'down',obj});
            
            %% Callback function:
            function Mouse_Callback(hObj,~,action,sObj)
                persistent curobj xdata ydata ind xdatarel ydatarel
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
                        % horizontal move
                        xx(ind) = pos(1);
                        % vertical move
                        yy(ind) = pos(3);
                        % update
                        curobj.setPosition(xx,yy);
                    case 'drag'
                        curobj = sObj;
                        xdatarel = [curobj.p1(1),curobj.p2(1)]-pos(1);
                        ydatarel = [curobj.p1(2),curobj.p2(2)]-pos(3);
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
                %
                % HIER MUSS DAS OBJEKT ZUM DrawMechSysWindow ÜBERGEBEN
                % WERDEN UND DORT DAS ZWEITE OBJEKT BESTIMMT WERDEN UM DANN
                % VON DIESER EBENE DIE bind()-FUNKTION DIESES OBJEKTS
                % AUFZURUFEN.
                %
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
            
            function ct_windings(src,event,obj,index)
                fprintf('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n');
                fprintf('Neue Windungszahl (aktuell: %d):\n', obj.n);
                obj.n = str2double(benutzereingabe( 'Neue Windungszahl:', @(n) (rem(str2double(n),1) == 0) & (str2double(n) > 0) ));
                % Referenzfeder (mittlerer Teil):
                dl = 1/obj.n;
                xsrMid = [dl/4 0 linspace(dl/4,1-dl/4,2*obj.n) 1 1-dl/4]; % 1. und letzte Punkte zusätzlich, um abgerundete Linie zu bekommen -> keine Lücke zwischen mittlerer Sektion und Endstücken
                ysrMid = [-obj.b 0 repmat([-obj.b obj.b],1,obj.n) 0 obj.b]./2;
                % update:
                xx = [obj.p1(1),obj.p2(1)];
                yy = [obj.p1(2),obj.p2(2)];
                obj.setPosition(xx,yy);
                delete(obj.plm);
                obj.plm = plot(xsrMid,ysrMid,'-','LineWidth',obj.lw,'Parent',obj.handlMid,'buttondownfcn',{@Mouse_Callback,'drag',obj});
                obj.plm.Color = obj.color;
                obj.plm.UIContextMenu = obj.plmcontext;
            end
            
            function ct_width(src,event,obj,index)
                fprintf('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n');
                fprintf('Neue Breite (aktuell: %.2f):\n', obj.b);
                obj.b = str2double(benutzereingabe( 'Neue Breite:', @(n) (str2double(n) > 0)));
                % Referenzfeder (mittlerer Teil):
                dl = 1/obj.n;
                xsrMid = [dl/4 0 linspace(dl/4,1-dl/4,2*obj.n) 1 1-dl/4]; % 1. und letzte Punkte zusätzlich, um abgerundete Linie zu bekommen -> keine Lücke zwischen mittlerer Sektion und Endstücken
                ysrMid = [-obj.b 0 repmat([-obj.b obj.b],1,obj.n) 0 obj.b]./2;
                % update:
                xx = [obj.p1(1),obj.p2(1)];
                yy = [obj.p1(2),obj.p2(2)];
                obj.setPosition(xx,yy);
                delete(obj.plm);
                obj.plm = plot(xsrMid,ysrMid,'-','LineWidth',obj.lw,'Parent',obj.handlMid,'buttondownfcn',{@Mouse_Callback,'drag',obj});
                obj.plm.Color = obj.color;
                obj.plm.UIContextMenu = obj.plmcontext;
            end
            
            function ct_delete(src,event,obj)
                obj.delete();
            end
        end
        
        
        function setPosition(obj,X,Y)
            
            dx = diff(X);
            dy = diff(Y);
            
            [alpha,L] = cart2pol(dx,dy);
            ca = cos(alpha);
            sa = sin(alpha);
            
            LMid = abs(L-obj.lmin);
            
            Xm1 = X(1) + dx*obj.lmin/2/L;
            Xm2 = X(2) - dx*obj.lmin/2/L;
            Ym1 = Y(1) + dy*obj.lmin/2/L;
            Ym2 = Y(2) - dy*obj.lmin/2/L;
            
            obj.handl1.Matrix = ...
                [ca -sa 0 Xm1;...
                sa ca 0 Ym1;...
                0 0 1 0;...
                0 0 0 1];
            
            obj.handl2.Matrix = ...
                [ca -sa 0 Xm2;...
                sa ca 0 Ym2;...
                0 0 1 0;...
                0 0 0 1];
            if L-obj.lmin>0
                obj.handlMid.Matrix = ...
                    [LMid*ca -sa 0 Xm1;...
                    LMid*sa ca 0 Ym1;...
                    0 0 1 0;...
                    0 0 0 1];
            else
                obj.handlMid.Matrix = ...
                    [LMid*ca -sa 0 Xm2;...
                    LMid*sa ca 0 Ym2;...
                    0 0 1 0;...
                    0 0 0 1];
            end
            
            obj.p1 = [X(1);Y(1)];
            obj.p2 = [X(2);Y(2)];
            notify(obj,'changedPosition');
        end
        
        function delete(obj)
            delete(obj.pll);
            delete(obj.plm);
            delete(obj.plr);
            delete(obj.scl);
            delete(obj.scr);
            if ~isempty(obj.window)
                obj.window.deleteObject(obj.id);
            end
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
            col = obj.pll.Color;
        end
    end
end