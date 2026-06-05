%% Introduction
%localhost magnetron

clc
clear all
close all

load('results.mat')

Currentdir = pwd;
cd('C:\Program Files\COMSOL\COMSOL61\Multiphysics\bin\win64');
system('comsolmphserver.exe &');
cd(Currentdir);
Currentdir = pwd;
cd('C:\Program Files\COMSOL\COMSOL61\Multiphysics\mli');
mphstart(2036);
cd(Currentdir);

Period = 12;
t_payload = 5;
Period_payload = 19;
N_payload = 5;

plus_x_left = 0.01;
plus_x_right = 0.48;
plus_x_down = 0.161;
plus_x_up = 0.341;
minus_x_left = 0.01;
minus_x_right = 0.48;
minus_x_down = 0.161;
minus_x_up = 0.341;
plus_y_left = 0.09;
plus_y_right = 0.41;
plus_y_down = 0.161;
plus_y_up = 0.341;

q_r_PlusX = results_h(:,1);
q_r_MinusX = results_h(:,2);
q_r_PlusY = results_h(:,3);
Sun_MinusY = results_h(:,4);
q_PlusSP = results_h(:,5);
q_MinusSP = results_h(:,6);
q_mli_PlusX = results_h(:,7);
q_mli_MinusX = results_h(:,8);
q_mli_PlusY = results_h(:,9);
q_mli_PlusZ = results_h(:,10);
q_mli_MinusZ = results_h(:,11);

N = length(q_mli_MinusZ);

%% Model & Physics

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');
model.modelPath('C:\Users\BUSTLab\Desktop\YIGITHAN\fea');
model.component.create('comp1', true);
model.component('comp1').geom.create('geom1', 3);
model.component('comp1').mesh.create('mesh1');

model.component('comp1').physics.create('ht', 'HeatTransfer', 'geom1');
model.component('comp1').physics.create('rad', 'SurfaceToSurfaceRadiation', 'geom1');
model.component('comp1').physics.create('ev', 'Events', 'geom1');

model.component('comp1').multiphysics.create('htrad1', 'HeatTransferWithSurfaceToSurfaceRadiation', 2);
model.component('comp1').multiphysics('htrad1').set('Heat_physics', 'ht');
model.component('comp1').multiphysics('htrad1').set('Rad_physics', 'rad');
model.component('comp1').multiphysics('htrad1').selection.all;

model.study.create('std1');
model.study('std1').create('time', 'Transient');
model.study('std1').feature('time').setSolveFor('/physics/ht', true);
model.study('std1').feature('time').setSolveFor('/physics/rad', true);
model.study('std1').feature('time').setSolveFor('/physics/ev', true);
model.study('std1').feature('time').setSolveFor('/multiphysics/htrad1', true);

%% Geometry

% Import
model.component('comp1').geom('geom1').create('imp1', 'Import');
model.component('comp1').geom('geom1').feature('imp1').set('filename', 'C:\Users\BUSTLab\Desktop\YIGITHAN\fea\Assembly1.stp');
model.component('comp1').geom('geom1').run('imp1');
model.component('comp1').geom('geom1').run('fin');

% Create radiator on +X panel
model.component('comp1').geom('geom1').create('wp1', 'WorkPlane');
model.component('comp1').geom('geom1').feature('wp1').set('unite', true);
model.component('comp1').geom('geom1').feature('wp1').set('planetype', 'faceparallel');
model.component('comp1').geom('geom1').feature('wp1').selection('face').set('imp1.panel_Solid1(6)', 3);
model.component('comp1').geom('geom1').run('wp1');

model.component('comp1').geom('geom1').feature('wp1').geom.create('r1', 'Rectangle');
model.component('comp1').geom('geom1').feature('wp1').geom.feature('r1').set('size', [0.5 0.522]);
model.component('comp1').geom('geom1').feature('wp1').geom.feature('r1').set('pos', [-0.25 -0.261]);
model.component('comp1').geom('geom1').feature('wp1').geom.useConstrDim(true);
model.component('comp1').geom('geom1').feature('wp1').geom.run('r1');

model.component('comp1').geom('geom1').feature('wp1').geom.create('dist1', 'Distance');
model.component('comp1').geom('geom1').feature('wp1').geom.feature('dist1').selection('entity1').set('r1', 4);
model.component('comp1').geom('geom1').feature('wp1').geom.feature('dist1').selection('entity2').set('r1', 2);
model.component('comp1').geom('geom1').feature('wp1').geom.feature('dist1').set('distance', 0.5);
model.component('comp1').geom('geom1').feature('wp1').geom.run('dist1');

model.component('comp1').geom('geom1').feature('wp1').geom.create('dist2', 'Distance');
model.component('comp1').geom('geom1').feature('wp1').geom.feature('dist2').selection('entity1').set('r1', 3);
model.component('comp1').geom('geom1').feature('wp1').geom.feature('dist2').selection('entity2').set('r1', 1);
model.component('comp1').geom('geom1').feature('wp1').geom.feature('dist2').set('distance', 0.522);
model.component('comp1').geom('geom1').feature('wp1').geom.run('dist2');

model.component('comp1').geom('geom1').feature('wp1').geom.create('r2', 'Rectangle');
model.component('comp1').geom('geom1').feature('wp1').geom.feature('r2').set('size', [0.32 0.18]);
model.component('comp1').geom('geom1').feature('wp1').geom.feature('r2').set('pos', [-0.16 -0.1]);
model.component('comp1').geom('geom1').feature('wp1').geom.run('r2');

model.component('comp1').geom('geom1').feature('wp1').geom.create('dist3', 'Distance');
model.component('comp1').geom('geom1').feature('wp1').geom.feature('dist3').selection('entity1').set('r2', 4);
model.component('comp1').geom('geom1').feature('wp1').geom.feature('dist3').selection('entity2').set('r1', 4);
model.component('comp1').geom('geom1').feature('wp1').geom.feature('dist3').set('distance', plus_x_left);
model.component('comp1').geom('geom1').feature('wp1').geom.run('dist3');

model.component('comp1').geom('geom1').feature('wp1').geom.create('dist4', 'Distance');
model.component('comp1').geom('geom1').feature('wp1').geom.feature('dist4').selection('entity1').set('r2', 2);
model.component('comp1').geom('geom1').feature('wp1').geom.feature('dist4').selection('entity2').set('r1', 4);
model.component('comp1').geom('geom1').feature('wp1').geom.feature('dist4').set('distance', plus_x_right);
model.component('comp1').geom('geom1').feature('wp1').geom.run('dist4');

model.component('comp1').geom('geom1').feature('wp1').geom.create('dist5', 'Distance');
model.component('comp1').geom('geom1').feature('wp1').geom.feature('dist5').selection('entity1').set('r2', 1);
model.component('comp1').geom('geom1').feature('wp1').geom.feature('dist5').selection('entity2').set('r1', 1);
model.component('comp1').geom('geom1').feature('wp1').geom.feature('dist5').set('distance', plus_x_down);
model.component('comp1').geom('geom1').feature('wp1').geom.run('dist5');

