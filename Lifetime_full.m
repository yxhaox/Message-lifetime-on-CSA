%% this is a program to simulate "Information Spreading" in an ER graph
%% A uniform number of messages are added to the system each step unless the system doesnot
%% have enough free nodes to accept them
clear
tic
%AAgeMouse = zeros(20,25);
for NW = 1:5 %2:20
%for NW = [167 189 207 606 815] %[897 900]  %[341 487]
%for NW = [52 89 235 563 930]       %6 Edge graphs
%for NW = [379 454 464 658 995]      %8 Edge graphs
    load(['Assorted100/BA18Edg_Topo_' num2str(NW) '.mat'])
    %load(['MouseAssAdj' num2str(NW) '_65.mat'])
    %load(['Mouse/MouseAssAdj_005/MouseAssAdj' num2str(NW) '.mat'])
    %load(['Baboon5/Baboon5Adj_H_Ass_' num2str(NW) '.mat'])
    %load(['GreenMonkey1/GMonkey1Adj_H_Ass_' num2str(NW) '.mat'])
    %load(['BrownLemur2Adj_H_Ass_' num2str(NW) '.mat'])
    %AAgeMouse = zeros(5,18,5);
    AAge = zeros(1,5); %zeros(5,15);
    for trial = 1:28 %[1, 2, 3, 18,19,20,33,34,35] %-9:7 %-4:.5:4 %-2.4:.2:2.4 % %2:18 %-8:6 %:18%2:2:16 %[1 25 50 75 100]
        %load(['Mouse/MouseAssAdj_005/MouseAssAdj' num2str(trial) '.mat'])
        %load(['Assorted/4/Assort4_' num2str(trial) '_' num2str(NW) '.mat'])
        %load(['Assorted/8/Assort8_' num2str(trial) '_' num2str(NW) '.mat'])
        %load(['Assorted/12/Assort12_' num2str(trial) '_' num2str(NW) '.mat'])

