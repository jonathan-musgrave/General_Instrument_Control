clear all;
clear all;

% Get all visa objects
osa_FF = visa('ni', 'GPIB1::1::INSTR'); % Replace with your instrument's VISA address
osa_FF.InputBufferSize = 2^16;
osa_SHG = visa('ni', 'GPIB0::2::INSTR'); % Replace with your instrument's VISA address
osa_SHG.InputBufferSize = 2^16;

device = visa('ni', 'GPIB2::18::INSTR'); % Replace with your instrument's VISA address
device.InputBufferSize = 2^16;

% Send Commands to New Yokogawa
set(osa_SHG,'Timeout',10);
fopen(osa_SHG);
fprintf(osa_SHG,'*IDN?');
fprintf(osa_SHG,':sens:wav:cent 786nm');
fprintf(osa_SHG,':sens:wav:span 25nm');
fprintf(osa_SHG,':sens:sweep:points 1500');



% Send Commands to old Yokogawa
set(osa_FF,'Timeout',10);
fopen(osa_FF);
fprintf(osa_FF,'*IDN?');
fprintf(osa_FF,':sens:wav:cent 1571.9nm');
fprintf(osa_FF,':sens:wav:span 50nm');
fprintf(osa_FF,':sens:sweep:points 1500');

% Configure the ESA
fopen(device);
fprintf(device,'*IDN?');
fscanf(device)
    SPAN_F = 4.90e9;
    CENT_F = 2.5E9;
    RBW = 10e6;
    nP = 1000;

fprintf(device,strcat(':FREQ:CENT '+" ",num2str(CENT_F)));
fprintf(device,strcat(':FREQ:SPAN '+" ",num2str(SPAN_F)));
fprintf(device,strcat(':BANDWIDTH:RESolution'+" ",num2str(RBW)));
fprintf(device,strcat(':SWE:POIN'+" ",num2str(nP)));
pause(2)
n = 1000;


% Now take the measurements
Twin = 60*5.*2+5;
tic
i = 1;
while i<2 %toc<Twin
    
    % Init RF spectrum since this takes longest
    fprintf(device, ':INIT');
    fprintf(device, ':TRAC? TRACE1');

    % Tell OSA's too take one sweep
    fprintf(osa_FF,':init:smode 1');
    fprintf(osa_SHG,':init:smode 1');
    fprintf(osa_FF,':init');
    fprintf(osa_SHG,':init');
    
    
    % Get OSA data save to Memory INT for internal EXT for External 
    STR_FF = strcat('"FF_',num2str(i),'"');
    STR_SHG = strcat('"SHG_',num2str(i),'"');
    
    fprintf(osa_FF,[":mmem:stor:ATR "+STR_FF+",EXT"]);
    fprintf(osa_SHG,[":mmem:stor:ATR "+STR_SHG+",EXT"]);

    % Scan the RF Spectrum Device
    data{i} = fscanf(device);
    t(i) = toc;

    % Pause so data can be downloaded
    pause(0.25)
    disp(t(i))
    % Now continue
    i = i+2;

end

nDat = i-1;
fclose(device);
fclose(osa_FF);
fclose(osa_SHG);
% Delete
delete(device);
delete(osa_FF);
delete(osa_SHG);
clear device osa_FF osa_SHG;
%% PROCESSING DATA
disp('Processing Data')
% Process and save data
delimiter = ',';
N = 1;
while N<nDat
        disp(N);

    try
    C = strsplit(data{N},delimiter);
    catch
        % disp(N);
        N = nDat;
    end
    if N == 1

        ESA_TimeTrace = zeros(length(C),n-1);
        dataArray = cell(nDat,1);
    end
%     inx_1 = strsplit(C{1},',');
%     dataArray = zeros(1,length(C));
%     dataArray(1) = str2num(inx_1{1});
    dataArray_temp = zeros(1,length(C));
    for i = 1:length(C)
        dataArray_temp(i) = str2num(C{i}); %#ok<ST2NM>
    
    end
    dataArray{N} = dataArray_temp;
    % ESA_TimeTrace(:,N) = dataArray;
    N = N+1;
end

D = 'E440_GPIB_TimeTrace';
ESA_TimeTrace = cell2mat(dataArray);
F = nextname(D,'outfile<01>.mat',true);
f = (CENT_F-SPAN_F/2):SPAN_F/n:(CENT_F+SPAN_F);
    SPAN_F = 4.90e9;
    CENT_F = 2.5E9;

save(F,'dataArray','f','t')
figure(1);clf;

    subplot(2,1,1)
    imagesc(ESA_TimeTrace);colorbar
    subplot(2,1,2)
    plot(ESA_TimeTrace');