model.component('comp1').geom('geom1').feature('wp1').geom.create('dist6', 'Distance');
model.component('comp1').geom('geom1').feature('wp1').geom.feature('dist6').selection('entity1').set('r2', 3);
model.component('comp1').geom('geom1').feature('wp1').geom.feature('dist6').selection('entity2').set('r1', 1);
model.component('comp1').geom('geom1').feature('wp1').geom.feature('dist6').set('distance', plus_x_up);
model.component('comp1').geom('geom1').feature('wp1').geom.run('dist6');
model.component('comp1').geom('geom1').run('wp1');

model.component('comp1').geom('geom1').feature.create('ext1', 'Extrude');
model.component('comp1').geom('geom1').feature('ext1').set('workplane', 'wp1');
model.component('comp1').geom('geom1').feature('ext1').selection('input').set({'wp1'});
model.component('comp1').geom('geom1').feature('ext1').set('extrudefrom', 'faces');
model.component('comp1').geom('geom1').feature('ext1').selection('inputface').set('wp1', 1);
model.component('comp1').geom('geom1').feature('ext1').setIndex('distance', 0.001, 0);
model.component('comp1').geom('geom1').run('ext1');

model.component('comp1').geom('geom1').feature.create('ext2', 'Extrude');
model.component('comp1').geom('geom1').feature('ext2').set('extrudefrom', 'faces');
model.component('comp1').geom('geom1').feature('ext2').selection('inputface').set('ext1', 8);
model.component('comp1').geom('geom1').feature('ext2').setIndex('distance', 0.002, 0);
model.component('comp1').geom('geom1').run('ext2');

% Create radiator on -X panel
model.component('comp1').geom('geom1').run('ext2');
model.component('comp1').geom('geom1').create('wp2', 'WorkPlane');
model.component('comp1').geom('geom1').feature('wp2').set('unite', true);
model.component('comp1').geom('geom1').feature('wp2').set('planetype', 'faceparallel');
model.component('comp1').geom('geom1').feature('wp2').selection('face').set('imp1.panel_Solid1(5)', 4);
model.component('comp1').geom('geom1').run('wp2');

model.component('comp1').geom('geom1').feature('wp2').geom.create('r1', 'Rectangle');
model.component('comp1').geom('geom1').feature('wp2').geom.feature('r1').set('size', [0.5 0.522]);
model.component('comp1').geom('geom1').feature('wp2').geom.feature('r1').set('pos', [-0.25 -0.261]);
model.component('comp1').geom('geom1').feature('wp2').geom.run('r1');
model.component('comp1').geom('geom1').feature('wp2').geom.useConstrDim(true);

model.component('comp1').geom('geom1').feature('wp2').geom.create('dist1', 'Distance');
model.component('comp1').geom('geom1').feature('wp2').geom.feature('dist1').selection('entity1').set('r1', 2);
model.component('comp1').geom('geom1').feature('wp2').geom.feature('dist1').selection('entity2').set('r1', 4);
model.component('comp1').geom('geom1').feature('wp2').geom.feature('dist1').set('distance', 0.5);
model.component('comp1').geom('geom1').feature('wp2').geom.run('dist1');

model.component('comp1').geom('geom1').feature('wp2').geom.create('dist2', 'Distance');
model.component('comp1').geom('geom1').feature('wp2').geom.feature('dist2').selection('entity1').set('r1', 3);
model.component('comp1').geom('geom1').feature('wp2').geom.feature('dist2').selection('entity2').set('r1', 1);
model.component('comp1').geom('geom1').feature('wp2').geom.feature('dist2').set('distance', 0.522);
model.component('comp1').geom('geom1').feature('wp2').geom.run('dist2');

model.component('comp1').geom('geom1').feature('wp2').geom.create('r2', 'Rectangle');
model.component('comp1').geom('geom1').feature('wp2').geom.feature('r2').set('size', [0.32 0.18]);
model.component('comp1').geom('geom1').feature('wp2').geom.feature('r2').set('pos', [-0.16 -0.08]);
model.component('comp1').geom('geom1').feature('wp2').geom.run('r2');

model.component('comp1').geom('geom1').feature('wp2').geom.create('dist3', 'Distance');
model.component('comp1').geom('geom1').feature('wp2').geom.feature('dist3').selection('entity1').set('r2', 4);
model.component('comp1').geom('geom1').feature('wp2').geom.feature('dist3').selection('entity2').set('r1', 4);
model.component('comp1').geom('geom1').feature('wp2').geom.feature('dist3').set('distance', minus_x_left);
model.component('comp1').geom('geom1').feature('wp2').geom.run('dist3');

model.component('comp1').geom('geom1').feature('wp2').geom.create('dist4', 'Distance');
model.component('comp1').geom('geom1').feature('wp2').geom.feature('dist4').selection('entity1').set('r2', 2);
model.component('comp1').geom('geom1').feature('wp2').geom.feature('dist4').selection('entity2').set('r1', 4);
model.component('comp1').geom('geom1').feature('wp2').geom.feature('dist4').set('distance', minus_x_right);
model.component('comp1').geom('geom1').feature('wp2').geom.run('dist4');

model.component('comp1').geom('geom1').feature('wp2').geom.create('dist5', 'Distance');
model.component('comp1').geom('geom1').feature('wp2').geom.feature('dist5').selection('entity1').set('r2', 1);
model.component('comp1').geom('geom1').feature('wp2').geom.feature('dist5').selection('entity2').set('r1', 1);
model.component('comp1').geom('geom1').feature('wp2').geom.feature('dist5').set('distance', minus_x_down);
model.component('comp1').geom('geom1').feature('wp2').geom.run('dist5');

model.component('comp1').geom('geom1').feature('wp2').geom.create('dist6', 'Distance');
model.component('comp1').geom('geom1').feature('wp2').geom.feature('dist6').selection('entity1').set('r2', 3);
model.component('comp1').geom('geom1').feature('wp2').geom.feature('dist6').selection('entity2').set('r1', 1);
model.component('comp1').geom('geom1').feature('wp2').geom.feature('dist6').set('distance', minus_x_up);
model.component('comp1').geom('geom1').feature('wp2').geom.run('dist6');
model.component('comp1').geom('geom1').run('wp2');

model.component('comp1').geom('geom1').feature.create('ext3', 'Extrude');
model.component('comp1').geom('geom1').feature('ext3').set('workplane', 'wp2');
model.component('comp1').geom('geom1').feature('ext3').selection('input').set({'wp2'});
model.component('comp1').geom('geom1').feature('ext3').set('extrudefrom', 'faces');
model.component('comp1').geom('geom1').feature('ext3').selection('inputface').set('wp2', 1);
model.component('comp1').geom('geom1').feature('ext3').setIndex('distance', 0.001, 0);
model.component('comp1').geom('geom1').run('ext3');

