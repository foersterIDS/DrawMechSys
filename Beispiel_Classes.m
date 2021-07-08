clear all;
close all;
clc;
%% Beispielsystem:
% Settings:
xmin = 0;
xmax = 15;
ymin = 0;
ymax = 11;
fps = 30;
yres = 720;
lw = 3;
ms = 20;
co = 'k';
fo = 'w';
cs = [1,0,0];
cn = [0.5,0,0.5];
cd = [0,0,1];
cf = [0,0.8,0];
cm = [0.25,0.75,0.75];
cl = [1.0,0.75,0.0];
fa1 = 0.9;
fa2 = 'fade';
Ntr1 = 55;
Ntr2 = 15;
npl = 6;
bl = 1;
bw = 1/6;
bs = 0.4;
bf = bw;
bh = 0.35;
lh = 0.75;
ns = 5;
lmin = 0.5;
lminr = 1.5;
dm = 0.6;
dg = 1/6;
l = 6;
rr = 1.5;
rk = 1;
ru = 1.5;
rm = ru+0.5;
ro = ru+1;
% Amplituden:
a = [0.5;0.1;0.7;-0.2;1;0.4;0.5;0.2];
af = 1.5;
ag = 2;
am = 1;
% Kreisfrequenzen:
w_basis = 2*pi;
w = w_basis*[1;1;1;1;1;2;1;1];
% Phasenverschiebung:
phi = -pi/2+[-1/16*pi;-5/8*pi/2;-13/8*pi/2;-10/8*pi/2;-5/8*pi/2;-3/16*pi/2;-13/8*pi/2;-15/8*pi/2];
% Schleife:
Tmax = 20;
N = Tmax*fps+1;
tt = linspace(0,Tmax,N);
dtt = tt(2)-tt(1);
%% set up Plot:
% Fenster:
frame = createWindow([xmin,xmax],[ymin,ymax],yres,'figure',1,'backcolor',fo,'grid','on','gridx',1,'gridy',1);
% Waende:
walls{1} = gfx2d.wall([1,1],[7,9],npl,+1,'Color',co,'LineWidth',lw);
walls{2} = gfx2d.wall([2.5,4.5],[7-bw,7-bw],npl,-1,'Color',co,'LineWidth',lw);
walls{3} = gfx2d.wall([2.5,4.5],[9+bw,9+bw],npl,+1,'Color',co,'LineWidth',lw);
walls{4} = gfx2d.wall([6+ru-0.5,6+ro+0.5],[2,2],npl,-1,'Color',co,'LineWidth',lw);
walls{5} = gfx2d.wall([0.5,1.5],[2,2],npl,-1,'Color',co,'LineWidth',lw);
walls{6} = gfx2d.wall([0.5,1.5],[6,6],npl,+1,'Color',co,'LineWidth',lw);
walls{7} = gfx2d.wall([6,8],[9+bw,9+bw],npl,+1,'Color',co,'LineWidth',lw);
% Massen:
masses{1} = gfx2d.mass(3.5,8,1,2,[0;1],'Color',co,'LineWidth',lw);
masses{2} = gfx2d.lumpedmass(6+l*sin(-0),(8-l)+l*cos(-0),dm,'Color',co);
masses{3} = gfx2d.roll(8,8-rr,2*rr,'Color',co,'LineWidth',lw);%,'orientation',[0,1]);
masses{4} = gfx2d.sphere(3.5,4,2*rk,'Color',co,'LineWidth',lw);
masses{5} = gfx2d.body(12,2.5,[11.5,12.5,12.5,13,13,12.5,12.5,11.5,11.5,11,11,11.5,11.5]-12,[3,3,4,4,1,1,2,2,1,1,4,4,3]-2.5,0,'Color',co,'LineWidth',lw);
masses{6} = gfx2d.potato(12,9,1.5,pi/6);
% Staebe:
bars{1} = gfx2d.bar([6+l*sin(-0),6],[(8-l)+l*cos(-0),(8-l)],'Color',co,'LineWidth',lw);
bars{2} = gfx2d.bar([1,1],[2,6],'Color',co,'LineWidth',lw);
% Slider:
sliders{1} = gfx2d.slider(7,9+bw,(1/2+2*bw)/sqrt(3),[0,-1],'Color',cl,'LineWidth',lw);
xconS = sliders{1}.xcon;
yconS = sliders{1}.ycon;
% Spur des Sliders
trails{1} = gfx2d.trail(Ntr1,[],[],0.08,'Color','m','FaceAlpha',fa1,'Wind',[0;0.03]);
trails{2} = gfx2d.trail(Ntr2,[],[],0.08,'Color','m','FaceAlpha',fa2);
% Federn & Daempfer:
springs{1} = gfx2d.spring([4,xconS(2)],[yconS(2),yconS(2)],bs,lmin,'n',ns,'Color',cs,'LineWidth',lw,'MarkerSize',ms);
springs{2} = gfx2d.spring([1,3],[8.5,8.5],bs,lmin,'n',ns,'Color',cs,'LineWidth',lw,'MarkerSize',ms);
springs{3} = gfx2d.spring([4,6+l*sin(0)],[8,(8-l)+l*cos(0)],bs,lmin,'n',ns,'Color',cs,'LineWidth',lw,'MarkerSize',ms);
springs{4} = gfx2d.spring([6+l*sin(0),8+rr*sin(0)],[(8-l)+l*cos(0),(8-rr)+rr*cos(0)],bs,lmin,'n',ns,'Color',cs,'LineWidth',lw,'MarkerSize',ms);
springs{5} = gfx2d.spring([3.5,3.5],[8,4],bs,lmin,'n',ns,'Color',cs,'LineWidth',lw,'MarkerSize',ms);
springs{6} = gfx2d.spring([8,12],[6.5,6.5],bs,lmin,'n',ns,'Color',cs,'LineWidth',lw,'MarkerSize',ms);
nlsprings{1} = gfx2d.nonlinspring([1,3],[8,8],bs,lmin,'n',ns,'Color',cn,'LineWidth',lw,'MarkerSize',ms);
dampers{1} = gfx2d.damper([1,3],[7.5,7.5],bs,lmin,'Color',cd,'LineWidth',lw,'MarkerSize',ms);
% rot. Federn & Daempfer:
rotsprings{1} = gfx2d.rotspring([6+ro,6+ro*sin(-0)],[2,2+ro*cos(-0)],bs,lminr,[6;2],'n',ns,'Color',cs,'LineWidth',lw,'MarkerSize',ms);
rotnonlinsprings{1} = gfx2d.rotnonlinspring([6+rm,6+rm*sin(-0)],[2,2+rm*cos(-0)],bs,lminr,[6;2],'n',ns,'Color',cn,'LineWidth',lw,'MarkerSize',ms);
rotdampers{1} = gfx2d.rotdamper([6+ru,6+ru*sin(-0)],[2,2+ru*cos(-0)],bs,lminr,[6;2],'Color',cd,'LineWidth',lw,'MarkerSize',ms);
% Lager:
bearings{1} = gfx2d.fixedbearing(6,8-l,bl,[0;1],'npl',npl,'Color',co,'LineWidth',lw);
bearings{2} = gfx2d.floatingbearing(8,8-rr,bl,8,8-rr,[1;0],'npl',npl,'Color',co,'LineWidth',lw);%,'wallsize',[-0.75,0.75]
bearings{3} = gfx2d.floatingbearing(12,8-rr,bl,12,8-rr,[1;0],'npl',npl,'Color',co,'LineWidth',lw);%,'wallsize',[-1,+1]
% Kraefte & Momente:
forces{1} = gfx2d.force(3.5,4,bf,ag*[0,-1],'Color',cf,'LineWidth',lw,'MarkerSize',ms); % Gravitation
forces{2} = gfx2d.force(4,7.25,bf,1*[1,0],'Color',cf,'LineWidth',lw,'MarkerSize',ms); % Erregerkraft
torques{1} = gfx2d.torque(6,2,bf,0.5,1,am,'alpha_0',pi/2,'delta_alpha_max',3*pi/4,'Color',cm,'LineWidth',lw); % Erregermoment
% Huelsen:
hulls{1} = gfx2d.hull(6+4.5*tan(-0)+bh/2*tan(-0)*sin(-0),8-rr+bh/2*sin(-0),bh,lh,[sin(-0);cos(-0)],'Color',co,'LineWidth',lw); % Pendel
hulls{2} = gfx2d.hull(1,4,bh,lh,[0;1],'Color',co,'LineWidth',lw); % Pendel
xconP = hulls{1}.xcon;
yconP = hulls{1}.ycon;
xconK = hulls{2}.xcon;
yconK = hulls{2}.ycon;
% Nichtlineare Feder an der Rolle (BESONDERHEIT WEGEN HUELSE!): Kann erst nach Huelse, aber vor dem Gelenk geplottet werden.
nlsprings{2} = gfx2d.nonlinspring([xconP(2),8-1/6],[8-rr,8-rr],bs,lmin,'n',ns,'Color',cn,'LineWidth',lw,'MarkerSize',ms);
% Daempfer an der Kugel (BESONDERHEIT WEGEN HUELSE!): Kann erst nach Huelse, aber vor dem Gelenk geplottet werden.
dampers{2} = gfx2d.damper([xconK(2),3.5],[yconK(2),4],bs,lmin,'Color',cd,'LineWidth',lw,'MarkerSize',ms);
% Stab an dem Loslager (BESONDERHEIT WEGEN Loslager!): Kann erst nach Loslager geplottet werden.
bars{3} = gfx2d.bar([12,12],[6.5-1/6,3],'Color',co,'LineWidth',lw);
% Gelenke:
joints{1} = gfx2d.joint(3.5,8,dg,'FaceColor',fo,'Color',co,'LineWidth',lw);
joints{2} = gfx2d.joint(4,8,dg,'FaceColor',fo,'Color',co,'LineWidth',lw);
joints{3} = gfx2d.joint(3.5,4,dg,'FaceColor',fo,'Color',co,'LineWidth',lw);
joints{4} = gfx2d.joint(6+l*sin(-0),(8-l)+l*cos(-0),dg,'FaceColor',co,'Color',fo,'LineWidth',lw);
joints{5} = gfx2d.joint(8+rr*sin(-0),(8-rr)+rr*cos(-0),dg,'FaceColor',fo,'Color',co,'LineWidth',lw);
joints{6} = gfx2d.joint(xconP(2),8-rr,dg,'FaceColor',fo,'Color',co,'LineWidth',lw);
hold off;
    
