%% getRGB
% 25.11.2020 - Alwin Förster
% 16.05.2023 - Florian Jäger
% ----------------------------------------------------------------------- %
% Purpose:
%           Get RGB values on a defined color value scale with specific
%           colorcode of a colormap.
% Input:
%           value           =       Vector of values for interpolation
%           maxValue        =       Max limit value
%           minValue        =       min limit value
%           cmName          =       Vector of values for interpolation
% Output:
%           rgb             =       Color codes
% ----------------------------------------------------------------------- %
function [ rgb ] = getRGB( value, maxValue, minValue, cmName )
    arguments
        value {valueInput}
        maxValue (1,1) double = 1
        minValue (1,1) double {mustBeLessThanOrEqual(minValue,maxValue)} = 0
        cmName {cmNameInput} = 'viridis'
    end
    value = value(:);
    if nargin==1 && isa(value,'char')
        switch value
            case 'b'
                rgb = [65,76,204]/255;
            case 'e'
                rgb = [181,0,24]/255;
            case 'g'
                rgb = [65,163,52]/255;
            case 'k'
                rgb = [0,0,0]/255;
            case 'm'
                rgb = [255,0,144]/255;
            case 'p'
                rgb = [0,20,204]/255;
            case 'r'
                rgb = [183,39,58]/255;
            case 'v'
                rgb = [153,0,204]/255;
            case 'w'
                rgb = [255,255,255]/255;
            case 'y'
                rgb = [183,142,39]/255;
            otherwise
                error('unknown color');
        end
    elseif nargin==1 && isa(value,'double') && numel(value)==3
        value = value(:).';
        rgb = max([0,0,0],min(value,[1,1,1]));
    else
        if nargin<4
            cmName = 'viridis';
        elseif nargin<3
            error('not enough input arguments');
        elseif nargin>4
            error('to many input arguments');
        end
        cm = colormap(cmName);
        Pcm = linspace(0,1,numel(cm(:,1)))';
        if maxValue<minValue
            temp = minValue;
            minValue = maxValue;
            maxValue = temp;
        end
        if minValue==maxValue
            if value>minValue
                P = 1;
            elseif value<minValue
                P = 0;
            else
                P = 0.5;
            end
        else
            P = (value-minValue)/(maxValue-minValue);
            P = max([zeros(size(P)),min([ones(size(P)),P],[],2)],[],2);
        end
        rgb = interp1(Pcm,cm,P);
    end
end

function valueInput(v)
    allowedColors = {'b','e','g','k','m','p','r','v','w','y'};
    if ~isa(v,'double') && ~sum(strcmp(v,allowedColors))
        errStr = "Input must be double or be a char of:";
        for ii=1:numel(allowedColors)
            errStr = strcat(errStr," '",allowedColors(ii),"'");
            if ii~=numel(allowedColors)
                errStr = strcat(errStr,",");
            end
        end
        error(errStr);
    end
end

function cmNameInput(c)
    errStr = [];
    if isa(c,'double')
        sz = size(c);
        if numel(sz)~=2 || sz(1)<2 || sz(2)~=3
            errStr = 'Input must be a colormap name or a (n x 3) double with n >= 2.';
        end
    elseif ~isa(c,'char') && ~isa(c,'string')
        errStr = 'Input (cmName) must be a colormap name or a (n x 3) double with n >= 2.';
    end
    if ~isempty(errStr)
        error(errStr);
    end
end