model.component('comp1').geom('geom1').feature.create('ext4', 'Extrude');
model.component('comp1').geom('geom1').feature('ext4').set('extrudefrom', 'faces');
model.component('comp1').geom('geom1').feature('ext4').selection('inputface').set('ext3', 8);
model.component('comp1').geom('geom1').feature('ext4').setIndex('distance', 0.002, 0);
model.component('comp1').geom('geom1').run('ext4');

% Create radiator on +Y panel
model.component('comp1').geom('geom1').create('wp3', 'WorkPlane');
model.component('comp1').geom('geom1').feature('wp3').set('unite', true);
model.component('comp1').geom('geom1').feature('wp3').set('planetype', 'faceparallel');
model.component('comp1').geom('geom1').feature('wp3').selection('face').set('imp1.panel_Solid1(4)', 6);
model.component('comp1').geom('geom1').run('wp3');

model.component('comp1').geom('geom1').feature('wp3').geom.create('r1', 'Rectangle');
model.component('comp1').geom('geom1').feature('wp3').geom.feature('r1').set('size', [0.512 0.522]);
model.component('comp1').geom('geom1').feature('wp3').geom.feature('r1').set('pos', [-0.256 -0.261]);
model.component('comp1').geom('geom1').feature('wp3').geom.run('r1');
model.component('comp1').geom('geom1').feature('wp3').geom.useConstrDim(true);

model.component('comp1').geom('geom1').feature('wp3').geom.create('dist1', 'Distance');
model.component('comp1').geom('geom1').feature('wp3').geom.feature('dist1').selection('entity1').set('r1', 2);
model.component('comp1').geom('geom1').feature('wp3').geom.feature('dist1').selection('entity2').set('r1', 4);
model.component('comp1').geom('geom1').feature('wp3').geom.feature('dist1').set('distance', 0.512);
model.component('comp1').geom('geom1').feature('wp3').geom.run('dist1');

model.component('comp1').geom('geom1').feature('wp3').geom.create('dist2', 'Distance');
model.component('comp1').geom('geom1').feature('wp3').geom.feature('dist2').selection('entity1').set('r1', 1);
model.component('comp1').geom('geom1').feature('wp3').geom.feature('dist2').selection('entity2').set('r1', 3);
model.component('comp1').geom('geom1').feature('wp3').geom.feature('dist2').set('distance', 0.522);
model.component('comp1').geom('geom1').feature('wp3').geom.run('dist2');

model.component('comp1').geom('geom1').feature('wp3').geom.create('r2', 'Rectangle');
model.component('comp1').geom('geom1').feature('wp3').geom.feature('r2').set('size', [0.28 0.2]);
model.component('comp1').geom('geom1').feature('wp3').geom.feature('r2').set('pos', [-0.14 -0.1]);
model.component('comp1').geom('geom1').feature('wp3').geom.run('r2');

model.component('comp1').geom('geom1').feature('wp3').geom.create('dist3', 'Distance');
model.component('comp1').geom('geom1').feature('wp3').geom.feature('dist3').selection('entity1').set('r2', 4);
model.component('comp1').geom('geom1').feature('wp3').geom.feature('dist3').selection('entity2').set('r1', 4);
model.component('comp1').geom('geom1').feature('wp3').geom.feature('dist3').set('distance', plus_y_left);
model.component('comp1').geom('geom1').feature('wp3').geom.run('dist3');

model.component('comp1').geom('geom1').feature('wp3').geom.create('dist4', 'Distance');
model.component('comp1').geom('geom1').feature('wp3').geom.feature('dist4').selection('entity1').set('r2', 2);
model.component('comp1').geom('geom1').feature('wp3').geom.feature('dist4').selection('entity2').set('r1', 4);
model.component('comp1').geom('geom1').feature('wp3').geom.feature('dist4').set('distance', plus_y_right);
model.component('comp1').geom('geom1').feature('wp3').geom.run('dist4');

model.component('comp1').geom('geom1').feature('wp3').geom.create('dist5', 'Distance');
model.component('comp1').geom('geom1').feature('wp3').geom.feature('dist5').selection('entity1').set('r2', 1);
model.component('comp1').geom('geom1').feature('wp3').geom.feature('dist5').selection('entity2').set('r1', 1);
model.component('comp1').geom('geom1').feature('wp3').geom.feature('dist5').set('distance', plus_y_down);
model.component('comp1').geom('geom1').feature('wp3').geom.run('dist5');

model.component('comp1').geom('geom1').feature('wp3').geom.create('dist6', 'Distance');
model.component('comp1').geom('geom1').feature('wp3').geom.feature('dist6').selection('entity1').set('r2', 3);
model.component('comp1').geom('geom1').feature('wp3').geom.feature('dist6').selection('entity2').set('r1', 1);
model.component('comp1').geom('geom1').feature('wp3').geom.feature('dist6').set('distance', plus_y_up);
model.component('comp1').geom('geom1').feature('wp3').geom.run('dist6');
model.component('comp1').geom('geom1').run('wp3');

model.component('comp1').geom('geom1').feature.create('ext5', 'Extrude');
model.component('comp1').geom('geom1').feature('ext5').set('workplane', 'wp3');
model.component('comp1').geom('geom1').feature('ext5').selection('input').set({'wp3'});
model.component('comp1').geom('geom1').feature('ext5').set('extrudefrom', 'faces');
model.component('comp1').geom('geom1').feature('ext5').selection('inputface').set('wp3', 1);
model.component('comp1').geom('geom1').feature('ext5').setIndex('distance', 0.001, 0);
model.component('comp1').geom('geom1').run('ext5');

model.component('comp1').geom('geom1').feature.create('ext6', 'Extrude');
model.component('comp1').geom('geom1').feature('ext6').set('extrudefrom', 'faces');
model.component('comp1').geom('geom1').feature('ext6').selection('inputface').set('ext5', 5);
model.component('comp1').geom('geom1').feature('ext6').setIndex('distance', 0.002, 0);
model.component('comp1').geom('geom1').run('ext6');
model.component('comp1').geom('geom1').runPre('fin');
model.component('comp1').geom('geom1').run('fin');
model.component('comp1').geom('geom1').run;

mphgeom(model)

%% Material properties

model.component('comp1').material.create('mat1', 'Common');
model.component('comp1').material('mat1').selection.all;
model.component('comp1').material('mat1').label('aluminum');
model.component('comp1').material('mat1').propertyGroup('def').set('thermalconductivity', {'130'});
model.component('comp1').material('mat1').propertyGroup('def').set('density', {'2700'});
model.component('comp1').material('mat1').propertyGroup('def').set('heatcapacity', {'900'});

model.component('comp1').material.create('mat2', 'Common');
model.component('comp1').material('mat2').selection.set([15 16 17 18 21 22 23 24 25 26 27 28 29]);
model.component('comp1').material('mat2').label('components');
model.component('comp1').material('mat2').propertyGroup('def').set('thermalconductivity', {'130'});
model.component('comp1').material('mat2').propertyGroup('def').set('density', {'2500'});
model.component('comp1').material('mat2').propertyGroup('def').set('heatcapacity', {'900'});

