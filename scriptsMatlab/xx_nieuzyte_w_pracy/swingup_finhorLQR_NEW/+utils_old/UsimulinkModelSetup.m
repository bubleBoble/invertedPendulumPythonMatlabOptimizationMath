load_system(sprintf('%s', model_name))
set_param(...
    sprintf('%s', model_name),...
    'Solver','ode45',...
    'StopTime',sprintf('%d', end_time))
set_param(sprintf('%s', model_name),"FastRestart","off")
set_param(sprintf('%s', model_name),'AccelVerboseBuild','on')
set_param(sprintf('%s', model_name),'SimulationMode','normal') % accelerator
set_param(sprintf('%s', model_name),'SimCompilerOptimization','on')