classdef GIFWriter < handle
    properties
        filename
        fps
        path
        name
        loops = inf; % Anzahl Schleifendurchläufe; 0 entspricht einem Durchlauf; inf führt zu Dauerschleife
        first = 1;
        write = 1;
    end
    
    methods
        function obj = GIFWriter(name,fps,varargin)
            stdinp = 2;
            obj.name = name;
            obj.fps = fps;
            obj.path = [pwd,'\'];
            if nargin>stdinp
                i = 1;
                while i<=nargin-stdinp
                    switch lower(varargin{i})
                        case 'path'
                            obj.path = varargin{i+1};
                            i = i+2;
                        case 'loops'
                            obj.loops = varargin{i+1};
                            i = i+2;
                        otherwise
                            error('No such option!');
                    end
                end
            end
            obj.filename = [obj.path,obj.name,'.gif'];
        end
        
        function obj = writeGIF(obj,frame,im)
            if nargin<3
                fr = getframe(frame);
                im = fr.cdata;
            end
            %% Farbkorrektur:
            [d1,d2,d3] = size(im);
            if d3==1
                temp = uint8(zeros(d1,d2,3));
                temp(:,:,1) = im;
                temp(:,:,2) = im;
                temp(:,:,3) = im;
                im = temp;
            end
            [imind,cm] = rgb2ind(im,256);
            %% neues Frame in Datei schreiben:
            if obj.write
                if obj.first
                    if isfile(obj.filename)
                        fprintf('Die Datei [%s.gif] im Pfad [%s] bereits vorhanden.\n',obj.name,obj.path);
                        ersetzen = benutzereingabe( 'Datei ersetzen? (y/n):', @(eingabe) strcmp(eingabe,'y') || strcmp(eingabe,'n') );
                        if strcmp(ersetzen,'y')
                            delete(obj.filename);
                            imwrite(imind,cm,obj.filename,'gif','DelayTime',1/obj.fps,'Loopcount',obj.loops);
                            obj.first = 0;
                        else
                            obj.write = 0;
                        end
                    else
                        imwrite(imind,cm,obj.filename,'gif','DelayTime',1/obj.fps,'Loopcount',obj.loops);
                        obj.first = 0;
                    end
                else
                    imwrite(imind,cm,obj.filename,'gif','WriteMode','append','DelayTime',1/obj.fps);
                end
            else
                warning('Die Datei wird nicht beschrieben, da sie bereits existiert.');
            end
        end
    end
end

