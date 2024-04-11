% a battery called battName with weight 100 grams, 100wh power.

% This whole project is inspired by David Poole and his in-class activity.

/*
6. add the comments
7. examples to be used in Demo
*/

% insertion(["Add" | L0], )

?- [droneDB].
:- use_module(library(clpfd)).

% Credit: David Poole, geography_QA_query.pl
q(Ans) :-
    write("Ask me: "), flush_output(current_output), 
    read_line_to_string(user_input, St),
    notin(St, ["quit", "quit.", "q", "q."]), % quit or q ends interaction
    % split_string(St, " -", " ,?.!-", Ln), % ignore punctuation
    split_string(St, " ", "", Ln), 
    parse_num(Ln, Liszt),
    (ask(Liszt, Ans) ;
    write("No more answers\n"),
    q(Ans)).

% Credit: David Poole, geography_QA_query.pl
% notin(E,L) is true if E is not in list L. Allows for E or elements of L to be variables.
notin(_,[]).
notin(E,[H|T]) :-
    dif(E,H),
    notin(E,T).

uask(Str, Ind) :- split_string(Str, " ", "", Strs), parse_num(Strs, Liszt), ask(Liszt, Ind).

uask(Str, Ind, C) :- split_string(Str, " ", "", Strs), parse_num(Strs, Liszt), ask(Liszt, Ind, C).

parse_num([], []).
parse_num([H|T], [N|Aft]) :- number_string(N, H), parse_num(T, Aft).
parse_num([H|T], [H|Aft]) :- not(number_string(_, H)), parse_num(T, Aft).

grounds([H | T]) :- ground(H), grounds(T).
grounds([]).

% ask(Q,A) gives answer A to question Q
ask(Q,A) :-
    get_constraints_from_question(Q,A,C),
    prove_all(C).

ask(Q,A,C) :-
    get_constraints_from_question(Q,A,C),
    prove_all(C).
    

% get_constraints_from_question(Q,A,C) is true if C is the constraints on A to infer question Q
get_constraints_from_question(Q,A,C) :-
    phrase(Q,End,A,C,[]),
    member(End,[[],["?"],["."]]).


% prove_all(L) is true if all elements of L can be proved from the knowledge base
prove_all([]).
prove_all([H|T]) :-
    call(H),      % built-in Prolog predicate calls an atom
    prove_all(T).


phrase(Q,End,A,C,[]) :- add_hardware_phrase(Q,End,A,C,[]).
phrase(Q,End,A,C,[]) :- noun_phrase(Q,End,A,C,[]).
phrase(Q,End,A,C,[]) :- create_build_phrase(Q,End,A,C,[]).
phrase(["What", "is" | Q],End,A,C,[]) :- noun_phrase(Q,End,A,C,[]). % a question phrase
phrase(["What", "is", "a" | Q],End,A,C,[]) :- noun_phrase(Q,End,A,C,[]). % a question phrase
phrase(["What", "are" | Q],End,A,C,[]) :- noun_phrase(Q,End,A,C,[]). % a question phrase
phrase(["show", "me" | Q],End,A,C,[]) :- noun_phrase(Q,End,A,C,[]). % a question phrase

noun_phrase(L0,L4,Ind,C0,C4) :-
    det(L0,L1,Ind,C0,C1),
    adjectives(L1,L2,Ind,C1,C2),
    noun(L2,L3,Ind,C2,C3),
    optPrePosition(L3,L4,Ind,C3,C4).

% TODO not finished yet
create_build_phrase(L, [], build(Name, Battery, Camera, ControlUnit, Frame, Motor), [Head|Tail], []) :-
        (
            L = ["create" | T];
            L = ["new" | T]
        ),
        noun_phrase(T, End, build(Name, Battery, Camera, ControlUnit, Frame, Motor), [Head|Tail], []),
        prove_all(Tail),
        member(End,[[],["to", "the", "database"],["."], ["to", "database"], ["to", "backend"]]),
        catch(
            createBuild(build(Name, Battery, Camera, ControlUnit, Frame, Motor)),
            _,
            (format("An error occurred during database operations, please make sure the Build's name is unique"), fail)
        ),
        !.

