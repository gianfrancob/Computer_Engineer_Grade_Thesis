% gf2_128 = gf(2,8);
x = gf([0 0 0 0 1 1 1 1], 8);
y = gf([0 0 0 0 1 0 0 0], 8);
z = conv(x,y);