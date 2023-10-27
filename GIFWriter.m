classdef GIFWriter < handle
    properties
        filename
        fps
        path
        name
        loops % Anzahl Schleifendurchläufe; 0 entspricht einem Durchlauf; inf führt zu Dauerschleife
        first = 1;
        write = 1;
    end
    
    methods
        function obj = GIFWriter(name,NameValueArgs)
            arguments
                name (1,:) char {mustBeTextScalar}
                NameValueArgs.fps (1,1) double {mustBeInteger,mustBePositive} = 30;
                NameValueArgs.path (1,:) char {mustBeTextScalar}
                NameValueArgs.loops (1,1) double {mustBeGreaterThanOrEqual(NameValueArgs.loops,0),mustBeIntegerOrInf} = inf;
            end
            obj.name = name;
            obj.fps = NameValueArgs.fps;
            obj.path = [pwd,'\'];
            if isfield(NameValueArgs,'path')
                obj.path = NameValueArgs.path;
            end
            obj.loops = NameValueArgs.loops;
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

function mustBeIntegerOrInf(val)
    if ~isinf(val) && ~(val == round(val))
        eidType = 'mustBeIntegerOrInf:notIntegerOrInf';
        msgType = 'Value must be a integer or inf.';
        throwAsCaller(MException(eidType,msgType))
    end
end