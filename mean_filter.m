clear all;
pkg load signal;

% The sampling frequency in Hz.
Fs = 1000;

% Sampling time
T = 1/Fs;

% Buffer length
L = 300;

% Create a time base
t = (0:L-1)*T;
input = 400*sin(2*pi*5*t+pi/3) + 60*randn(size(t));

% moving average
moving_average = input;
N = 10;
moving_average(N) = (1/N)*(sum(input(1:N)));
for i=N+1:L
  moving_average(i) = moving_average(i-1) + ((1/N)*(input(i) - input(i-N)));
end

% pt1 filter
pt1_filter = input;
K = 1;
Tau = (5*T)-T;
for i=2:L
  pt1_filter(i) = pt1_filter(i-1) + ((T/(Tau+T))*(K*input(i) - pt1_filter(i-1)));
end

input_response = zeros(1,L);
pt1_filter_response = input_response;
for i=2:L
  input_response(i) = 1;
  pt1_filter_response(i) = pt1_filter_response(i-1) + ((T/(Tau+T))*(K*input_response(i) - pt1_filter_response(i-1)));
end

% LP first order
lp_filter = input;
b = K*(1-exp(-(T/Tau))); %0.0625;
a = -exp(-(T/Tau)); %0.9375;
for i=2:L
   lp_filter(i) = b*input(i) - a*lp_filter(i-1);
end

% Median filter
median_filter = input;
median_sorted = zeros(1,9);
M = 9;
for i=M:L
   med_vals = input(i-M+1:i);
   med_vals_sort = sort(med_vals);
   if( i == 50 )
    median_sorted = med_vals_sort;
   endif
   median_filter(i) = med_vals_sort(((M/2)+0.5));
end

% Morphological filter
morph_filter = input;
FilterMax = input;
FilterMin = input;
Mask1 = [10 5 0 5 10];
Mask2 = [-10 -5 0 -5 -10];
for i=5:L
  masked = input(i-4:i)-Mask1(1:5);
  FilterMax(i) = max(masked);
  masked = input(i-4:i)-Mask2(1:5);
  FilterMin(i) = min(masked);
  morph_filter(i) = (FilterMax(i)+FilterMin(i))/2;
end


figure(1)
subplot(1,1,1)
clf
plot(t,input,'Color',[0.5 0.5 0.5])
hold on
plot(t,lp_filter,'r')
hold on
plot(t,moving_average,'b')
hold on
plot(t,pt1_filter,'g')
hold on
plot(t,median_filter,'m')
hold on
plot(t,morph_filter,'c')
hold on
%axis([0 0.21 -600 600])
axis([0.01 0.04 200 600])
%ylabel('Input signal')
%xlabel('Time in s','fontweight','normal','FontName','Arial', 'FontSize',10)
%title('Input signal','fontweight','normal','FontName','Arial', 'FontSize',12)
%legend('Noise','Low Pass','Moving Average','PT1','Median','Morphological Operators','Location','north')
legend('Noise','Low Pass','Moving Average','PT1','Median','Morphological Operators')
%axis off
%grid on
%{
subplot(2,1,2)
plot(t,output,'k')
%axis([0 0.2 0 1.2])
%ylabel('Output signal')
xlabel('Time in s','fontweight','normal','FontName','Arial', 'FontSize',10)
%axis([0 3 -2 30])
title('Output signal','fontweight','normal','FontName','Arial', 'FontSize',12)
grid on

bb = [b 0];
aa = [1 a];

[H,f] = freqz(bb,aa,2000,Fs); % Frequenzgang eines zeitdiskreten Systems

figure(2)
subplot(1,1,1)
%plot(ff,Ha)
semilogx(f,abs(H),'r')
axis([0 500 0 1.05])
%ylabel('Frequency response')
xlabel('f in Hz','fontweight','normal','FontName','Arial', 'FontSize',12)
%title('Frequency response','fontweight','normal','FontName','Arial', 'FontSize',12)
text(5,0.707,'f=fcut=(2 pi T)^{-1} @ 70.7% \rightarrow ','FontSize',12)
legend('Frequency response Low Pass','FontSize',12)
grid on
%}

figure(3)
subplot(1,1,1)
clf
plot(t,input_response,'Color',[0.5 0.5 0.5])
hold on
plot(t,pt1_filter_response,'g')
hold on
axis([-0.01 0.04 0 1.1])
text(0.005,0.63,'\leftarrow t=T @ 63%','FontSize',12)
%ylabel('Input signal')
xlabel('t in s','FontSize',12)
%title('Input signal','fontweight','normal','FontName','Arial', 'FontSize',12)
legend('Step','PT1 Response','FontSize',12)
%axis off
grid on

figure(4)
subplot(1,1,1)
clf
x = 1:9;
colours = { 'm', 'm', 'm', 'm', 'b', 'm', 'm', 'm', 'm' };
hold on
for i = 1 : 9
  H(i) = bar( x(i), median_sorted(i), 0.4, 'facecolor', colours{i} );
endfor
%bar(median_sorted, 'facecolor', colours{'g', 'g', 'g', 'g', 'y', 'r', 'r', 'r', 'r' })
hold on
%ylabel('Input signal')
%xlabel('t in s','FontSize',12)
%title('Input signal','fontweight','normal','FontName','Arial', 'FontSize',12)
%text(3.2,300,'Median value \downarrow','FontSize',12)
%legend('Median Filter','FontSize',12)
%axis off
grid on

figure(5)
subplot(1,1,1)
clf
plot(t,input,'Color',[0.5 0.5 0.5])
hold on
plot(t,FilterMax,'k.-')
hold on
plot(t,FilterMin,'k--')
hold on
plot(t,morph_filter,'c')
hold on
axis([0.01 0.04 100 700])
%text(0.005,0.63,'\leftarrow t=T @ 63%','FontSize',12)
%ylabel('Input signal')
xlabel('t in s','FontSize',12)
%title('Input signal','fontweight','normal','FontName','Arial', 'FontSize',12)
legend('Noise','Dilation','Erosion','Morphological Operation','FontSize',12)
%axis off
grid on
