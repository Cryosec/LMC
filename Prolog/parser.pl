
:- style_check(-singleton).
:- dynamic labelized/2.


lmc_load(File, NewCodes) :-
    open(File, read, Str),
    N is 0,
    read_stuff(Str, N, L),
    remove_blank(L, OpCodes),
    get_machine_codes(OpCodes, Machine_Codes), !,
    close(Str),
    fill(Machine_Codes, NewCodes),
    print(NewCodes).

fill(Mem, Mem, Length) :-
    Length = 100, !.

fill(Mem, NewMem, N) :-
    Length is 100 - N,
    randseq(Length, 99, L),
    append(Mem, L, NewMem).

fill(Mem, NewMem) :-
    length(Mem, Length),
    fill(Mem, NewMem, Length).

read_stuff(Str, N, [L|T]) :-
    \+ at_end_of_stream(Str),
    read_string(Str, "\n", "\r", _, String),
    parse_string(String, N, M, L), !,
    M1 is M+1,
    read_stuff(Str, M1, T).

read_stuff(Str, N, []) :-
    at_end_of_stream(Str).

%% instruction codes

    codice_stringa("ADD", 100).
    codice_stringa("SUB", 200).
    codice_stringa("STA", 300).
    codice_stringa("LDA", 500).
    codice_stringa("BRA", 600).
    codice_stringa("BRZ", 700).
    codice_stringa("BRP", 800).
    codice_stringa("INP", 901).
    codice_stringa("OUT", 902).
    codice_stringa("HLT", 000).
    codice_stringa("DAT", 00).
%% end of instruction codes

parse_string(String, N, M, Codes) :-
    string_chars(String, Chars),
    skip_comment(Chars, RestOf_Char),
    string_chars(NewString, RestOf_Char),
    split_string(NewString, " ", " ", L),
    is_label(L, N, M, Codes).

skip_comment([], []).

skip_comment(['/', '/' | _T], []).

skip_comment([H | T1], [H | T2]) :-
    dif(H, '/'),
    skip_comment(T1, T2).

remove_blank([], []).

remove_blank([[""] | T], OpCodes) :-
    remove_blank(T, OpCodes).

remove_blank([H | T], [H | T1]) :-
    dif(H, [""]),
    remove_blank(T, T1).

is_label([H | T], N, N, T) :-
    string_upper(H, Label),
    dif(Label, "ADD"),
    dif(Label, "SUB"),
    dif(Label, "STA"),
    dif(Label, "LDA"),
    dif(Label, "BRA"),
    dif(Label, "BRZ"),
    dif(Label, "BRP"),
    dif(Label, "INP"),
    dif(Label, "OUT"),
    dif(Label, "HLT"),
    dif(Label, "DAT"),
    dif(Label, ""), !,
    \+ labelized(Label, _),
    !,
    assertz(labelized(Label, N)).

is_label([""], N, M, [""]) :- M is N - 1.

is_label(Codes, N, N, Codes).

get_machine_codes([], []).

get_machine_codes([[X, Y] | T], [Z | T1]) :-
    string_upper(X, X1),
    string_upper(Y, Y1),
    codice_stringa(X1, Operator_Number),
    number_string(Cell, Y1),
    Z is Operator_Number + Cell,
    get_machine_codes(T, T1).

get_machine_codes([[X, Y ] | T], [Z | T1]) :-
    string_upper(X, X1),
    string_upper(Y, Y1),
    codice_stringa(X1, Operator_Number),
    labelized(Y1, Cell),
    Z is Operator_Number + Cell,
    get_machine_codes(T, T1).

get_machine_codes([[H] | T], [Operator_Number | T1]) :-
    string_upper(H, Up),
    codice_stringa(Up, Operator_Number),
    get_machine_codes(T, T1).
