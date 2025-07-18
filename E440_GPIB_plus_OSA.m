clear all;
device = visa('ni', 'GPIB0::18::INSTR'); % Replace with your instrument's VISA address
device.InputBufferSize = 2^14;
osa = visa('ni', 'GPIB1::1::INSTR'); % Replace with your instrument's VISA address
osa.InputBufferSize = 2^16;
% set(osa,'Terminator', 'CR/LF');
set(osa,'Timeout',10);
fopen(osa);
fprintf(osa,'*IDN?');
% fprintf(osa,':sens:wav:cent 1571.9nm');
% fprintf(osa,':sens:wav:cent 65nm');
% fprintf(osa,':sens:sweep:points 1500');

fprintf(osa,':sens:wav:cent 785.95nm');
fprintf(osa,':sens:wav:cent 20.0nm');
fprintf(osa,':sens:sweep:points 1500');

nn = 10;



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
Twin = 700+30;
tic
i = 1;
while toc<Twin

    fprintf(device, ':INIT');
    fprintf(device, ':TRAC? TRACE1');
    data{i} = fscanf(device);
    t(i) = toc;

    % OSA data
    fprintf(osa,':init:smode 1');
    fprintf(osa,':init');
    STR = strcat('"Sweep_',num2str(i),'"');
    fprintf(osa,[":mmem:stor:ATR "+STR+",ext"]);

    pause(0.25)
    i = i+1;

end

nDat = i-1;
fclose(device);
fclose(osa)
delete(osa)
delete(device);
clear device osa;
%% 
disp('Processing Data')
% Process and save data
delimiter = ',';
N = 1;
while N<nDat+1
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


