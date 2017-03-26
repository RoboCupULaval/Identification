clear all
%% Model:

nwheel = 3;

m = 2.2;
L = 0.085;
tau_moteur = 0.2;
gain_moteur = 2*pi*6;
J = 0.5*m*L^2;
r = 0.025;
gear_ratio = 3.2;

theta = (1:nwheel)*pi/2-pi/4;
Mc = [-cos(theta') -sin(theta') L*ones(nwheel,1)];
Mm = diag([1/m 1/m 1/J]);

Gb = J/tau_moteur;
Ga = gain_moteur*Gb;

Ma = Ga*eye(nwheel);
Mb = Gb*eye(nwheel);

M1 = Mc*Mm*Mc'*Ma/r;
M2 = Mc*Mm*Mc'*Mb/r;


%% Controller

dt = 1/20;

Kp = 7*eye(nwheel);
Ki = 25*eye(nwheel);

gamma = -1/0.2;

N = 1000;

w_ref = zeros(nwheel,N);
w_ref(1:3,100:500) = 15;


w    = zeros(nwheel,N);
w_m  = zeros(nwheel,N);
u    = zeros(nwheel,N);
err  = zeros(nwheel,N);
errI = zeros(nwheel,N);

for i = 2:N
      
    w(:,i) = w(:,i-1) + (M1*u(:,i-1)-M2*w(:,i-1)).*(1+0.5*randn(nwheel,1))*dt + 0*rand(nwheel,1);
    
    w_m(:,i) = w_m(:,i-1)./(1-dt*gamma) - (dt*gamma/(1-dt*gamma)).*w_ref(:,i); % filtered tracking reference

    err(:,i) = w_m(:,i) - w(:,i); % Tracking error
    errI(:,i) = errI(:,i-1) + err(:,i)*dt;
    
    PI_action = Kp*err(:,i) + Ki*errI(:,i);
    u(:,i) = M1\( gamma*(w_m(:,i)-w_ref(:,i)) + M2*w(:,i) + PI_action);
    u(u(:,i) > 1,i) = 1;
    u(u(:,i) < -1,i) = -1;
end


figure(3)

t = (1:N)*dt;

subplot(1,3,1)
plot(t, u(1,:)), hold on
plot(t, w_m(1,:))
plot(t, w(1,:)), hold off
legend('u','w_m','w')

subplot(1,3,2)
plot(t, u(2,:)), hold on
plot(t, w_m(2,:))
plot(t, w(2,:)), hold off
legend('u','w_m','w')

subplot(1,3,3)
plot(t, u(3,:)), hold on
plot(t, w_m(3,:))
plot(t, w(3,:)), hold off
legend('u','w_m','w')