model.component('comp1').material.create('mat3', 'Common');
model.component('comp1').material('mat3').label('propulsion');
model.component('comp1').material('mat3').selection.set([19]);
model.component('comp1').material('mat3').propertyGroup('def').set('thermalconductivity', {'5'});
model.component('comp1').material('mat3').propertyGroup('def').set('density', {'2640'});
model.component('comp1').material('mat3').propertyGroup('def').set('heatcapacity', {'1200'});

model.component('comp1').material.create('mat4', 'Common');
model.component('comp1').material('mat4').label('x_mli');
model.component('comp1').material('mat4').selection.set([4 6]);
model.component('comp1').material('mat4').propertyGroup('def').set('thermalconductivity', {'5' '5' '1e-5'});
model.component('comp1').material('mat4').propertyGroup('def').set('density', {'600'});
model.component('comp1').material('mat4').propertyGroup('def').set('heatcapacity', {'600'});

model.component('comp1').material.create('mat5', 'Common');
model.component('comp1').material('mat5').label('y_mli');
model.component('comp1').material('mat5').selection.set([31]);
model.component('comp1').material('mat5').propertyGroup('def').set('thermalconductivity', {'1e-5' '5' '5'});
model.component('comp1').material('mat5').propertyGroup('def').set('density', {'600'});
model.component('comp1').material('mat5').propertyGroup('def').set('heatcapacity', {'600'});

model.component('comp1').material.create('mat6', 'Common');
model.component('comp1').material('mat6').label('z_mli');
model.component('comp1').material('mat6').selection.set([5 12]);
model.component('comp1').material('mat6').propertyGroup('def').set('thermalconductivity', {'5' '1e-5' '5'});
model.component('comp1').material('mat6').propertyGroup('def').set('density', {'600'});
model.component('comp1').material('mat6').propertyGroup('def').set('heatcapacity', {'600'});

model.component('comp1').material.create('mat7', 'Common');
model.component('comp1').material('mat7').label('panels');
model.component('comp1').material('mat7').selection.set([7 8 10 11 30]);
model.component('comp1').material('mat7').propertyGroup('def').set('density', {'1600'});
model.component('comp1').material('mat7').selection.set([1 2 3 7 8 10 11 30]);
model.component('comp1').material('mat7').propertyGroup('def').set('thermalconductivity', {'130'});
model.component('comp1').material('mat7').propertyGroup('def').set('heatcapacity', {'900'});

%% Transponder Heat

model.func.create('int1', 'Interpolation');
model.func('int1').label('transponder');

for i=1:N_payload*Period
    for j=1:Period_payload
        t = (i-1)*Period_payload + j;
        model.func('int1').setIndex('table', (t-1)*60, t-1, 0);
        if j <= t_payload
            model.func('int1').setIndex('table', 140, t-1, 1);
        else
            model.func('int1').setIndex('table', 0, t-1, 1);
        end
    end
end

model.func('int1').setIndex('fununit', 'W', 0);
model.func('int1').setIndex('argunit', 's', 0);

%% Heat Sources

model.component('comp1').physics('ht').create('hs1', 'HeatSource', 3);
model.component('comp1').physics('ht').feature('hs1').selection.set([17 18]);
model.component('comp1').physics('ht').feature('hs1').set('heatSourceType', 'HeatRate');
model.component('comp1').physics('ht').feature('hs1').set('P0', 18);

model.component('comp1').physics('ht').create('hs2', 'HeatSource', 3);
model.component('comp1').physics('ht').feature('hs2').selection.set([15 16]);
model.component('comp1').physics('ht').feature('hs2').set('heatSourceType', 'HeatRate');
model.component('comp1').physics('ht').feature('hs2').set('P0', 10);

model.component('comp1').physics('ht').create('hs3', 'HeatSource', 3);
model.component('comp1').physics('ht').feature('hs3').selection.set([24 25]);
model.component('comp1').physics('ht').feature('hs3').set('heatSourceType', 'HeatRate');
model.component('comp1').physics('ht').feature('hs3').set('P0', 8);

model.component('comp1').physics('ht').create('hs4', 'HeatSource', 3);
model.component('comp1').physics('ht').feature('hs4').selection.set([22 23]);
model.component('comp1').physics('ht').feature('hs4').set('heatSourceType', 'HeatRate');
model.component('comp1').physics('ht').feature('hs4').set('P0', 20);

model.component('comp1').physics('ht').create('hs5', 'HeatSource', 3);
model.component('comp1').physics('ht').feature('hs5').selection.set([28]);
model.component('comp1').physics('ht').feature('hs5').set('heatSourceType', 'HeatRate');
model.component('comp1').physics('ht').feature('hs5').set('P0', 13);

model.component('comp1').physics('ht').create('hs6', 'HeatSource', 3);
model.component('comp1').physics('ht').feature('hs6').selection.set([29]);
model.component('comp1').physics('ht').feature('hs6').set('heatSourceType', 'HeatRate');
model.component('comp1').physics('ht').feature('hs6').set('P0', 13);

model.component('comp1').physics('ht').create('hs7', 'HeatSource', 3);
model.component('comp1').physics('ht').feature('hs7').label('Transponder');
model.component('comp1').physics('ht').feature('hs7').selection.set([21]);
model.component('comp1').physics('ht').feature('hs7').set('heatSourceType', 'HeatRate');
model.component('comp1').physics('ht').feature('hs7').set('P0', 'int1(t)');

model.component('comp1').physics('ht').create('hs8', 'HeatSource', 3);
model.component('comp1').physics('ht').feature('hs8').label('PCDU');
model.component('comp1').physics('ht').feature('hs8').selection.set([26]);
model.component('comp1').physics('ht').feature('hs8').set('heatSourceType', 'HeatRate');
model.component('comp1').physics('ht').feature('hs8').set('P0', '(138+int1(t))*(1/0.9-1)');

%% Diffuse Surfaces

model.component('comp1').physics('rad').feature('dsurf1').set('epsilon_rad_mat', 'userdef');
model.component('comp1').physics('rad').feature('dsurf1').set('epsilon_rad', 0.03);

model.component('comp1').physics('rad').create('dsurf2', 'DiffuseSurface', 2);
model.component('comp1').physics('rad').feature('dsurf2').set('epsilon_rad_mat', 'userdef');
model.component('comp1').physics('rad').feature('dsurf2').set('epsilon_rad', 0.4);
model.component('comp1').physics('rad').feature('dsurf2').label('components');
model.component('comp1').physics('rad').feature('dsurf2').selection.set([78 79 81 82 83 84 86 87 88 89 91 92 93 94 96 97 108 110 111 112 113 114 115 116 120 121 123 124 125 126 128 129 130 131 133 134 135 136 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164]);

