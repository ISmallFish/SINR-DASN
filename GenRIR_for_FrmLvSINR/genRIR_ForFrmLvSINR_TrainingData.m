clc;
clear all;
close all;

rir_total_nums       = 3*120000; %
rir_total_nums_apart = 1200; %

% Fix Parameter --------------------------------------------------------- %
c                 = 340;       % sound speed, in m/s
fs                = 16e3;      % sampling rate, in Hz
Qmax              = 2;

minDistoWall      = 0.2;
minDistoSrc       = 0.2;
minDisBTSrc       = 0.5;

T60_Range         = 0.1:0.001:0.8;
inf_spkr_numRange = [0, 1, 2];

% ----------------------------------------------------------------------- %
p = parpool('local',48);
for idx_apart = 1:rir_total_nums/rir_total_nums_apart
% for idx_apart = rir_total_nums/rir_total_nums_apart + 1:150000/rir_total_nums_apart
    rir_rvb_full_struct = {};

    parfor idx = 1:rir_total_nums_apart
        % room size
        vec_L             = [3 + 5*rand; 3 + 5*rand; 2.5 + 1.5*rand];   % param. size parameters of the room, in meter
        a                 = vec_L(1) - 2*minDistoWall;
        b                 = vec_L(2) - 2*minDistoWall;
        c                 = minDisBTSrc;
        d                 = minDistoSrc;
        % T60. --------------------------------------------------- %
        T60_idx  = randperm(length(T60_Range),1);
        % if T60_idx <= 2 + 1
        %     Lh                = 1024*2;   % length of IR,
        % else
        %     Lh                = 1024*(T60_idx - 1);   % length of IR,
        % end
        Lh       = 1024*8;

        T60      = T60_Range(T60_idx);
        % T60      = round(0.1 + 0.7*rand);

        absrb    = 0.1611*vec_L(1)*vec_L(2)*vec_L(3)/(T60*2*(vec_L(1)*vec_L(2) + vec_L(1)*vec_L(3) + vec_L(2)*vec_L(3)));
        absrb    = min([absrb 1]);

        beta     = realsqrt(1-absrb);
        mat_beta = [beta,beta;beta,beta;beta,beta];

        % SpkrNum. ----------------------------------------------- %
        inf_spkr_num = inf_spkr_numRange(randperm(length(inf_spkr_numRange),1));
        src_num      = inf_spkr_num + 1;

        % place src. ============================================================ %
        vec_rs = [];
        if src_num == 1
            x       = rand*a;
            y       = rand*b;
            rs_temp = [x;y;1.2 + 0.6*rand];
            vec_rs  = [vec_rs,rs_temp];
        else
            while size(vec_rs,2) < src_num
                x       = rand*a;
                y       = rand*b;
                rs_temp = [x;y;1.2 + 0.6*rand];

                % check the dis btw points
                min_dist = 1000000;
                for p_idx = 1:size(vec_rs,2)
                    dist     = sqrt((x - vec_rs(1,p_idx))^2 + (y - vec_rs(2,p_idx))^2);
                    min_dist = min([min_dist, dist]);
                end
                if min_dist >= c
                    vec_rs  = [vec_rs,rs_temp];
                end
            end
        end

        % place mic. ============================================================ %
        vec_rm = [];
        while size(vec_rm,2) < 1

            x       = rand*a;
            y       = rand*b;
            rm_temp = [x;y;0.6 + 0.6*rand];

            % check the dis btw points
            min_dist = 1000000;
            for p_idx = 1:size(vec_rs,2)
                dist     = sqrt((x - vec_rs(1,p_idx))^2 + (y - vec_rs(2,p_idx))^2);
                min_dist = min([min_dist, dist]);
            end
            if min_dist >= d
                vec_rm  = rm_temp;
            end
        end

        vec_rs       = vec_rs + [minDistoWall;minDistoWall;0]*ones(1,size(vec_rs,2));
        vec_rm       = vec_rm + [minDistoWall;minDistoWall;0]*ones(1,size(vec_rm,2));

        % determine orientation of src. ========================================= %
        phi   = [];
        theta = [];
        for n = 1:size(vec_rs, 2)
            phi   = [phi   -rand*(pi/6)];
            theta = [theta  rand*(2*pi)];
        end
        vec_as = vec_rs - [cos(phi).*cos(theta);cos(phi).*sin(theta);sin(phi)];

        % % *********************************************************************** %
        % % -------------------------------- test --------------------------------- %
        % vec_pos      = [vec_rs, vec_rm];
        % vec_pos(3,:) = [];
        %
        % scatter(vec_pos(1,1:size(vec_rs, 2)), vec_pos(2,1:size(vec_rs, 2)));
        % hold on;
        % scatter(vec_pos(1,size(vec_rs, 2) + 1), vec_pos(2,size(vec_rs, 2) + 1));
        % hold off;
        % axis([0 5 0 5]);
        %
        % figure;
        % for n = 1:size(vec_rs, 2)
        %     [hVec] = cal_IRismFdirectional(vec_L, vec_rs(:,n), vec_as(:,n),Qmax, vec_rm, mat_beta, fs, Lh,0);
        %     plot(hVec);
        %     hold on;
        % end
        % hold off;axis tight;
        % % ----------------------------   test end  ------------------------------ %
        % % *********************************************************************** %

        rir_rvb_full = zeros(size(vec_rs, 2),1,Lh);
        for n = 1:size(vec_rs, 2)
            [hVec]      = cal_IRismFdirectional(vec_L, vec_rs(:,n), vec_as(:,n),Qmax, vec_rm, mat_beta, fs, Lh,1);
            rir_rvb_full(n,1,:) = hVec;
        end

        rir_rvb_full_struct(idx).rir_rvb_full = rir_rvb_full;
        rir_rvb_full_struct(idx).T60          = T60;
        rir_rvb_full_struct(idx).src_num      = src_num;

        % disp(['processing rate: ' num2str(round(idx/(rir_total_nums_apart)*100),3) '%']);

    end
    
    for idx = 1:rir_total_nums_apart
        rir_rvb_full = rir_rvb_full_struct(idx).rir_rvb_full;
        T60          = rir_rvb_full_struct(idx).T60;
        src_num      = rir_rvb_full_struct(idx).src_num;
        save(['./RIR_AnchorPoint_TrainData_HighPass/' num2str(idx + (idx_apart-1)*rir_total_nums_apart) '_' num2str(T60*1000) 'ms_' num2str(src_num) '.mat'],'rir_rvb_full');
    end
    
    disp('=========================================================');
    disp(['processing rate: ' num2str(round(idx_apart/(rir_total_nums/rir_total_nums_apart)*100),3) '%']);
    disp('=========================================================');
end

delete(gcp('nocreate'));
