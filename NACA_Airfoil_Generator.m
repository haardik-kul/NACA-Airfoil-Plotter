%% ========================================================================
%  NACA 4 & 5-Digit (Standard) Airfoil Geometry Generator
%  ------------------------------------------------------------------------
%  This MATLAB script plots the airfoil geometry (upper, lower, and camber
%  lines) for standard NACA 4-digit and 5-digit series based on user input.
%
%  Author: Haardik Kulshreshtha
%
%  Description:
%  - Accepts a user-defined NACA airfoil number (4 or 5 digits)
%  - Extracts camber, thickness, and position parameters
%  - Computes mean camber line, thickness distribution, and surface points
%  - Generates a professional plot showing the airfoil geometry
%  ------------------------------------------------------------------------

%% ---------------------- Define Chord Line Parameters --------------------
c = 1;                % Maximum Chord Length (normalized)
x_overall = c;        % Overall chord length reference


%% ---------------------- User Input: NACA Airfoil ------------------------
NACA_airfoil = input("Enter the desired NACA Airfoil Number -  \n"); 
num_digits = floor(log10(abs(NACA_airfoil))) + 1;  % Determine if 4- or 5-digit


%% ========================================================================
%  NACA 4-DIGIT SERIES IMPLEMENTATION
%  ------------------------------------------------------------------------
%  NACA 4-digit format: MPXX
%  - M = maximum camber (as % of chord)
%  - P = position of max camber (in tenths of chord)
%  - XX = thickness (as % of chord)

if (num_digits == 4)

    % Extract basic parameters from NACA number
    t = rem((NACA_airfoil),100) / 100;       % Max thickness ratio
    naca_update = floor(NACA_airfoil / 100);
    p = rem((naca_update),10) / 10;          % Max camber position
    naca_update = floor(naca_update / 10);
    m = naca_update / 100;                   % Max camber value

    % Define x-coordinates (split before and after max camber)
    x_0_to_p = 0:0.00001:(p*x_overall);
    x_p_to_c = (p*x_overall):0.0001:c;
    x_vector = [x_0_to_p x_p_to_c];

    % Mean camber line equation (NACA 4-digit standard)
    Y_c_1 = (m/(p.^2)) .* ((2.*p.*x_0_to_p) - (x_0_to_p).^2);
    Y_c_2 = (m / ((1 - p)^2)) .* ((1 - 2*p) + 2*p.*x_p_to_c - x_p_to_c.^2);
    Y_C = [Y_c_1 Y_c_2];

    % Slope and angle calculations
    dyc = diff(Y_C);
    dx = diff(x_vector);
    theta_update = atan(dyc./dx);
    theta = [theta_update, theta_update(end)];


%% ========================================================================
%  NACA 5-DIGIT SERIES IMPLEMENTATION
%  ------------------------------------------------------------------------
%  NACA 5-digit format: LPQXX
%  - L/P define design lift coefficient and camber position
%  - Q defines camber type (reflexed or non-reflexed)
%  - XX defines thickness

elseif (num_digits == 5)

    % Extract basic parameters from NACA number
    t = rem((NACA_airfoil),100) / 100;       % Max thickness ratio
    naca_update = floor(NACA_airfoil / 100);
    p = rem((naca_update),100) / 200;        % Max camber position

    % Determine constants (m, k1) from standard NACA definitions
    if p == 0.05
        m = 0.058;  k1 = 361.400;
    elseif p == 0.1
        m = 0.126;  k1 = 51.64;
    elseif p == 0.15
        m = 0.2025; k1 = 15.957;
    elseif p == 0.2
        m = 0.29;   k1 = 6.643;
    elseif p == 0.25
        m = 0.391;  k1 = 3.23;
    end

    % Define x-coordinates (split before and after max camber)
    c = 1; x_overall = 1;
    x_0_to_p = 0:0.000001:(p*x_overall);
    x_p_to_c = (p*x_overall):0.00001:c;
    x_vector = [x_0_to_p x_p_to_c];

    % Mean camber line equation (NACA 5-digit standard)
    Y_c_1 = (k1/6) .* ((x_0_to_p.^3) - (3*m*x_0_to_p.^2) + (m.^2.*(3 - m).*x_0_to_p));
    Y_c_2 = (k1*m^3/6) .* (1 - x_p_to_c);
    Y_C = [Y_c_1 Y_c_2];

    % Slope and angle calculations
    dyc_1 = (k1/6) * (3.*x_0_to_p.^2 - 6.*m.*x_0_to_p + m.^2.*(3 - m));
    dyc_2 = (-(k1 * m^3) / 6) * ones(1, (length(x_vector) - length(dyc_1)));
    dyc = [dyc_1 dyc_2];
    theta_update = atan(dyc);
    theta = theta_update;
end


%% ========================================================================
%  THICKNESS DISTRIBUTION (Common to Both 4- and 5-Digit Series)
%  ------------------------------------------------------------------------

Y_T = (t/.2) .* ( 0.2969 .* sqrt(x_vector) - 0.1260 .* x_vector ...
                 - 0.3516 .* x_vector.^2 + 0.2843 .* x_vector.^3 ...
                 - 0.1015 .* x_vector.^4 );


%% ========================================================================
%  UPPER AND LOWER SURFACE COORDINATES
%  ------------------------------------------------------------------------
%  Calculated using theta and thickness distribution.
%  xu, yu = upper surface | xl, yl = lower surface

x_u = x_vector - Y_T.*sin(theta);
y_u = Y_C + Y_T .* cos(theta);
x_l = x_vector + Y_T .* sin(theta);
y_l = Y_C - Y_T .* cos(theta);


%% ========================================================================
%  PLOTTING THE AIRFOIL GEOMETRY
%  ------------------------------------------------------------------------
%  Displays the chord line, upper/lower surfaces, and camber line.
%  Auto-generates a labeled plot with formatted axes and legend.

plot(x_vector, zeros(size(x_vector)), 'k--', 'LineWidth', 1);   % Chord line
hold on
plot(x_u, y_u, 'b', 'LineWidth', 1.5);                          % Upper surface
hold on
plot(x_l, y_l, 'r', 'LineWidth', 1.5);                          % Lower surface
hold on
plot(x_vector, Y_C, 'g--', 'LineWidth', 1.2);                   % Mean camber line
hold off

% Formatting for technical presentation
axis equal;
grid on;
xlabel('x / Chord length');
ylabel('y / Chord length');
legend('Chord Line', 'Upper Surface', 'Lower Surface', 'Camber Line', ...
       'Location', 'NorthEast');
title(sprintf('NACA %05d Airfoil Geometry', NACA_airfoil));
