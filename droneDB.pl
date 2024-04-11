/*
conventions:

add a battery called battName with weight 100 grams, 100wh power.

motor(Name, Thrust, Weight, Power)
battery(Name, Capacity, Weight)
camera(Name, Resolution, Weight)
controlUnit(Name, TransmissionDistance, Weight)
frame(Name, Weight, NumberOfMotors) 

build(Name,
    battery(BattName, Capacity, BattWeight),
    camera(CamName, Resolution, CamWeight), 
    controlUnit(ControlName, TransmissionDistance, ControlWeight), 
    frame(FrameName, FrameWeight, NumberOfMotors),
    motor(MotorName, Thrust, MotorWeight, Power))

acknowledgement:
The database access code were written with the faciliation from ChatGPT
it only provided examples of the use of ODBC library on a test database differ from this project's scope. 
*/

connect_db :-
    odbc_connect('localMysql', _Connection, 
                 [ user('root'),
                   password('localMysql7'),
                   alias(prologDB),
                   open(once)
                 ]).

% credit to joeblog @ site https://swi-prolog.discourse.group/t/is-this-the-best-way-to-replace-characters-in-a-string/640
sql_escape_single_quotes(StringIn, StringOut) :-
    split_string(StringIn, "'", "", List),
    atomics_to_string(List, "''", StringOut).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
isMotor(motor(Name, Thrust, Weight, Power)) :-
    connect_db,
    odbc_query(prologDB, 'SELECT * FROM motor', row(NameSingle, Thrust, Weight, Power)),
    sql_escape_single_quotes(NameSingle, Name).

addMotor(motor(Name, Thrust, Weight, Power)) :-
    connect_db,
    odbc_prepare(prologDB, 
        'INSERT INTO motor (sname, thrust, weight, power) VALUES (?, ?, ?, ?)', 
        [varchar(string), integer, integer, integer], 
        Statement, 
        [fetch(fetch)]),
        odbc_execute(Statement, [Name, Thrust, Weight, Power]),
        odbc_free_statement(Statement).
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
isBattery(battery(Name, Capacity, Weight)) :-
    connect_db,
    odbc_query(prologDB, 'SELECT * FROM battery', row(NameSingle, Capacity, Weight)),
    sql_escape_single_quotes(NameSingle, Name).


% isBattery(battery(Name, CapacityQ, WeightQ)) :-
%     not(number(CapacityQ)),
%     connect_db,
%     odbc_query(prologDB, 'SELECT * FROM battery', row(NameSingle, Capacity, Weight)),
%     sql_escape_single_quotes(Capacity, CapacityQ),
%     sql_escape_single_quotes(Weight, WeightQ),
%     sql_escape_single_quotes(NameSingle, Name).

addBattery(battery(Name, Capacity, Weight)) :-
    connect_db,
    odbc_prepare(prologDB, 
        'INSERT INTO battery (sname, capacity, weight) VALUES (?, ?, ?)', 
        [varchar(string), integer, integer], 
        Statement, 
        [fetch(fetch)]),
        odbc_execute(Statement, [Name, Capacity, Weight]),
        odbc_free_statement(Statement).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

isCamera(camera(Name, Resolution, Weight)) :-
    connect_db,
    odbc_query(prologDB, 'SELECT * FROM camera', row(NameSingle, Resolution, Weight)),
    sql_escape_single_quotes(NameSingle, Name).

addCamera(camera(Name, Resolution, Weight)) :-
    connect_db,
    odbc_prepare(prologDB, 
        'INSERT INTO camera (sname, resolution, weight) VALUES (?, ?, ?)', 
        [varchar(string), float, integer], 
        Statement, 
        [fetch(fetch)]),
        odbc_execute(Statement, [Name, Resolution, Weight]),
        odbc_free_statement(Statement).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

isControlUnit(controlUnit(Name, TransmissionDistance, Weight)) :-
    connect_db,
    odbc_query(prologDB, 'SELECT * FROM controlUnit', row(NameSingle, TransmissionDistance, Weight)),
    sql_escape_single_quotes(NameSingle, Name).

addControlUnit(controlUnit(Name, TransmissionDistance, Weight)) :-
    connect_db,
    odbc_prepare(prologDB, 
        'INSERT INTO controlUnit (sname, transmissionDistance, weight) VALUES (?, ?, ?)', 
        [varchar(string), integer, integer], 
        Statement, 
        [fetch(fetch)]),
        odbc_execute(Statement, [Name, TransmissionDistance, Weight]),
        odbc_free_statement(Statement).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

