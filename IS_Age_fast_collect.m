%% This is a faster way of finding Tree Age of IS
%% This code collects active node at each step
%% !!!!!!!!!!!!!This one curently only works for load of 1!!!!!!!!!!!!!

%clear
%tic
function [Age, Weight,Status,New] = IS_Age_fast_collect(Adj)
tic
%Adj = makeSFgraph(10,4);
load = 1;
n_steps = 5000;
n_nodes = length(Adj);  
Msg = zeros(n_steps*load,n_nodes);     % Storage for msgs
Msg1 = zeros(n_steps,n_nodes);    % Storage for temporary msgs
Age = zeros(1,n_steps);
Dead = zeros(1,n_steps);
Weight = zeros(1,n_steps);
Total = zeros(n_steps);
Status = zeros(n_steps,n_nodes);

New(1) = ceil(n_nodes*rand);
Msg(1,New(1)) = 1;       %Initial message
Status = Msg;
%Msg(1,ceil(50*rand)) = 1;       %Initial message
Msg1(1,:)=Msg(1,:)*Adj;         %Msg Attemps from last step
Status(2,:) = Msg1(1,:);
AllFree = ones(1,n_nodes)-Msg1(1,:);  %all nodes that are free for injection
Msg = Msg1;                     %Msg to report to the next step

%% Inject msg
Avail = nonzeros((1:n_nodes).* AllFree);  %find all available locations for injection
NewLoc = randsample(Avail,load);
New(2)=NewLoc;
Status(2,NewLoc) = 1;

for i = 2: n_steps
    NewMsg = zeros(1,n_nodes);
    NewMsg(NewLoc)=1;
    Msg(i,:)=NewMsg;
    
    %% Move to the next nodes
    Msg1=Msg*Adj;
    
    %% checking for jams
    Check = sum(Msg1);
    Where = find(Check>1);
    Msg = Msg1;
    Msg(:,Where)=0;
    
    %% Find Injection sites msg
    Check(Where) = 0;
    AllFree = ones(1,n_nodes)-Check;
    Avail = nonzeros((1:n_nodes).* AllFree);
    NewLoc = randsample(Avail,load);
    New(i+1)=NewLoc;
    
    %% Find dead
    Total(:,i) = sum(Msg,2);
    LastTotal = sum(Msg1,2);     %# of copies of the current msg from last step
    for j = 1:i
        if Total(j,i)==0 && Dead(j)==0
            Age(j)=i-j+1;
            Dead(j) = 1;
            Weight(j)=LastTotal(j);
        end
    end
    Temp = Status(i,:)*Adj;
    Status(i+1,:)=(Temp==1);
    Status(i+1,NewLoc)=1;
end
Oldest = find(sum(Msg,2)>0);
Dummy = (n_steps:-1:1);
Age(Oldest)=Dummy(Oldest);
toc
return
