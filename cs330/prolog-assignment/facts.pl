% Extra data for testing
student(bad,cs).
student(jon,cs).

% taking class before prerequisite
entry(bad,cs367,[spring,2008]).
entry(bad,cs330,[spring,2008]).
entry(bad,cs211,[fall,2008]).
entry(bad,cs465,[fall,2008]).

% taking an invalid class
entry(bad,geo201,[fall,2008]).

entry(jon,cs101,[fall,2005]).
entry(jon,cs211,[spring,2006]).
entry(jon,cs310,[fall,2007]).
entry(jon,cs303,[spring,2008]).
entry(jon,cs330,[fall,2008]).

prereq(cs101,cs211).
prereq(cs211,cs330).
prereq(cs211,cs310).
prereq(cs211,cs367).
prereq(cs310,cs483).
prereq(cs330,cs483).
prereq(cs367,cs465).
prereq(cs330,cs465).
prereq(cs211,cs421).

approved_list(cs,[cs101,cs105,cs112,cs211,cs303,cs310,cs330,cs367,cs465,cs483]).
approved_list(geo,[geo101, geo201, geo301]).