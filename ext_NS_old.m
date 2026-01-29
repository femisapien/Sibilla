function [ y_out, tau ] = ext_NS( nCurves, nHorizons, nSims, tau_, beta_, lambdas_, abc_, Mean_F_, Q_, R_ )
%
%  Simulates the Extended NS model of Koivu, Nyholm, Stromberg
%
scTau  = 12;
abc    = [zeros(1,3);abc_];
nFacts = 3+(nCurves-1)*2;
%------------------------
% Creating the H matrix
%------------------------
for ( j=1:nCurves )
    index_(j,1) = find(~isnan(tau_(:,j)),1,'last');
end
for (j=1:nCurves)
    tau{j} = tau_(1:index_(j,1),j);
end
tot_Tau = sum(index_(:,1));
H_tot   = zeros(tot_Tau,nFacts);

for ( j=1:nCurves ) 
    H_NS{j,1} = [ ones(index_(j,1),1) (1-exp(-lambdas_(1,j).*tau{j}))./(lambdas_(1,j).*tau{j}) ...
                    (1-exp(-lambdas_(1,j).*tau{j}))./(lambdas_(1,j).*tau{j})-exp(-lambdas_(1,j).*tau{j}) ];
end
for ( j=1:nCurves )
    for ( k=1:nCurves )
        if ( j==k )
            H_diff{j,k} = [ ones(index_(j,1),1) abc(j,1) + abc(j,2).*(tau{j}./scTau) + abc(j,3).*(tau{j}./scTau).^2 ];
        else
            H_diff{j,k} = zeros(index_(j,1),2);
        end
    end
end

for ( j=1:nCurves )
    H_diff_1{1,j} = cat(1,H_diff{:,j});
end
H_NS_      = cat(1,H_NS{:,:});
H_diff_tot = cat(2,H_diff_1{:,:});
H_tot      = [H_NS_(:,:) H_diff_tot(:,3:end)];


%=======================================
%=======================================
% SIMULATION LOOP BEGIN
%=======================================
%=======================================

for ( z=1:nSims )

%-----------------------------
% DRAWING THE RANDOM NUMBERS
%-----------------------------
    QQ_ = zeros(nFacts,nFacts);
    for ( j=1:nFacts )
        for ( k=1:nFacts)
            if ( ~isnan(Q_(j,k)) & isnumeric(Q_(j,k)) )
                QQ_(j,k) = Q_(j,k);
            else
                QQ_(j,k) = 0;
            end
        end
    end

    for ( j=1:nCurves )
        R_tmp{j,1} = R_(1,j).*ones(index_(j,1),1);
    end
    R_tmp_ = cat(1,R_tmp{:,:});
    RR_    = diag(R_tmp_);

    et  = [zeros(nFacts,1) chol(QQ_)*randn(nFacts, nHorizons) ];           % State equation
    vt  = [zeros(tot_Tau,1) chol(RR_)*randn(tot_Tau, nHorizons) ];         % Obs equation

    %------------------------
    % EVOLVING THE BETAS
    %------------------------
    m_     = Mean_F_(:,1);
    AR_tmp = Mean_F_(:,2:end);
    AR_    = zeros(nFacts,nFacts);
    for ( j=1:nFacts )
        for ( k=1:nFacts)
            if ( ~isnan(AR_tmp(j,k)) & isnumeric(AR_tmp(j,k)) )
                AR_(j,k) = AR_tmp(j,k);
            else
                AR_(j,k) = 0;
            end
        end
    end
    B_      = zeros(nFacts,nHorizons+1);
    B_1     = beta_(:,1);
    B_2     = beta_(1:2,2:end);
    B_(:,1) = [ B_1(:,1); B_2(:) ];

    for ( j=2:nHorizons+1 )
        B_(:,j) = m_ + AR_*B_(:,j-1) + et(:,j);
    end

    y_sim = H_tot*B_ + vt;
    
    %... index counter for the curves stored in y_sim
    n_      = ones(nCurves,2);
    n_(1,2) = index_(1,1); 
    for ( j=2:nCurves )
        n_(j,2) = sum(index_(1:j,1));
        n_(j,1) = n_(j-1,2)+1;
    end
    %... storing the simulated curves
    for ( j=1:nCurves )
        y_out{z}.curve{j} = y_sim( n_(j,1):n_(j,2),:);
    end
end   % Main simulation loop end


