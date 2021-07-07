function F = ift2(f)

F = ifftshift(ifft2(ifftshift(f)));