% Credit: error handling techniques learnt from ChatGPT. (Syntax only)
add_hardware_phrase(["add" | L0], End, Ind, C, []) :-
    noun_phrase(L0, End, Ind, C, []),
    member(End,[[],["to", "the", "database"],["."], ["to", "database"], ["to", "backend"]]),
    ground(Ind),
    catch(
        addHardware(Ind),
        _,
        (format('An error occurred during database operations, please make sure the name is unique'), fail)
    ),
    !.

addHardware(battery(Name, Capacity, Weight)) :-
    addBattery(battery(Name, Capacity, Weight)).
addHardware(motor(Name, Thrust, Weight, Power)) :-
    addMotor(motor(Name, Thrust, Weight, Power)).
addHardware(camera(Name, Resolution, Weight)) :-
    writeln("aaa"),
    addCamera(camera(Name, Resolution, Weight)).
addHardware(controlUnit(Name, TransmissionDistance, Weight)) :-
    addControlUnit(controlUnit(Name, TransmissionDistance, Weight)).
addHardware(frame(Name, Weight, NumberOfMotors)) :-
    addFrame(frame(Name, Weight, NumberOfMotors)).

det(["the" | L],L,_,C,C).
det(["a" | L],L,_,C,C).
det(["an" | L],L,_,C,C).
det(L,L,_,C,C).


adjectives(L,L,_,C,C).

called(Name, motor(Name, _, _, _)).
called(Name, battery(Name, _, _)).
called(Name, camera(Name, _, _)).
called(Name, controlUnit(Name, _, _)).
called(Name, frame(Name, _, _)).
called(Name, build(Name, _, _, _, _, _)).


weight(Weight, motor(_, _, Weight, _)).
weight(Weight, battery(_, _, Weight)).
weight(Weight, camera(_, _, Weight)).
weight(Weight, controlUnit(_, _, Weight)).
weight(Weight, frame(_, Weight, _) ).

sweight(SWeight, motor(_, _, Weight, _)) :- Weight #< SWeight.
sweight(SWeight, battery(_, _, Weight)) :- Weight #< SWeight.
sweight(SWeight, camera(_, _, Weight)) :- Weight #< SWeight.
sweight(SWeight, controlUnit(_, _, Weight)) :- Weight #< SWeight.
sweight(SWeight, frame(_, Weight, _) ) :- Weight #< SWeight.

bweight(SWeight, motor(_, _, Weight, _)) :- Weight #> SWeight.
bweight(SWeight, battery(_, _, Weight)) :- Weight #> SWeight.
bweight(SWeight, camera(_, _, Weight)) :- Weight #> SWeight.
bweight(SWeight, controlUnit(_, _, Weight)) :- Weight #> SWeight.
bweight(SWeight, frame(_, Weight, _) ) :- Weight #> SWeight.

thrust(Thrust, motor(_, Thrust, _, _)).
sthrust(SThrust, motor(_, Thrust, _, _)) :- Thrust #< SThrust.
bthrust(SThrust, motor(_, Thrust, _, _)) :- Thrust #> SThrust.

powerCons(PowerCons, motor(_, _, _, PowerCons)).
spowerCons(SPowerCons, motor(_, _, _, PowerCons)) :- PowerCons #< SPowerCons.
bpowerCons(SPowerCons, motor(_, _, _, PowerCons)) :- PowerCons #> SPowerCons.

capacity(Capacity, battery(_, Capacity, _)).
scapacity(SCapacity, battery(_, Capacity, _)) :- Capacity #< SCapacity.
bcapacity(SCapacity, battery(_, Capacity, _)) :- Capacity #> SCapacity.

resolution(Resolution, camera(_, Resolution, _)).
sresolution(SResolution, camera(_, Resolution, _)) :- Resolution #< SResolution.
bresolution(SResolution, camera(_, Resolution, _)) :- Resolution #> SResolution.

transmissionDistance(Distance, controlUnit(_, Distance, _)).
stransmissionDistance(SDistance, controlUnit(_, Distance, _)) :- Distance #< SDistance.
btransmissionDistance(SDistance, controlUnit(_, Distance, _)) :- Distance #> SDistance.

numberOfMotors(NumberOfMotors, frame(_, _, NumberOfMotors)).
snumberOfMotors(SNumberOfMotors, frame(_, _, NumberOfMotors)) :- NumberOfMotors #< SNumberOfMotors.
bnumberOfMotors(SNumberOfMotors, frame(_, _, NumberOfMotors)) :- NumberOfMotors #> SNumberOfMotors.


