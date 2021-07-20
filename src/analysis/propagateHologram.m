function hologram = propagateHologram(hologram, prop_l, lambda, CCD_S_DIST, cut_center, meth)

% SYNTAX:
%   hologram = propagate(hologram, prop_l)
%   hologram = propagate(hologram, prop_l, wavelength, CCD_DIST, method)
%
% DESCRIPTION:
%   Propagates the input 'hologram' to the distance 'prop_l'. Default
%   method is the plane wave propagator. Use optional parameter method =
%   'fresnel' to use the Fresnel Rayleigh propagator.
%   This is the version for holoShow v3

if nargin < 6
    if nargin < 5
        if nargin < 4
            if nargin < 3
                lambda = 1.053e-9;
            end
            CCD_S_DIST = 0.735;
        end
        cut_center = 0;
    end
    meth='plane-wave';
end

[Xrange, Yrange] = size(hologram);
PX_SIZE = 75e-6;
H_center_q=Xrange/2+1;
H_center_p=Yrange/2+1;
[p,q] = meshgrid(1:Yrange, 1:Xrange);

switch meth
    case 'plane-wave'
        tempPhase=(prop_l*2*pi/(lambda*1e9))*(1-((PX_SIZE/CCD_S_DIST)^2)*((q-H_center_q).^2+ (p-H_center_p).^2)).^(1/2); % plane wave propagation
    case 'fresnel'
        tempPhase=-prop_l*pi*(lambda*1e9)*(PX_SIZE/CCD_S_DIST)^2*((q-H_center_q).^2+ (p-H_center_p).^2); % Fresnel Rayleigh propagator
end

if cut_center > 0
    c = size(hologram)/2;
    [xx,yy] = meshgrid((1:size(hologram,2)) - c(2), (1:size(hologram,1)) - c(1));
    hologram = ft2(ift2(hologram).*(xx.^2 + yy.^2 > cut_center.^2));
end

hologram = hologram.*exp(1i*tempPhase);
