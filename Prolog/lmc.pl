
%%% lmc.pl

:- style_check(-singleton).
:- consult('parser.pl').

one_instruction(state(Acc, Pc, Mem, In, Out, Flag), NewState) :-
    \+ length(Mem, 0),
    exec_instruction(state(Acc, Pc, Mem, In, Out, Flag), NewState).

execution_loop(halted_state(Acc, Pc, Mem, In, Out, Flag), Out) :- !.

execution_loop(state(Acc, Pc, Mem, In, Out, Flag), Out2) :-
    length(Mem, 100),
    exec_instruction(state(Acc, Pc, Mem, In, Out, Flag), NewState),
    execution_loop(NewState, Out2).

%%% Definizioni delle operazioni assembly

add(Elem, Acc, NewAcc, flag) :-
    Result is (Elem + Acc),
    Result >= 1000, !,
    NewAcc is Result mod 1000.

add(Elem, Acc, NewAcc, noflag) :-
    NewAcc is (Elem + Acc), !.

sub(Elem, Acc, NewAcc, flag) :-
    Result is (Acc - Elem),
    Result < 0, !,
    NewAcc is Result mod 1000.

sub(Elem, Acc, NewAcc, noflag) :-
    NewAcc is (Acc - Elem), !.

store(Acc, Elem, Mem, NewMem) :-
    replace(Acc, Elem, Mem, NewMem).

load(Index, Acc, Mem, NewAcc) :-
    nth0(Index, Mem, NewAcc).

branch(Elem, Elem).

branchz(Elem, 0, noflag, Pc, NewPc) :-
	NewPc is Elem, !.

branchz(Elem, Acc, Flag, Pc, NewPc) :-
    NewPc is (Pc + 1) mod 100.

branch_pos(Elem, Acc, noflag, Pc, Elem) :-
    Acc > 0, !.

branch_pos(Elem, Acc, Flag, Pc, NewPc) :-
    \+ (Acc > 0, Flag = string("noflag")), !,
    NewPc is (Pc + 1) mod 100.

input(In, NewAcc, NewIn) :-
    \+ length(In, 0), !,
    nth0(0, In, NewAcc, NewIn).

output(Acc, Out, NewOut) :-
    append(Out, [Acc], NewOut).

get_operation(Elem, Type, Num) :-
    Type is (Elem div 100), !,
    Num is (Elem mod 100).

get_operation(Elem, Elem) :-
    between(901, 902, Elem).

replace(Num, 0, [X | Xs], [Num | Xs]) :- !.

replace(Num, Pos, [X | Xs], [X | Ys]) :-
    NewPos is Pos - 1,
    replace(Num, NewPos, Xs, Ys).

lmc_run(File, In, Out) :-
    lmc_load(File, Mem),
    execution_loop(state(0, 0, Mem, In, [], noflag), Out).

%%% Fine definizioni

/* 1 ADD */
exec_instruction(state(Acc, Pc, Mem, In, Out, Flag),
				state(NewAcc, NewPc, Mem, In, Out, NewFlag)) :-
    nth0(Pc, Mem, Elem, R),
    get_operation(Elem, 1, Rest), !,
    nth0(Rest, Mem, Num, R1),
    add(Num, Acc, NewAcc, NewFlag),
    NewPc is (Pc + 1) mod 100.

/* 2 SUB */
exec_instruction(state(Acc, Pc, Mem, In, Out, Flag),
                 state(NewAcc, NewPc, Mem, In, Out, NewFlag)) :-
    nth0(Pc, Mem, Elem, R),
    get_operation(Elem, 2, Rest), !,
    nth0(Rest, Mem, Num, R1),
    sub(Num, Acc, NewAcc, NewFlag),
    NewPc is (Pc + 1) mod 100.

/* 3 STORE */
exec_instruction(state(Acc, Pc, Mem, In, Out, Flag),
                 state(Acc, NewPc, NewMem, In, Out, Flag)) :-
    nth0(Pc, Mem, Elem, R),
    get_operation(Elem, 3, Num), !,
    store(Acc, Num, Mem, NewMem),
    NewPc is (Pc + 1) mod 100.

/* 5 LOAD */
exec_instruction(state(Acc, Pc, Mem, In, Out, Flag),
                 state(NewAcc, NewPc, Mem, In, Out, Flag)) :-
    nth0(Pc, Mem, Elem, R),
    get_operation(Elem, 5, Num), !,
    load(Num, Acc, Mem, NewAcc),
    NewPc is (Pc + 1) mod 100.
/* 6 BRANCH */
exec_instruction(state(Acc, Pc, Mem, In, Out, Flag),
                 state(Acc, NewPc, Mem, In, Out, Flag)) :-
    nth0(Pc, Mem, Elem, R),
    get_operation(Elem, 6, Num), !,
    branch(Num, NewPc).

/* 7 BRANCHZ */
exec_instruction(state(Acc, Pc, Mem, In, Out, Flag),
                 state(Acc, NewPc, Mem, In, Out, Flag)) :-
    nth0(Pc, Mem, Elem, R),
    get_operation(Elem, 7, Num), !,
    branchz(Num, Acc, Flag, Pc, NewPc).

/* 8 BRANCHP */
exec_instruction(state(Acc, Pc, Mem, In, Out, Flag),
                 state(Acc, NewPc, Mem, In, Out, Flag)) :-
    nth0(Pc, Mem, Elem, R),
    get_operation(Elem, 8, Num), !,
    branch_pos(Num, Acc, Flag, Pc, NewPc).

/* 901 INPUT */
exec_instruction(state(Acc, Pc, Mem, In, Out, Flag),
                 state(NewAcc, NewPc, Mem, NewIn, Out, Flag)) :-
    nth0(Pc, Mem, Elem, R),
    get_operation(Elem, 901), !,
    input(In, NewAcc, NewIn),
    NewPc is (Pc + 1) mod 100.

/* 902 OUTPUT */
exec_instruction(state(Acc, Pc, Mem, In, Out, Flag),
                 state(Acc, NewPc, Mem, In, NewOut, Flag)) :-
    nth0(Pc, Mem, Elem, R),
    get_operation(Elem, 902), !,
    output(Acc, Out, NewOut),
    NewPc is (Pc + 1) mod 100.

/* 0 HALT */
exec_instruction(state(Acc, Pc, Mem, In, Out, Flag),
                 halted_state(Acc, NewPc, Mem, In, Out, Flag)) :-
    nth0(Pc, Mem, Elem, R),
    get_operation(Elem, 0, Num),
    NewPc is (Pc + 1) mod 100,
    retractall(labelized(_,_)).

%%%% EOF