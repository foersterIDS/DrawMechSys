classdef rod < gfx2d.LineObject
    
    properties
        window
        id
        d
        l
        lw
        handl
        pl
    end
    properties (Dependent)
        eColor
        fColor
    end
    
    methods
        function obj = rod(X,Y,d,varargin)
            obj@gfx2d.LineObject([X(1); Y(1)], [X(2); Y(2)]);
            %% Init:
            stdinp = 3;
            obj.eColor = [0,0,0];
            obj.fColor = 0.6*[1,1,1];
            lw = 3;
            obj.lw = lw;
            obj.d = d;
            %% Input:
            if nargin>stdinp
                i = 1;
                while i<=nargin-stdinp
                    switch lower(varargin{i})
                        case 'ecolor'
                            obj.eColor = varargin{i+1};
                            i = i+1;
                        case 'fcolor'
                            obj.fColor = varargin{i+1};
                            i = i+1;
                        case 'linewidth'
                            lw = varargin{i+1};
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
            obj.l = sqrt(diff(X)^2 + diff(Y)^2);
            r = d/2;
            theta = atan2(Y(2)-Y(1),X(2)-X(1));
            
            % Referenz
            nPhi = 100;
            phi = linspace(0,pi,nPhi);
            xl = [X(1) + r * sin(theta), X(1) + obj.l * cos(theta) + r*sin(phi+theta), X(1) - r*sin(phi+theta)];
            yl = [Y(1) - r * cos(theta), Y(1) + obj.l * sin(theta) - r*cos(phi+theta), Y(1) + r*cos(phi+theta)];
            obj.pl = patch('XData',xl,'YData',yl,'LineWidth',lw,'FaceColor',obj.fColor,'EdgeColor',obj.eColor);
        end
        
        
        function setPosition(obj,X,Y)
            obj.l = sqrt(diff(X)^2 + diff(Y)^2);
            r = obj.d/2;
            theta = atan2(Y(2)-Y(1),X(2)-X(1));
            
            % Referenz
            nPhi = 100;
            phi = linspace(0,pi,nPhi);
             xl = [X(1) + r * sin(theta), X(1) + obj.l * cos(theta) + r*sin(phi+theta), X(1) - r*sin(phi+theta)];
            yl = [Y(1) - r * cos(theta), Y(1) + obj.l * sin(theta) - r*cos(phi+theta), Y(1) + r*cos(phi+theta)];

            obj.pl.XData = xl;
            obj.pl.YData = yl;
            
            obj.p1 = [X(1);Y(1)];
            obj.p2 = [X(2);Y(2)];
            notify(obj,'changedPosition');
        end
        
        function delete(obj)
            delete(obj.pl);
            if ~isempty(obj.window)
                obj.window.deleteObject(obj.id);
            end
        end
        
        function set.eColor(obj,newcolor)
            obj.pl.EdgeColor = newcolor;
        end

        function set.fColor(obj,newcolor)
            obj.pl.FaceColor = newcolor;
        end
        
        function col = get.eColor(obj)
            col = obj.pl.EdgeColor;
        end

        function col = get.fColor(obj)
            col = obj.pl.FaceColor;
        end
    end
end