model.component('comp1').physics('rad').create('dsurf3', 'DiffuseSurface', 2);
model.component('comp1').physics('rad').feature('dsurf3').label('MLI');
model.component('comp1').physics('rad').feature('dsurf3').selection.set([16 18 23 55 196]);
model.component('comp1').physics('rad').feature('dsurf3').set('epsilon_rad_mat', 'userdef');
model.component('comp1').physics('rad').feature('dsurf3').set('epsilon_rad', 0.4);

model.component('comp1').physics('rad').create('dsurf4', 'DiffuseSurface', 2);
model.component('comp1').physics('rad').feature('dsurf4').selection.set([67 70 201]);
model.component('comp1').physics('rad').feature('dsurf4').label('radiator');
model.component('comp1').physics('rad').feature('dsurf4').set('epsilon_rad_mat', 'userdef');
model.component('comp1').physics('rad').feature('dsurf4').set('epsilon_rad', 0.9);

model.component('comp1').physics('rad').create('dsurf5', 'DiffuseSurface', 2);
model.component('comp1').physics('rad').feature('dsurf3').selection.set([16 18 23 55 104 196]);
model.component('comp1').physics('rad').feature('dsurf5').selection.set([24 31]);
model.component('comp1').physics('rad').feature('dsurf5').label('solar panel back');
model.component('comp1').physics('rad').feature('dsurf5').set('epsilon_rad_mat', 'userdef');
model.component('comp1').physics('rad').feature('dsurf5').set('epsilon_rad', 0.3);

model.component('comp1').physics('rad').create('dsurf6', 'DiffuseSurface', 2);
model.component('comp1').physics('rad').feature('dsurf6').selection.set([1 4 7]);
model.component('comp1').physics('rad').feature('dsurf6').set('epsilon_rad_mat', 'userdef');
model.component('comp1').physics('rad').feature('dsurf6').set('epsilon_rad', 0.9);
model.component('comp1').physics('rad').feature('dsurf6').label('solar panels');

%% External heat fluxes

%Functions
model.func.create('int2', 'Interpolation');
model.func('int2').label('PlusX_rad');
model.func.move('int2', 1);
model.func('int2').setIndex('fununit', 'W/m^2', 0);
model.func('int2').setIndex('argunit', 's', 0);

model.func.create('int3', 'Interpolation');
model.func('int3').label('MinusX_rad');
model.func.move('int3', 2);
model.func('int3').setIndex('fununit', 'W/m^2', 0);
model.func('int3').setIndex('argunit', 's', 0);

model.func.create('int4', 'Interpolation');
model.func('int4').label('PlusY_rad');
model.func.move('int4', 3);
model.func('int4').setIndex('fununit', 'W/m^2', 0);
model.func('int4').setIndex('argunit', 's', 0);

model.func.create('int5', 'Interpolation');
model.func('int5').label('PlusZ_MLI');
model.func.move('int5', 4);
model.func('int5').setIndex('fununit', 'W/m^2', 0);
model.func('int5').setIndex('argunit', 's', 0);

model.func.create('int6', 'Interpolation');
model.func('int6').label('MinusZ_MLI');
model.func.move('int6', 5);
model.func('int6').setIndex('fununit', 'W/m^2', 0);
model.func('int6').setIndex('argunit', 's', 0);

model.func.create('int7', 'Interpolation');
model.func('int7').label('PlusSP');
model.func.move('int7', 6);
model.func('int7').setIndex('fununit', 'W/m^2', 0);
model.func('int7').setIndex('argunit', 's', 0);

model.func.create('int8', 'Interpolation');
model.func('int8').label('MinusSP');
model.func.move('int8', 7);
model.func('int8').setIndex('fununit', 'W/m^2', 0);
model.func('int8').setIndex('argunit', 's', 0);

model.func.create('int9', 'Interpolation');
model.func('int9').label('PlusX_MLI');
model.func.move('int9', 8);
model.func('int9').setIndex('fununit', 'W/m^2', 0);
model.func('int9').setIndex('argunit', 's', 0);

model.func.create('int10', 'Interpolation');
model.func('int10').label('MinusX_MLI');
model.func.move('int10', 9);
model.func('int10').setIndex('fununit', 'W/m^2', 0);
model.func('int10').setIndex('argunit', 's', 0);

model.func.create('int11', 'Interpolation');
model.func('int11').label('PlusY_MLI');
model.func.move('int11', 10);
model.func('int11').setIndex('fununit', 'W/m^2', 0);
model.func('int11').setIndex('argunit', 's', 0);

model.func.create('int12', 'Interpolation');
model.func('int12').label('Solar_Flux');
model.func.move('int12', 11);
model.func('int12').setIndex('fununit', 'W/m^2', 0);
model.func('int12').setIndex('argunit', 's', 0);

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
    model.func('int12').setIndex('table', Sun_MinusY(t), t-1, 1);
end

%Heat flux assignment
model.component('comp1').physics('ht').create('hf1', 'HeatFluxBoundary', 2);
model.component('comp1').physics('ht').feature('hf1').setIndex('materialType', 'solid', 0);
model.component('comp1').physics('ht').feature('hf1').selection.set([70]);
model.component('comp1').physics('ht').feature('hf1').set('q0_input', 'int2(t)');
model.component('comp1').physics('ht').feature('hf1').label('Plus X rad');

model.component('comp1').physics('ht').create('hf2', 'HeatFluxBoundary', 2);
model.component('comp1').physics('ht').feature('hf2').label('Minus X rad');
model.component('comp1').physics('ht').feature('hf2').selection.set([67]);
model.component('comp1').physics('ht').feature('hf2').setIndex('materialType', 'solid', 0);
model.component('comp1').physics('ht').feature('hf2').set('q0_input', 'int3(t)');

model.component('comp1').physics('ht').create('hf3', 'HeatFluxBoundary', 2);
model.component('comp1').physics('ht').feature('hf3').selection.set([201]);
model.component('comp1').physics('ht').feature('hf3').label('Plus Y rad');
model.component('comp1').physics('ht').feature('hf3').setIndex('materialType', 'solid', 0);
model.component('comp1').physics('ht').feature('hf3').set('q0_input', 'int4(t)');

model.component('comp1').physics('ht').create('hf4', 'HeatFluxBoundary', 2);
model.component('comp1').physics('ht').feature('hf4').selection.set([1 4 7]);
model.component('comp1').physics('ht').feature('hf4').label('Minus Y SP');
model.component('comp1').physics('ht').feature('hf4').setIndex('materialType', 'solid', 0);
model.component('comp1').physics('ht').feature('hf4').set('q0_input', 'int12(t)*0.6');

model.component('comp1').physics('ht').create('hf5', 'HeatFluxBoundary', 2);
model.component('comp1').physics('ht').feature('hf5').selection.set([18 104]);
model.component('comp1').physics('ht').feature('hf5').label('Plus Z');
model.component('comp1').physics('ht').feature('hf5').setIndex('materialType', 'solid', 0);
model.component('comp1').physics('ht').feature('hf5').set('q0_input', 'int5(t)');