noun(["battery" | L], L1, Ind, [isBattery(Ind)|C1],C) :-
    optObjClause(L, L1, Ind, C1, C).
noun(["motor" | L], L1, Ind, [isMotor(Ind)|C1],C) :-
    optObjClause(L, L1, Ind, C1, C).
noun(["camera" | L], L1, Ind, [isCamera(Ind)|C1],C) :-
    optObjClause(L, L1, Ind, C1, C).
noun(["control", "unit" | L], L1, Ind, [isControlUnit(Ind)|C1],C) :-
    optObjClause(L, L1, Ind, C1, C).
noun(["frame"| L], L1, Ind, [isFrame(Ind)|C1],C) :-
    optObjClause(L, L1, Ind, C1, C).
noun(["build"| L], L1, Ind, [isBuild(Ind)|C1],C) :-
    optObjClause(L, L1, Ind, C1, C).

optObjClause(["called", Name | L], L, Ind, [called(Name, Ind)|C], C) :- called(Name, Ind).
optObjClause(L, L, _, C, C).

optPrePosition(["with" | L], L1, Ind, C0, C) :- preposition(L, L1, Ind, C0, C).
optPrePosition(["that" | L], L1, Ind, C0, C) :- preposition(L, L1, Ind, C0, C).
optPrePosition(["has" | L], L1, Ind, C0, C) :- preposition(L, L1, Ind, C0, C).
% optPrePosition(L, L1, Ind, C0, C) :- preposition(L, L1, Ind, C0, C).
optPrePosition(L, L, _, C, C).



build_contains(build(_, battery(BattName, Capacity, BattWeight), _, _, _, _), battery(BattName, Capacity, BattWeight)).
build_contains(build(_, _, camera(CamName, Resolution, CamWeight), _, _, _), camera(CamName, Resolution, CamWeight)).
build_contains(build(_, _, _, controlUnit(ControlName, TransmissionDistance, ControlWeight), _, _), controlUnit(ControlName, TransmissionDistance, ControlWeight)).
build_contains(build(_, _, _, _, frame(FrameName, FrameWeight, NumberOfMotors), _), frame(FrameName, FrameWeight, NumberOfMotors)).
build_contains(build(_, _, _, _, _, motor(MotorName, Thrust, MotorWeight, Power)), motor(MotorName, Thrust, MotorWeight, Power)).




%%%%% Weight
preposition(L0, L1, Ind, C0, C) :- 
    ((
        C0 = [bweight(Weight, Ind)|C1],
        bweight(Weight, Ind),
        (
            L0 = ["and", "weights", "more", "than", Weight| T] ;
            L0 = ["and", "weight", "more", "than", Weight| T];
            L0 = ["weight", "more", "than", Weight| T] ;
            L0 = ["weights", "more", "than", Weight| T]
            
        )
    ); 
    (
        C0 = [sweight(Weight, Ind)|C1],
        sweight(Weight, Ind),
        (   
            L0 = ["and", "weights", "less", "than", Weight| T] ;
            L0 = ["and", "weight", "less", "than", Weight| T];
            L0 = ["weight", "less", "than", Weight| T] ;
            L0 = ["weights", "less", "than", Weight| T]
            
        )
    );
    (
        C0 = [weight(Weight, Ind)|C1],
        weight(Weight, Ind),
        (   
            L0 = ["and", "weight", "exactly", Weight| T] ;
            L0 = ["and", "weights", "exactly", Weight| T];
            L0 = ["weight", "exactly", Weight| T] ;
            L0 = ["weights", "exactly", Weight| T]
            
        )
       
    )),
    (
        T = ["grams" | L] ;
        T = ["gram" | L] ;
        T = ["g" | L]
    ),
    preposition(L, L1, Ind, C1, C).

