% author: Jon morton

prereq_chain(Class1,Class2) :-
  prereq(Class1,Class2).

prereq_chain(Class1,Class2) :-
  prereq(Class1,OtherClass),
  prereq(OtherClass,Class2).

% For student X there exists a prereq_chain between Y and Z
% for which Z is scheduled before Y.
invalid_pair(Student,Class1,Class2) :-
  prereq_chain(Class1,Class2),
  entry(Student,Class1,Semester1),
  entry(Student,Class2,Semester2),
  before(Semester2,Semester1).
  
invalid_pair(Student,Class1,Class2) :-
  prereq_chain(Class2,Class1),
  entry(Student,Class1,Semester1),
  entry(Student,Class2,Semester2),
  before(Semester1,Semester2).

all_valid_pairs(Student) :-
  invalid_pair(Student,_,_),!,fail;true.

no_invalid_pairs(Student) :-
  student(Student,_),
  all_valid_pairs(Student).
  
% The course is one that is not part of the major
% and is on the students schedule
bad_course(Student,Course) :-
  student(Student,Major),
  entry(Student,Course,_),
  approved_list(Major,Courses),
  not_member(Course,Courses).

only_good_courses(Student) :-
  entry(Student,Course,_),
  bad_course(Student,Course),!,fail;true.

no_bad_courses(Student) :- 
  entry(Student,_,_),
  only_good_courses(Student).

not_enrolled(Student,Course) :-
  entry(Student,Course,_),!,fail;true.

missing_course(Student,MissingCourse) :-
  entry(Student,Course,_),
  prereq_chain(MissingCourse,Course),
  not_enrolled(Student,MissingCourse).
  
missing_course_b(Student,MissingCourse) :-
  entry(Student,Course,_),
  prereq_chain(MissingCourse,Course),
  entry(Student,MissingCourse,_);
  fail.

not_member(K,L) :- member(K,L),!,fail.
not_member(_,_).

before(spring,summer).
before(spring,fall).
before(summer,fall).
before([S1,Y1],[S2,Y2]) :- Y1 < Y2; Y1 = Y2, before(S1,S2).
