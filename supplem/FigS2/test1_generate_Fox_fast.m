%
% Test suite for generate_Fox_fast.m
%
% Sep 2nd 2010 - Michele Giugliano, PhD
%

dt   = 0.001; % same units of 1/alpha or 1/beta 

M    = fix(3 * 30. / dt); % transient to be ignored
Npts = M + 10000000.;   % number of points to be generated
R    = 5;           % number of repetition per point

% Desired range of Voltages
Vd   =  -60:5:50;

% Actual estimate of the std and their std of the estimator
mUe    = zeros(size(Vd));
smUe   = zeros(size(Vd));
sUe    = zeros(size(Vd));
ssUe   = zeros(size(Vd));

theory_mUe = zeros(size(Vd));
theory_sUe = zeros(size(Vd));

ind   = 1;

for V=Vd,
% CHOSE ONE SET OF ALPHA, BETA FROM BELOW ---------------------------------
%
%
%if (V==-40), alpha_m = 1; else alpha_m = -0.1 * (V+40.)/(exp(-0.1*(V+40.)) -1.); end;
%beta_m  =   4. * exp(-(V+65.)/18.);
%alpha_h =   0.07 * exp(-(V+65.)/20.);
%beta_h  =   1. / (exp(-0.1 * (V+35.)) + 1.);
%if (V==-55), alpha_n = 0.1; else alpha_n = -0.01 * (V+55.)/ ( exp(-0.1*(V+55.)) - 1. ); end
%beta_n  =   0.125 * exp(-(V+65.)/80.);

if (V==-55), alpha_n = 0.1; else alpha_n = -0.01 * (V+55.)/ ( exp(-0.1*(V+55.)) - 1. ); end
beta_n  =   0.125 * exp(-(V+65.)/80.);
alpha = alpha_n;
beta  = beta_n;
%--------------------------------------------------------------------------
 
    
 tmp1 = zeros(R,1);
 tmp2 = zeros(R,1);
 Nchan = 100.;
 
 for h=1:R,
  out = generate_Fox_fast(V, dt, Nchan, alpha, beta, Npts);
  out = out(M:end);
  tmp1(h) = mean(out);
  tmp2(h) = std(out);
 end
  
 mUe(ind)   = mean(tmp1);
 smUe(ind) = std(tmp1);
 sUe(ind)  = mean(tmp2);
 ssUe(ind) = std(tmp2);

 theory_mUe(ind) = alpha/(alpha+beta);
 theory_sUe(ind) = sqrt((1./Nchan)*alpha*beta/(alpha+beta)^2);
 
 ind = ind + 1;
 disp(sprintf('%.0f %% done...', 100. * (V-Vd(1))/(Vd(end)-Vd(1))));
end

clf;
figure(1);
hold on;
P = plot(Vd, theory_mUe);
set(P, 'Color', [0 0 0], 'LineWidth', 1);

Q = errorbar(Vd, mUe, smUe);
set(Q, 'LineStyle', 'none', 'Marker', 'o', 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [0 0 0], 'Color', [0 0 0]);

set(gca, 'XLim', [-65 55], 'XTick', [-60:10:50]);
set(gca, 'FontName', 'Arial', 'FontSize', 15, 'XGrid', 'on', 'YGrid', 'on', 'box', 'on');
xlabel('V', 'FontSize', 20); ylabel('< u >', 'FontSize', 20)
print(gcf, 'panel1.eps', '-loose', '-depsc2');
print(gcf, 'panel1.png', '-loose', '-dpng');


clf
figure(2);
hold on;
P = plot(Vd, theory_sUe);
set(P, 'Color', [0 0 0], 'LineWidth', 1);

Q = errorbar(Vd, sUe, ssUe);
set(Q, 'LineStyle', 'none', 'Marker', 'o', 'MarkerFaceColor', [0 0 0], 'MarkerEdgeColor', [0 0 0], 'Color', [0 0 0]);

set(gca, 'XLim', [-65 55], 'XTick', [-60:10:50]);
set(gca, 'FontName', 'Arial', 'FontSize', 15, 'XGrid', 'on', 'YGrid', 'on', 'box', 'on');
xlabel('V', 'FontSize', 20); ylabel('\sigma_u', 'FontSize', 20)
print(gcf, 'panel2.eps', '-loose', '-depsc2');
print(gcf, 'panel2.png', '-loose', '-dpng');