/* Thrust begins here */
% Uses ; -> OR operator to condense number of pattern matches
preposition(L0, L1, Ind, C0, C) :- 
    ((
        C0 = [bthrust(Thrust, Ind)|C1],
        bthrust(Thrust, Ind),
        (
            L0 = ["thrust", "more", "than", Thrust| T] ;
            L0 = ["thrusts", "more", "than", Thrust| T] ;
            L0 = ["more", "than", Thrust| T];
            L0 = ["and", "thrust", "more", "than", Thrust| T] ;
            L0 = ["and", "thrusts", "more", "than", Thrust| T] ;
            L0 = ["and", "more", "than", Thrust| T]
        )
    ) ; 
    (
        C0 = [sthrust(Thrust, Ind)|C1],
        sthrust(Thrust, Ind),
        (
            L0 = ["thrust", "less", "than", Thrust| T] ;
            L0 = ["thrusts", "less", "than", Thrust| T] ;
            L0 = ["less", "than", Thrust| T];
            L0 = ["and", "thrust", "less", "than", Thrust| T] ;
            L0 = ["and", "thrusts", "less", "than", Thrust| T] ;
            L0 = ["and", "less", "than", Thrust| T]
        )
    );
    (
        C0 = [thrust(Thrust, Ind)|C1],
        thrust(Thrust, Ind),
        (
            L0 = ["thrust", "exactly", Thrust| T] ;
            L0 = ["thrusts", "exactly", Thrust| T];
            L0 = ["and", "thrust", "exactly",Thrust| T] ;
            L0 = ["and", "thrusts", "exactly",Thrust| T]
        )
    )),
    (
        T = ["grams", "of", "thrust" | L] ;
        T = ["grams" | L] ;
        T = ["gram" | L] ;
        T = ["g" | L]
    ),
    preposition(L, L1, Ind, C1, C).

%%%%% Power consumption
% preposition([PowerCons, "w", "of", "power", "consumption"| L], L1, Ind, [powerCons(PowerCons, Ind)|C1], C) :- 
%     powerCons(PowerCons, Ind),
%     preposition(L, L1, Ind, C1, C).

preposition(L0, L1, Ind, C0, C) :- 
    ((
        C0 = [bpowerCons(PowerCons, Ind)|C1],
        bpowerCons(PowerCons, Ind),
        (
            L0 = ["more", "than", PowerCons| T];
            L0 = ["and", "more", "than", PowerCons| T]
        )
        
    ); 
    (
        C0 = [spowerCons(PowerCons, Ind)|C1],
        spowerCons(PowerCons, Ind),
        (
            L0 = ["less", "than", PowerCons| T];
            L0 = ["and", "less", "than", PowerCons| T]
        )
    );
    (
        C0 = [powerCons(PowerCons, Ind)|C1],
        powerCons(PowerCons, Ind),
        (
            L0 = ["and", "exactly",PowerCons| T];
            L0 = ["exactly", PowerCons| T]
        )
    )),
    (
        T = ["w" | L] ;
        T = ["watt" | L] ;
        T = ["watts" | L] ;
        T = ["watts", "of", "power" | L] ;
        T = ["w", "of", "power", "consumption" | L] ;
        T = ["watts", "of", "power", "consumption" | L] ;
        T = ["watts", "of", "power" | L] ;
        T = ["power" | L]
    ),
    preposition(L, L1, Ind, C1, C).

preposition(L0, L1, Ind, C0, C) :- 
    (
        C0 = [called(Name, Ind)|C1],
        called(Name, Ind),
        (
            L0 = ["called", Name| L];
            L0 = ["and", "called", Name| L]
        )
        
    ),
    preposition(L, L1, Ind, C1, C).

%%%%% Capacity
preposition(L0, L1, Ind, C0, C) :- 
    ((
        C0 = [bcapacity(Capacity, Ind)|C1],
        bcapacity(Capacity, Ind),
        (
            L0 = ["more", "than", Capacity| T];
            L0 = ["and", "more", "than", Capacity| T]
        )
    ); 
    (
        C0 = [scapacity(Capacity, Ind)|C1],
        scapacity(Capacity, Ind),
        (
            L0 = ["less", "than", Capacity| T];
            L0 = ["and", "less", "than", Capacity| T]
        )
    );
    (
        C0 = [capacity(Capacity, Ind)|C1],
        capacity(Capacity, Ind),
        (
            L0 = ["exactly", Capacity| T];
            L0 = ["and", "exactly", Capacity| T]
        )
    )),
    (
        T = ["wh" | L] ;
        T = ["watt-hour" | L] ;
        T = ["watt-hours" | L] ;
        T = ["wh", "capacity" | L] ;
        T = ["watt-hour", "capacity" | L] ;
        T = ["watt-hours", "capacity" | L] ;
        T = ["capacity" | L]
    ),
    preposition(L, L1, Ind, C1, C).

