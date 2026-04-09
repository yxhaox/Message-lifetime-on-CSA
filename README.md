MakeSFgraph.m    Is a program that generates scale free networks using the BA algorithm

DecAssort.m      Carries out edge switch randomization to an adjacency matrix and generates a new adjacency matrix that features a desired, lower, assortativity value while maintaining the degree sequence.

IncAssort.m      Carries out edge switch randomization to an adjacency matrix and generates a new adjacency matrix that features a desired, higher, assortativity value while maintaining the degree sequence.

Lifetime_full.m  implements Copy-Spread-Annhilate dynamics and keep all messages/copies ever generated in the whole process

Lifetime_fast_collect.m   Implements CRA much faster but only track the life time of each message. This version only works for one message per injection as used in the paper. It does not keep records of individual messages.

Lifetime_fast_multi.m     Implements CRA much faster but only track the life time of each message. This version works for multiple messages per injection. 
