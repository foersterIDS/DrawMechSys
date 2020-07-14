% create figure
close all;
f = figure('WindowStyle','normal');
% Plot a line
pl1 = plot(1:10,1:10,'-o','buttondownfcn',{@Mouse_Callback,'down'});
% create plot context menu
pl1context = uicontextmenu;
pl1.UIContextMenu = pl1context;
pl1context1 = uimenu(pl1context,'Label','change color');
pl1context1_1 = uimenu('Parent',pl1context1,'Label','blue','Callback',{@setcolor,pl1});
pl1context1_2 = uimenu('Parent',pl1context1,'Label','red','Callback',{@setcolor,pl1});
pl1context2 = uimenu(pl1context,'Label','dashed','Callback',{@setline,pl1});
pl1context3 = uimenu(pl1context,'Label','solid','Callback',{@setline,pl1});
pl1context4 = uimenu(pl1context,'Label','add','Callback',{@addpoint,pl1});
% Plot a line
hold on;
pl2 = plot(1:10,10:-1:1,'-o','buttondownfcn',{@Mouse_Callback,'down'});
hold off;
% create plot context menu
pl2context = uicontextmenu;
pl2.UIContextMenu = pl2context;
pl2context1 = uimenu(pl2context,'Label','change color');
pl2context1_1 = uimenu('Parent',pl2context1,'Label','blue','Callback',{@setcolor,pl2});
pl2context1_2 = uimenu('Parent',pl2context1,'Label','red','Callback',{@setcolor,pl2});
pl2context2 = uimenu(pl2context,'Label','dashed','Callback',{@setline,pl2});
pl2context3 = uimenu(pl2context,'Label','solid','Callback',{@setline,pl2});
pl2context4 = uimenu(pl2context,'Label','add','Callback',{@addpoint,pl2});
% Callback function
function Mouse_Callback(hObj,~,action)
    persistent curobj xdata ydata ind
    pos = get(gca,'CurrentPoint');
    switch action
        case 'down'
            curobj = hObj;
            xdata = get(hObj,'xdata');
            ydata = get(hObj,'ydata');
            [~,ind] = min(sum((xdata-pos(1)).^2+(ydata-pos(3)).^2,1));
            set(gcf,...
                'WindowButtonMotionFcn',  {@Mouse_Callback,'move'},...
                'WindowButtonUpFcn',      {@Mouse_Callback,'up'});
        case 'move'
            % horizontal move
            xdata(ind) = pos(2);
            set(curobj,'xdata',xdata)
            % vertical move
            ydata(ind) = pos(3);
            set(curobj,'ydata',ydata)
        case 'up'
            set(gcf,...
                'WindowButtonMotionFcn',  '',...
                'WindowButtonUpFcn',      '');
        case 'click'
            fprintf('Hello World!');
    end
end
% context function
function setline(src,event,pl)
    switch src.Label
        case 'dashed'
            pl.LineStyle = '--';
        case 'solid'
            pl.LineStyle = '-';
    end
end
function setcolor(src,event,pl)
    switch src.Label
        case 'blue'
            pl.Color = 'b';
        case 'red'
            pl.Color = 'r';
    end
end
function addpoint(src,event,pl)
    switch src.Label
        case 'blue'
            pl.Color = 'b';
        case 'red'
            pl.Color = 'r';
    end
end