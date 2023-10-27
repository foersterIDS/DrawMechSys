classdef damper < gfx2d.LineObject
    
    properties
        window
        id
        b
        lmin
        xsrl
        ysrl
        xsrm
        ysrm
        xsrr
        ysrr
        handl
    end
    properties (Dependent)
        color
    end
    
    methods
        function obj = damper(X,Y,b,lmin,varargin)
            
            obj@gfx2d.LineObject([X(1); Y(1)], [X(2); Y(2)])
            
            %% Init:
            stdinp = 4;
            color = [0,0,0];
            lw = 3;
            ms = 1*lw;
            obj.b = b;
            obj.lmin = lmin;
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
                        otherwise
                            error('No such element: %s',varargin{i});
                    end
                    i = i+1;
                end
            end
            if obj.lmin<0
                error('lmin must be lmin>=0');
            elseif sqrt((X(2)-X(1))^2+(Y(2)-Y(1))^2)<obj.lmin
                error('Distance smaller than lmin!');
            end
            %% Calc:
            % Referenzdaempfer:
            obj.xsrl = [0,obj.lmin/3];
            obj.ysrl = [0,0];
            obj.xsrm = [obj.lmin/3,obj.lmin/3,obj.L-obj.lmin/3,NaN,...
                    obj.lmin/3,obj.L-obj.lmin/3,NaN,...
                    obj.L-2*obj.lmin/3,obj.L-2*obj.lmin/3,NaN,...
                    obj.L-2*obj.lmin/3,obj.L-obj.lmin/3];
            obj.ysrm = [-obj.b/2,+obj.b/2,+obj.b/2,NaN,...
                    -obj.b/2,-obj.b/2,NaN,...
                    -obj.b/4,+obj.b/4,NaN,...
                    0,0];
            obj.xsrr = [obj.L-obj.lmin/3,obj.L];
            obj.ysrr = [0,0];
            % Transformation:
            alpha = atan((Y(2)-Y(1))/(X(2)-X(1)));
            xsl = X(1)+sgn(X(2)-X(1))*(obj.xsrl*cos(alpha)+obj.ysrl*sin(alpha));
            ysl = Y(1)+sgn(X(2)-X(1))*(obj.xsrl*sin(alpha)-obj.ysrl*cos(alpha));
            xsm = X(1)+sgn(X(2)-X(1))*(obj.xsrm*cos(alpha)+obj.ysrm*sin(alpha));
            ysm = Y(1)+sgn(X(2)-X(1))*(obj.xsrm*sin(alpha)-obj.ysrm*cos(alpha));
            xsr = X(1)+sgn(X(2)-X(1))*(obj.xsrr*cos(alpha)+obj.ysrr*sin(alpha));
            ysr = Y(1)+sgn(X(2)-X(1))*(obj.xsrr*sin(alpha)-obj.ysrr*cos(alpha));
            %% Plot:
            obj.handl = cell(3,1);
            obj.handl{1} = plot(xsl,ysl,'-','MarkerSize',ms,'MarkerIndices',1,'Color',color,'LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'down',obj});
            obj.handl{2} = plot(xsm,ysm,'-','Color',color,'LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'drag',obj});
            obj.handl{3} = plot(xsr,ysr,'-','MarkerSize',ms,'MarkerIndices',2,'Color',color,'LineWidth',lw,'buttondownfcn',{@Mouse_Callback,'down',obj});
            obj.handl{4} = scatter(xsl,ysl,ms,color,"filled","MarkerEdgeColor",'none',"MarkerFaceColor",color,"LineWidth",lw,'buttondownfcn',{@Mouse_Callback,'down',obj});
            obj.handl{5} = scatter(xsr,ysr,ms,color,"filled","MarkerEdgeColor",'none',"MarkerFaceColor",color,"LineWidth",lw,'buttondownfcn',{@Mouse_Callback,'down',obj});
            
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
            plmcontext2 = uimenu(plmcontext,'Label','delete','Callback',{@ct_delete,obj});
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
            pllcontext4 = uimenu(pllcontext,'Label','delete','Callback',{@ct_delete,obj});
            % r:
            plrcontext = uicontextmenu;
            obj.handl{3}.UIContextMenu = plrcontext;
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
            obj.handl{1}.UIContextMenu = sclcontext;
            sclcontext1 = uimenu(sclcontext,'Label','change color');
            sclcontext1_1 = uimenu('Parent',sclcontext1,'Label','blue','Callback',{@ct_setcolor,obj});
            sclcontext1_2 = uimenu('Parent',sclcontext1,'Label','red','Callback',{@ct_setcolor,obj});
            sclcontext1_3 = uimenu('Parent',sclcontext1,'Label','magenta','Callback',{@ct_setcolor,obj});
            sclcontext1_4 = uimenu('Parent',sclcontext1,'Label','green','Callback',{@ct_setcolor,obj});
            sclcontext1_5 = uimenu('Parent',sclcontext1,'Label','yellow','Callback',{@ct_setcolor,obj});
            sclcontext1_6 = uimenu('Parent',sclcontext1,'Label','black','Callback',{@ct_setcolor,obj});
            sclcontext1_7 = uimenu('Parent',sclcontext1,'Label','white','Callback',{@ct_setcolor,obj});
            sclcontext1_8 = uimenu('Parent',sclcontext1,'Label','random','Callback',{@ct_setcolor,obj});
            pllcontext2 = uimenu(sclcontext,'Label','bind','Callback',{@ct_bind,obj,1});
            pllcontext3 = uimenu(sclcontext,'Label','set position','Callback',{@ct_setposition,obj,1});
            pllcontext4 = uimenu(sclcontext,'Label','delete','Callback',{@ct_delete,obj});
            % r:
            scrcontext = uicontextmenu;
            obj.handl{3}.UIContextMenu = scrcontext;
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
            
            function ct_delete(src,event,obj)
                obj.delete();
            end
        end
        
        
        function setPosition(obj,X,Y)
            %% Calc. & initial update:
            l = sqrt((X(2)-X(1))^2+(Y(2)-Y(1))^2);
            alpha = atan((Y(2)-Y(1))/(X(2)-X(1)));
            obj.p1 = [X(1);Y(1)];
            obj.p2 = [X(2);Y(2)];
            %% Referenzdämpfer:
            obj.xsrl = [0,obj.lmin/3];
            obj.ysrl = [0,0];
            obj.xsrm = [obj.lmin/3,obj.lmin/3,obj.L-obj.lmin/3,NaN,...
                    obj.lmin/3,obj.L-obj.lmin/3,NaN,...
                    obj.L-2*obj.lmin/3,obj.L-2*obj.lmin/3,NaN,...
                    obj.L-2*obj.lmin/3,obj.L-obj.lmin/3];
            obj.ysrm = [-obj.b/2,+obj.b/2,+obj.b/2,NaN,...
                    -obj.b/2,-obj.b/2,NaN,...
                    -obj.b/4,+obj.b/4,NaN,...
                    0,0];
            obj.xsrr = [obj.L-obj.lmin/3,obj.L];
            obj.ysrr = [0,0];
            %% Transformation:
            xsl = X(1)+sgn(X(2)-X(1))*(obj.xsrl*cos(alpha)+obj.ysrl*sin(alpha));
            ysl = Y(1)+sgn(X(2)-X(1))*(obj.xsrl*sin(alpha)-obj.ysrl*cos(alpha));
            xsm = X(1)+sgn(X(2)-X(1))*(obj.xsrm*cos(alpha)+obj.ysrm*sin(alpha));
            ysm = Y(1)+sgn(X(2)-X(1))*(obj.xsrm*sin(alpha)-obj.ysrm*cos(alpha));
            xsr = X(1)+sgn(X(2)-X(1))*(obj.xsrr*cos(alpha)+obj.ysrr*sin(alpha));
            ysr = Y(1)+sgn(X(2)-X(1))*(obj.xsrr*sin(alpha)-obj.ysrr*cos(alpha));
            %% Update:
            set(obj.handl{1},'XData',xsl,'YData',ysl);
            set(obj.handl{2},'XData',xsm,'YData',ysm);
            set(obj.handl{3},'XData',xsr,'YData',ysr);
            set(obj.handl{4},'XData',xsl,'YData',ysl);
            set(obj.handl{5},'XData',xsr,'YData',ysr);

            notify(obj,'changedPosition');
        end
        
        function delete(obj)
            delete(obj.handl{1});
            delete(obj.handl{2});
            delete(obj.handl{3});
            delete(obj.handl{4});
            delete(obj.handl{5});
            obj.window.deleteObject(obj.id);
        end
        
        function set.color(obj,newcolor)
            obj.handl{1}.Color = newcolor;
            obj.handl{2}.Color = newcolor;
            obj.handl{3}.Color = newcolor;
            obj.handl{4}.MarkerEdgeColor = newcolor;
            obj.handl{4}.MarkerFaceColor = newcolor;
            obj.handl{5}.MarkerEdgeColor = newcolor;
            obj.handl{4}.MarkerFaceColor = newcolor;
        end
        
        function col = get.color(obj)
            col = obj.handl{2}.Color;
        end
    end
end