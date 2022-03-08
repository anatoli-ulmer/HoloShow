function [S, C, ang] = calcmie( r, ns, nm, lambda, nang, varargin )
%CALCMIE Calculates the amplitude scattering matrix and cross sections for
%   the scattering of electromagnetic radiation by a single (stratified)
%   sphere.
%
%   [S,C,ANG] = CALCMIE(R,NS,NM,LAMBDA,NANG) calculates the amplitude
%   scattering matrix S and cross sections C for the scattering of a
%   monochromatic electromagnetic wave with vacuum wavelength LAMBDA by a
%   sphere with radius R and (complex) refractive index NS. NM is the
%   refractive index of the surrounding medium.
%
%   For a stratified sphere R and NS are given as one-dimensional lists.
%   The radii and refractive index lists have to be the same size, the
%   radii have to be sorted from smallest to largest and the corresponding
%   refractive indices have to be in the same order.
%
%   VARARGIN can take the following keywords:
%    'ConvergenceFactor'    : CONV - Alters the convergence criteria,
%       M=M*CONV (default CONV=1).
%
%   The amplitude scattering matrix S is calculated for a total of NANG
%   scattering angles between 0 and 180 degrees and has dimension 2x2xNANG.
%   The considered angles are returned in vector ANG (in degrees).
%
%   The cross sections (extinction, scattering and absorption) and
%   wavenumber k are returned in the structure matrix C.
%
%   The calculation is based on the book of Bohren and Huffman [1]:
%   [1] Bohren, C. F. and Huffman, D. R., Absorption and scattering of
%       light by small particles, Wiley-Interscience, New York, 1998.
%
%
%   SYNTAX:
%
%   [S, C, ANG] = calcmie( r, ns, nm, lambda, nang )
%
%   See also:
%   CALCMIE_NF
%
%   Copyright 2012 Jan SchÃ¤fer, Institut fÃ¼r Lasertechnologien (ILM)
%   Author: Jan SchÃ¤fer (jan.schaefer@ilm.uni-ulm.de)
%   Organization: Institut fÃ¼r Lasertechnologien in der Medizin und
%       Meßtechnik an der UniversitÃ¤t Ulm (http://www.ilm-ulm.de)
%
%Addition:
% Edited by Julian Zimmermann (j.zimmermann@tu-berlin.de ) on 03|16|16:
% * Changed the output of the routine to give the
%   squared S Values. -> MatScat now returns the same values as the
%   Maetzler Mie routine (http://omlc.org/software/mie) -> Line 85 - 87
%
%Addition:
% Edited by Anatoli Ulmer (anatoli.ulmer@gmail.com ) on 2022-01-12:
% Added parameter for maximum angle -> Line 63
% changed input of function asmmie(an, bn, nang, k, maxang) -> Line 94
% Removed previous addition from Julian Zimmermann


%% Initialize Parameters
addpath(genpath(userpath))

p = inputParser;
p.addParameter('ConvergenceFactor', 1, @isscalar);
p.addParameter('MaximumAngle', 180, @isscalar);
p.parse(varargin{:});

conv = p.Results.ConvergenceFactor;
maxang = p.Results.MaximumAngle;

if ~exist('nang', 'var')
  nang = 180;
end %if ~exist('nang', 'var')

strtfd = false;
if numel(r) > 1
  strtfd = true;
end %if numel(r) > 1

if numel(r) ~= numel(ns)
  error('Radius list r and refractive index list NS have to be same size!');
end %if numel(r) ~= numel(n)

k = 2*pi/lambda*nm;     % wavenumber in medium nm
x = k*r;                % size parameter
m = ns/nm;              % relative refractive index

%% Calculate expansion coefficients
if strtfd
  [an, bn] = expcoeff_mie_strat(x, m, conv);
else %strtfd
  [an, bn] = expcoeff_mie(x, m, conv);
end %strtfd

%% Calculate amplitude scattering matrix
[S, C, ang] = asmmie(an, bn, nang, k, maxang);

%% Compute the square and normalize it
% S(1,1,:) = real(conj(S(1,1,:)).*S(1,1,:))/(pi*x^2);
% S(2,2,:) = real(conj(S(2,2,:)).*S(2,2,:))/(pi*x^2);

%% Calculate the angle axis
ang = ang/pi*180;

end