%% collect network info
        thresh = 0;               %select only significant edges from Matrix
        %Adj = NewAdj;
        Adj = AllAdj(:,:,trial);
        %Adj = M(:,:,trial);
        %Adj = Adjs(:,:,trial+10);
        %Adj = M(:,:,round(trial/0.2+13));%
        %Adj = M(:,:,round(trial*2+9));
        %Adj = M1(:,:,round(trial*2-8));
        n = length(Adj);
        NxtStp = cell(n,1);
        for i = 1:n
            [~, NxtStp{i}] = find(Adj(i,:)>0);     
        end
        n_node = n;
        Out_Deg = sum(Adj,2);
        n_to = nnz(Out_Deg);

    %% set parameters and initialize variables
        n_repeat = 5; %5;%500;                      % # of repetitions
        n_batch = 2000;                      % # of batches
        for perc = 0.01 %[0.01 0.02 0.05]%[0.005 0.01 0.025] % 0.05 0.1] %[0.04 0.06 0.08 0.1] % %[0.02 0.04 0.06 0.08 0.1] %[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9]
            cc = 1;
            AllNewMsg = cell(n_batch,1);
            AllAvail = cell(n_batch,1);
            %n_msg1 = 1; %3; %floor(perc*n_node);         %number of messages per batch
            n_msg1 = round(perc*n_node);         %number of messages per batch
            New = zeros(1,n_batch);
            NodeAttemp = zeros(n_batch,n);  %Nodes being attempted in the whole process
            NodeAct = zeros(n_batch,n);     %Nodes being visited in the whole process

    %% the experiments are repeated "n_repeat " times to find average behavior
            for kkk = 1 : n_repeat   %:5 %:3%1:
            Dead = sparse(n_batch,n_batch*n_msg1*5);
            Alive = zeros(n_batch,n_node);
            boardsize = 2000;
            NewMsg = diffrand(n_msg1,n_node); %[1 2 3 4 5]; % % First msg
            CurMsg = NewMsg;                    % current msg we are looking at
            NodeAttemp(1,NewMsg) = 1;  %Nodes being attempted
            NodeAct(1,NewMsg) = 1;     %Nodes being visited
            AllNewMsg{1} = CurMsg;
            AllAvail{1} = 1:n;
            MsgCard = sparse(ones(n_msg1,1),CurMsg,1,1,n_node);  %msg in binary form.
            Alive(1,1:n_msg1) = NewMsg;

            ttl_copies = n_msg1;                 % total # of copies of all messages
            New(1) = n_msg1;
            livect = 0;                     %Counter of live msg
            deadct = 0;                     %Counter of dead msg

            for i = 2:n_batch
            %% make copies of each message to all neighbors
            %MsgBoard = sparse(n_batch,boardsize);
            MsgBoard = zeros(n_batch,boardsize);
            marker = 1;                     %pointer
            for j = 1:length(CurMsg)
                n_copy = Out_Deg(CurMsg(j));
                CurPos = marker:marker+n_copy-1; %Current positions on the messageboard
                Copies = [kron(Alive(1:i-1,j),ones(1,n_copy));NxtStp{CurMsg(j)}];
                MsgBoard(1:i,CurPos)= Copies;
                marker = marker+n_copy;
                ttl_copies = ttl_copies+n_copy-1;
            end

            AttemptCard = MsgCard * Adj;   %Attempted passes
            MsgCard = (AttemptCard == 1);  %Actual passing msgs in binary
            NodeAttemp(i,:) = AttemptCard;  %Nodes being attempted
            NodeAct(i,:) = MsgCard;     %Nodes being visited

            %% Collect dead messages
            Pass = nonzeros(MsgCard.* (1:n_node));  % Node positions where msg pass
            if isempty(Pass)
                WhoPass = [];
                livect = 0;
                Alive = zeros(n_batch,n_node);
                CurMsg = [];
                MsgCard = zeros(1,n_node);

            else
                WhoPass = nonzeros(ismember(MsgBoard(i,:),Pass).*(1:max(boardsize,marker-1))); %MsgBrd position where msg pass
                livect = sum(MsgCard);
                Alive = zeros(n_batch,n_node);
                Alive(:,1:livect) = MsgBoard(:,WhoPass); 
                CurMsg = nonzeros(Alive(i,:))';
                MsgCard = sparse(ones(livect,1),CurMsg,1,1,n_node);
            end

            WhoDie = setdiff(1:marker-1,WhoPass);
            newdeadct = deadct+ (marker - 1) - livect;
            Dead(:,deadct+1:newdeadct) = MsgBoard(:,WhoDie); 
            deadct = newdeadct;

            %% new message arrive
            %n_msg2 = round(perc*(n_node-sum(MsgCard)));
            n_msg2 = min(n_node-sum(MsgCard),n_msg1);
            %n_msg2 = ceil(perc*(n_node-sum(MsgCard)));
            %n_msg2 = round(perc*n_node);
            New(i) = n_msg2;
            if n_msg2>0
                ttl_copies = ttl_copies+n_msg2;
                Available = find(MsgCard==0);
                NewMsg = randsample(Available,min(n_msg2,length(Available)));
                %NewMsg = randsample(1:n_node,n_msg2);
                AllNewMsg{i} = NewMsg';
                AllAvail{i} = Available;
                NewMsgCard = sparse(ones(n_msg2,1),NewMsg,1,1,n_node);
                AttemptCard = MsgCard + NewMsgCard;  %Attempted passes
                MsgCard = (AttemptCard == 1);              %Actual passing msgs in binary
                NodeAttemp(i,:) = NodeAttemp(i,:)+ NewMsgCard;  %Nodes being attempted
                NodeAct(i,:) = MsgCard;     %Nodes being visited
                Alive(i,livect+1:livect+n_msg2) = NewMsg; 
                CurMsg = nonzeros(Alive(i,:))';
            end
        end

        aliveEnd = find(sum(Alive>0)==1,1);
        %cutoff = find(Dead(5,:)>0,1);
        %FinalDead = [Dead(:,cutoff:newdeadct), Alive(:,1:aliveEnd-1)];
        %FinalDead = Dead(:,cutoff:newdeadct);
        MsgB = sparse(Dead);
        toc
        Path = Dead>0;
        AgeAll = sum(Path)-ones(1,length(Path));
        avgAge = mean(AgeAll);
        %AAge(kkk,round(trial*2+9)) = avgAge;
        %save(['24_05_20_Age_IS_Dym_Asso_8edge_2k_' num2str(n_msg1) 'msg_' num2str(trial) '_' num2str(NW) '_' num2str(kkk) '.mat'])
        %save(['25_09_25_Age_IS_Dym_Asso_Mouse_2k_' num2str(NW) '_' num2str(n_msg1) 'msg_' num2str(round(trial)) '_' num2str(kkk) '.mat'])
        %save(['25_09_25_Age_IS_Dym_Asso_Baboon5_2k_' num2str(NW) '_' num2str(n_msg1) 'msg_' num2str(round(trial)) '_' num2str(kkk) '.mat'])
        %save(['25_09_25_Age_IS_Dym_Asso_GMonkey1_2k_' num2str(NW) '_' num2str(n_msg1) 'msg_' num2str(round(trial)) '_' num2str(kkk) '.mat'])
        save(['25_10_01_Age_IS_Dym_Asso_18edge100_2k_' num2str(NW) '_' num2str(n_msg1) 'msg_' num2str(round(trial)) '_' num2str(kkk) '.mat'])

%%NA means "NoAdding"
        %AAgeMouse(perc*50,trial+10,kkk)=avgAge;
        %AAgeMouse(cc,round(trial/.2),kkk)=avgAge;
        end
    cc=cc+1;    
        end
    end
    %AAgeMouse(NW,:)=AAge;
%    AAgeMouse(NW,:)=AAge;
    %save(['25_6_25_AverageAge_IS_Asso_Mouse_' num2str(NW) '_' num2str(kkk) '_2.mat'],'AAgeMouse','AAge')
end
%save(['25_6_25_AverageAge_IS_Asso_Mouse_' num2str(NW) '_2.mat'],'AAgeMouse')