%%%%% Resolution
preposition(L0, L1, Ind, C0, C) :- 
    ((
        C0 = [bresolution(Resolution, Ind)|C1],
        bresolution(Resolution, Ind),
        (
            L0 = ["more", "than", Resolution| T];
            L0 = ["and", "more", "than", Resolution| T]
        )
    ); 
    (
        C0 = [sresolution(Resolution, Ind)|C1],
        sresolution(Resolution, Ind),
        (
            L0 = ["less", "than", Resolution| T];
            L0 = ["and", "less", "than", Resolution| T]
        )
    );
    (
        C0 = [resolution(Resolution, Ind)|C1],
        resolution(Resolution, Ind),
        (
            L0 = ["exactly", Resolution| T];
            L0 = ["and", "exactly", Resolution| T]
        )
    )),
    (
        T = ["p" | L] ;
        T = ["mp" | L] ;
        T = ["pixel" | L] ;
        T = ["pixels" | L] ;
        T = ["p", "camera" | L] ;
        T = ["mp", "camera" | L] ;
        T = ["pixel", "camera" | L] ;
        T = ["pixels", "camera" | L]
    ),
    preposition(L, L1, Ind, C1, C).


%%%%% Transmission distance
preposition(L0, L1, Ind, C0, C) :- 
    ((
        C0 = [btransmissionDistance(Distance, Ind)|C1],
        btransmissionDistance(Distance, Ind),
        (
            L0 = ["more", "than", Distance| T];
            L0 = ["and", "more", "than", Distance| T]
        )
    ); 
    (
        C0 = [stransmissionDistance(Distance, Ind)|C1],
        stransmissionDistance(Distance, Ind),
        (
            L0 = ["less", "than", Distance| T];
            L0 = ["and", "less", "than", Distance| T]
        )
    );
    (
        C0 = [transmissionDistance(Distance, Ind)|C1],
        transmissionDistance(Distance, Ind),
        (
            L0 = ["exactly", Distance| T];
            L0 = ["and", "exactly", Distance| T]
        )
    )),
    (
        T = ["meters" | L] ;
        T = ["meters", "of", "transmission" | L] ;
        T = ["meters", "of", "distance" | L] ;
        T = ["meters", "of", "discourse" | L] ;
        T = ["meters", "of", "transmission", "discourse" | L] ;
        T = ["meters", "of", "transmission", "distance" | L]
    ),
    preposition(L, L1, Ind, C1, C).


%%%%% Number of motors
preposition(L0, L1, Ind, C0, C) :- 
    ((
        C0 = [bnumberOfMotors(NumberOfMotors, Ind)|C1],
        bnumberOfMotors(NumberOfMotors, Ind),
        (
            L0 = ["more", "than", NumberOfMotors| T];
            L0 = ["and", "more", "than", NumberOfMotors| T]
        )
    ); 
    (
        C0 = [snumberOfMotors(NumberOfMotors, Ind)|C1],
        snumberOfMotors(NumberOfMotors, Ind),
        (
            L0 = ["less", "than", NumberOfMotors| T];
            L0 = ["and", "less", "than", NumberOfMotors| T]
        )
    );
    (
        C0 = [numberOfMotors(NumberOfMotors, Ind)|C1],
        numberOfMotors(NumberOfMotors, Ind),
        (
            L0 = ["exactly", NumberOfMotors| T];
            L0 = ["and", "exactly", NumberOfMotors| T]
        )
    )),
    (
        T = ["motor" | L] ;
        T = ["motors" | L]
    ),
    preposition(L, L1, Ind, C1, C).

preposition(L0, L2, build(Name, Battery, Camera, ControlUnit, Frame, Motor), [build_contains(build(Name, Battery, Camera, ControlUnit, Frame, Motor), Comp) | Cr], C0) :-
    noun_phrase(L0, L1, Comp, Cn, []),
    preposition(L1, L2, build(Name, Battery, Camera, ControlUnit, Frame, Motor), C1, C0),
    append(Cn, C1, Cr).

preposition(L0, L2, build(Name, Battery, Camera, ControlUnit, Frame, Motor), [build_contains(build(Name, Battery, Camera, ControlUnit, Frame, Motor), Comp) | Cr], C0) :-
    noun_phrase(L0, ["and" | L1], Comp, Cn, []),
    preposition(L1, L2, build(Name, Battery, Camera, ControlUnit, Frame, Motor), C1, C0),
    append(Cn, C1, Cr).
        
preposition(L,L,_,C,C).

%%%%% Tests
test([[H|T], A, "of" | L], [H|T], L, A).

