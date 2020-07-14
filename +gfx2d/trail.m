classdef trail < handle
   
    properties
        window
        id
        n
        x
        y
        b
        windX = 0;
        windY = 0;
        handl
    end
    
    methods
        function obj = trail(nPoints,x0,y0,b0,varargin)
            %TRAIL Spur von Objekten: Linie die mit der Zeit dünner wird
            %
            % trail(nPoints,x0,y0,b0,windX,windY,color)
            %
            % nPoints   maximale Anzahl an Punkten
            % x0        Vektor der X-Werte
            % y0        Vektor der Y-Werte
            % b0        Breite der Spur
            % windX     Alte Punkte werden um diesen Betrag verschoben wenn ein neuer Punkt mit addPoint(obj,x,y) hinzugefügt wird
            % windY     Alte Punkte werden um diesen Betrag verschoben wenn ein neuer Punkt mit addPoint(obj,x,y) hinzugefügt wird
            % color     Farbe
            stdinp = 4;
            color = 'r';
            fa = 1;
            % Input:
            if nargin>stdinp
                i = 1;
                while i<=nargin-stdinp
                    switch lower(varargin{i})
                        case 'color'
                            color = varargin{i+1};
                            i = i+1;
                        case 'facealpha'
                            fa = varargin{i+1};
                            if ~isnumeric(fa)
                                fa = linspace(1,0,2*nPoints)';
                            end
                            i = i+1;
                        case 'wind'
                            wind = varargin{i+1};
                            obj.windX = wind(1);
                            obj.windY = wind(2);
                            i = i+1;
                        case 'window'
                            obj.window = varargin{i+1};
                            i = i+1;
                        otherwise
                            error('No such element: %s',varargin{i});
                    end
                    i = i+1;
                end
            end
            
            assert(length(x0)<=nPoints);
            assert(length(y0)<=nPoints);
            
            obj.n = nPoints;
            obj.x = nan(obj.n,1);
            obj.y = nan(obj.n,1);
            obj.x(1:length(x0)) = x0;
            obj.y(1:length(y0)) = y0;
           
            obj.b = (b0*sqrt(linspace(1,0,obj.n)))';
            
            % Nummerierung der Vertices: (o) = Mittelpunkte (obj.x, obj.y)
            %
            % 1--3--5-...
            % o--o--o-...
            % 2--4--6-...            
            v = [repelem(obj.x(:),2) repelem(obj.y(:),2)];  %zunächst Breite nicht berücksichtigen
            f = [0 1 2] + (1:2*obj.n-2)'; 
            
            if numel(fa) == 1
                obj.handl = patch('Faces',f,'Vertices',v,...
                'EdgeColor','none','FaceColor',color, 'FaceAlpha',fa,'CDataMapping','direct');
            
            else
                assert(numel(fa) == 2*obj.n);
                obj.handl = patch('Faces',f,'Vertices',v,...
                'EdgeColor','none','FaceColor',color,'FaceVertexAlphaData',fa, 'FaceAlpha','interp','CDataMapping','direct');
            
            end
            
            
            updateVertices(obj); % hier
        end
        
        function addPoint(obj,x,y)
            %ADDPOINT einzelnen Punkt hinzufügen, ältester wird gelöscht
            
            % neue Koordinaten
            obj.x = [x; obj.x(1:end-1)+obj.windX];
            obj.y = [y; obj.y(1:end-1)+obj.windY];
            updateVertices(obj);
        end
        
        function setPoints(obj,X,Y)
            %SETPOINTS Punktepfad ändern
            obj.x = nan(obj.n,1);
            obj.y = nan(obj.n,1);
            
            % neue Koordinaten
            obj.x(1:min([length(X),obj.n])) = X(1:min([length(X),obj.n]));
            obj.y(1:min([length(Y),obj.n])) = Y(1:min([length(X),obj.n]));
            updateVertices(obj);
        end
    end
    methods (Access=private)
        function updateVertices(obj)
            
            gx = gradient(obj.x(:));
            gy = gradient(obj.y(:));
            
            vlen = vecnorm([gx,gy]')';
            bv = obj.b ./ vlen;
            
            % offset der Umrandungspunkte
            dx = reshape([bv, -bv]',[],1).*repelem(gy,2);
            dy = reshape([-bv, bv]',[],1).*repelem(gx,2);            
            
            obj.handl.Vertices = [repelem(obj.x(:),2)+dx repelem(obj.y(:),2)+dy];
        end
    
    end
    
end

