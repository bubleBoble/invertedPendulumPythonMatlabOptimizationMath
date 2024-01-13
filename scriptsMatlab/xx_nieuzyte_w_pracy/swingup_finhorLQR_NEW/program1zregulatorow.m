%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%   Stabilizacja wahadła w górnym położeniu
%   LQR, śledzenie zmiennej pozycji zadanej wózka
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
clc;
utils.change_simulink_stupid_cache_directory;
utils.change_text_interpreter_to_latex;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% Parametry dla model liniowego - z tarciem lepkim
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% optym_M  = [0.4178;0.4202;0.4118;0.4118;0.4118;0.4160];
% optym_mp = [0.0881;0.0899;0.0881;0.0892;0.0881;0.0890];
% optym_mc = [0;0;0;0;0;0;];
% optym_Lp = [0.1213;0.1213;0.1213;0.1213;0.1213;0.1225];
% optym_B  = [26.5928;23.8970;23.1800;23.1077;23.1016;23.1000];
% optym_gm = [0.0087;0.0048;0.0028;0.0018;0.0014;0.0014];
% optym_al = [1.5400;1.5400;1.5400;1.5400;1.5400;1.5500];
% params_lin_vis = [optym_M, optym_mp , optym_mc, optym_Lp, optym_B, optym_gm, optym_al];
params_lin_vis = [0.416, 0.089, 0, 0.1225, 23.8299, 0.0035, 1.5417];
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% Macierze modelu liniowego
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
[A, B, C, D, E, H] = macierze_lin('lepki gora', params_lin_vis);
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% Parametry dla modelu nieliniowego - z tarciem z stribecka
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
p_2v_rampa    = [0.4160 0.0890 0 0.1225 1.5417 20.9002 0.0109 0.0651 0.1284 13.9983];
p_4v_rampa    = [0.4160 0.0890 0 0.1225 1.5417 20.9004 0.0053 0.0651 0.1284 14.0000];
p_6v_rampa    = [0.4160 0.0890 0 0.1225 1.5417 20.9004 0.0038 0.0651 0.1284 13.9983];
p_2v_skok     = [0.4160 0.0890 0 0.1225 1.5417 20.9004 0.0090 0.0652 0.1297 13.9983];
p_4v_skok     = [0.4160 0.0890 0 0.1225 1.5417 20.9004 0.0048 0.0656 0.1297 13.9983];
p_6v_skok     = [0.4160 0.0890 0 0.1225 1.5417 20.9004 0.0033 0.0658 0.1297 13.9966];
p_8v_skok     = [0.4160 0.0890 0 0.1225 1.5417 20.9004 0.0022 0.0651 0.1297 13.9986];
p_10v_skok    = [0.4160 0.0890 0 0.1225 1.5417 20.9004 0.0020 0.0644 0.1297 14.0001];
% params_nonlin_stri = [p_2v_rampa; p_4v_rampa; p_6v_rampa];
% M, mp, mc, Lp, alpha_dcm, B, gamma_stri, miu_c, miu_s, vs 
params_nonlin_stri = [0.4160, 0.0890, 0, 0.1225, 1.5417, 20.9, 0.0067, 0.0651, 0.1284, 13.9989];
% params_nonlin_stri = p_10v_skok;
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% Ustawienia
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
track_len               = 0.47;         % długość suwnicy, NIE ZMIENIAĆ
end_time                = 80;           % końcowy czas symulacji
sat                     = [-12, 12];    % saturacja sygnału sterującego
animacjaON              = 0;            % animacja on/off
save_anim               = 0;            % zapisanie animacji on/off
enableLinmodel          = 1;            % on/off system liniowy w modelu (simulink)
cart_pos_allowed_error  = 0.003;        % dozwolny uchyb położęnia wózka w metrach
pend_position_allowed_error = 1*pi/180; % dozwolony uchyb wychylenia wahadła
dead_zone_ctrl_ampl     = 1.0;          % martwa sterfa sygnału sterującego w REGULATORZE
dead_zone_ampl          = 1.0;          % martwa strefa napięcia do silnika w MODELU
IC                      = [ ...
    0.2; ...
    0*pi/180; ...
    0; ...
    0 ... 
];
IC_liniowy = IC - [0; 0; 0; 0];
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% LQR
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% % % % Q = diag( [50, 0.01, 0.05, 0] );
% % % % R = 0.009;
% % % % F=lqr(A, B, Q, R);
% % % 
% % % % Q = diag( [70, 100, 0.05, 0] );
% % % % R = 0.03;
% % % % F=lqr(A, B, Q, R);
% % % 
% % % % te wyglądają na dobre do dodania do pracy
% % % % Q = diag( [70, 100, 1, 0.6] );
% % % % R = 0.03;
% % % % F=lqr(A, B, Q, R);
% % % 
% % % % Q = diag( [50, 4, 0, 0] );
% % % % R = 0.0005;
% % % % F=lqr(A, B, Q, R);
% % % 
% % % % sprawdzić
% % % % Q = diag( [40, 5, 0.001, 0.001] );
% % % % R = 0.001;
% % % % F=lqr(A, B, Q, R);

Q = diag( [500e3, 3e3, 0, 0] );
R = 100;
F=lqr(A, B, Q, R);

% Q = diag( [600e3, 3e3, 30e3, 0] );
% R = 100;
% F=lqr(A, B, Q, R);

% brzydkie ale działa
% Q = diag( [800e3, 100e3, 120e3, 30e3] );
% R = 100;
% F=lqr(A, B, Q, R);
% 
% Q = diag( [900e3, 0, 120e3, 0] );
% R = 70;
% F=lqr(A, B, Q, R);

disp('F LQR:')
disp(F)
disp('F tuned:')
F = [ -74.5, -76.0, -51.5, -9.0 ];
disp(F)
disp(eig(A-B*F))
% return
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% Symulacja
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
model_name = 'model_lqr_gora_stribeck';
run('UsimulinkModelSetup.m')
run('Uinputsignals.m'); 
% accelbuild(sprintf('%s', model_name));
out = sim(sprintf('%s.slx', model_name));
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% Output z simulinka
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
run('Uoutputsignals.m')
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% ploty
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% run('Uplots1.m');
run('Uplots2.m');
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% Animacja
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
Lc = 2*params_nonlin_stri(4) / 4;
if animacjaON
    utils.animate(IC, Lc, 0.001 , xw_nl, the_nl*pi/180, t, save_anim, "vid_new");
end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
disp("FEEDBACK (jednostki podstawowe):");
fprintf("float gains[4] = {%f, %f, %f, %f};\n", F);
