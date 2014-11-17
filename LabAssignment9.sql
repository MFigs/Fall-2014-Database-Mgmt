CREATE TABLE people (
  personID      char(4) not null,
  firstName     text,
  lastName      text,
  address       text,
  phoneNum      text,
 primary key(personID)
);

CREATE TABLE coaches (
  coachID       char(4) not null references people(personID),
  yearsCoached  integer,
 primary key(coachID)
);

CREATE TABLE headCoaches (
  headCoachID   char(4) not null references coaches(coachID),
 primary key(headCoachID)
);

CREATE TABLE asstCoaches (
  asstCoachID   char(4) not null references coaches(coachID),
 primary key(asstCoachID)
);

CREATE TABLE ageGroups (
  AGID          char(4) not null,
  minAge        integer,
  maxAge        integer,
 primary key(AGID)
);

CREATE TABLE teams (
  teamID        char(4) not null,
  AGID          char(4) references ageGroups(AGID),
 primary key(teamID)
);

CREATE TABLE players (
  playerID      char(4) not null references people(personID),
  teamID        char(4) references teams(teamID),
 primary key(playerID)
);

CREATE TABLE headCoachRoster (
  headCoachID   char(4) not null references headCoaches(headCoachID),
  AGID          char(4) not null references ageGroups(AGID),
  teamID        char(4) not null,
 primary key(headCoachID, AGID)
);

CREATE TABLE asstCoachRoster (
  asstCoachID   char(4) not null references asstCoaches(asstCoachID),
  AGID          char(4) not null references ageGroups(AGID),
  teamID        char(4) not null,
 primary key(asstCoachID, AGID)
);