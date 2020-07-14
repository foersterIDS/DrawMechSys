function [color] = systemColors(name)
    switch name
        case 'grid color'
            color = 233/255*[1,1,1];
        case 'body facecolor'
            color = 233/255*[1,1,1];
        case 'blue'
            color = 'b';
        case 'red'
            color = 'r';
        case 'magenta'
            color = 'm';
        case 'green'
            color = [38,194,0]./255;
        case 'yellow'
            color = [255,216,0]./255;
        case 'black'
            color = 'k';
        case 'white'
            color = 'w';
        case 'random'
            color = rand(1,3);
        otherwise
            color = 'k';
    end
end