

clear all;
clear all;

% Get all visa objects
osa_FF = visa('ni', 'GPIB1::1::INSTR'); % Replace with your instrument's VISA address
osa_FF.InputBufferSize = 2^16;
osa_SHG = visa('ni', 'GPIB0::2::INSTR'); % Replace with your instrument's VISA address
osa_SHG.InputBufferSize = 2^16;

ESA_SHG = visa('ni', 'GPIB2::18::INSTR'); % Replace with your instrument's VISA address
ESA_SHG.InputBufferSize = 2^16;

ESA_FF = visa('ni','USB0::0x1AB1::0x0960::DSA8E203500075::INSTR');
ESA_FF.InputBufferSize = 2^16;


% Send Commands to New Yokogawa
set(osa_SHG,'Timeout',10);
fopen(osa_SHG);
fprintf(osa_SHG,'*IDN?');
fprintf(osa_SHG,':sens:wav:cent 786nm');
fprintf(osa_SHG,':sens:wav:span 15nm');
fprintf(osa_SHG,':sens:sweep:points 3000');
fprintf(osa_SHG,':sens:sens high2')



% Send Commands to old Yokogawa
set(osa_FF,'Timeout',10);
fopen(osa_FF);
fprintf(osa_FF,'*IDN?');
fprintf(osa_FF,':sens:wav:cent 1571.9nm');
fprintf(osa_FF,':sens:wav:span 60nm');
fprintf(osa_FF,':sens:sweep:points 3000');
fprintf(osa_FF,':sens:sens high2');

% Configure the ESA For SHG
fopen(ESA_SHG);
fprintf(ESA_SHG,'*IDN?');
fscanf(ESA_SHG)

fopen(ESA_FF);
fprintf(ESA_FF,'*IDN?');
fscanf(ESA_FF)

% ESA Measurement Options
    SPAN_F1 = 4.0e9;
    ss_f1 = SPAN_F1;
    CENT_F1 = 2.1E9;
    cc_f1 = CENT_F1;
    RBW1 = 1e6;
    nP1 = 1000;


    SPAN_F2 = 5e6;
    ss_f2 = SPAN_F2;
    CENT_F2 = 380.127E6;
    cc_f2 = CENT_F2;
    RBW2 = 1e3;
    nP2 = 3000;

fprintf(ESA_SHG,strcat(':FREQ:CENT '+" ",num2str(CENT_F1)));
fprintf(ESA_SHG,strcat(':FREQ:SPAN '+" ",num2str(SPAN_F1)));
fprintf(ESA_SHG,strcat(':BANDWIDTH:RESolution'+" ",num2str(RBW1)));
fprintf(ESA_SHG,strcat(':SWE:POIN'+" ",num2str(nP1)));


fprintf(ESA_FF,strcat(':FREQ:CENT '+" ",num2str(CENT_F1)));
fprintf(ESA_FF,strcat(':FREQ:SPAN '+" ",num2str(SPAN_F1)));
fprintf(ESA_FF,strcat(':BANDWIDTH:RESolution'+" ",num2str(RBW1)));
fprintf(ESA_FF,strcat(':SWE:POIN'+" ",num2str(nP1)));
pause(2)

% Naming Convention
NAME = 'outfile__5192025_DROPO';
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
    fprintf(ESA_SHG, ':INIT');
    fprintf(ESA_FF, ':INIT');

    % Tell OSA's too take one sweep
    fprintf(osa_FF,':init:smode 1');
    fprintf(osa_SHG,':init:smode 1');
    fprintf(osa_FF,':init');
    fprintf(osa_SHG,':init');
    
    
    % Get OSA data save to Memory INT for internal EXT for External 
    
    
    
    % Scan the RF Spectrum Device
    fprintf(ESA_SHG, ':TRAC? TRACE1');
    fprintf(ESA_FF, ':TRAC? TRACE1');
    pause(0.5)
    ESAdata_SHG_longScan{i} = fscanf(ESA_SHG);
    ESAdata_FF_longScan{i} = fscanf(ESA_FF);
    % Pause so data can be downloaded

    % Scan RF spec 2 closer in
fprintf(ESA_SHG,strcat(':FREQ:CENT '+" ",num2str(CENT_F2)));
fprintf(ESA_SHG,strcat(':FREQ:SPAN '+" ",num2str(SPAN_F2)));
fprintf(ESA_SHG,strcat(':BANDWIDTH:RESolution'+" ",num2str(RBW2)));
fprintf(ESA_SHG,strcat(':SWE:POIN'+" ",num2str(nP2)));
    % Scan RF spec 2 Closer in on fund rep Rate
fprintf(ESA_FF,strcat(':FREQ:CENT '+" ",num2str(CENT_F2)));
fprintf(ESA_FF,strcat(':FREQ:SPAN '+" ",num2str(SPAN_F2)));
fprintf(ESA_FF,strcat(':BANDWIDTH:RESolution'+" ",num2str(RBW2)));
fprintf(ESA_FF,strcat(':SWE:POIN'+" ",num2str(nP2)));
    % Init RF spectrum since this takes longest
    fprintf(ESA_SHG, ':INIT:CONT off');
    fprintf(ESA_FF, ':INIT:CONT off');
    pause(25)
    fprintf(ESA_SHG, ':TRAC? TRACE1');
    ESAdata_SHG_shortScan{i} = fscanf(ESA_SHG);
    fprintf(ESA_FF, ':TRAC? TRACE1');
    ESAdata_FF_shortScan{i} = fscanf(ESA_FF);
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

