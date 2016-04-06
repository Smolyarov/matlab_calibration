close all
clear all
clc

logfile_path = '/home/pilgrim/QGC_logs/';
num_logfiles = 6;
row_start = 7;
B_mag = 500;
B_acc = -9810;
B_gyr = 0;
temp_base = 30; % celsius
temp_hi = 48;
temp_lo = 44;

cnt = 0;
for i = 1:num_logfiles
    logfile = strcat(logfile_path,int2str(i),'_compressed.txt');
    disp(logfile);
    log_data = dlmread(logfile,'\t',row_start,1);
    log_data(:,4) = round(log_data(:,4)); % round temperature
    
    for temp = temp_lo:temp_hi
        log_part = log_data(log_data(:,4)==temp,:); % measurements with equal temperature
        if (~isempty(log_part))
            cnt = cnt + 1;
            meas_avg = mean(log_part,1);
            prep_data(cnt,1) = meas_avg(1);
            prep_data(cnt,2) = meas_avg(2);
            prep_data(cnt,3) = meas_avg(3);
            prep_data(cnt,4) = meas_avg(4);
%             prep_data(cnt,:)
        end
    end
end
% at this point we have prep_data array which contains
% one measurement(x,y,z) per orientation per degree celsius

% for calibration we need measurements with equal temperature
% but various orientations

pointsCount = num_logfiles;

cnt = 0;
for temp = temp_lo:temp_hi
    imuCalibrator = Calibrator('vectorModule', B_acc, ...
                           'calibrationParametersCount', 6, ...
                           'type', 'recursive', ...
                           'R', 5, ...
                           'P', 1e30);
    calib_in = (prep_data(prep_data(:,4)==temp,1:3))';
    calib_out = zeros(3,pointsCount);
    input_mod = zeros(1, pointsCount);
    output_mod = zeros(1, pointsCount);
    if (~isempty(calib_in))
        temp
        calib_in
        for i = 1 : pointsCount
        imuCalibrator.calibration(calib_in(:,i));
        end
        for i = 1 : pointsCount
        calib_out(:, i) = imuCalibrator.correction(calib_in(:, i));
        input_mod(1,i) = norm(calib_in(:, i));
        output_mod(1,i) = norm(calib_out(:, i));
        end   
%         imuCalibrator.bias
%         imuCalibrator.Winv
        cnt = cnt + 1;
        WINV(cnt,:) = diag(imuCalibrator.Winv);
        BIAS(cnt,:) = imuCalibrator.bias;
        
        
%         figure
%         plot3(calib_in(1,:),calib_in(2,:),calib_in(3,:),'r.');
%         hold on;
%         plot3(calib_out(1,:),calib_out(2,:),calib_out(3,:),'.');
%         axis equal
%         grid on
% 
%         figure;
%         plot(input_mod,'r');
%         hold on;
%         plot(output_mod,'b');
    end
end






% debug 43 - temp C