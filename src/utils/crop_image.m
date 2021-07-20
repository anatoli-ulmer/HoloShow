function image = crop_image(image, crop_factor)

[p3, p4] = size(image);

i3_start = floor(p3/2*(1 - 1/crop_factor)) + 1;
i3_stop = floor(p3/2*(1 + 1/crop_factor));

i4_start = floor(p4/2*(1 - 1/crop_factor)) + 1;
i4_stop = floor(p4/2*(1 + 1/crop_factor));

image = image(i3_start:i3_stop, i4_start:i4_stop);
