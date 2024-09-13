-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era) AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT 
    namefirst, 
    namelast, 
    birthyear
FROM 
    people
WHERE 
    namefirst LIKE '% %'
ORDER BY 
    namefirst ASC, 
    namelast ASC; 

;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*) AS count
  FROM people
  GROUP BY birthyear
  HAVING COUNT(*) > 0
  ORDER BY birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, avgheight, count
  FROM q1iii
  WHERE avgheight > 70
  ORDER BY birthyear ASC;
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT p.namefirst, p.namelast, h.playerID, h.yearid
  FROM halloffame h
  JOIN people p ON h.playerID = p.playerID
  WHERE h.inducted = 'Y'
  ORDER BY yearid DESC, h.playerID;
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT p.namefirst, p.namelast, h.playerID, c.schoolID, h.yearid
  FROM halloffame h
  JOIN people p ON h.playerID = p.playerID
  JOIN collegeplaying c ON p.playerID = c.playerid
  JOIN schools s ON c.schoolID = s.schoolID
  WHERE h.inducted = 'Y' and s.schoolState = "CA"
  ORDER BY h.yearid DESC, c.schoolID ASC, p.playerID ASC
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT p.playerID, p.nameFirst, p.nameLast, c.schoolID
FROM 
    halloffame h
JOIN 
    people p ON h.playerID = p.playerID
LEFT JOIN 
    collegeplaying c ON p.playerID = c.playerid
WHERE 
    h.inducted = 'Y'   
ORDER BY 
    p.playerID DESC, c.schoolID ASC; 
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT 
    p.playerID, p.nameFirst, p.nameLast, b.yearID, 
    CAST(( (b.H - b.H2B - b.H3B - b.HR) + (2 * b.H2B) + (3 * b.H3B) + (4 * b.HR) ) AS FLOAT) / b.AB AS slg
  FROM 
    batting b
  JOIN 
    people p ON p.playerID = b.playerID
  WHERE 
    b.AB > 50
  ORDER BY 
    slg DESC, 
    b.yearID DESC, 
    p.playerID ASC
  LIMIT 10;
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT 
    p.playerID,
    p.nameFirst,
    p.nameLast,
    (CAST(SUM(b.H - b.H2B - b.H3B - b.HR) AS FLOAT) + (2 * SUM(b.H2B)) + (3 * SUM(b.H3B)) + (4 * SUM(b.HR))) / SUM(b.AB) AS lslg
  FROM 
    batting b
  JOIN 
    people p ON b.playerID = p.playerID
  GROUP BY 
    p.playerID, p.nameFirst, p.nameLast
  HAVING 
    SUM(b.AB) > 50
  ORDER BY 
    lslg DESC, 
    p.playerID ASC
  LIMIT 10;
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT p.nameFirst, p.nameLast,
    (CAST(SUM(b.H - b.H2B - b.H3B - b.HR) AS FLOAT) + (2 * SUM(b.H2B)) + (3 * SUM(b.H3B)) + (4 * SUM(b.HR))) / SUM(b.AB) AS lslg
  FROM 
    batting b 
  JOIN 
    people p ON b.playerID = p.playerID
  GROUP BY 
    p.playerID, p.nameFirst, p.nameLast
  HAVING 
    SUM(b.AB) > 50
    AND (CAST(SUM(b.H - b.H2B - b.H3B - b.HR) AS FLOAT) + (2 * SUM(b.H2B)) + (3 * SUM(b.H3B)) + (4 * SUM(b.HR))) / SUM(b.AB) > 
    (SELECT 
        (CAST(SUM(b2.H - b2.H2B - b2.H3B - b2.HR) AS FLOAT) + (2 * SUM(b2.H2B)) + (3 * SUM(b2.H3B)) + (4 * SUM(b2.HR))) / SUM(b2.AB)
     FROM 
        batting b2
     WHERE 
        b2.playerID = 'mayswi01'
    )
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT s.yearID, min(s.salary), max(s.salary), AVG(s.salary)
  FROM salaries s
  GROUP BY s.yearID
  ORDER BY s.yearID ASC;
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)

AS
  -- one table give max min and bin size, 
  -- second one make ranges for the bin size, 
  -- third one make the salaries fo to a certain bin
  WITH salary_stats AS (
    SELECT 
        MIN(salary) AS min_salary, 
        MAX(salary) AS max_salary,
        (MAX(salary)-MIN(salary))/10.0 AS bin_size
    FROM 
        salaries
    WHERE 
        yearID = 2016
  ),
  bins AS (
    SELECT 
        binid,
        FLOOR(min_salary + (binid * bin_size)) AS bin_low,
        CASE 
            WHEN binid = 9 THEN max_salary + 1  -- to include the upper limit for the last bin
            ELSE FLOOR(min_salary + ((binid + 1) * bin_size))
        END AS bin_high
    FROM 
        salary_stats
    CROSS JOIN 
        binids
  )
  SELECT 
    b.binid,
    b.bin_low AS low,
    b.bin_high AS high,
    COUNT(s.salary) AS count
  FROM 
      bins b
  LEFT JOIN salaries s
  ON s.salary >= b.bin_low 
            AND (s.salary < b.bin_high OR (b.binid = 9 AND s.salary <= b.bin_high))
           AND s.yearID = 2016
  GROUP BY 
      b.binid, b.bin_low, b.bin_high
  ORDER BY 
      b.binid;
  


-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT 
    curr.yearID,
    (curr.min_salary - prev.min_salary) AS mindiff,
    (curr.max_salary - prev.max_salary) AS maxdiff,
    (curr.avg_salary - prev.avg_salary) AS avgdiff
  FROM
    (SELECT 
         yearID,
         MIN(salary) AS min_salary,
         MAX(salary) AS max_salary,
         AVG(salary) AS avg_salary
     FROM salaries
     GROUP BY yearID) AS curr
  JOIN
    (SELECT 
         yearID,
         MIN(salary) AS min_salary,
         MAX(salary) AS max_salary,
         AVG(salary) AS avg_salary
    FROM salaries
    GROUP BY yearID) AS prev
  ON curr.yearID = prev.yearID + 1
  ORDER BY curr.yearID; 
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT
    s2000.playerID,
    p.nameFirst,
    p.nameLast,
    s2000.salary,
    s2000.yearID
  FROM
      (SELECT playerID, salary, yearID
      FROM salaries
      WHERE yearID = 2000
        AND salary = (SELECT MAX(salary) FROM salaries WHERE yearID = 2000)
      ) AS s2000
  JOIN people p
  ON s2000.playerID = p.playerID

  UNION ALL

  SELECT
      s2001.playerID,
      p.nameFirst,
      p.nameLast,
      s2001.salary,
      s2001.yearID
  FROM
      (SELECT playerID, salary, yearID
      FROM salaries
      WHERE yearID = 2001
        AND salary = (SELECT MAX(salary) FROM salaries WHERE yearID = 2001)
      ) AS s2001
  JOIN people p
  ON s2001.playerID = p.playerID
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT
    a.teamID,
    MAX(s.salary) - MIN(s.salary) AS diffAvg
  FROM
      allstarfull a
  JOIN
      salaries s
  ON
      a.playerID = s.playerID
      AND s.yearID = 2016
  WHERE
      a.yearID = 2016
  GROUP BY
      a.teamID;

;

