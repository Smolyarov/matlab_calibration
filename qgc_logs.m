close all
clear all
clc

num_logfiles = 6;
B_mag = 500;
B_acc = 9.81;
B_gyr = 0;
temp_base = 30; % celsius
temp_lo = 36;
temp_hi = 61;
fit_order = 1;

cnt = 0;
for i = 1:num_logfiles
    load(strcat(int2str(i),'.mat'));
    disp(strcat(int2str(i),'.mat'));
    log_data = [double(acc)./1000 round(temp)];
    
    for t = temp_lo:temp_hi
        log_part = log_data(log_data(:,4)==t,:); % measurements with equal temperature
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
for t = temp_lo:temp_hi
    imuCalibrator = Calibrator('vectorModule', B_acc, ...
                           'calibrationParametersCount', 6, ...
                           'type', 'recursive', ...
                           'R', 5, ...
                           'P', 1e30);
    calib_in = (prep_data(prep_data(:,4)==t,1:3))';
    calib_out = zeros(3,pointsCount);
    input_mod = zeros(1, pointsCount);
    output_mod = zeros(1, pointsCount);
    if (~isempty(calib_in))
%         t
%         calib_in
        for i = 1 : pointsCount
        imuCalibrator.calibration(calib_in(:,i));
        end
        for i = 1 : pointsCount
        calib_out(:, i) = imuCalibrator.correction(calib_in(:, i));
        input_mod(1,i) = norm(calib_in(:, i));
        output_mod(1,i) = norm(calib_out(:, i));
        end   
        cnt = cnt + 1;
        WINV(cnt,:) = diag(imuCalibrator.Winv);
        BIAS(cnt,:) = imuCalibrator.bias;
    end
end
temp = (temp_lo:temp_hi)';
for i = 1:3
    Pbias(i,:) = polyfit(temp,BIAS(:,i),fit_order);
    Pscale(i,:) = polyfit(temp,WINV(:,i),fit_order);
end
%accel
Pbias 
Pscale

%% gyro (bias only)
load('gyro.mat');
clear prep_data
log_data = [double(gyro)./1000 round(temp)];

cnt = 0;
    for t = temp_lo:temp_hi
        log_part = log_data(log_data(:,4)==t,:); % measurements with equal temperature
        if (~isempty(log_part))
            cnt = cnt + 1;
            meas_avg = mean(log_part,1);
            prep_data(cnt,1) = meas_avg(1);
            prep_data(cnt,2) = meas_avg(2);
            prep_data(cnt,3) = meas_avg(3);
            prep_data(cnt,4) = meas_avg(4);
        end
    end
BIAS_gyro = prep_data(:,1:3);

temp = (temp_lo:temp_hi)';
for i = 1:3
    Pbias_gyro(i,:) = polyfit(temp,BIAS_gyro(:,i),fit_order);
end
Pbias_gyro

temp = 36:61;
for i = 1:3
    acc_bias(:,i) = polyval(Pbias(i,:),temp);
    gyro_bias(:,i) = polyval(Pbias_gyro(i,:),temp);
end
figure
subplot 231; plot(temp,BIAS);title('acc actual');
subplot 234; plot(temp,BIAS_gyro);title('gyro actual');
subplot 232; plot(temp,acc_bias);title('acc estimate');
subplot 235; plot(temp,gyro_bias);title('gyro estimate');
subplot 233; plot(temp,abs(BIAS-acc_bias));title('err');
subplot 236; plot(temp,abs(BIAS_gyro-gyro_bias));title('err');