model.component('comp1').physics('ht').create('hf6', 'HeatFluxBoundary', 2);
model.component('comp1').physics('ht').feature('hf6').selection.set([55]);
model.component('comp1').physics('ht').feature('hf6').label('Minus Z');
model.component('comp1').physics('ht').feature('hf6').setIndex('materialType', 'solid', 0);
model.component('comp1').physics('ht').feature('hf6').set('q0_input', 'int6(t)');

model.component('comp1').physics('ht').create('hf7', 'HeatFluxBoundary', 2);
model.component('comp1').physics('ht').feature('hf7').selection.set([24]);
model.component('comp1').physics('ht').feature('hf7').label('Plus SP');
model.component('comp1').physics('ht').feature('hf7').setIndex('materialType', 'solid', 0);
model.component('comp1').physics('ht').feature('hf7').set('q0_input', 'int7(t)');

model.component('comp1').physics('ht').create('hf8', 'HeatFluxBoundary', 2);
model.component('comp1').physics('ht').feature('hf8').selection.set([31]);
model.component('comp1').physics('ht').feature('hf8').label('Minus SP');
model.component('comp1').physics('ht').feature('hf8').setIndex('materialType', 'solid', 0);
model.component('comp1').physics('ht').feature('hf8').set('q0_input', 'int8(t)');

model.component('comp1').physics('ht').create('hf9', 'HeatFluxBoundary', 2);
model.component('comp1').physics('ht').feature('hf9').selection.set([16]);
model.component('comp1').physics('ht').feature('hf9').label('Plus X MLI');
model.component('comp1').physics('ht').feature('hf9').setIndex('materialType', 'solid', 0);
model.component('comp1').physics('ht').feature('hf9').set('q0_input', 'int9(t)');

model.component('comp1').physics('ht').create('hf10', 'HeatFluxBoundary', 2);
model.component('comp1').physics('ht').feature('hf10').selection.set([23]);
model.component('comp1').physics('ht').feature('hf10').label('Minus X MLI');
model.component('comp1').physics('ht').feature('hf10').setIndex('materialType', 'solid', 0);
model.component('comp1').physics('ht').feature('hf10').set('q0_input', 'int10(t)');

model.component('comp1').physics('ht').create('hf11', 'HeatFluxBoundary', 2);
model.component('comp1').physics('ht').feature('hf11').selection.set([196]);
model.component('comp1').physics('ht').feature('hf11').label('Plus Y MLI');
model.component('comp1').physics('ht').feature('hf11').setIndex('materialType', 'solid', 0);
model.component('comp1').physics('ht').feature('hf11').set('q0_input', 'int11(t)');

%% Battery heat dissipation

model.func.create('extm1', 'MATLAB');
model.func('extm1').setIndex('funcs', 'battery_heat_dissipation', 0, 0);
model.func('extm1').setIndex('funcs', 'P,T,S', 0, 1);

model.component('comp1').physics('ht').create('hs9', 'HeatSource', 3);
model.component('comp1').physics('ht').feature('hs9').label('Battery');
model.component('comp1').physics('ht').feature('hs9').selection.set([27]);
model.component('comp1').physics('ht').feature('hs9').set('heatSourceType', 'HeatRate');
model.component('comp1').physics('ht').feature('hs9').set('P0', 'battery_heat_dissipation((138+int1(t))*(1/0.9),bnd1,int12(t))');

%% Cold case heaters

model.func('extm1').setIndex('funcs', 'on_off_heater', 1, 0);
model.func('extm1').setIndex('funcs', 'T', 1, 1);

model.component('comp1').probe.create('point1', 'Point');
model.component('comp1').probe('point1').selection.set([141 142 145 146]);
model.component('comp1').probe('point1').label('battery');

model.component('comp1').physics('ht').create('hf12', 'HeatFluxBoundary', 2);
model.component('comp1').physics('ht').feature('hf12').selection.set([149]);
model.component('comp1').physics('ht').feature('hf12').label('battery heater');
model.component('comp1').physics('ht').feature('hf12').set('q0_input', 'on_off_heater(point1)');

model.component('comp1').physics('ht').create('hf13', 'HeatFluxBoundary', 2);
model.component('comp1').physics('ht').feature('hf13').selection.set([100]);
model.component('comp1').physics('ht').feature('hf13').label('prop heater');

model.component('comp1').probe.create('point2', 'Point');
model.component('comp1').probe('point2').selection.set([69 70 121 122]);
model.component('comp1').probe('point2').label('propulsion');
model.component('comp1').physics('ht').feature('hf13').set('q0_input', 'on_off_heater(point2)');

%% Probes

model.result.table.create('tbl1', 'Table');

model.component('comp1').probe.create('dom1', 'Domain');
model.component('comp1').probe('dom1').label('lumped');
model.component('comp1').probe('dom1').set('intsurface', true);
model.component('comp1').probe('dom1').set('intvolume', true);
model.component('comp1').probe('dom1').selection.set([7 8 9 10 11 13 14 15 16 17 18 19 21 22 23 24 25 26 27 28 29 30 32]);
model.component('comp1').probe('dom1').set('table', 'tbl1');

model.component('comp1').probe.create('bnd1', 'Boundary');
model.component('comp1').probe('bnd1').set('intsurface', true);
model.component('comp1').probe('bnd1').selection.set([1 4 7]);
model.component('comp1').probe('bnd1').label('solar cells');
model.component('comp1').probe('bnd1').set('table', 'tbl1');

model.component('comp1').probe.create('var1', 'GlobalVariable');
model.component('comp1').probe('var1').set('expr', 'battery_heat_dissipation((138+int1(t))*(1/0.9),bnd1,int12(t))');
model.component('comp1').probe('var1').set('table', 'tbl1');
model.component('comp1').probe('var1').set('unit', 'W');

model.component('comp1').probe.create('var2', 'GlobalVariable');
model.component('comp1').probe('var2').set('expr', 'on_off_heater(point1)+on_off_heater(point2)');
model.component('comp1').probe('var2').set('table', 'tbl1');
model.component('comp1').probe('var2').set('unit', 'W');

model.component('comp1').probe('point1').set('table', 'tbl1');

model.component('comp1').probe('point2').set('table', 'tbl1');

%% Mesh and solution

model.component('comp1').mesh('mesh1').run;
model.study('std1').feature('time').set('tlist', 'range(0,0.1,10)');
model.sol.create('sol1');
model.sol('sol1').study('std1');

model.study('std1').feature('time').set('notlistsolnum', 1);
model.study('std1').feature('time').set('notsolnum', 'auto');
model.study('std1').feature('time').set('listsolnum', 1);
model.study('std1').feature('time').set('solnum', 'auto');

