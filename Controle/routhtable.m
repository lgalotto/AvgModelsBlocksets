function t = routhtable(r)
% Retorna a tabela de Routh-Hurwitz, dado um polin�mio num�rico ou simb�lico
% na entrada r.
%
% Exemplos: 
% t = eval(routhtable([1 2 1])) % tabela para s^2 + 2s + 1 = 0
%
% syms k; t2 = routhtable([1 2 k]) % tabela para s^2 + 2s + k = 0
%

%The Routh-Hurwitz stability criterion is a necessary (and frequently
%sufficient) method to establish the stability of a single-input,
%single-output (SISO), linear time invariant (LTI) control system. 
%More generally, given a polynomial, some calculations using only the 
%coefficients of that polynomial can lead us to the conclusion that it
%is not stable.
%in this program you must give your system coefficents and the
%Routh-Hurwitz table would be shown

% Based on:
%   Farzad Sagharchi ,Iran
%   2007/11/12
% 
% Modified: 2015-11,  LGJ

m = length(r);
n = round(m/2);
q = 1;
k = 0;

% separar pares dos impares
for p = 1:length(r) 
    if rem(p,2) == 0
        c_even(k) = r(p); 
    else
        c_odd(q) = r(p); 

        k = k+1;
        q = q+1;
    end
end
a=sym(zeros(m,n)); % inicializando a tabela de routh, permitindo symbolic

if m/2 ~= round(m/2)
    c_even(n)=0;
end
a(1,:) = c_odd;
a(2,:) = c_even;
if a(2,1)==0
    a(2,1)=0.01;
end

for i=3:m
    for j=1:n-1
        x=a(i-1,1);
        if x==0
            x=0.01;
        end

        a(i,j)=((a(i-1,1)*a(i-2,j+1))-(a(i-2,1)*a(i-1,j+1)))/x;

    end
    if a(i,:)==0
        order=(m-i+1);
        c=0;
        d=1;
        for j=1:n-1
            a(i,j)=(order-c)*(a(i-1,d));
            d=d+1;
            c=c+2;
        end
    end
    if a(i,1)==0
        a(i,1)=0.01;
    end
end
% Right_poles=0;
% for i=1:m-1
%     if sign(a(i,1))*sign(a(i+1,1))==-1
%         Right_poles=Right_poles+1;
%     end
% end
% fprintf('\n Number Of Right Poles =%2.0f\n',Right_poles)

% fprintf('\n Routh-Hurwitz Table:\n')
t = simplify(a);


% 
% reply = input('Do You Need Roots of System? Y/N ', 's');
% if reply=='y'||reply=='Y'
%     ROOTS=roots(r);
%     fprintf('\n Given Polynomials Coefficents Roots :\n')
%     ROOTS
% else
% end




