function cost = pidfeedbacktest(x,Gs,updesejado,tedesejado)

PID = zpk([x(2) x(3)],0,x(1));

if x(2) > 0 || x(3) > 0 || x(1) < 0 % restricoes
    cost = 1e9;
else
    Ts = feedback(PID*Gs,1);
    resp = stepinfo(Ts);
    cost = abs(resp.SettlingTime - tedesejado)./tedesejado + abs(resp.Overshoot - updesejado) + sum(abs(x));
end