classdef DrawMechSysWindow < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        xLimits = [0,10];
        yLimits = [0,10];
        yResolution = 720;
        idcnt = 0;
        xadd
        yadd
        isFig = 0;
        grid
        gridon = 0;
        gridcolor
        gridx = 1;
        gridy = 1;
        xgrid
        ygrid
        glw = 2;
        backcolor = [1,1,1];
        nfig
        lw = 3;
        ms = 3;
        npl
        fig
        objects = cell(0); % Subelements
        delta_angle = pi/32;
    end
    properties (Dependent)
        color
    end
    
    methods
        function obj = DrawMechSysWindow(xLimits,yLimits,yResolution,varargin)
            obj.gridcolor = systemColors('grid color');
            global gcw;
            gcw = obj;
            %% Input:
            stdinp = 3;
            obj.xLimits = sort(xLimits);
            obj.yLimits = sort(yLimits);
            obj.yResolution = yResolution;
            obj.npl = 60/(obj.yLimits(2)-obj.yLimits(1));
            if nargin>stdinp
                i = 1;
                while i<=nargin-stdinp
                    switch lower(varargin{i})
                        case 'grid'
                            if strcmp(varargin{i+1},'on')
                                obj.gridon = 1;
                            elseif strcmp(varargin{i+1},'off')
                                obj.gridon = 0;
                            else
                                error('No such option for grid!');
                            end
                            i = i+1;
                        case 'gridcolor'
                            obj.gridcolor = varargin{i+1};
                            i = i+1;
                        case 'gridx'
                            obj.gridx = varargin{i+1};
                            i = i+1;
                        case 'gridy'
                            obj.gridy = varargin{i+1};
                            i = i+1;
                        case 'gridlinewidth'
                            obj.glw = varargin{i+1};
                            i = i+1;
                        case 'backcolor'
                            obj.backcolor = varargin{i+1};
                            i = i+1;
                        case 'figure'
                            obj.isFig = 1;
                            obj.nfig = varargin{i+1};
                            i = i+1;
                        case 'markersize'
                            obj.ms = varargin{i+1};
                            i = i+1;
                        otherwise
                            error('No such element: %s',varargin{i});
                    end
                    i = i+1;
                end
            end
            %% get screen resolution
            mScreenSize = get(groot,'ScreenSize'); % scaled pixels
            jScreenSize = java.awt.Toolkit.getDefaultToolkit.getScreenSize; % actual pixels
            scaleFactor = mScreenSize(3) / jScreenSize.getWidth ;
            %% calculate figure width
            xResolution = yResolution * diff(obj.xLimits) / diff(obj.yLimits);
            if xResolution > jScreenSize.getWidth || yResolution > jScreenSize.getHeight
                error('The requested size is larger than the screen resolution')
            end
            %% place figure in center of screen
            offsetX = (jScreenSize.getWidth - xResolution) / 2;
            offsetY = (jScreenSize.getHeight - yResolution) / 2;
            fPosition = [offsetX offsetY xResolution yResolution]*scaleFactor;
            %% create figure
            if obj.isFig
                obj.fig = figure(obj.nfig);
                clf(obj.fig,'reset');
            else
                obj.fig = figure;
            end
            obj.fig.Color = obj.backcolor;
            obj.fig.Position = fPosition;
            %% create axes
            ax = axes;
            ax.Position = [0,0,1,1];
            axis off
            hold on
            xlim(obj.xLimits);
            ylim(obj.yLimits);
            obj.xadd = (obj.xLimits(2)-obj.xLimits(1))/2+obj.xLimits(1);
            obj.yadd = (obj.yLimits(2)-obj.yLimits(1))/2+obj.yLimits(1);
            set(obj.fig, 'Resize', 'off');
            %% grid:
            hold on;
            if mod((obj.xLimits(2)-obj.xLimits(1)),obj.gridx)~=0
                error('gridx must fit xmax-xmin!');
            end
            if mod((obj.yLimits(2)-obj.yLimits(1)),obj.gridy)~=0
                error('gridy must fit ymax-ymin!');
            end
            obj.xgrid = [kron(obj.xLimits(1):obj.gridx:obj.xLimits(2),[1,1,NaN]),kron(ones(1,round((obj.yLimits(2)-obj.yLimits(1))/obj.gridy+1)),[obj.xLimits(1),obj.xLimits(2),NaN])];
            obj.ygrid = [kron(ones(1,round((obj.xLimits(2)-obj.xLimits(1))/obj.gridx+1)),[obj.yLimits(1),obj.yLimits(2),NaN]),kron(obj.yLimits(1):obj.gridy:obj.yLimits(2),[1,1,NaN])];
            obj.grid = plot(obj.xgrid,obj.ygrid,'-','Color',obj.gridcolor,'LineWidth',obj.glw);
            if obj.gridon
                obj.grid.Visible = 'on';
            else
                obj.grid.Visible = 'off';
            end
            %% Context menus:
            % figure
            fcontext = uicontextmenu;
            obj.fig.UIContextMenu = fcontext;
            obj.grid.UIContextMenu = fcontext;
            fcontext1 = uimenu(fcontext,'Label','add element');
            fcontext1_1 = uimenu('Parent',fcontext1,'Label','masses & bodies');
            fcontext1_1_1 = uimenu('Parent',fcontext1_1,'Label','mass','Callback',{@ct_addelement,obj});
            fcontext1_1_2 = uimenu('Parent',fcontext1_1,'Label','lumped mass','Callback',{@ct_addelement,obj});
            fcontext1_1_3 = uimenu('Parent',fcontext1_1,'Label','roll','Callback',{@ct_addelement,obj});
            fcontext1_1_4 = uimenu('Parent',fcontext1_1,'Label','sphere','Callback',{@ct_addelement,obj});
            fcontext1_1_5 = uimenu('Parent',fcontext1_1,'Label','body','Callback',{@ct_addelement,obj});
            fcontext1_1_6 = uimenu('Parent',fcontext1_1,'Label','bar','Callback',{@ct_addelement,obj});
            fcontext1_1_7 = uimenu('Parent',fcontext1_1,'Label','potato','Callback',{@ct_addelement,obj});
            fcontext1_2 = uimenu('Parent',fcontext1,'Label','walls & bearings');
            fcontext1_2_1 = uimenu('Parent',fcontext1_2,'Label','wall','Callback',{@ct_addelement,obj});
            fcontext1_2_2 = uimenu('Parent',fcontext1_2,'Label','circular wall','Callback',{@ct_addelement,obj});
            fcontext1_2_3 = uimenu('Parent',fcontext1_2,'Label','fixed bearing','Callback',{@ct_addelement,obj});
            fcontext1_2_4 = uimenu('Parent',fcontext1_2,'Label','floating bearing','Callback',{@ct_addelement,obj});
            fcontext1_3 = uimenu('Parent',fcontext1,'Label','springs');
            fcontext1_3_1 = uimenu('Parent',fcontext1_3,'Label','spring','Callback',{@ct_addelement,obj});
            fcontext1_3_2 = uimenu('Parent',fcontext1_3,'Label','nonlinear spring','Callback',{@ct_addelement,obj});
            fcontext1_3_3 = uimenu('Parent',fcontext1_3,'Label','circular spring','Callback',{@ct_addelement,obj});
            fcontext1_3_4 = uimenu('Parent',fcontext1_3,'Label','nonlinear circular spring','Callback',{@ct_addelement,obj});
            fcontext1_4 = uimenu('Parent',fcontext1,'Label','dampers');
            fcontext1_4_1 = uimenu('Parent',fcontext1_4,'Label','damper','Callback',{@ct_addelement,obj});
            fcontext1_4_2 = uimenu('Parent',fcontext1_4,'Label','circular damper','Callback',{@ct_addelement,obj});
            fcontext1_5 = uimenu('Parent',fcontext1,'Label','vectors');
            fcontext1_5_1 = uimenu('Parent',fcontext1_5,'Label','force','Callback',{@ct_addelement,obj});
            fcontext1_5_2 = uimenu('Parent',fcontext1_5,'Label','torque','Callback',{@ct_addelement,obj});
            fcontext1_6 = uimenu('Parent',fcontext1,'Label','connectors');
            fcontext1_6_1 = uimenu('Parent',fcontext1_6,'Label','joint','Callback',{@ct_addelement,obj});
            fcontext1_6_2 = uimenu('Parent',fcontext1_6,'Label','hull','Callback',{@ct_addelement,obj});
            fcontext1_6_3 = uimenu('Parent',fcontext1_6,'Label','slider','Callback',{@ct_addelement,obj});
            fcontext1_7 = uimenu('Parent',fcontext1,'Label','misc');
            fcontext1_7_1 = uimenu('Parent',fcontext1_7,'Label','trail','ForegroundColor',0.5*[1,1,1]);%,'Callback',{@ct_addelement,obj});
            fcontext1_7_2 = uimenu('Parent',fcontext1_7,'Label','text','Callback',{@ct_addelement,obj});
            fcontext1_7_3 = uimenu('Parent',fcontext1_7,'Label','coordinate system','Callback',{@ct_addelement,obj});
            fcontext2 = uimenu(fcontext,'Label','change color');
            fcontext2_1 = uimenu('Parent',fcontext2,'Label','blue','Callback',{@ct_setcolor,obj});
            fcontext2_2 = uimenu('Parent',fcontext2,'Label','red','Callback',{@ct_setcolor,obj});
            fcontext2_3 = uimenu('Parent',fcontext2,'Label','magenta','Callback',{@ct_setcolor,obj});
            fcontext2_4 = uimenu('Parent',fcontext2,'Label','green','Callback',{@ct_setcolor,obj});
            fcontext2_5 = uimenu('Parent',fcontext2,'Label','yellow','Callback',{@ct_setcolor,obj});
            fcontext2_6 = uimenu('Parent',fcontext2,'Label','black','Callback',{@ct_setcolor,obj});
            fcontext2_7 = uimenu('Parent',fcontext2,'Label','white','Callback',{@ct_setcolor,obj});
            fcontext2_8 = uimenu('Parent',fcontext2,'Label','random','Callback',{@ct_setcolor,obj});
            fcontext3 = uimenu(fcontext,'Label','grid');
            fcontext3_1 = uimenu('Parent',fcontext3,'Label','grid on','Callback',{@ct_setgridon,obj});
            fcontext3_2 = uimenu('Parent',fcontext3,'Label','grid off','Callback',{@ct_setgridoff,obj});
            fcontext3_3 = uimenu('Parent',fcontext3,'Label','color');
            fcontext3_3_1 = uimenu('Parent',fcontext3_3,'Label','grid color','Callback',{@ct_setgridcolor,obj});
            fcontext3_3_1 = uimenu('Parent',fcontext3_3,'Label','blue','Callback',{@ct_setgridcolor,obj});
            fcontext3_3_2 = uimenu('Parent',fcontext3_3,'Label','red','Callback',{@ct_setgridcolor,obj});
            fcontext3_3_3 = uimenu('Parent',fcontext3_3,'Label','magenta','Callback',{@ct_setgridcolor,obj});
            fcontext3_3_4 = uimenu('Parent',fcontext3_3,'Label','green','Callback',{@ct_setgridcolor,obj});
            fcontext3_3_5 = uimenu('Parent',fcontext3_3,'Label','yellow','Callback',{@ct_setgridcolor,obj});
            fcontext3_3_6 = uimenu('Parent',fcontext3_3,'Label','black','Callback',{@ct_setgridcolor,obj});
            fcontext3_3_7 = uimenu('Parent',fcontext3_3,'Label','white','Callback',{@ct_setgridcolor,obj});
            fcontext3_3_8 = uimenu('Parent',fcontext3_3,'Label','random','Callback',{@ct_setgridcolor,obj});
            
            %% Context functions:
            function ct_setcolor(src,event,curobj)
                curobj.color = systemColors(src.Label);
            end
            
            function ct_setgridon(src,event,obj)
                obj.gridon = 1;
                obj.grid.Visible = 'on';
            end
            
            function ct_setgridoff(src,event,obj)
                obj.gridon = 0;
                obj.grid.Visible = 'off';
            end
            
            function ct_setgridcolor(src,event,obj)
                obj.gridcolor = systemColors(src.Label);
                obj.grid.Color = obj.gridcolor;
            end
            
            function ct_addelement(src,event,obj)
                switch src.Label
                    case 'mass'
                        obj.addObject(gfx2d.mass(obj.xadd,...
                                                obj.yadd,...
                                                abs(obj.xLimits(2)-obj.xLimits(1))/4,...
                                                abs(obj.yLimits(2)-obj.yLimits(1))/6,...
                                                [0;0],...
                                                'LineWidth',obj.lw,'window',obj,obj.idcnt));
                    case 'lumped mass'
                        obj.addObject(gfx2d.lumpedmass(obj.xadd,...
                                                                  obj.yadd,...
                                                                  abs(obj.xLimits(2)-obj.xLimits(1))/20,...
                                                                  'window',obj,obj.idcnt));
                    case 'roll'
                        obj.addObject(gfx2d.roll(obj.xadd,...
                                                     obj.yadd,...
                                                     abs(obj.xLimits(2)-obj.xLimits(1))/5,...
                                                     'LineWidth',obj.lw,'window',obj,obj.idcnt));
                    case 'sphere'
                        obj.addObject(gfx2d.sphere(obj.xadd,...
                                                        obj.yadd,...
                                                        abs(obj.xLimits(2)-obj.xLimits(1))/5,...
                                                        'LineWidth',obj.lw,'window',obj,obj.idcnt));
                    case 'body'
                        obj.addObject(gfx2d.body(obj.xadd,...
                                                 obj.yadd,...
                                                      [(obj.xLimits(2)-obj.xLimits(1))*-1/8,(obj.xLimits(2)-obj.xLimits(1))*+1/8,0,(obj.xLimits(2)-obj.xLimits(1))*-1/8],...
                                                      [(obj.yLimits(2)-obj.yLimits(1))*-1/8,(obj.yLimits(2)-obj.yLimits(1))*-1/8,(obj.yLimits(2)-obj.yLimits(1))*+1/8,(obj.yLimits(2)-obj.yLimits(1))*-1/8],...
                                                      [0;0],...
                                                      'LineWidth',obj.lw,'window',obj,obj.idcnt));
                    case 'bar'
                        obj.addObject(gfx2d.bar([(obj.xLimits(2)-obj.xLimits(1))*1/4+obj.xLimits(1),(obj.xLimits(2)-obj.xLimits(1))*3/4+obj.xLimits(1)],...
                                                    obj.yadd*[1,1],...
                                                    'LineWidth',obj.lw,'window',obj,obj.idcnt));
                    case 'potato'
                        obj.addObject(gfx2d.potato(obj.xadd,...
                                                   obj.yadd,...
                                                   min([abs(obj.xLimits(2)-obj.xLimits(1)),abs(obj.yLimits(2)-obj.yLimits(1))])/10,...
                                                   [0;0],...
                                                   'LineWidth',obj.lw,'window',obj,obj.idcnt));
                    case 'wall'
                        obj.addObject(gfx2d.wall([(obj.xLimits(2)-obj.xLimits(1))*1/4+obj.xLimits(1),(obj.xLimits(2)-obj.xLimits(1))*3/4+obj.xLimits(1)],...
                                                    obj.yadd*[1,1],...
                                                    obj.npl,...
                                                    -1,...
                                                    'LineWidth',obj.lw,'window',obj,obj.idcnt,'direction',-1));
                    case 'circular wall'
                        obj.addObject(gfx2d.rotwall([obj.xadd,obj.yadd],(obj.xLimits(2)-obj.xLimits(1))*1/4,[0,pi/2],...
                                                    (obj.yLimits(2)-obj.yLimits(1))/60,obj.npl,-1,...
                                                    'LineWidth',obj.lw,'window',obj,obj.idcnt,'direction',-1,'MarkerVisibility','On'));
                    case 'fixed bearing'
                        obj.addObject(gfx2d.fixedbearing(obj.xadd,obj.yadd,(obj.xLimits(2)-obj.xLimits(1))/10,0,...
                                                         'npl',obj.npl,'LineWidth',obj.lw,'window',obj,obj.idcnt,'direction',-1));
                    case 'floating bearing'
                        obj.addObject(gfx2d.floatingbearing(obj.xadd,obj.yadd,(obj.xLimits(2)-obj.xLimits(1))/10,obj.xadd,obj.yadd,0,...
                                                            'npl',obj.npl,'LineWidth',obj.lw,'window',obj,obj.idcnt,'direction',-1));
                    case 'spring'
                        obj.addObject(gfx2d.spring([(obj.xLimits(2)-obj.xLimits(1))*1/4+obj.xLimits(1),(obj.xLimits(2)-obj.xLimits(1))*3/4+obj.xLimits(1)],...
                                                        obj.yadd*[1,1],...
                                                        (obj.yLimits(2)-obj.yLimits(1))/20,...
                                                        (obj.xLimits(2)-obj.xLimits(1))/14,...
                                                        'LineWidth',obj.lw,'MarkerSize',obj.ms,'window',obj,obj.idcnt));
                    case 'nonlinear spring'
                        obj.addObject(gfx2d.nonlinspring([(obj.xLimits(2)-obj.xLimits(1))*1/4+obj.xLimits(1),(obj.xLimits(2)-obj.xLimits(1))*3/4+obj.xLimits(1)],...
                                                               obj.yadd*[1,1],...
                                                               (obj.yLimits(2)-obj.yLimits(1))/20,...
                                                               (obj.xLimits(2)-obj.xLimits(1))/14,...
                                                               'LineWidth',obj.lw,'MarkerSize',obj.ms,'window',obj,obj.idcnt));
                    case 'circular spring'
                        obj.addObject(gfx2d.rotspring([obj.xadd+(obj.xLimits(2)-obj.xLimits(1))*1/4,obj.xadd],...
                                                      [obj.yadd,obj.yadd+(obj.xLimits(2)-obj.xLimits(1))*1/4],...
                                                      (obj.yLimits(2)-obj.yLimits(1))/20,...
                                                      (obj.xLimits(2)-obj.xLimits(1))/10,...
                                                      [obj.xadd;obj.yadd],...
                                                      'LineWidth',obj.lw,'MarkerSize',obj.ms,'window',obj,obj.idcnt,'MarkerVisibility','On'));
                    case 'nonlinear circular spring'
                        obj.addObject(gfx2d.rotnonlinspring([obj.xadd+(obj.xLimits(2)-obj.xLimits(1))*1/4,obj.xadd],...
                                                            [obj.yadd,obj.yadd+(obj.xLimits(2)-obj.xLimits(1))*1/4],...
                                                            (obj.yLimits(2)-obj.yLimits(1))/20,...
                                                            (obj.xLimits(2)-obj.xLimits(1))/10,...
                                                            [obj.xadd;obj.yadd],...
                                                            'LineWidth',obj.lw,'MarkerSize',obj.ms,'window',obj,obj.idcnt,'MarkerVisibility','On'));
                    case 'damper'
                        obj.addObject(gfx2d.damper([(obj.xLimits(2)-obj.xLimits(1))*1/4+obj.xLimits(1),(obj.xLimits(2)-obj.xLimits(1))*3/4+obj.xLimits(1)],...
                                                        obj.yadd*[1,1],...
                                                        (obj.yLimits(2)-obj.yLimits(1))/20,...
                                                        (obj.xLimits(2)-obj.xLimits(1))/8,...
                                                        'LineWidth',obj.lw,'MarkerSize',obj.ms,'window',obj,obj.idcnt));
                    case 'circular damper'
                        obj.addObject(gfx2d.rotdamper([obj.xadd+(obj.xLimits(2)-obj.xLimits(1))*1/4,obj.xadd],...
                                                      [obj.yadd,obj.yadd+(obj.xLimits(2)-obj.xLimits(1))*1/4],...
                                                      (obj.yLimits(2)-obj.yLimits(1))/20,...
                                                      (obj.xLimits(2)-obj.xLimits(1))/10,...
                                                      [obj.xadd;obj.yadd],...
                                                      'LineWidth',obj.lw,'MarkerSize',obj.ms,'window',obj,obj.idcnt,'MarkerVisibility','On'));
                    case 'force'
                        obj.addObject(gfx2d.force(obj.xadd,obj.yadd,0.2,[1;1]/sqrt(2),'LineWidth',obj.lw,'MarkerSize',obj.ms,'window',obj,obj.idcnt));
                    case 'torque'
                        obj.addObject(gfx2d.torque(obj.xadd,obj.yadd,0.2,1,0.25,1,'alpha_0',0,'delta_alpha_max',2*pi,'LineWidth',obj.lw,'window',obj,obj.idcnt,'MarkerVisibility','On'));
                    case 'joint'
                        obj.addObject(gfx2d.joint(obj.xadd,...
                                                  obj.yadd,...
                                                  abs(obj.xLimits(2)-obj.xLimits(1))/40,...
                                                  'LineWidth',obj.lw,'window',obj,obj.idcnt));
                    case 'hull'
                        obj.addObject(gfx2d.hull(obj.xadd,...
                                                 obj.yadd,...
                                                 abs(obj.xLimits(2)-obj.xLimits(1))/40,...
                                                 abs(obj.xLimits(2)-obj.xLimits(1))/20,...
                                                 [0;0],...
                                                 'LineWidth',obj.lw,'window',obj,obj.idcnt));
                    case 'slider'
                        obj.addObject(gfx2d.slider(obj.xadd,...
                                                   obj.yadd,...
                                                   abs(obj.xLimits(2)-obj.xLimits(1))/10,...
                                                   [0;0],...
                                                   'LineWidth',obj.lw,'window',obj,obj.idcnt));
                    case 'trail'
                        warning('Trail is not drag- & dropable.');
