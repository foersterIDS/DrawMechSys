% canvas
f = createWindow([-12.8 12.8],[-6.2 8.2],1080/2);

% initialize masses
nSprings = 13;
for iis = 1:nSprings
    s(iis) = gfx2d.spring(...
        [0 10],[0 0],...
        0.1+iis/nSprings,...
        iis/nSprings,...
        'LineWidth', 3*iis/nSprings,...
        'MarkerSize', 30*iis/nSprings,...
        'n',nSprings+3-iis);
end
hold off
drawnow

% plotting loop
for ii = 1:200
    for iis = 1:nSprings
        s(iis).setPosition(...
            [0 6*cos(ii/20-iis/2)],...
            [0 6*-sin(ii/20-iis/2)-1.5*cos(ii/10-iis)]);
    end
    drawnow
end

