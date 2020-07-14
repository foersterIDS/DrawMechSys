classdef RigidBody < handle
    
    properties
        position
        angle = 0
        hgTransformHandle
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

