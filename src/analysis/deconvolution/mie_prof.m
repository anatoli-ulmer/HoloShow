function [S2, ang] = mie_prof(r, wavelength, material, precision, maxang)

switch material
    case 'Xe'
        n_matrix = dlmread('index_Xe.txt');
    case 'Kr'
        n_matrix = dlmread('index_Kr.txt');
    case 'Ag'
        n_matrix = dlmread('index_Ag.txt');
    case 'Su'
        n_matrix = dlmread('index_Sucrose_C12H22O11.txt');
end

elementary_charge = 1.6022e-19;
planck_constant = 6.6261e-34;
speed_of_light = 299792458;

e = n_matrix(:,1);
E_photon = planck_constant*speed_of_light/elementary_charge/wavelength; % [eV]
[~, ind] = min(abs(e-E_photon));

[S, ~, ang] = calcmie(r, (1-n_matrix(ind,2)) - 1i*n_matrix(ind,3) , 1, wavelength, precision, 'MaximumAngle', maxang);
% S1 = squeeze(S(1,1,:));
S2 = squeeze(S(2,2,:));
