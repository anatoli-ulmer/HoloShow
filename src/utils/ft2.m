function F = ft2(f)

F = fftshift(fft2(fftshift(f)));