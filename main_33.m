%% Clear Space
clc
clear
close all
warning off
%% Input system parameters
mpc = IEEE33;
nb=33;                              % Number of nodes
ns=1;                               % Number of power nodes
nl=37;                              % Number of branches
P_load=mpc.bus(:,3)/mpc.baseMVA;    % Active load demand
Q_load=mpc.bus(:,4)/mpc.baseMVA;    % Reactive load demand
r_ij=mpc.branch(:,3);               % Resistance
x_ij=mpc.branch(:,4);               % Reactance
M=1.06*1.06 - 0.94*0.94;
% Maximum power
P_g_max=zeros(nb,1);
P_g_max(1)=10/mpc.baseMVA;
Q_g_max=zeros(nb,1);
Q_g_max(1)=10/mpc.baseMVA;
% Minimum power supply
P_g_min=zeros(nb,1);
Q_g_min=[-10/mpc.baseMVA;zeros(nb-1,1)];
% Maximum branch power
Sij_max=8/mpc.baseMVA;
% Maximum voltage
Umax=[1;1.1*1.1*ones(32,1)];
Umin=[1;0.9*0.9*ones(32,1)];
% Branches that flow into nodes
branch_to_node=zeros(nb,nl);
% Branches that flow outflow nodes
branch_from_node=zeros(nb,nl);
for k=1:nl
    branch_to_node(mpc.branch(k,2),k)=1;
    branch_from_node(mpc.branch(k,1),k)=1;
end

%% variable
z_ij=binvar(nl,1);          % Branch status
U_i=sdpvar(nb,1);           % Square of voltage
L_ij=sdpvar(nl,1);          % Square of current
P_ij=sdpvar(nl,1);          % Line active power
Q_ij=sdpvar(nl,1);          % Line reactive power
P_g=sdpvar(nb,1);           % Active output of power supply
Q_g=sdpvar(nb,1);           % Power reactive power

%% Constraints for distribution networks reconfiguration
Constraints = [];
%% 1.Power flow constraints
m_ij=(1-z_ij)*M; 
Constraints = [Constraints, P_g-P_load+branch_to_node*P_ij-branch_to_node*(L_ij.*r_ij)-branch_from_node*P_ij == 0];
Constraints = [Constraints, Q_g-Q_load+branch_to_node*Q_ij-branch_to_node*(L_ij.*x_ij)-branch_from_node*Q_ij == 0];
Constraints = [Constraints,U_i(mpc.branch(:,1))-U_i(mpc.branch(:,2))<= m_ij + 2*r_ij.*P_ij + 2*x_ij.*Q_ij - ((r_ij.^2 + x_ij.^2)).*L_ij];
Constraints = [Constraints,U_i(mpc.branch(:,1))-U_i(mpc.branch(:,2))>= -m_ij + 2*r_ij.*P_ij + 2*x_ij.*Q_ij - ((r_ij.^2 + x_ij.^2)).*L_ij];
for k=1:nl
    Constraints = [Constraints, cone([2*P_ij(k) 2*Q_ij(k) L_ij(k)-U_i(mpc.branch(k,1))],L_ij(k)+U_i(mpc.branch(k,1)))];
end
Constraints = [Constraints, Sij_max'.^2.*z_ij >= P_ij.^2+Q_ij.^2];
Constraints = [Constraints, Umin <= U_i,U_i <= Umax];


%% 2.Topological constraints
Constraints = [Constraints , sum(z_ij) == nb-ns];

%% 3.Injection power constraint
Constraints = [Constraints, P_g>=P_g_min,P_g<=P_g_max];
Constraints = [Constraints, Q_g>=Q_g_min,Q_g<=Q_g_max];
%% objective function
objective = sum(L_ij.*r_ij);%ÍøËð×îÐ¡
%% Solver settings
ops=sdpsettings('verbose', 1, 'solver', 'gurobi');
sol=optimize(Constraints,objective,ops);
value(objective)

%% Output AMPL model
% saveampl(Constraints,objective,'mymodel');

%% Analysis of Error
if sol.problem == 0
    disp('Solved successfully');
else
    disp('Error');
    yalmiperror(sol.problem)
end
%% Output Results
P_ij=value(P_ij)*10;
Q_ij=value(Q_ij)*10;
P_g=value(P_g)*10;
Q_g=value(Q_g)*10;
z_ij=value(z_ij);
U_i=value(U_i);
L_ij=value(L_ij);
P_loss=L_ij.*r_ij*1000*mpc.baseMVA;
result=runpf('IEEE33');
P_loss0=(result.branch(:,14)+result.branch(:,16))*1000;
V0=result.bus(:,8);
disp('******************Before reconfiguration******************')
disp(['The disconnected branch is£º',num2str(33:37)])
disp(['The system network loss is£º',num2str(sum(P_loss0)),'kW'])
disp(['The minimum node voltage is£º',num2str(min(V0))])
disp('******************After reconfiguration******************')
disp(['The disconnected branch is£º',num2str(find(~z_ij)')])
disp(['The system network loss is£º',num2str(value(objective)*1000*mpc.baseMVA),'kW'])
disp(['The minimum node voltage is£º',num2str(min(sqrt(U_i)))])
figure
plot(V0,'k','linewidth',1)
hold on
plot(sqrt(U_i),'k--','linewidth',1)
title('Node voltage comparison')
xlabel('Nodes')
ylabel('voltage amplitude/pu')
legend('Before reconfiguration','After reconfiguration')
figure
plot(P_loss0,'k--','linewidth',1)
hold on
plot(P_loss,'k','linewidth',1)
title('Comparison of branch active power losses')
ylabel('Branch active power loss/kW')
xlabel('Nodes')
legend('Before reconfiguration','After reconfiguration')