-- List tables:
SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name;

-- Preview data:
SELECT * FROM JournalEntries LIMIT 10;

-- Inspect columns:
PRAGMA table_info('JournalEntries');

-- Count rows:
SELECT COUNT(*) AS JournalLineCount FROM JournalEntries;

--2. SELECT, FILTER, SORT
----------------------
SELECT BusinessUnitID, PreparerID
FROM JournalEntries
WHERE BusinessUnitID = 'BU01'
ORDER BY PreparerID;
-- Replace BU01 with an actual value in your data.

--3. UNIQUE VALUES AND GROUPING
-----------------------------
SELECT DISTINCT BusinessUnitID, PreparerID
FROM JournalEntries
ORDER BY BusinessUnitID, PreparerID;

SELECT BusinessUnitID, COUNT(*) AS JournalLines
FROM JournalEntries
GROUP BY BusinessUnitID
ORDER BY JournalLines DESC;

--4. CHECK LOOKUP KEY UNIQUENESS
------------------------------
-- A composite key uses TWO columns together.
SELECT BusinessUnitID, PreparerID, COUNT(*) AS KeyCount
FROM ValidPreparers
GROUP BY BusinessUnitID, PreparerID
HAVING COUNT(*) > 1;
-- Ideally zero rows. Duplicate lookup keys can multiply join rows.

--5. INNER JOIN: MATCHED ROWS ONLY
--------------------------------
SELECT j.*
FROM JournalEntries AS j
INNER JOIN ValidPreparers AS p
    ON j.BusinessUnitID = p.BusinessUnitID
   AND j.PreparerID = p.PreparerID;
-- Unmatched journal lines are excluded.

--6. LEFT JOIN: KEEP ALL JOURNAL LINES
------------------------------------
SELECT j.*,
       p.PreparerID AS MatchedPreparerID
FROM JournalEntries AS j
LEFT JOIN ValidPreparers AS p
    ON j.BusinessUnitID = p.BusinessUnitID
   AND j.PreparerID = p.PreparerID;
-- Unmatched lookup fields appear as NULL.
-- Duplicate lookup keys can increase the number of rows.

--7. FIND UNMATCHED JOURNAL LINES
-------------------------------
SELECT j.*
FROM JournalEntries AS j
WHERE NOT EXISTS (
    SELECT 1
    FROM ValidPreparers AS p
    WHERE p.BusinessUnitID = j.BusinessUnitID
      AND p.PreparerID = j.PreparerID
);
-- NOT EXISTS is a robust way to identify unmatched rows.

--8. COUNT MATCHED AND UNMATCHED
------------------------------
SELECT
    COUNT(*) AS TotalLines,
    SUM(CASE WHEN EXISTS (
        SELECT 1 FROM ValidPreparers AS p
        WHERE p.BusinessUnitID = j.BusinessUnitID
          AND p.PreparerID = j.PreparerID
    ) THEN 1 ELSE 0 END) AS MatchedLines,
    SUM(CASE WHEN NOT EXISTS (
        SELECT 1 FROM ValidPreparers AS p
        WHERE p.BusinessUnitID = j.BusinessUnitID
          AND p.PreparerID = j.PreparerID
    ) THEN 1 ELSE 0 END) AS UnmatchedLines
FROM JournalEntries AS j;

-- Case 4 benchmark from the case discussion/solution:
-- 789 total journal lines, 148 unmatched, 641 matched.
-- Confirm against the actual database before relying on these counts.

--9. VALIDATE ROW COUNTS AFTER A JOIN
-----------------------------------
SELECT
    (SELECT COUNT(*) FROM JournalEntries) AS BeforeJoin,
    (SELECT COUNT(*)
     FROM JournalEntries AS j
     LEFT JOIN ValidPreparers AS p
       ON j.BusinessUnitID = p.BusinessUnitID
      AND j.PreparerID = p.PreparerID) AS AfterJoin;
-- More rows after LEFT JOIN? Investigate duplicate lookup keys.
-- Same number? Still check for unmatched keys.
