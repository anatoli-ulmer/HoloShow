function hologram = propagate(hologram, prop_l, lambda, CCD_S_DIST, meth)

% SYNTAX:
%   hologram = propagate(hologram, prop_l)
%   hologram = propagate(hologram, prop_l, method)
%
% DESCRIPTION:
%   Propagates the input 'hologram' to the distance 'prop_l'. Default
%   method is the plane wave propagator. Use optional parameter method =
%   'fresnel' to use the Fresnel Rayleigh propagator.
if nargin < 5
    if nargin < 4
        if nargin < 3
            lambda = 1.053e-9;
        end
        CCD_S_DIST = 0.735;
    end
    meth='plane-wave';
end

[Xrange, Yrange] = size(hologram);
PX_SIZE = 75e-6;
H_center_q=Xrange/2+1;
H_center_p=Yrange/2+1;
[p,q] = meshgrid(1:Xrange, 1:Yrange);

switch meth
    case 'plane-wave'
        tempPhase=(prop_l*2*pi/(lambda*1e9))*(1-((PX_SIZE/CCD_S_DIST)^2)*((q-H_center_q).^2+ (p-H_center_p).^2)).^(1/2); % plane wave propagation
    case 'fresnel'
        tempPhase=-prop_l*pi*(lambda*1e9)*(PX_SIZE/CCD_S_DIST)^2*((q-H_center_q).^2+ (p-H_center_p).^2); % Fresnel Rayleigh propagator
end

hologram = hologram.*exp(1i*tempPhase);