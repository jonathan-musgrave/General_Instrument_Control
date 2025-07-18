


clear all;
osa_FF = visa('ni', 'GPIB0::2::INSTR'); % Replace with your instrument's VISA address
osa_FF.InputBufferSize = 2^16;
osa_SHG = visa('ni', 'GPIB1::1::INSTR'); % Replace with your instrument's VISA address
osa_SHG.InputBufferSize = 2^16;


% Send Commands to New Yokogawa
set(osa_SHG,'Timeout',10);
fopen(osa_SHG);
fprintf(osa_SHG,'*IDN?');
fprintf(osa_SHG,':sens:wav:cent 1571.9nm');
fprintf(osa_SHG,':sens:wav:cent 65nm');
fprintf(osa_SHG,':sens:sweep:points 1500');



% Send Commands to old Yokogawa
set(osa_FF,'Timeout',10);
fopen(osa_FF);
fprintf(osa_FF,'*IDN?');
fprintf(osa_FF,':sens:wav:cent 1571.9nm');
fprintf(osa_FF,':sens:wav:cent 65nm');
fprintf(osa_FF,':sens:sweep:points 1500');





nn = 10;
for i = 1:nn
fprintf(osa_FF,':init:smode 1');
fprintf(osa_SHG,':init:smode 1');
% fprintf(osa,':*CLS"');
fprintf(osa_FF,':init');
fprintf(osa_SHG,':init');
% fprintf(osa,':TRACe:W')



STR_FF = strcat('"FF_',num2str(i),'"');
STR_SHG = strcat('"SHG_',num2str(i),'"');

fprintf(osa_FF,[":mmem:stor:ATR "+STR_FF+",int"]);
fprintf(osa_SHG,[":mmem:stor:ATR "+STR_SHG+",int"]);


end

fclose(osa_FF)
fclose(osa_SHG)
