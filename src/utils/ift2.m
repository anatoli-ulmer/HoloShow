function F = ift2(f)

F = fftshift(ifft2(fftshift(f)));