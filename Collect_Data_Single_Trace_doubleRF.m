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
fprintf(osa_SHG,':sens:wav:span 15nm');
fprintf(osa_SHG,':sens:sweep:points 4000');
fprintf(osa_SHG,':sens:sens high1')



% Send Commands to old Yokogawa
set(osa_FF,'Timeout',10);
fopen(osa_FF);
fprintf(osa_FF,'*IDN?');
fprintf(osa_FF,':sens:wav:cent 1571.9nm');
fprintf(osa_FF,':sens:wav:span 60nm');
fprintf(osa_FF,':sens:sweep:points 4000');
fprintf(osa_FF,':sens:sens mid');

% Configure the ESA
fopen(device);
fprintf(device,'*IDN?');
fscanf(device)
    SPAN_F1 = 4.90e9;
    ss_f1 = SPAN_F1;
    CENT_F1 = 2.5E9;
    cc_f1 = CENT_F1;
    RBW1 = 10e6;
    nP1 = 1000;


    SPAN_F2 = 10e6;
    ss_f2 = SPAN_F2;
    CENT_F2 = 380E6;
    cc_f2 = CENT_F2;
    RBW2 = 1e3;
    nP2 = 1000;

fprintf(device,strcat(':FREQ:CENT '+" ",num2str(CENT_F1)));
fprintf(device,strcat(':FREQ:SPAN '+" ",num2str(SPAN_F1)));
fprintf(device,strcat(':BANDWIDTH:RESolution'+" ",num2str(RBW1)));
fprintf(device,strcat(':SWE:POIN'+" ",num2str(nP1)));
pause(2)

% Naming Convention
NAME = 'outfile_DROPO_Sweep_Blue2Red';
D = 'RF_Spectrum_FromSingleTrace';
F = nextname(D,strcat(NAME,'<01>.mat'),true);
STR_FF = strcat('"FF_',F(length(D)+2:end-4),'"');
STR_SHG = strcat('"SHG_',F(length(D)+2:end-4),'"');
% Now take the measurements
Twin = 60*5.*2+5;
tic
i = 1;
while i<2
    
    % Init RF spectrum since this takes longest
    fprintf(device, ':INIT');

    % Tell OSA's too take one sweep
    fprintf(osa_FF,':init:smode 1');
    fprintf(osa_SHG,':init:smode 1');
    fprintf(osa_FF,':init');
    fprintf(osa_SHG,':init');
    
    
    % Get OSA data save to Memory INT for internal EXT for External 
    
    
    
    % Scan the RF Spectrum Device
    fprintf(device, ':TRAC? TRACE1');
    pause(0.5)
    data1{i} = fscanf(device);
    % Pause so data can be downloaded

    % Scan RF spec 2 closer in
fprintf(device,strcat(':FREQ:CENT '+" ",num2str(CENT_F2)));
fprintf(device,strcat(':FREQ:SPAN '+" ",num2str(SPAN_F2)));
fprintf(device,strcat(':BANDWIDTH:RESolution'+" ",num2str(RBW2)));
fprintf(device,strcat(':SWE:POIN'+" ",num2str(nP2)));
    % Init RF spectrum since this takes longest
    fprintf(device, ':INIT');
    pause(14)
    fprintf(device, ':TRAC? TRACE1');
    data2{i} = fscanf(device);
    t(i) = toc;
    fprintf(osa_FF,[":mmem:stor:ATR "+STR_FF+",EXT"]);
    fprintf(osa_FF,':sens:sens norm');
    fprintf(osa_FF,':init:smode 2');

    %pause(10)
    fprintf(osa_SHG,[":mmem:stor:ATR "+STR_SHG+",EXT"]);

    disp(t(i))
    % Now continue
    i = i+1;

end


    % Tell OSA's too take one sweep
    fprintf(osa_FF,':sens:sens norm');
    fprintf(osa_SHG,':sens:sens norm');
    fprintf(osa_FF,':init:smode 2');
    fprintf(osa_SHG,':init:smode 2');
    fprintf(osa_FF,':init');
    fprintf(osa_SHG,':init');

fprintf(device,strcat(':FREQ:CENT '+" ",num2str(CENT_F1)));
fprintf(device,strcat(':FREQ:SPAN '+" ",num2str(SPAN_F1)));
fprintf(device,strcat(':BANDWIDTH:RESolution'+" ",num2str(RBW1)));
fprintf(device,strcat(':SWE:POIN'+" ",num2str(nP1)));

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
while N<nDat+1
        disp(N);

    try
    C1 = strsplit(data1{N},delimiter);
    C2 = strsplit(data2{N},delimiter);
    catch
        % disp(N);
        N = nDat;
    end
    if N == 1
% 
%         ESA_TimeTrace_1 = zeros(length(C1),n-1);
%         ESA_TimeTrace_2 = zeros(length(C2),n-1);
        dataArray1 = cell(nDat,1);
        dataArray2 = cell(nDat,1);
    end
%     inx_1 = strsplit(C{1},',');
%     dataArray = zeros(1,length(C));
%     dataArray(1) = str2num(inx_1{1});
    dataArray_temp1 = zeros(1,length(C1));
    dataArray_temp2 = zeros(1,length(C2));
    for i = 1:length(C1)
        dataArray_temp1(i) = str2num(C1{i}); %#ok<ST2NM>
    end
    for i = 1:length(C2)
        dataArray_temp2(i) = str2num(C2{i}); %#ok<ST2NM>
    end
    dataArray1{N} = dataArray_temp1;
    dataArray2{N} = dataArray_temp2;
    % ESA_TimeTrace(:,N) = dataArray;
    N = N+1;
end

ESA_TimeTrace_1 = cell2mat(dataArray1);
ESA_TimeTrace_2 = cell2mat(dataArray2);
    SPAN_F1 = ss_f1;
    CENT_F1 = cc_f1;
    SPAN_F2 = ss_f2;
    CENT_F2 = cc_f2;
    
% f = (CENT_F-SPAN_F/2):SPAN_F/n:(CENT_F+SPAN_F);
f1 = linspace((CENT_F1-SPAN_F1/2),(CENT_F1+SPAN_F1/2),length(ESA_TimeTrace_1));
f2 = linspace((CENT_F2-SPAN_F2/2),(CENT_F2+SPAN_F2/2),length(ESA_TimeTrace_2));
save(F,'dataArray1','f1','t','dataArray2','f2')
figure(1);clf;

    subplot(2,2,1)
    imagesc(ESA_TimeTrace_1);colorbar
    subplot(2,2,3)
    plot(f1,ESA_TimeTrace_1');
    subplot(2,2,2)
    imagesc(ESA_TimeTrace_2);colorbar
    subplot(2,2,4)
    plot(f2,ESA_TimeTrace_2');
    


