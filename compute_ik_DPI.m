function q_ik= compute_ik_DPI(handle,q_cur,tar_p)
tic

% Iteration �ʱ� ����
dt=0.001;
maxiter = 30000;
threshold = 1e-4;
kp = 20.0;
kv = 0.3;
% ���� �� �ִ� �ִ�Ÿ� ����.(ur-5)
R = 0.9281;
% �� random �� ��ǥ���� �ð��� iter Ƚ���� ����� �迭
iter_count = 0;


if R <norm(tar_p)
    tar_p = tar_p/norm(tar_p)*R;
end

x_d = tar_p';

% �� cycle ���� q_current �ʱ�ȭ�ϱ�
q_current = q_cur';

%iteration ����(PI)
while iter_count < maxiter
    T_current = FK(q_current);
    x_current = T_current(1:3, 4);
    
    % step input�� ���� x_dot_des
    x_dot_des = (x_d-x_current)/dt;
    
    x_error(1:3, 1) = x_d - x_current;
    J_ = Jaco(q_current);
    % ���ۼ�����(Manipulability Measure)
    MM = sqrt(det(J_*J_'));
    % ���ۼ����� �Ӱ谪 (Manipulability Measure threshold)
    MM_thres = 0.001;
    % ������ �����ϸ� ���� (Scaling Gain)
    scaling_gain = 0.001;
    if MM > MM_thres 
        lamda_squared = 0;
    else
        lamda_squared = (1-(MM/MM_thres))^2*scaling_gain;
    end
    
    J_DPI = J_' / (J_ * J_'+lamda_squared*eye(3));
    
    q_current = q_current + J_DPI * (kv*x_dot_des)*dt;
    
    tol = norm(x_error);
    if tol < threshold
        break;
    end
    iter_count = iter_count + 1;
    
end
% �ð����
time= toc


q_ik = q_current;
iter_count;

end

