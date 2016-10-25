/* Yiming Yu
   A99088554
   cs132aby 
*/

/*
(a)
CREATE TABLE SAILOR (
sname VARCHAR(20) PRIMARY KEY,
rating INTEGER NOT NULL
);

CREATE TABLE BOAT (
bname  VARCHAR(20) PRIMARY KEY,
color TEXT NOT NULL ,
rating INTEGER NOT NULL
);

CREATE TABLE RESERVATION (
sname TEXT NOT NULL REFERENCES SAILOR(sname) ,
bname TEXT NOT NULL REFERENCES BOAT(bname) ,
day TEXT NOT NULL
);
*/

/* (b)
1. List all boats reserved on Wednesday and their color
*/
SELECT b.bname,b.color
FROM BOAT b,RESERVATION r
WHERE r.bname=b.bname AND r.day="Wednesday";

/* 
2. List all pairs of sailors who have reserved boats on the same day
*/
SELECT sa.sname,sb.sname
FROM SAILOR sa,SAILOR sb ,RESERVATION r1,RESERVATION r2
WHERE r1.sname=sa.sname AND r2.sname=sb.sname AND r1.day=r2.day AND sa.sname < sb.sname
GROUP BY sa.sname,sb.sname;

/*
3. For each day, list the number of red boats reserved on that day.
*/
CREATE TABLE DATE (
day TEXT
);
INSERT INTO DATE values("Monday");
INSERT INTO DATE values("Tuesday");
INSERT INTO DATE values("Wednesday");
INSERT INTO DATE values("Thursday");
INSERT INTO DATE values("Friday");
INSERT INTO DATE values("Saturday");
INSERT INTO DATE values("Sunday");


SELECT D.day, COALESCE(D.d, 0 ) 
FROM (SELECT a.day AS day,B.t
   	FROM (Select * FROM DATE) AS a LEFT OUTER JOIN
		(SELECT r.day,COUNT(*) as t
		FROM RESERVATION r, BOAT b
		WHERE r.bname=b.bname AND b.color="red"
		GROUP BY r.day) AS B
ON a.day=B.day
) AS D;

/*
4. List the days appearing in the reservation table for which only
red boats are reserved.
(a)with only NOT IN tests.
*/
SELECT day
FROM RESERVATION 
WHERE day NOT IN (
	SELECT r.day
	FROM RESERVATION r,BOAT b
	WHERE r.bname=b.bname AND b.color <> "red"
)
GROUP BY day;

/*
4. (b)with only NOT EXISTS tests;
*/
SELECT r1.day 
FROM reservation r1
WHERE NOT EXISTS(
 	SELECT r2.day 
 	FROM reservation r2, BOAT b
 	WHERE b.bname = r2.bname AND b.color <> "red" AND r1.day = r2.day
)
GROUP by r1.day;

/*
4. (c)with only COUNT aggregate functions.
*/
SELECT r1.day
FROM RESERVATION r1, BOAT b1,
		      (SELECT r2.day as d2, count(*) as c1 
                      FROM RESERVATION r2
                      GROUP BY r2.day ) AS D2,
		      (SELECT r.day as d, count(*) as c 
                      FROM RESERVATION r,BOAT b 
                      WHERE r.bname=b.bname AND b.color = "red"
		      GROUP BY r.day ) AS D
WHERE D.d = D2.d2 AND D.c = D2.c1 AND r1.day = D.d
GROUP BY r1.day

/*
5.List the days on which no red boats are reserved.
*/
CREATE TABLE WEEK (
day TEXT
);
INSERT INTO DATE values("Monday");
INSERT INTO DATE values("Tuesday");
INSERT INTO DATE values("Wednesday");
INSERT INTO DATE values("Thursday");
INSERT INTO DATE values("Friday");
INSERT INTO DATE values("Saturday");
INSERT INTO DATE values("Sunday");

SELECT day
FROM WEEK 
WHERE day NOT IN (
SELECT r.day
FROM RESERVATION r,BOAT b
WHERE r.bname=b.bname AND b.color = "red"
);

/*
6. For each day of the week occurring in the reservation relation,
list the average rating of sailors having reserved boats that day.
*/
(
SELECT r1.day,AVG(s1.rating)
FROM RESERVATION r1, SAILOR s1, RESERVATION r2
WHERE r1.sname=s1.sname AND r2.day=r1.day AND r2.sname <> r1.sname
GROUP BY r1.day
)
UNION 
(
SELECT r2.day, s2.rating
FROM RESERVATION r3, SAILOR s2
WHERE r3.sname = s2.sname
GROUP BY r3.day
HAVING count(*) < 2
);

/*
7. List the busiest days
*/
SELECT day,count(*) as t
FROM RESERVATION
GROUP BY day
HAVING t =
	(SELECT MAX(a.t1) 
	 FROM (SELECT day,COUNT(*) as t1
	       FROM RESERVATION
	       GROUP BY day) AS a
	) 

/*
(c) Formulate and run a query to verify that all sailors having reservations
are qualified to sail the boats they reserved.
*/
SELECT r.sname, r.bname, s.rating AS Sailor_rating, b.rating as boat_rating, r.day
FROM Sailor s, Boat b, reservation r
Where s.sname = r.sname AND r.bname = b.bname AND s.rating < b.rating

/*
(d) 1. Switch all Wednesday and Monday reservations, without explicitly
naming the boats involved.
*/
update RESERVATION
SET day = "special"
WHERE day = "Wednesday";


update RESERVATION
SET day = "Wednesday"
WHERE day = "Monday";


update RESERVATION
SET day = "Monday"
WHERE day = "special";

/*
(d) 2. Delete all reservations violating the constraint in (c) above.
*/
DELETE FROM RESERVATION
WHERE EXISTS
(
	SELECT RESERVATION.day, RESERVATION.sname, RESERVATION.bname
	FROM Sailor s, Boat b
	Where s.sname = RESERVATION.sname AND RESERVATION.bname = b.bname AND s.rating < b.rating
);







