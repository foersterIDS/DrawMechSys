classdef word < gfx2d.DrawMechSysObject
    
    properties
        window
        id
        position
        angle = 0;
        pl
        fs
        str
    end
    properties (Dependent)
        color
    end
    
    methods
        function obj = word(x,y,str,varargin)
            %% Init:
            obj.position(1) = x;
            obj.position(2) = y;
            stdinp = 3;
            obj.color = [0,0,0];
            obj.fs = 28;
            obj.position = [x;y];
            obj.str = str;
            %% Input:
            if nargin>stdinp
                i = 1;
                while i<=nargin-stdinp
                    switch lower(varargin{i})
                        case 'color'
                            obj.color = varargin{i+1};
                            i = i+1;
                        case 'fontsize'
                            obj.fs = varargin{i+1};
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
            
            obj.pl = text(obj.position(1),obj.position(2),['$',obj.str,'$'],'interpreter','latex',...
                          'FontSize',obj.fs,'Color',obj.color,'HorizontalAlignment','center',...
                          'VerticalAlignment','middle','buttondownfcn',{@Mouse_Callback,'drag',obj});
            set(obj.pl,'Rotation',obj.angle);
            
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
            plcontext2 = uimenu(plcontext,'Label','change text','Callback',{@ct_change_text,obj});
            plcontext3 = uimenu(plcontext,'Label','change fontsize','Callback',{@ct_change_textsize,obj});
            plcontext4 = uimenu(plcontext,'Label','rotate','Callback',{@ct_rotate,obj});
            plcontext5 = uimenu(plcontext,'Label','freeze rotation','Callback',{@ct_freezerotation,obj});
            plcontext6 = uimenu(plcontext,'Label','delete','Callback',{@ct_delete,obj});
            
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
            
            function ct_change_text(src,event,obj)
                fprintf('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n');
                fprintf('Latex-Mathemodus ein? (1/0):\n');
                mathmode = benutzereingabe( 'Latex-Mathemodus ein? (1/0):', @(x) (strcmp(x,'1') || strcmp(x,'0')) );
                fprintf('Text:\n');
                temp = benutzereingabe( 'Text:', @(x) 1 );
                if mathmode
                    temp = ['$',temp,'$'];
                end
                obj.pl.String = temp;
            end
            
            function ct_change_textsize(src,event,obj)
                fprintf('- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n');
                fprintf('Neue Schriftgroesse (aktuell: %d):\n', obj.pl.FontSize);
                temp = benutzereingabe( 'Neue Schriftgroesse:', @(n) (rem(str2double(n),1) == 0) & (str2double(n) > 0) );
                obj.pl.FontSize = str2double(temp);
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
        
        function setPosition(obj,X,Y,angle)
            obj.position(1) = X;
            obj.position(2) = Y;
            if nargin==4
                obj.angle = angle;
            end
            
            obj.pl.Position = [obj.position(1),obj.position(2),0];
            obj.pl.Rotation = obj.angle*360/(2*pi);
        end

        function setText(obj,str)
            obj.str = str;
            set(obj.pl,'String',['$',str,'$']);
        end
        
        function delete(obj)
            delete(obj.pl);
            try
                obj.window.deleteObject(obj.id);
            catch
            end
        end
        
        function globalLocation = local2global(obj,localLocation)
            ca = cos(obj.angle);
            sa = sin(obj.angle);
            dXdY = [ca -sa;sa ca]*(0.5*[obj.b;obj.h].*localLocation(:));
            
            globalLocation = obj.position +dXdY;            
        end
        
        function set.color(obj,newcolor)
            obj.pl.Color = newcolor;
        end
        
        function col = get.color(obj)
            col = obj.pl.Color;
        end
    end
end