%% Live-Plot:
for i=1:N%[1:N,1:N,1:N]%
    % Zeit:
    t = tt(i);
    % Zustandwerte:
    q1 = a(1)*cos(w(1)*t+phi(1));
    q2 = a(2)*cos(w(2)*t+phi(2));
    q3 = a(3)*cos(w(3)*t+phi(3));
    q4 = a(4)*cos(w(4)*t+phi(4));
    q5 = a(5)*cos(w(5)*t+phi(5));
    q6 = a(6)*cos(w(6)*t+phi(6));
    q7 = a(7)*cos(w(7)*t+phi(7));
    q8 = a(8)*cos(w(8)*t+phi(8));
    % Slider:
    q1im1 = a(1)*cos(w(1)*(t-dtt)+phi(1));
    if q1>=0 && q1-q1im1>=0
        qs = q1;
    elseif q1>=0 && q1-q1im1<0
        qs = a(1);
    elseif q1<0 && q1-q1im1<0
        qs = q1+a(1);
    else
        qs = 0;
    end
    % Kraefte & Momente:
    f = af*cos(w_basis*t);
    m = am*cos(w_basis*t-pi/4);
    % Massen:
    masses{1}.setPosition(3.5+q1,8,[0;1]);
    masses{2}.setPosition(6+l*sin(-q2),(8-l)+l*cos(-q2));
    masses{3}.setPosition(8+q4,8-rr);%,[sin(q3);cos(q3)]);
    masses{4}.setPosition(3.5+q5,4+q6);
    masses{5}.setPosition(12+q7+4*sin(q8),2.5+4-4*cos(q8),q8);
    % Staebe:
    bars{1}.setPosition([6+l*sin(-q2),6],[(8-l)+l*cos(-q2),(8-l)]);
    bars{3}.setPosition([12+q7+1/6*sin(q8),12+q7+3.5*sin(q8)],[6.5-1/6*cos(q8),6.5-3.5*cos(q8)]);
    % Slider:
    sliders{1}.setPosition(6.75+qs,9+bw,[0,-1]);
    xconS = sliders{1}.xcon;
    yconS = sliders{1}.ycon;
    % Spur des Sliders
    trails{1}.addPoint(6.75+qs,9+bw);
    trails{2}.addPoint(3.5+q5,4+q6);
    % Federn & Daempfer:
    springs{1}.setPosition([4+q1,xconS(2)],[yconS(2),yconS(2)]);
    springs{2}.setPosition([1,3+q1],[8.5,8.5]);
    springs{3}.setPosition([4+q1,6+l*sin(-q2)],[8,(8-l)+l*cos(-q2)]);
    springs{4}.setPosition([6+l*sin(-q2),8+rr*sin(-q3)+q4],[(8-l)+l*cos(-q2),(8-rr)+rr*cos(-q3)]);
    springs{5}.setPosition([3.5+q1,3.5+q5],[8,4+q6]);
    springs{6}.setPosition([8+q4,12+q7],[6.5,6.5]);
    nlsprings{1}.setPosition([1,3+q1],[8,8]);
    dampers{1}.setPosition([1,3+q1],[7.5,7.5]);
    % rot. Federn & Daempfer:
    rotsprings{1}.setPosition([6+ro,6+ro*sin(-q2)],[2,2+ro*cos(-q2)]);
    rotnonlinsprings{1}.setPosition([6+rm,6+rm*sin(-q2)],[2,2+rm*cos(-q2)]);
    rotdampers{1}.setPosition([6+ru,6+ru*sin(-q2)],[2,2+ru*cos(-q2)]);
    % Lager:
    bearings{2}.setPosition(8+q4,8-rr);
    bearings{3}.setPosition(12+q7,6.5);
    % Kraefte & Momente:
    forces{1}.setPosition(3.5+q5,4+q6,ag*[0,-1]);
    forces{2}.setPosition(4+q1,7.25,f*[1,0]);
    torques{1}.setPosition(6,2,m);
    % Huelsen:
    hulls{1}.setPosition(6+4.5*tan(-q2)+bh/2*tan(-q2)*sin(-q2),8-rr+bh/2*sin(-q2),q2);
    hulls{2}.setPosition(1,4+q6,[0;1]);
    xconP = hulls{1}.xcon;
    yconP = hulls{1}.ycon;
    xconK = hulls{2}.xcon;
    yconK = hulls{2}.ycon;
    % Nichtlineare Feder an der Rolle (BESONDERHEIT WEGEN HUELSE!): Kann erst nach Huelse, aber vor dem Gelenk geplottet werden.
    nlsprings{2}.setPosition([xconP(2),8+q4-1/6],[8-rr,8-rr]);
    % Daempfer an der Kugel (BESONDERHEIT WEGEN HUELSE!): Kann erst nach Huelse, aber vor dem Gelenk geplottet werden.
    dampers{2}.setPosition([xconK(2),3.5+q5],[yconK(2),4+q6]);
    % Gelenke:
    joints{1}.setPosition(3.5+q1,8);
    joints{2}.setPosition(4+q1,8);
    joints{3}.setPosition(3.5+q5,4+q6);
    joints{4}.setPosition(6+l*sin(-q2),(8-l)+l*cos(-q2));
    joints{5}.setPosition(8+rr*sin(-q3)+q4,(8-rr)+rr*cos(-q3));
    joints{6}.setPosition(xconP(2),8-rr);
    drawnow;
end