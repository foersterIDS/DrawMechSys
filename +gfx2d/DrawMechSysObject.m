classdef DrawMechSysObject < handle
    properties (Access = public)
        visible = true
        alpha = 0
    end
    
    methods
        function set.visible(obj,val)
            arguments
                obj (1,1) gfx2d.DrawMechSysObject
                val (1,1) logical
            end
            if obj.visible ~= val
                obj.changeObjVisibility(obj,val);
                obj.visible = val;
            end
        end

        function set.alpha(obj,val)
            arguments
                obj (1,1) gfx2d.DrawMechSysObject
                val (1,1) double {mustBeInRange(val,0,1)}
            end
            obj.changeObjAlpha(obj,val);
            obj.alpha = val;
        end
    end

    methods (Static, Access = protected)
        function changeObjVisibility(objectToChange,val)
            arguments
                objectToChange
                val (1,1) logical
            end
            allowedClasses = {'matlab.graphics.primitive.Patch','matlab.graphics.primitive.Text','matlab.graphics.chart.primitive.Line',...
                'matlab.graphics.chart.primitive.Line','matlab.graphics.chart.primitive.Scatter'};
            if any(strcmp(class(objectToChange), allowedClasses)) && isprop(objectToChange,'Visible')
                if val
                    objectToChange(jj).Visible = 'on';
                else
                    objectToChange(jj).Visible = 'off';
                end
            else
                if isa(objectToChange, 'gfx2d.DrawMechSysObject') || any(strcmp(class(objectToChange), allowedClasses))
                    fNames = properties(objectToChange);
                    for kk = 1:length(fNames)
                        gfx2d.DrawMechSysObject.changeObjVisibility(objectToChange.(fNames{kk}),val);
                    end
                elseif iscell(objectToChange)
                    for kk = 1:length(objectToChange)
                        gfx2d.DrawMechSysObject.changeObjVisibility(objectToChange{kk},val);
                    end
                end
            end
        end

        function changeObjAlpha(objectToChange,val)
            arguments
                objectToChange
                val (1,1) double
            end
            allowedClasses = {'matlab.graphics.primitive.Patch','matlab.graphics.primitive.Text','matlab.graphics.chart.primitive.Line',...
                'matlab.graphics.chart.primitive.Line','matlab.graphics.chart.primitive.Scatter'};
            if any(strcmp(class(objectToChange), allowedClasses))
                if isprop(objectToChange,'FaceAlpha')
                    try
                        objectToChange.FaceAlpha = val;
                    catch 
                        % ...
                    end
                end
                if isprop(objectToChange,'EdgeAlpha')
                    try
                        objectToChange.EdgeAlpha = val;
                    catch 
                        % ...
                    end
                end
                if isprop(objectToChange,'MarkerEdgeAlpha')
                    try
                        objectToChange.MarkerEdgeAlpha = val/2;
                    catch 
                        % ...
                    end
                end
                if isprop(objectToChange,'MarkerFaceAlpha')
                    try
                        objectToChange.MarkerFaceAlpha = val/2;
                    catch 
                        % ...
                    end
                end
                if isprop(objectToChange,'Color')
                    try
                        currentColor = objectToChange.Color;
                        objectToChange.Color = [currentColor, val];
                    catch 
                        % ...
                    end
                end
                if isa(objectToChange,'matlab.graphics.primitive.Text')
                    objectToChange.Color = (1-val) * [1,1,1];
                end
            else
                if isa(objectToChange, 'gfx2d.DrawMechSysObject') || any(strcmp(class(objectToChange), allowedClasses))
                    fNames = properties(objectToChange);
                    for kk = 1:length(fNames)
                        gfx2d.DrawMechSysObject.changeObjAlpha(objectToChange.(fNames{kk}),val);
                    end
                elseif iscell(objectToChange)
                    for kk = 1:length(objectToChange)
                        gfx2d.DrawMechSysObject.changeObjAlpha(objectToChange{kk},val);
                    end
                end
            end
        end
    end
end