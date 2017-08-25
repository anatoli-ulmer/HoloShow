function [S2, ang] = mie_prof(r, lambda, material, precision)

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

e = n_matrix(:,1);
E_photon = 6.6e-34*3e8/1.6e-19/lambda; % [eV]
[~, ind] = min(abs(e-E_photon));

[S, C, ang] = calcmie(r, (1-n_matrix(ind,2)) - 1i*n_matrix(ind,3) , 1, lambda, precision);
S1 = squeeze(S(1,1,:));
S2 = squeeze(S(2,2,:));
