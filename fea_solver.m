function results = fea_solver(model,inputs,q_int,X)
%% Introduction

plus_x_left = X(1);
plus_x_right = X(2);
plus_x_down = X(3);
plus_x_up = X(4);
minus_x_left = X(5);
minus_x_right = X(6);
minus_x_down = X(7);
minus_x_up = X(8);
plus_y_left = X(9);
plus_y_right = X(10);
plus_y_down = X(11);
plus_y_up = X(12);

q_r_PlusX = inputs(:,1);
q_r_MinusX = inputs(:,2);
q_r_PlusY = inputs(:,3);
q_SP_f = inputs(:,4);
q_PlusSP = inputs(:,5);
q_MinusSP = inputs(:,6);
q_mli_PlusX = inputs(:,7);
q_mli_MinusX = inputs(:,8);
q_mli_PlusY = inputs(:,9);
q_mli_PlusZ = inputs(:,10);
q_mli_MinusZ = inputs(:,11);
Sun_MinusY = inputs(:,12);

N = length(q_r_PlusX);

%% Geometry

model.component('comp1').geom('geom1').feature('wp1').geom.feature('dist3').set('distance', plus_x_left);
model.component('comp1').geom('geom1').feature('wp1').geom.run('dist3');

model.component('comp1').geom('geom1').feature('wp1').geom.feature('dist4').set('distance', plus_x_right);
model.component('comp1').geom('geom1').feature('wp1').geom.run('dist4');

model.component('comp1').geom('geom1').feature('wp1').geom.feature('dist5').set('distance', plus_x_down);
model.component('comp1').geom('geom1').feature('wp1').geom.run('dist5');

model.component('comp1').geom('geom1').feature('wp1').geom.feature('dist6').set('distance', plus_x_up);
model.component('comp1').geom('geom1').feature('wp1').geom.run('dist6');
model.component('comp1').geom('geom1').run('wp1');

model.component('comp1').geom('geom1').feature('wp2').geom.feature('dist3').set('distance', minus_x_left);
model.component('comp1').geom('geom1').feature('wp2').geom.run('dist3');

model.component('comp1').geom('geom1').feature('wp2').geom.feature('dist4').set('distance', minus_x_right);
model.component('comp1').geom('geom1').feature('wp2').geom.run('dist4');

model.component('comp1').geom('geom1').feature('wp2').geom.feature('dist5').set('distance', minus_x_down);
model.component('comp1').geom('geom1').feature('wp2').geom.run('dist5');

model.component('comp1').geom('geom1').feature('wp2').geom.feature('dist6').set('distance', minus_x_up);
model.component('comp1').geom('geom1').feature('wp2').geom.run('dist6');
model.component('comp1').geom('geom1').run('wp2');

model.component('comp1').geom('geom1').feature('wp3').geom.feature('dist3').set('distance', plus_y_left);
model.component('comp1').geom('geom1').feature('wp3').geom.run('dist3');

model.component('comp1').geom('geom1').feature('wp3').geom.feature('dist4').set('distance', plus_y_right);
model.component('comp1').geom('geom1').feature('wp3').geom.run('dist4');

model.component('comp1').geom('geom1').feature('wp3').geom.feature('dist5').set('distance', plus_y_down);
model.component('comp1').geom('geom1').feature('wp3').geom.run('dist5');

model.component('comp1').geom('geom1').feature('wp3').geom.feature('dist6').set('distance', plus_y_up);
model.component('comp1').geom('geom1').feature('wp3').geom.run('dist6');
model.component('comp1').geom('geom1').run('wp3');

model.component('comp1').geom('geom1').run;

%% External heat fluxes

for t=1:N
    model.func('int2').setIndex('table', (t-1)*60, t-1, 0);
    model.func('int3').setIndex('table', (t-1)*60, t-1, 0);
    model.func('int4').setIndex('table', (t-1)*60, t-1, 0);
    model.func('int5').setIndex('table', (t-1)*60, t-1, 0);
    model.func('int6').setIndex('table', (t-1)*60, t-1, 0);
    model.func('int7').setIndex('table', (t-1)*60, t-1, 0);
    model.func('int8').setIndex('table', (t-1)*60, t-1, 0);
    model.func('int9').setIndex('table', (t-1)*60, t-1, 0);
    model.func('int10').setIndex('table', (t-1)*60, t-1, 0);
    model.func('int11').setIndex('table', (t-1)*60, t-1, 0);
    model.func('int12').setIndex('table', (t-1)*60, t-1, 0);
    model.func('int13').setIndex('table', (t-1)*60, t-1, 0);

    model.func('int2').setIndex('table', q_r_PlusX(t), t-1, 1);
    model.func('int3').setIndex('table', q_r_MinusX(t), t-1, 1);
    model.func('int4').setIndex('table', q_r_PlusY(t), t-1, 1);
    model.func('int5').setIndex('table', q_mli_PlusZ(t), t-1, 1);
    model.func('int6').setIndex('table', q_mli_MinusZ(t), t-1, 1);
    model.func('int7').setIndex('table', q_PlusSP(t), t-1, 1);
    model.func('int8').setIndex('table', q_MinusSP(t), t-1, 1);
    model.func('int9').setIndex('table', q_mli_PlusX(t), t-1, 1);
    model.func('int10').setIndex('table', q_mli_MinusX(t), t-1, 1);
    model.func('int11').setIndex('table', q_mli_PlusY(t), t-1, 1);
    model.func('int12').setIndex('table', q_SP_f(t), t-1, 1);
    model.func('int13').setIndex('table', Sun_MinusY(t), t-1, 1);
end

%% Internal heat generation

Period = 12;
t_payload = 5;
Period_payload = 19;
N_payload = 5;

model.component('comp1').physics('ht').feature('hs1').set('P0', q_int(1));
model.component('comp1').physics('ht').feature('hs2').set('P0', q_int(2));
model.component('comp1').physics('ht').feature('hs3').set('P0', q_int(3));
model.component('comp1').physics('ht').feature('hs4').set('P0', q_int(4));
model.component('comp1').physics('ht').feature('hs5').set('P0', q_int(5));
model.component('comp1').physics('ht').feature('hs6').set('P0', q_int(6));

if q_int(7)==100
    model.component('comp1').physics('ht').feature('hs8').set('P0', '(120+int1(t))*(1/0.9-1)');
else
    model.component('comp1').physics('ht').feature('hs8').set('P0', '(on_off_heater(bnd2)+on_off_heater(bnd3))*(1/0.9-1)');
    model.component('comp1').probe('var1').set('expr', 'battery_heat_dissipation((on_off_heater(bnd2)+on_off_heater(bnd3))*(1/0.9),bnd1,int13(t),1)');
end

for i=1:N_payload*Period
    for j=1:Period_payload
        t = (i-1)*Period_payload + j;
        model.func('int1').setIndex('table', (t-1)*60, t-1, 0);
        if j <= t_payload
            model.func('int1').setIndex('table', q_int(7), t-1, 1);
        else
            model.func('int1').setIndex('table', 0, t-1, 1);
        end
    end
end

%% Mesh and solution

model.component('comp1').mesh('mesh1').run;
model.sol('sol1').runAll;

%% Postprocessing

results = mphtable(model,'tbl1');

end