model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').feature('st1').set('study', 'std1');
model.sol('sol1').feature('st1').set('studystep', 'time');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').feature('v1').feature('comp1_rad_dsurf6_Ju_band').set('scalemethod', 'init');
model.sol('sol1').feature('v1').feature('comp1_rad_dsurf2_Jd_band').set('scalemethod', 'init');
model.sol('sol1').feature('v1').feature('comp1_rad_dsurf2_Ju_band').set('scalemethod', 'init');
model.sol('sol1').feature('v1').feature('comp1_rad_dsurf5_Ju_band').set('scalemethod', 'init');
model.sol('sol1').feature('v1').feature('comp1_rad_dsurf6_Jd_band').set('scalemethod', 'init');
model.sol('sol1').feature('v1').feature('comp1_rad_dsurf3_Ju_band').set('scalemethod', 'init');
model.sol('sol1').feature('v1').feature('comp1_rad_dsurf3_Jd_band').set('scalemethod', 'init');
model.sol('sol1').feature('v1').feature('comp1_rad_dsurf4_Ju_band').set('scalemethod', 'init');
model.sol('sol1').feature('v1').feature('comp1_rad_dsurf5_Jd_band').set('scalemethod', 'init');
model.sol('sol1').feature('v1').feature('comp1_rad_dsurf1_Jd_band').set('scalemethod', 'init');
model.sol('sol1').feature('v1').feature('comp1_rad_dsurf4_Jd_band').set('scalemethod', 'init');
model.sol('sol1').feature('v1').feature('comp1_rad_dsurf1_Ju_band').set('scalemethod', 'init');
model.sol('sol1').feature('v1').set('control', 'time');
model.sol('sol1').create('t1', 'Time');
model.sol('sol1').feature('t1').set('tlist', 'range(0,0.1,10)');
model.sol('sol1').feature('t1').set('plot', 'off');
model.sol('sol1').feature('t1').set('plotgroup', 'Default');
model.sol('sol1').feature('t1').set('plotfreq', 'tout');
model.sol('sol1').feature('t1').set('probesel', 'all');
model.sol('sol1').feature('t1').set('probes', {'dom1' 'bnd1' 'point1' 'point2'});
model.sol('sol1').feature('t1').set('probefreq', 'tsteps');
model.sol('sol1').feature('t1').set('atolglobalvaluemethod', 'factor');
model.sol('sol1').feature('t1').set('atolmethod', {'comp1_rad_dsurf1_Jd_band' 'global' 'comp1_rad_dsurf1_Ju_band' 'global' 'comp1_rad_dsurf2_Jd_band' 'global' 'comp1_rad_dsurf2_Ju_band' 'global' 'comp1_rad_dsurf3_Jd_band' 'global'  ...
'comp1_rad_dsurf3_Ju_band' 'global' 'comp1_rad_dsurf4_Jd_band' 'global' 'comp1_rad_dsurf4_Ju_band' 'global' 'comp1_rad_dsurf5_Jd_band' 'global' 'comp1_rad_dsurf5_Ju_band' 'global'  ...
'comp1_rad_dsurf6_Jd_band' 'global' 'comp1_rad_dsurf6_Ju_band' 'global' 'comp1_T' 'global'});
model.sol('sol1').feature('t1').set('atol', {'comp1_rad_dsurf1_Jd_band' '1e-3' 'comp1_rad_dsurf1_Ju_band' '1e-3' 'comp1_rad_dsurf2_Jd_band' '1e-3' 'comp1_rad_dsurf2_Ju_band' '1e-3' 'comp1_rad_dsurf3_Jd_band' '1e-3'  ...
'comp1_rad_dsurf3_Ju_band' '1e-3' 'comp1_rad_dsurf4_Jd_band' '1e-3' 'comp1_rad_dsurf4_Ju_band' '1e-3' 'comp1_rad_dsurf5_Jd_band' '1e-3' 'comp1_rad_dsurf5_Ju_band' '1e-3'  ...
'comp1_rad_dsurf6_Jd_band' '1e-3' 'comp1_rad_dsurf6_Ju_band' '1e-3' 'comp1_T' '1e-3'});
model.sol('sol1').feature('t1').set('atolvaluemethod', {'comp1_rad_dsurf1_Jd_band' 'factor' 'comp1_rad_dsurf1_Ju_band' 'factor' 'comp1_rad_dsurf2_Jd_band' 'factor' 'comp1_rad_dsurf2_Ju_band' 'factor' 'comp1_rad_dsurf3_Jd_band' 'factor'  ...
'comp1_rad_dsurf3_Ju_band' 'factor' 'comp1_rad_dsurf4_Jd_band' 'factor' 'comp1_rad_dsurf4_Ju_band' 'factor' 'comp1_rad_dsurf5_Jd_band' 'factor' 'comp1_rad_dsurf5_Ju_band' 'factor'  ...
'comp1_rad_dsurf6_Jd_band' 'factor' 'comp1_rad_dsurf6_Ju_band' 'factor' 'comp1_T' 'factor'});
model.sol('sol1').feature('t1').set('reacf', true);
model.sol('sol1').feature('t1').set('storeudot', true);
model.sol('sol1').feature('t1').set('endtimeinterpolation', true);
model.sol('sol1').feature('t1').set('estrat', 'exclude');
model.sol('sol1').feature('t1').set('maxorder', 2);
model.sol('sol1').feature('t1').set('control', 'time');
model.sol('sol1').feature('t1').create('se1', 'Segregated');
model.sol('sol1').feature('t1').feature('se1').feature.remove('ssDef');
model.sol('sol1').feature('t1').feature('se1').create('ss1', 'SegregatedStep');
model.sol('sol1').feature('t1').feature('se1').feature('ss1').set('segvar', {'comp1_T'});
model.sol('sol1').feature('t1').feature('se1').feature('ss1').set('subdamp', 0.8);
model.sol('sol1').feature('t1').feature('se1').feature('ss1').set('subjtech', 'once');
model.sol('sol1').feature('t1').create('d1', 'Direct');
model.sol('sol1').feature('t1').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').feature('t1').feature('d1').set('pivotperturb', 1.0E-13);
model.sol('sol1').feature('t1').feature('d1').label('Direct, heat transfer variables (ht)');
model.sol('sol1').feature('t1').feature('se1').feature('ss1').set('linsolver', 'd1');
model.sol('sol1').feature('t1').feature('se1').feature('ss1').label('Temperature');
model.sol('sol1').feature('t1').feature('se1').create('ss2', 'SegregatedStep');
model.sol('sol1').feature('t1').feature('se1').feature('ss2').set('segvar', {'comp1_rad_dsurf1_Ju_band' 'comp1_rad_dsurf1_Jd_band' 'comp1_rad_dsurf2_Ju_band' 'comp1_rad_dsurf2_Jd_band' 'comp1_rad_dsurf3_Ju_band' 'comp1_rad_dsurf3_Jd_band' 'comp1_rad_dsurf4_Ju_band' 'comp1_rad_dsurf4_Jd_band' 'comp1_rad_dsurf5_Ju_band' 'comp1_rad_dsurf5_Jd_band'  ...
'comp1_rad_dsurf6_Ju_band' 'comp1_rad_dsurf6_Jd_band'});
model.sol('sol1').feature('t1').feature('se1').feature('ss2').set('subdamp', 0.8);
model.sol('sol1').feature('t1').feature('se1').feature('ss2').set('subjtech', 'once');
model.sol('sol1').feature('t1').create('d2', 'Direct');
model.sol('sol1').feature('t1').feature('d2').set('linsolver', 'pardiso');
model.sol('sol1').feature('t1').feature('d2').set('pivotperturb', 1.0E-13);
model.sol('sol1').feature('t1').feature('d2').label('Direct, radiation variables');
model.sol('sol1').feature('t1').feature('se1').feature('ss2').set('linsolver', 'd2');
model.sol('sol1').feature('t1').feature('se1').feature('ss2').label('Radiosity');
model.sol('sol1').feature('t1').feature('se1').set('segstabacc', 'segaacc');
model.sol('sol1').feature('t1').feature('se1').set('segaaccdim', 5);
model.sol('sol1').feature('t1').feature('se1').set('segaaccmix', 0.9);
model.sol('sol1').feature('t1').feature('se1').set('segaaccdelay', 1);
model.sol('sol1').feature('t1').feature('se1').set('ntolfact', 0.1);
model.sol('sol1').feature('t1').feature('se1').create('ll1', 'LowerLimit');
model.sol('sol1').feature('t1').feature('se1').feature('ll1').set('lowerlimit', 'comp1.T 0 ');
model.sol('sol1').feature('t1').create('i1', 'Iterative');
model.sol('sol1').feature('t1').feature('i1').set('linsolver', 'gmres');
model.sol('sol1').feature('t1').feature('i1').set('prefuntype', 'left');
model.sol('sol1').feature('t1').feature('i1').set('itrestart', 50);
model.sol('sol1').feature('t1').feature('i1').set('rhob', 20);
model.sol('sol1').feature('t1').feature('i1').set('maxlinit', 10000);
model.sol('sol1').feature('t1').feature('i1').set('nlinnormuse', 'on');
model.sol('sol1').feature('t1').feature('i1').label('AMG, heat transfer variables (ht)');
model.sol('sol1').feature('t1').feature('i1').create('mg1', 'Multigrid');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').set('prefun', 'saamg');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').set('mgcycle', 'v');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').set('maxcoarsedof', 50000);
model.sol('sol1').feature('t1').feature('i1').feature('mg1').set('strconn', 0.01);
model.sol('sol1').feature('t1').feature('i1').feature('mg1').set('nullspace', 'constant');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').set('usesmooth', false);
model.sol('sol1').feature('t1').feature('i1').feature('mg1').set('saamgcompwise', true);
model.sol('sol1').feature('t1').feature('i1').feature('mg1').set('loweramg', true);
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('pr').create('so1', 'SOR');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('pr').feature('so1').set('iter', 2);
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('pr').feature('so1').set('relax', 0.9);
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('po').create('so1', 'SOR');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('po').feature('so1').set('iter', 2);
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('po').feature('so1').set('relax', 0.9);
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('cs').create('d1', 'Direct');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('cs').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').feature('t1').feature('i1').feature('mg1').feature('cs').feature('d1').set('pivotperturb', 1.0E-13);
model.sol('sol1').feature('t1').create('i2', 'Iterative');
model.sol('sol1').feature('t1').feature('i2').set('linsolver', 'gmres');
model.sol('sol1').feature('t1').feature('i2').set('prefuntype', 'left');
model.sol('sol1').feature('t1').feature('i2').set('rhob', 400);
model.sol('sol1').feature('t1').feature('i2').label('AMG, radiation variables');
model.sol('sol1').feature('t1').feature('i2').create('mg1', 'Multigrid');
model.sol('sol1').feature('t1').feature('i2').feature('mg1').set('prefun', 'saamg');
model.sol('sol1').feature('t1').feature('i2').feature('mg1').set('usesmooth', false);
model.sol('sol1').feature('t1').feature('i2').feature('mg1').set('saamgcompwise', true);
model.sol('sol1').feature('t1').feature('i2').feature('mg1').feature('pr').create('so1', 'SOR');
model.sol('sol1').feature('t1').feature('i2').feature('mg1').feature('pr').feature('so1').set('iter', 2);
model.sol('sol1').feature('t1').feature('i2').feature('mg1').feature('pr').feature('so1').set('relax', 0.9);
model.sol('sol1').feature('t1').feature('i2').feature('mg1').feature('po').create('so1', 'SOR');
model.sol('sol1').feature('t1').feature('i2').feature('mg1').feature('po').feature('so1').set('iter', 2);
model.sol('sol1').feature('t1').feature('i2').feature('mg1').feature('po').feature('so1').set('relax', 0.9);
model.sol('sol1').feature('t1').feature('i2').feature('mg1').feature('cs').create('d1', 'Direct');
model.sol('sol1').feature('t1').feature('i2').feature('mg1').feature('cs').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').feature('t1').create('i3', 'Iterative');
model.sol('sol1').feature('t1').feature('i3').set('linsolver', 'gmres');
model.sol('sol1').feature('t1').feature('i3').set('prefuntype', 'left');
model.sol('sol1').feature('t1').feature('i3').set('rhob', 20);
model.sol('sol1').feature('t1').feature('i3').label('GMG, radiation variables');
model.sol('sol1').feature('t1').feature('i3').create('mg1', 'Multigrid');
model.sol('sol1').feature('t1').feature('i3').feature('mg1').set('prefun', 'gmg');
model.sol('sol1').feature('t1').feature('i3').feature('mg1').set('mcasegen', 'any');
model.sol('sol1').feature('t1').feature('i3').feature('mg1').feature('pr').create('so1', 'SOR');
model.sol('sol1').feature('t1').feature('i3').feature('mg1').feature('pr').feature('so1').set('iter', 2);
model.sol('sol1').feature('t1').feature('i3').feature('mg1').feature('po').create('so1', 'SOR');
model.sol('sol1').feature('t1').feature('i3').feature('mg1').feature('po').feature('so1').set('iter', 2);
model.sol('sol1').feature('t1').feature('i3').feature('mg1').feature('cs').create('d1', 'Direct');
model.sol('sol1').feature('t1').feature('i3').feature('mg1').feature('cs').feature('d1').set('linsolver', 'pardiso');
model.sol('sol1').feature('t1').feature.remove('fcDef');
model.sol('sol1').attach('std1');

model.component('comp1').probe('dom1').genResult('none');
model.component('comp1').probe('bnd1').genResult('none');
model.component('comp1').probe('var1').genResult('none');
model.component('comp1').probe('var2').genResult('none');
model.component('comp1').probe('point1').genResult('none');
model.component('comp1').probe('point2').genResult('none');

model.sol('sol1').runAll;

%% Postprocessing

results = mphtable(model,'tbl1');
Time = results.data(:,1);
T_sp_av = results.data(:,2);
T_av = results.data(:,3);
Q_bat = results.data(:,4);
Q_heater = results.data(:,5);
T_bat = results.data(:,6);
T_prop = results.data(:,7);
plot(Time,T_bat)
