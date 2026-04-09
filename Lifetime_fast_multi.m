%% This is a faster way of finding Tree Age of IS
%% !!!!!!!!!!!!!This one works for any load !!!!!!!!!!!!!
%clear
%tic
function [Age, Weight, Status, New] = IS_Age_fast_multi(Adj,n_new) %n_new is how many new addition per step

n_steps = 2000;
n_nodes = length(Adj);
Msg = zeros(n_steps,n_nodes,n_new);     % Storage for msgs
Msg1 = zeros(n_steps,n_nodes,n_new);    % Storage for temporary msgs
Age = zeros(n_new,n_steps);
Dead = zeros(n_new,n_steps);
Weight = zeros(n_new,n_steps);
Total = zeros(n_steps,n_steps,n_new);
LastTotal = zeros(n_steps,n_new);
New = zeros(n_steps,n_new);
Status = zeros(n_steps,n_nodes);


New(1,:) = ceil(n_nodes*rand(1,n_new));
for i = 1:n_new
    Msg(1,New(1,i),i) = 1;       %Initial message
    Msg1(1,:,i)=Msg(1,:,i)*Adj;         %Msg Attemps from last step
end
Status = sum(Msg,3);
Msg = (Msg1==1);                     %Msg to report to the next step
Status(2,:) = (sum(Msg1(1,:,:),3)==1);
AllFree = ones(1,n_nodes)-Status(2,:);  %all nodes that are free for injection

    %% Inject msg
Avail = nonzeros((1:n_nodes).* AllFree);  %find all available locations for injection
NewLoc = randsample(Avail,n_new);
New(2,:)=NewLoc;
Status(2,NewLoc) = 1;

for i = 2: n_steps
    for j = 1:n_new
        NewMsg = zeros(1,n_nodes);
        NewMsg(NewLoc(j))=1;
        Msg(i,:,j)=NewMsg;
        %Status(i,:,j) = 0;
        %% Move to the next nodes
        Msg1(:,:,j)=Msg(:,:,j)*Adj;
    end
    %% checking for jams
    Check = sum(sum(Msg1,3));
    Where = find(Check>1);
    Msg = Msg1;
    Msg(:,Where,:)=0;
    
    %% Find Injection sites msg
    Check(Where) = 0;
    AllFree = ones(1,n_nodes)-Check;
    Avail = nonzeros((1:n_nodes).* AllFree);
    NewLoc = randsample(Avail,n_new);
    New(i+1,:)=NewLoc;
    
    %% Find dead
    for k = 1:n_new
        Total(:,i,k) = sum(Msg(:,:,k),2);
        LastTotal(:,k) = sum(Msg1(:,:,k),2);     %# of copies of the current msg from last step
        for j = 1:i
            if Total(j,i,k)==0 && Dead(k,j)==0
                Age(k,j)=i-j+1;
                Dead(k,j) = 1;
                Weight(k,j)=LastTotal(j,k);
            end
        end
    end
    Temp = Status(i,:)*Adj;
    Status(i+1,:)=(Temp==1);
    Status(i+1,NewLoc)=1;
end
%Oldest = find(sum(Msg,2)>0);
%Dummy = (n_steps:-1:1);
%Age(Oldest)=Dummy(Oldest);
return
%toc