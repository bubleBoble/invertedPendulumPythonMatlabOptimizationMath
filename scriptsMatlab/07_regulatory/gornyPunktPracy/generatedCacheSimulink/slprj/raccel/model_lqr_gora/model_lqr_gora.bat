@echo off
set MATLAB=C:\Program Files\MATLAB\R2023a

call  "\\N-20L6PF1K8U2B\C$\Program Files\MATLAB\R2023a\bin\win64\checkMATLABRootForDriveMap.exe" "\\N-20L6PF1K8U2B\C$\Program Files\MATLAB\R2023a"  > mlEnv.txt
for /f %%a in (mlEnv.txt) do set "%%a"\n
"%MATLAB%\bin\win64\gmake" -f model_lqr_gora.mk MATLAB_ROOT=%MATLAB_ROOT% ALT_MATLAB_ROOT=%ALT_MATLAB_ROOT% MATLAB_BIN=%MATLAB_BIN% ALT_MATLAB_BIN=%ALT_MATLAB_BIN%  RSIM_SOLVER_SELECTION=1 PCMATLABROOT="C:\\Program Files\\MATLAB\\R2023a" EXTMODE_STATIC_ALLOC=0 EXTMODE_STATIC_ALLOC_SIZE=1000000 EXTMODE_TRANSPORT=0 TMW_EXTMODE_TESTING=0 RSIM_PARAMETER_LOADING=1 OPTS="-DTGTCONN -DIS_SIM_TARGET -DNRT -DRSIM_PARAMETER_LOADING -DRSIM_WITH_SL_SOLVER -DENABLE_SLEXEC_SSBRIDGE=1 -DMODEL_HAS_DYNAMICALLY_LOADED_SFCNS=0 -DON_TARGET_WAIT_FOR_START=0 -DTID01EQ=1"