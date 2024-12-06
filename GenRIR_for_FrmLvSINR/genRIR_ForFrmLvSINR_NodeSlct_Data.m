clc;
clear all;
close all;

rir_total_nums       = 1; %
rir_total_nums_apart = 1; %

% Fix Parameter --------------------------------------------------------- %
c                 = 340;          % sound speed, in m/s
fs                = 16e3;         % sampling rate, in Hz
vec_L             = [10; 6; 3];   % param. size parameters of the room, in meter
Qmax              = 2;

minDistoWall      = 0.2;
minDistoSrc       = 0.4;       % orginal is 0,2, now is 0.4
minDisBTSrc       = 0.5;

a                 = vec_L(1) - 2*minDistoWall;
b                 = vec_L(2) - 2*minDistoWall;
c                 = minDisBTSrc;
d                 = minDistoSrc;

T60_Range         = 0.4;
inf_spkr_numRange = 2;

% ----------------------------------------------------------------------- %
% p = parpool('local',40);

for idx_apart = 1:rir_total_nums/rir_total_nums_apart

    rir_rvb_full_struct = {};

    for idx = 1:rir_total_nums_apart
        % T60. --------------------------------------------------- %
        T60_idx  = randperm(length(T60_Range),1);
        Lh       = 1024*4;

        T60      = T60_Range(T60_idx);
        absrb    = 0.1611*vec_L(1)*vec_L(2)*vec_L(3)/(T60*2*(vec_L(1)*vec_L(2) + vec_L(1)*vec_L(3) + vec_L(2)*vec_L(3)));
        absrb    = min([absrb 1]);

        beta     = realsqrt(1-absrb);
        mat_beta = [beta,beta;beta,beta;beta,beta];

        % SpkrNum. ----------------------------------------------- %
        inf_spkr_num = 2; 
        src_num      = inf_spkr_num + 1;

        % place mic. ============================================================ %

        vec_rm_1 = [3.0 + (0:0.8:4);         3 + 0.7*ones(1, 6); 1.0*ones(1, 6)];
        vec_rm_2 = [fliplr(3.0 + (0:0.8:4)); 3 - 0.7*ones(1, 6); 1.0*ones(1, 6)];

        vec_rm   = [vec_rm_1, vec_rm_2];

        % place src. ==================================================== %

        vec_rs_1 = vec_rm_2(:,end) + [0; -0.6; 0.2];
        vec_rs_2 = vec_rm_2(:,1)   + [0; -0.6; 0.2];

        vec_rs_3 = vec_rm_1(:,1)   + [0;  0.6; 0.2] + [0:0.2:4; zeros(size(0:0.2:4)); [0, 0.4 + zeros(1, size(0:0.2:4,2) - 2), 0] ];

        vec_rs   = [vec_rs_1, vec_rs_2, vec_rs_3];

        % % determine orientation of src. ========================================= %

        vec_as_1      = vec_rs_1 - [0; 1; 0];
        vec_as_2      = vec_rs_2 - [0; 1; 0];
        vec_as_3      = vec_rs_3 + vec_rs_3 - vec_rs_2*ones(1, size(vec_rs_3,2));
        vec_as_3(:,1) = vec_rs_3(:,1) + vec_rs_3(:,1) - vec_rs_1*ones(1, 1);
        vec_as   = [vec_as_1, vec_as_2, vec_as_3];

        % *********************************************************************** %
        % -------------------------------- test --------------------------------- %
        figure;
        plot3(vec_rs(1,:),  vec_rs(2,:), vec_rs(3,:),'ko');
        hold on;
        plot3(vec_rs(1,:),  vec_rs(2,:), vec_rs(3,:), 'r.');

        quiver3(vec_rs(1,:), vec_rs(2,:), vec_rs(3,:), vec_rs(1,:) - vec_as(1,:), vec_rs(2,:) - vec_as(2,:), vec_rs(3,:) - vec_as(3,:), 'k');
        
        rectangle('Position', [0, 0, vec_L(1), vec_L(2)], 'EdgeColor', 'k', 'LineWidth', 2); % 
        axis equal;
        xlabel('X Coordinate (m)');
        ylabel('Y Coordinate (m)');
        grid on;
        
        % hold off;

        vec_pos      = [vec_rs, vec_rm];
        % vec_pos(3,:) = [];

        scatter3(vec_pos(1,1:size(vec_pos, 2)), vec_pos(2,1:size(vec_pos, 2)), vec_pos(3,1:size(vec_pos, 2)));
        % hold on;
        % scatter(vec_pos(1,size(vec_rs, 2) + 1), vec_pos(2,size(vec_rs, 2) + 1));
        hold off;

        axis([0 10 0 6 0 3]);
        
        flag = 1;

        rir_rvb_full = zeros(size(vec_rs, 2),size(vec_rm,2),Lh);
        
        for k = 1:size(vec_rm,2)
            for n = 1:size(vec_rs, 2)
                [hVec]      = cal_IRismFdirectional(vec_L, vec_rs(:,n), vec_as(:,n),Qmax, vec_rm(:, k), mat_beta, fs, Lh,1);
                rir_rvb_full(n,k,:) = hVec;
                disp('=================');
                disp([k,n]);
                disp('=================');
            end
        end

        rir_rvb_full_struct(idx).rir_rvb_full = rir_rvb_full;
        rir_rvb_full_struct(idx).T60          = T60;
        rir_rvb_full_struct(idx).src_num      = src_num;


    end
    
    for idx = 1:rir_total_nums_apart
        rir_rvb_full = rir_rvb_full_struct(idx).rir_rvb_full;
        T60          = rir_rvb_full_struct(idx).T60;
        src_num      = rir_rvb_full_struct(idx).src_num;
        save(['./RIR_AnchorPoint_TestData_12CH/' num2str(idx + (idx_apart-1)*rir_total_nums_apart) '_' num2str(T60*1000) 'ms_' num2str(src_num) '.mat'],'rir_rvb_full');
    end
    
end

% delete(gcp('nocreate'));