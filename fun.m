function [E_h,C,plt] = fun(TimeEpSec,S,AngleX,AngleY,AngleZ,AngleAlb,Q_comp_c,Q_comp_h,model,Input)

X(1) = Input.plus_x_left;
X(2) = Input.plus_x_right;
X(3) = Input.plus_x_down;
X(4) = Input.plus_x_up;
X(5) = Input.minus_x_left;
X(6) = Input.minus_x_right;
X(7) = Input.minus_x_down;
X(8) = Input.minus_x_up;
X(9) = Input.plus_y_left;
X(10) = Input.plus_y_right;
X(11) = Input.plus_y_down;
X(12) = Input.plus_y_up;

[inputs_h,inputs_c] = lumped_v2(TimeEpSec,S,AngleX,AngleY,AngleZ,AngleAlb,Q_comp_c,Q_comp_h,X);

q_int_h = [10*2 8*2 12*2 15*2 10 20 100];
%q_int_c = [5*2 0 5*2 0 4 6 0];
q_int_c = [0 0 0 0 0 0 0];

results_h = fea_solver(model,inputs_h,q_int_h,X);
results_c = fea_solver(model,inputs_c,q_int_c,X);

T_bat_h = results_h.data(:,6);
T_prop_h = results_h.data(:,7);
T_bat_c = results_c.data(:,6);
T_prop_c = results_c.data(:,7);

T_bat_max = max(T_bat_h);
T_prop_max = max(T_prop_h);
T_bat_min = min(T_bat_c);
T_prop_min = min(T_prop_c);

Q_heater = results_c.data(:,5);
Time = results_c.data(:,1);
integ = zeros(1,length(Time));

for i=1:length(Time)-1
    integ(i) = (Time(i+1)-Time(i))*(Q_heater(i+1)+Q_heater(i))/2;
end

E_h = sum(integ);

if T_bat_max > 310
    C = T_bat_max - 310;
elseif T_prop_max < 313
    C = T_prop_max - 313;
elseif T_bat_min < 283
    C = 283 - T_bat_min;
elseif T_prop_min < 278
    C = 278 - T_prop_min;
else
    C = -1;
end

plt = [results_h results_c];

end