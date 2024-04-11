# create database prologDB;
use prologDB;

drop table build;
drop table frame;
drop table motor;
drop table controlUnit;
drop table camera;
drop table battery;

create table frame (
    sname varchar(255) primary key,
    weight int not null,
    numberOfMotors int not null
);

create table motor(
    sname varchar(255) primary key,
    thrust int not null,
    weight int not null,
    power int not null
);

create table controlUnit
(
    sname varchar(255) primary key,
    transmissionDistance int not null,
    weight int not null
);

create table camera(
    sname varchar(255) primary key,
    resolution int not null,
    weight int not null
);

create table battery(
    sname varchar(255) primary key,
    capacity int not null,
    weight int not null
);

create table build (
    buildName varchar(255) primary key,
    battery varchar(255),
    camera varchar(255),
    controlUnit varchar(255),
    frame varchar(255),
    motor varchar(255),
    foreign key (battery) references battery(sname),
    foreign key (camera) references camera(sname),
    foreign key (controlUnit) references controlUnit(sname),
    foreign key (frame) references frame(sname),
    foreign key (motor) references motor(sname)
);

# weight = grams (rounded to whole number)
insert into frame(sname, weight, numberOfMotors) values ('TBSV5', 124, 4);
insert into frame(sname, weight, numberOfMotors) values ('Assassin', 210, 4);
insert into frame(sname, weight, numberOfMotors) values ('BumblebeeV3', 164, 4);
insert into frame(sname, weight, numberOfMotors) values ('BWhoop65', 3, 4);
insert into frame(sname, weight, numberOfMotors) values ('Feather120', 10, 4);

# didn't find much information about thrust
# power = watts (rounded, some converted/estimated from KV)
# weight = grams (rounded)
insert into motor(sname, thrust, weight, power) values ('FlexRC', 1000, 4, 86);
insert into motor(sname, thrust, weight, power) values ('FlyFishRCPro', 2000, 36, 875);
insert into motor(sname, thrust, weight, power) values ('Lumenier', 1500, 23, 150);
insert into motor(sname, thrust, weight, power) values ('FlyFishRC', 950, 14, 200);
insert into motor(sname, thrust, weight, power) values ('T-Motor', 2500, 34, 1297);

# resolution = pixels
# weight = grams (rounded to whole number)
insert into camera(sname, resolution, weight) values ('RunCam', 720, 1); # 800tvl resolution
insert into camera(sname, resolution, weight) values ('DJI', 1080, 36);
insert into camera(sname, resolution, weight) values ('JINJIEAN', 1080, 20);
insert into camera(sname, resolution, weight) values ('Firefly', 2160, 19);
insert into camera(sname, resolution, weight) values ('RunCamPro', 1080, 5); # 1200tvl

# not much information about transmission distance
# transmission distance = m
# weight = grams (rounded)
insert into controlUnit(sname, transmissionDistance, weight) values ('F411', 3000, 7);
insert into controlUnit(sname, transmissionDistance, weight) values ('O3Air', 10000, 28);
insert into controlUnit(sname, transmissionDistance, weight) values ('Tinyhawk', 12000, 20);
insert into controlUnit(sname, transmissionDistance, weight) values ('NewBeeDrone', 9000, 16);
insert into controlUnit(sname, transmissionDistance, weight) values ('Holybro', 15000, 8);

# capacity = mAh
# weight = grams (rounded)
insert into battery(sname, capacity, weight) values ('1SLipo', 650, 16);
insert into battery(sname, capacity, weight) values ('6SLipo', 1050, 186);
insert into battery(sname, capacity, weight) values ('DJIMavic', 3600, 408);
insert into battery(sname, capacity, weight) values ('DJIPhantom4', 5200, 635);
insert into battery(sname, capacity, weight) values ('DJIPhantom3', 2600, 91);

insert into build(buildName, battery, camera, controlUnit, frame, motor) values ('Feather120', '1SLipo', 'RunCam', 'F411', 'Feather120', 'FlexRC');
insert into build(buildName, battery, camera, controlUnit, frame, motor) values ('DJI_O3_Air', '6SLipo', 'DJI', 'O3Air', 'BWhoop65', 'FlyFishRC');
# custom builds
-- insert into build(buildName, battery, camera, controlUnit, frame, motor) values ('Custom_drone_1', 'DJI Mavic 2 Pro Mavic 2 Battery', '2022 New Hawkeye Firefly Split', 'Holybro Kakute G4 AIO', 'TBS Source One V5 5', 'Lumenier ZIP V2 2006 2450Kv Cinematic');
-- insert into build(buildName, battery, camera, controlUnit, frame, motor) values ('Custom drone 2', 'DJI Phantom 4 Pro Battery', 'JINJIEAN White Snake', 'NewBeeDrone X FETTec Infinity AIO', 'Assassin 5-inch', 'Lumenier ZIP V2 2006 2450Kv Cinematic');
-- insert into build(buildName, battery, camera, controlUnit, frame, motor) values ('Custom drone 3', 'DJI Phantom 4 Pro Battery', 'RunCam Nano 4', 'EMAX Tinyhawk III AIO', 'Bumblebee HD V3', 'T-Motor F60 Pro V 2207.5 2020Kv Motor');
