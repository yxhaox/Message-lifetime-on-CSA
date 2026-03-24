%% A function that builds Scale Free network with n nodes and k links
%% per node.
function A = makeSFgraph(n,k)
if round(k/2)~=k/2
    disp('ERROR: k must be an even number')
    A = [];
    return
end
A1 = zeros(n);
A1(1:k/2+1,1:k/2+1) = ones(k/2+1);
A2 = A1 - diag(diag(A1));
CurDeg = sum(A2);
%if k/2 ==round(k)
    n_sam = k;
    for i = k/2+2:n
        Cumu = cumsum(CurDeg);
        Weight = Cumu/max(Cumu);
        Where = [];
        counter = 0;
        while counter<k/2
            winner = find(Weight>rand,1);
            if 1-ismember(winner,Where)
                Where = [Where winner];
                counter = counter+1;
            end
        end
        A2(Where,i) = 1;
        A2(i,Where) = 1;
        CurDeg = sum(A2); 
    end
    A = A2;
%else
%end
    