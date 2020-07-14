classdef PointObject < handle
    
    properties
        position
        angle = 0
        hgTransformHandle
    end
    events
        changedPosition
    end
    
    methods
        function obj = PointObject(position)
            if nargin > 0
                obj.position = position(:);
            end
        end
        
        function globalPosition = local2global(obj,localPosition)
            globalPosition = obj.position + localPosition(:);
        end
        
        function setPosition(obj,x,y)
            % Transformation:
            obj.hgTransformHandle.Matrix = ...
                [1 0 0 x;...
                0 1 0 y;...
                0 0 1 0;...
                0 0 0 1];
            obj.position = [x;y];
            notify(obj,'changedPosition');
        end
        
        function bind(obj,target,localOffset)
            addlistener(target,'changedPosition',@(src,evt) obj.updatePosition(src,evt,localOffset));
        end
        
        function updatePosition(obj,src,~,localOffset)            
            globalPosition = src.local2global(localOffset);
            setPosition(obj,globalPosition(1),globalPosition(2));
        end
        
    end
end