%                         obj.addObject(gfx2d.xxxxxxxx());
                    case 'text'
                        obj.addObject(gfx2d.word(obj.xadd,obj.yadd,'text'));
                    case 'coordinate system'
                        obj.addObject(gfx2d.coordinatesystem(obj.xadd,obj.yadd,0));
                end
            end
        end
        
        function addObject(obj,aobj)
            obj.idcnt = obj.idcnt+1;
            aobj.id = obj.idcnt;
            aobj.window = obj;
            nn = length(obj.objects);
            obj.objects{nn+1} = aobj;
        end
        
        function subobj = getObject(obj,id)
            subobj = {};
            for i=1:length(obj.objects)
                if obj.objects{i}==id
                    subobj = obj.objects{i};
                    break;
                end
            end
        end
        
        function objNr = getObjectNumber(obj,id)
            objNr = 1;
            for i=1:length(obj.objects)
                if obj.objects{i}==id
                    objNr = i;
                    break;
                end
            end
        end
        
        function deleteObject(obj,id)
            pos = 1;
            arr = cell(1,length(obj.objects));
            for i=1:length(obj.objects)
                if obj.objects{i}.id==id
                    % Objekt auslassen
                else
                    arr{pos} = obj.objects{i};
                    pos = pos+1;
                end
            end
            arre = cell(1,pos-1);
            for i=1:pos-1
                arre{i} = arr{i};
            end
            obj.objects = arre;
        end
        
        function setLineWidth(obj,lw)
            obj.lw = lw;
        end
        
        function set.color(obj,newcolor)
            obj.fig.Color = newcolor;
        end
        
        function col = get.color(obj)
            col = obj.fig.Color;
        end
    end
end