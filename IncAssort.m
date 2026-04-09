%% function that increases assortativity of a network. Adj is the original network, 
%% It stops at a desired assortativity r = n/10 ± 0.002
%% swap is the max # of times random swaping was performed and NewAdj is the output Adjacency Matrix

function NewAdj = IncAssort(Adj,n)
TempAdj = Adj;
aaa=-100;
nswap = 2000;
Results = zeros(1,nswap);
n_node = length(Adj);
Deg = sum(Adj);

for i = 2:n_node
    TempAdj(i,1:i-1) = 0;
end

[r,c] = find(TempAdj);
Edges = [r,c];
n_edge = length(Edges);

dummy = find(Adj,2);
fr21 = 1;
to21 = dummy(1);
fr22 = 1;
to22 = dummy(2);

counter = 1;
%while aaa<-1.003+jj/10 || aaa>-0.997+jj/10
%while aaa> 0.105 || aaa<0.095
while   (aaa>n/10+0.002 || aaa<n/10-0.002) && counter<nswap
%while  aaa<0.795
    counter = counter +1;
    while(TempAdj(fr21, to21)+TempAdj(fr22, to22) >0)
        Where = randsample(n_edge,2);
        Chosen = Edges(Where,:);
        while(length(unique(Chosen))<4)
            Where = randsample(n_edge,2);
            Chosen = Edges(Where,:);
        end
        fr11 = Chosen(1,1);     %Original selections
        to11 = Chosen(1,2);
        fr12 = Chosen(2,1);
        to12 = Chosen(2,2);
    %     TempAdj(to1, fr1) = 0;
    %     TempAdj(to2, fr2) = 0;
    %     TempAdj(fr1, to1) = 0;
    %     TempAdj(fr2, to2) = 0;

        Flat = Chosen(1:4);  % "flatten" Chosen to a vector
        A = Deg(Flat);
        [~, Pos] = sort(A);
        fr21 = min(Flat(Pos(3)),Flat(Pos(4)));  %After swaping
        to21 = max(Flat(Pos(3)),Flat(Pos(4)));
        fr22 = min(Flat(Pos(1)),Flat(Pos(2)));
        to22 = max(Flat(Pos(1)),Flat(Pos(2)));
    %     TempAdj(to1, fr1) = 0;
    %     TempAdj(to2, fr2) = 0;
    %     TempAdj(fr1, to1) = 0;
    %     TempAdj(fr2, to2) = 0;
    end
    TempAdj(fr11, to11) = 0;
    TempAdj(fr12, to12) = 0;
    TempAdj(fr21, to21) = 1;
    TempAdj(fr22, to22) = 1;
    Edges(Where,:) = [fr21 to21;fr22 to22];
    NAdj = sparse(Edges(:, 1), Edges(:, 2), 1, n_node, n_node);
    NewAdj = full((NAdj+NAdj')>0);
    aaa = assortativity(NewAdj,0);
    %Results(counter)=aaa;
end
return