isFrame(frame(Name, Weight, NumberOfMotors)) :-
    connect_db,
    odbc_query(prologDB, 'SELECT * FROM frame', row(NameSingle, Weight, NumberOfMotors)),
    sql_escape_single_quotes(NameSingle, Name).

addFrame(frame(Name, Weight, NumberOfMotors)) :-
    connect_db,
    odbc_prepare(prologDB, 
        'INSERT INTO frame (sname, weight, numberOfMotors) VALUES (?, ?, ?)', 
        [varchar(string), integer, integer], 
        Statement, 
        [fetch(fetch)]),
        odbc_execute(Statement, [Name, Weight, NumberOfMotors]),
        odbc_free_statement(Statement).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

empOrSame('$null$', _).
empOrSame(Actual, Expected) :- sql_escape_single_quotes(Actual, Expected).

% valOrNull(Actual, Actual) :- ground(Actual).
valOrNull(battery(BattName, _, _), BattName) :- 
    ground(BattName),
    isBattery(battery(BattName, _, _)).

valOrNull(camera(CamName, _, _), CamName) :- 
    ground(CamName),
    isCamera(camera(CamName, _, _)).

valOrNull(controlUnit(ControlName, _, _), ControlName) :- 
    ground(ControlName),
    isControlUnit(controlUnit(ControlName, _, _)).

valOrNull(frame(FrameName, _, _), FrameName) :- 
    ground(FrameName),
    isFrame(frame(FrameName, _, _)).

valOrNull(motor(MotorName, _, _, _), MotorName) :- 
    ground(MotorName),
    isMotor(motor(MotorName, _, _, _)).

valOrNull(_, '$null$').

createBuild(build(Name, Battery, Camera, ControlUnit, Frame, Motor)) :-
    connect_db,
    odbc_prepare(prologDB, 
        'INSERT INTO build (buildName, battery, camera, controlUnit, frame, motor) VALUES (?, ?, ?, ?, ?, ?)', 
        [varchar(string), varchar(string), varchar(string), varchar(string), varchar(string), varchar(string)], 
        Statement, 
        [fetch(fetch)]),
        ground(Name),
        valOrNull(Battery, BattTemp),
        valOrNull(Camera, CamTemp),
        valOrNull(ControlUnit, CtrTemp),
        valOrNull(Frame, FrTemp),
        valOrNull(Motor, MotorTemp),
        odbc_execute(Statement, [Name, BattTemp, CamTemp, CtrTemp, FrTemp, MotorTemp]),
        odbc_free_statement(Statement).

isBuild(build(Name,
    battery(BattName, Capacity, BattWeight),
    camera(CamName, Resolution, CamWeight), 
    controlUnit(ControlName, TransmissionDistance, ControlWeight), 
    frame(FrameName, FrameWeight, NumberOfMotors),
    motor(MotorName, Thrust, MotorWeight, Power))) :-

    connect_db,
    odbc_query(prologDB, 'SELECT * FROM build', row(NameSingle, 
        BattNameSingle, 
        CamNameSingle, 
        ControlNameSingle, 
        FrameNameSingle,
        MotorNameSingle)),
    
    sql_escape_single_quotes(NameSingle, Name),
    sql_escape_single_quotes(BattNameSingle, BattName),
    sql_escape_single_quotes(CamNameSingle, CamName),
    sql_escape_single_quotes(ControlNameSingle, ControlName),
    sql_escape_single_quotes(FrameNameSingle, FrameName),
    sql_escape_single_quotes(MotorNameSingle, MotorName),
    (
        isBattery(battery(BattName, Capacity, BattWeight));
        BattNameSingle = '$null$'
    ),
    (
        isCamera(camera(CamName, Resolution, CamWeight));
        CamNameSingle = '$null$'
    ),
    (
        isControlUnit(controlUnit(ControlName, TransmissionDistance, ControlWeight));
        ControlNameSingle = '$null$'
    ),
    (
        isFrame(frame(FrameName, FrameWeight, NumberOfMotors));
        FrameNameSingle = '$null$'
    ),
    (
        isMotor(motor(MotorName, Thrust, MotorWeight, Power));
        MotorNameSingle = '$null$'
    ).
