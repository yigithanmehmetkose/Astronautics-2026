function F = F_rect_to_rect(x1,x2,y1,y2,u1,u2,v1,v2)

x = [x1 x2];
y = [y1 y2];
ksi = [u1 u2];
eta = [v1 v2];

A1 = (y2-y1)*(x2-x1);

sum = 0;

for l=1:2
    for k=1:2
        for j=1:2
            for i=1:2
                xi = x(i);
                yj = y(j);
                etak = eta(k);
                ksil = ksi(l);
                C = sqrt(xi^2+ksil^2);
                D = (yj-etak)/C;
                B = (yj-etak)*C*atan(D)-C^2/4*(1-D^2)*log(C^2*(1+D^2));
                sum = sum + ((-1)^(i+j+k+l)*B);
            end
        end
    end
end

F = 1/(2*pi*A1)*sum;

end
