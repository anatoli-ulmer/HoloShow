function output = part_and_scale (data, logSwitch, partSwitch)

switch partSwitch
    case 'real'
        output = real(data);
    case 'imag'
        output = imag(data);
    case 'abs'
        output = abs(data);
    case 'angle'
        output = angle(data);
end

if logSwitch
    output = log10(abs(output));
end