fprintf(ESA_SHG,strcat(':FREQ:CENT '+" ",num2str(CENT_F1)));
fprintf(ESA_SHG,strcat(':FREQ:SPAN '+" ",num2str(SPAN_F1)));
fprintf(ESA_SHG,strcat(':BANDWIDTH:RESolution'+" ",num2str(RBW1)));
fprintf(ESA_SHG,strcat(':SWE:POIN'+" ",num2str(nP1)));

fprintf(ESA_FF,strcat(':FREQ:CENT '+" ",num2str(CENT_F1)));
fprintf(ESA_FF,strcat(':FREQ:SPAN '+" ",num2str(SPAN_F1)));
fprintf(ESA_FF,strcat(':BANDWIDTH:RESolution'+" ",num2str(RBW1)));
fprintf(ESA_FF,strcat(':SWE:POIN'+" ",num2str(nP1)));

    fprintf(ESA_SHG, ':INIT:CONT on');
    fprintf(ESA_FF, ':INIT:CONT on');

nDat = i-1;
fclose(ESA_SHG);
fclose(ESA_FF);
fclose(osa_FF);
fclose(osa_SHG);
% Delete
delete(ESA_SHG);
delete(ESA_FF);
delete(osa_FF);
delete(osa_SHG);
clear ESA_SHG osa_FF osa_SHG ESA_FF;
%% PROCESSING DATA
disp('Processing Data')
% Process and save data
delimiter = ',';
N = 1;
while N<nDat+1
        disp(N);

    try
    C1 = strsplit(ESAdata_SHG_longScan{N},delimiter);
    C2 = strsplit(ESAdata_SHG_shortScan{N},delimiter);
    catch
        % disp(N);
        N = nDat;
    end
    if N == 1
        SHGdataArray_longScan = cell(nDat,1);
        SHGdataArray_shortScan = cell(nDat,1);
    end
    dataArray_temp1 = zeros(1,length(C1));
    dataArray_temp2 = zeros(1,length(C2));
    for i = 1:length(C1)
        dataArray_temp1(i) = str2num(C1{i}); %#ok<ST2NM>
    end
    for i = 1:length(C2)
        dataArray_temp2(i) = str2num(C2{i}); %#ok<ST2NM>
    end
    SHGdataArray_longScan{N} = dataArray_temp1;
    SHGdataArray_shortScan{N} = dataArray_temp2;
    % ESA_TimeTrace(:,N) = dataArray;
    N = N+1;
end

%%%%% FF Esa Process Data
N = 1;
while N<nDat+1
        disp(N);

    try
    C3 = strsplit(ESAdata_FF_longScan{N},delimiter);
    C4 = strsplit(ESAdata_FF_shortScan{N},delimiter);
    catch
        % disp(N);
        N = nDat;
    end
    if N == 1
        FFdataArray_longScan = cell(nDat,1);
        FFdataArray_shortScan = cell(nDat,1);
    end
    dataArray_temp3 = zeros(1,length(C3));
    dataArray_temp4 = zeros(1,length(C4));
    for i = 1:length(C3)
        if i == 1
            str = C3{i};
            str = str(12:end);

        else
            str = C3{i};
        end
            dataArray_temp3(i) = str2num(str); %#ok<ST2NM>
    end
    for i = 1:length(C4)
        if i == 1
            str = C4{i};
            str = str(12:end);

        else
            str = C4{i};
        end
        dataArray_temp4(i) = str2num(str); %#ok<ST2NM>
    end
    FFdataArray_longScan{N} = dataArray_temp3;
    FFdataArray_shortScan{N} = dataArray_temp4;
    % ESA_TimeTrace(:,N) = dataArray;
    N = N+1;
end

%%%%%%% 



SHG_ESA_TimeTrace_longScan = cell2mat(SHGdataArray_longScan);
SHG_ESA_TimeTrace_shortScan = cell2mat(SHGdataArray_shortScan);
FF_ESA_TimeTrace_longScan = cell2mat(FFdataArray_longScan);
FF_ESA_TimeTrace_shortScan = cell2mat(FFdataArray_shortScan);
    SPAN_F1 = ss_f1;
    CENT_F1 = cc_f1;
    SPAN_F2 = ss_f2;
    CENT_F2 = cc_f2;

RBW_long = RBW1;
RBW_short = RBW2;
    
% f = (CENT_F-SPAN_F/2):SPAN_F/n:(CENT_F+SPAN_F);
f1 = linspace((CENT_F1-SPAN_F1/2),(CENT_F1+SPAN_F1/2),length(SHG_ESA_TimeTrace_longScan));
f2 = linspace((CENT_F2-SPAN_F2/2),(CENT_F2+SPAN_F2/2),length(SHG_ESA_TimeTrace_shortScan));
save(F,'RBW_long','RBW_short','SHG_ESA_TimeTrace_longScan','FF_ESA_TimeTrace_longScan','f1','t','SHG_ESA_TimeTrace_shortScan','FF_ESA_TimeTrace_shortScan','f2')
figure(1);clf;

    subplot(2,2,1)
    plot(f1,SHG_ESA_TimeTrace_longScan','Color',[0,0.7,0]);
    subplot(2,2,3)
    plot(f1,FF_ESA_TimeTrace_longScan','Color',[0.7,0,0]);
    subplot(2,2,2)
    plot(f2,SHG_ESA_TimeTrace_shortScan,'Color',[0,0.7,0]);
    subplot(2,2,4)
    plot(f2,FF_ESA_TimeTrace_shortScan','Color',[0.7,0,0]);
    


