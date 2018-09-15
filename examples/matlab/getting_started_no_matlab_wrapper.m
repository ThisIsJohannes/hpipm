% pyversion /usr/bin/python3
%  py.sys.path

% addpath("~/pytave")

clear all
close all
clc

% import python modules
np = py.importlib.import_module('numpy');
hp = py.importlib.import_module('hpipm_python');

% dims
N = 5;

tic
dims = hp.hpipm_ocp_qp_dim(int32(N));
tmp_time = toc
fprintf('create dim time %e\n', tmp_time);

dims.set_nx(np.array([2, 2, 2, 2, 2, 2], np.int32));
dims.set_nu(np.array([1, 1, 1, 1, 1], np.int32));
dims.set_nbx(int32(2), int32(0));
dims.set_nbx(int32(2), int32(5));

dims.print_C_struct()


% data
A = np.array([1, 0, 1, 1]);
B = np.array([0, 1]);
%b = np.array([0, 0]);

Q = np.array([1, 0, 0, 1]);
S = np.array([0, 0]);
R = np.array([1]);
q = np.array([1, 1]);
%r = np.array([0]);

Jx = np.array([1, 0, 0, 1]);
x0 = np.array([1, 1]);
Jsx = np.array([1, 0, 0, 1]);
Zl = np.array([1e5, 0, 0, 1e5]);
Zu = np.array([1e5, 0, 0, 1e5]);
zl = np.array([1e5, 1e5]);
zu = np.array([1e5, 1e5]);


% qp
tic
qp = hp.hpipm_ocp_qp(dims);
tmp_time = toc
fprintf('create qp time %e\n', tmp_time);

tic
qp.set_A(py.list({A, A, A, A, A}))
tmp_time = toc
fprintf('create set A time %e\n', tmp_time);
qp.set_B(py.list({B, B, B, B, B}))
%qp.set_b(py.list({b, b, b, b, b}))
qp.set_Q(py.list({Q, Q, Q, Q, Q, Q}))
qp.set_S(py.list({S, S, S, S, S}))
qp.set_R(py.list({R, R, R, R, R}))
qp.set_q(py.list({q, q, q, q, q, q}))
%qp.set_r(py.list({r, r, r, r, r}))
qp.set_Jx(Jx, int32(0))
qp.set_lx(x0, int32(0))
qp.set_ux(x0, int32(0))
qp.set_Jx(Jx, int32(5))

qp.print_C_struct()


% qp sol
tic
qp_sol = hp.hpipm_ocp_qp_sol(dims);
tmp_time = toc
fprintf('create qp_sol time %e\n', tmp_time);


% set up solver
tic
solver = hp.hpipm_ocp_qp_solver(dims);
tmp_time = toc
fprintf('create solver time %e\n', tmp_time);


% solve qp
tic
return_flag = solver.solve(qp, qp_sol);
tmp_time = toc
fprintf('solve time %e\n', tmp_time);

%fprintf('HPIPM returned with flag %d\n', return_flag);

%if return_flag == 0:
%    print('-> QP solved! Solution:\n')
    qp_sol.print_C_struct()
%else:
%    print('-> Solver failed!')

% extract and print sol
%print('u =')
%u = qp_sol.get_u()
%for i in range(N+1):
%	print(u[i])

%print('x =')
%for i in range(N+1):
%	tmp = qp_sol.get_x(i)
%	print(tmp)




return



% old example



qp_data = hp.hpipm_data();

A = m2py([1, 0; 1, 1], np);
B = m2py([0, 1].', np);
b = m2py([0, 0].', np);

Q = m2py([1, 0; 0, 1], np);
S = m2py([0, 0].', np);
R = m2py([1].', np);
q = m2py([1, 1].', np);
r = m2py([0].', np);

qp_data.A = py.list({A, A, A, A, A});
qp_data.B = py.list({B, B, B, B, B});
qp_data.b = py.list({b, b, b, b, b});
qp_data.Q = py.list({Q, Q, Q, Q, Q, Q});
qp_data.S = py.list({S, S, S, S, S, S});
qp_data.R = py.list({R, R, R, R, R, R});
qp_data.q = py.list({q, q, q, q, q, q});
qp_data.r = py.list({r, r, r, r, r, r});

x0 = m2py([1, 1].', np);

qp_data.d_lb = py.list({x0});
qp_data.d_ub = py.list({x0});

qp_data.idxb = py.list({m2py([1, 2].', np)});

qp_dims = hp.hpipm_dims();

qp_dims.nx   = m2py([2, 2, 2, 2, 2, 2].', np);
qp_dims.nu   = m2py([1, 1, 1, 1, 1, 0].', np);
qp_dims.nb   = m2py([2, 0, 0, 0, 0, 0].', np);
qp_dims.nbx  = m2py([2, 0, 0, 0, 0, 0].', np);
qp_dims.nbu  = m2py([0, 0, 0, 0, 0, 0].', np);
qp_dims.ng   = m2py([0, 0, 0, 0, 0, 0].', np);
qp_dims.ns   = m2py([0, 0, 0, 0, 0, 0].', np);
qp_dims.nsbx = m2py([0, 0, 0, 0, 0, 0].', np);
qp_dims.nsbu = m2py([0, 0, 0, 0, 0, 0].', np);
qp_dims.nsg  = m2py([0, 0, 0, 0, 0, 0].', np);
qp_dims.N    = int32(5);

% set up solver
solver = hp.hpipm_solver(qp_dims, qp_data);

% solve qp
return_flag = solver.solve();

solver.print_sol();

