function [rdat,xcoord,ycoord] = rscan(M0,varargin),

% RDAT = RSCAN(M0,VARARGIN)
% Get radial scan of a matrix using the following procedure:
% [1] Get coordinates of a circle around an origin.
% [2] Average values of points where the circle passes through.
% [3] Change radius of the circle and repeat [1] until rprofile is obtained.
%
% For DEMO, run
% >> rscan_qavg();
% or
% >> rscan_qavg('demo','dispflag',0);
% >> plot(ans);
% or
% >> rdat = rscan_qavg();
% >> plot(rdat);
% or
% >> a = peaks(300);
% >> rscan_qavg(a);
% >> rscan_qavg(a,'rlim',50,'xavg',100);
% >> rscan_qavg(a,'rlim',25,'xavg',100,'dispflag',1,'dispflagc',1);
% >> rscan_qavg(a,'rlim',25,'xavg',100,'dispflag',1,'dispflagc',1, ...
%    'squeezx',0.7,'rot',pi/4);
%
% Draw Circle:
% [ref] http://www.mathworks.com/matlabcentral/fileexchange/
%       loadFile.do?objectId=2876&objectType=file

if nargin < 1,
    disp('This is a Demo');
    M0 = 'demo';
end

if strmatch('demo',lower(M0),'exact')
    %M0 = peaks(200);
    [xx,yy] = meshgrid(linspace(-3,3,201));
    [phi,rho] = cart2pol(xx,yy);
    M0 = besselj(1,rho);
    clear xx yy phi rho;
end

xavg = size(M0,2)/2;
yavg = size(M0,1)/2;
Rlim = floor(min(size(M0))/2)-1;
dispFlag = 1;
dispFlagC = 0;
rot = 0; %% radian
squeezx = 1; %% 0.80;
squeezy = 1;
rstep = 1;

if exist('varargin','var')
    L = length(varargin);
    if rem(L,2) ~= 0, error('Parameters/Values must come in pairs.'); end
    for ni = 1:2:L
        switch lower(varargin{ni})
            case 'xavg', xavg = varargin{ni+1};
            case 'yavg', yavg = varargin{ni+1};
            case 'squeezx', squeezx = varargin{ni+1};
            case 'squeezy', squeezy = varargin{ni+1};
            case 'rot', rot = varargin{ni+1};
            case 'rlim', Rlim = varargin{ni+1};
            case 'dispflag', dispFlag = varargin{ni+1};
            case 'dispflagc', dispFlagC = varargin{ni+1};
            case 'rstep', rstep = varargin{ni+1};
        end
    end
end


yxz = size(M0);
Rbnd = floor(min(yxz)/2)-1;
if Rlim > Rbnd, Rlim = Rbnd; end

for nRho = 1:rstep:floor(Rlim),
    NOP = round(2*pi*nRho);
    THETA=linspace(0,2*pi,NOP);
    RHO=ones(1,NOP)*round(nRho);
    [X,Y] = pol2cart(THETA,RHO);
    X = squeezx*X;
    Y = squeezy*Y;
    [THETA,RHO] = cart2pol(X,Y);
    [X,Y] = pol2cart(THETA+rot,RHO);
    X = X + xavg;
    Y = Y + yavg;
    
    if dispFlag,
        h1 = figure(100);clf;box on;
        %     set(h1,'position',[10 500 400 300]);
        %     set(h1,'units','pixels');
        %     set(gca,'units','pixels');
        imagesc(M0);axis image;hold on; colormap fire;
        % H = plot(X,Y,'c-');
        line([xavg xavg],[1 yxz(1)],'color',[1 1 0],'linewidth',1);
        line([1 yxz(2)],[yavg yavg],'color',[1 1 0],'linewidth',1);
    end
    
    %%%
    X = round(X);
    Y = round(Y);
    %%%
    
    clear dat uxy pxy mxy mx nx my ny;
    dat = [X;Y];
    uxy = diff(dat,1,2);
    uxy = [[1;1],uxy];
    pxy = union(find(uxy(1,:)~=0),find(uxy(2,:)~=0));
    dat = dat(:,pxy);
    integ=M0(yxz(1)*(dat(1,:)-1) + dat(2,:));
    integ=integ(integ>0);
    norm = length(integ);
    rdat(nRho) = sum(integ)/norm;
    
    if dispFlag,
        H = plot(dat(1,:),dat(2,:),'y-');
        if dispFlagC,
            for nrn = 1:length(dat)
                H = plot(dat(1,nrn),dat(2,nrn),'m.','MarkerSize',12);
                drawnow;
                delete(H);
            end
        end
        drawnow;
    end
end

% rdat = rdat/max(rdat);
xcoord = dat(1,:);
ycoord = dat(2,:);

if dispFlag,
    h2 = figure(101); clf; hold on;
    %     set(h2,'position',[10 100 400 300]);
    subplot(121); plot(rdat);axis tight; title('linear');
    subplot(122); plot(log(rdat));axis tight; title('logarithmic');
    %     plot(M0(round(xavg)+1,round(yavg)+1:end),'b','linewidth',2);
end



