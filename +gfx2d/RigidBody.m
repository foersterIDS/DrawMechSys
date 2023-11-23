classdef RigidBody < gfx2d.DrawMechSysObject
    
    properties
        position
        angle = 0
        hgTransformHandle
        currentScale = 1
    end
    events
        changedPosition
    end
    
    methods
        function obj = RigidBody()
            
        end
        
        function setPosition(obj,x,y,orientation)
            if nargin == 4
                obj.angle = orientation;
            end
            obj.position = [x; y];
            
            ca = cos(obj.angle);
            sa = sin(obj.angle);
            obj.hgTransformHandle.Matrix = ...
                [ca -sa 0 x;...
                sa ca 0 y;...
                0 0 1 0;...
                0 0 0 1];
            notify(obj,'changedPosition');
        end

        function rotatedArroundPoint(obj,pointOfRotation,angleOfRotation,NameValueArgs)
            arguments
                obj (1,1)
                pointOfRotation (2,1) double
                angleOfRotation (1,1) double
                NameValueArgs.type (1,:) char {mustBeMember(NameValueArgs.type,{'abs','rel'})} = 'rel'
            end

            ca = cos(angleOfRotation);
            sa = sin(angleOfRotation);

            R = [ca, -sa, 0;
                 sa,  ca, 0;
                 0,    0, 1];

            t = [obj.position - pointOfRotation; 1];
            
            if strcmp(NameValueArgs.type,'rel')
                obj.hgTransformHandle.Matrix = obj.hgTransformHandle.Matrix*...
                [R, R*t - t;
                 zeros(1,3), 1];
            else
                tInitial = obj.hgTransformHandle.Matrix(1:3,4);
                obj.hgTransformHandle.Matrix = [R, R*t - t + tInitial;zeros(1,3), 1];
            end

            notify(obj,'changedPosition');
        end

        function translateObject(obj,vector,NameValueArgs)
            arguments
                obj (1,1)
                vector (2,1) double
                NameValueArgs.type (1,:) char {mustBeMember(NameValueArgs.type,{'abs','rel'})} = 'rel'
            end

            if strcmp(NameValueArgs.type,'rel')
                t = [vector + obj.position; 0];
            else
                t = [vector ; 0]; 
            end
            
            obj.setPosition(t(1),t(2),0);
        end

        function scaleObject(obj,scale,NameValueArgs)
            arguments
                obj (1,1)
                scale (1,1) double
                NameValueArgs.type (1,:) char {mustBeMember(NameValueArgs.type,{'abs','rel'})} = 'rel'
            end

            if strcmp(NameValueArgs.type,'rel')
                obj.currentScale = obj.currentScale * scale;
                R = [scale, 0, 0;
                 0,  scale, 0;
                 0,    0, 1];
                obj.hgTransformHandle.Matrix = obj.hgTransformHandle.Matrix*...
                [R, zeros(3,1);
                 zeros(1,3), 1];
            else
                oldScale = obj.currentScale;
                obj.currentScale = scale;
                scale = scale/oldScale;
                R = [scale, 0, 0;
                 0,  scale, 0;
                 0,    0, 1];
                obj.hgTransformHandle.Matrix = obj.hgTransformHandle.Matrix*...
                [R, zeros(3,1);
                 zeros(1,3), 1];
            end
            notify(obj,'changedPosition');
        end 
        
        function set.angle(obj,orientation)
            if numel(orientation) == 1
                obj.angle = orientation;
            else
                obj.angle = atan2(orientation(1),orientation(2));
            end
        end
        
        function bind(obj,target,targetLocalOffset,thisLocalOffset,bindRotation,angleOffset)
            if nargin<5
                angleOffset = 0;
            end
            addlistener(target,'changedPosition',@(src,evt) obj.updatePosition(src,evt,targetLocalOffset,thisLocalOffset,bindRotation,angleOffset));
        end
        
        function updatePosition(obj,src,~,targetLocalOffset,thisObjLocalOffset,bindRotation,angleOffset)            
            globalPosition = src.local2global(targetLocalOffset); % global position of connected point            
            if bindRotation
                newAngle = src.angle + angleOffset;
                obj.angle = newAngle;
            else
                newAngle = obj.angle;
            end            
            thisGlobalOffset = obj.position - obj.local2global(thisObjLocalOffset); % offset of object origin to globalPosition         
            newPosition = globalPosition + thisGlobalOffset;            
            setPosition(obj,newPosition(1),newPosition(2),newAngle)
        end
        
    end
end

