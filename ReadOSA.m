


clear all;
osa_SHG = visa('ni', 'GPIB0::2::INSTR'); % Replace with your instrument's VISA address
osa_SHG.InputBufferSize = 2^16;
% set(osa,'Terminator', 'CR/LF');
set(osa_SHG,'Timeout',10);
fopen(osa_SHG);
fprintf(osa_SHG,'*IDN?');
fprintf(osa_SHG,':sens:wav:cent 1571.9nm');
fprintf(osa_SHG,':sens:wav:cent 65nm');
fprintf(osa_SHG,':sens:sweep:points 1500');

fprintf(osa_SHG,':sens:wav:cent 785.95nm');
fprintf(osa_SHG,':sens:wav:cent 32.5nm');
fprintf(osa_SHG,':sens:sweep:points 1500');

nn = 10;
for i = 1:nn
fprintf(osa_SHG,':init:smode 1');
% fprintf(osa,':*CLS"');
fprintf(osa_SHG,':init');
% fprintf(osa,':TRACe:W')



STR = strcat('"SHG_Sweep_',num2str(i),'"');
fprintf(osa_SHG,[":mmem:stor:ATR "+STR+",ext"]);


end

fclose(osa_SHG)
