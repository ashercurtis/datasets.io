-- ============================================================================
-- ACCTG 522 | ETL Case 3: Finding payroll-frequency exceptions with SQLite
-- ============================================================================
-- LEARNING GOAL
-- Turn unstructured employee codes into useful evidence by extracting fields,
-- standardizing labels, joining reference data, and identifying exceptions.
--
-- HOW TO RUN
-- Open this file in a SQLite-capable SQL editor connected to a SQLite database.
-- Run the entire script, or execute one statement at a time from top to bottom.
-- The file is SELF-CONTAINED: it loads the modified student data as SQL INSERTs.
-- It does not include the instructor answer key.
--
-- If your editor displays only the last result set, run the SELECT statements
-- individually. The final SELECT returns the employees needing investigation.
--
-- EXPECTED CHECKS (instructor reference; verify independently):
-- 597 employees, 133 plant lookup rows, 18 exceptions, 0 unmatched plants.
-- ============================================================================

-- PART 1 | Build the two input tables.
-- CREATE TABLE defines the schema (columns and types).
-- DROP TABLE IF EXISTS makes the script repeatable: it replaces these two tables.
-- IMPORTANT: run in a disposable class database, not a database containing
-- valuable tables with the same names.

DROP TABLE IF EXISTS EmployeeData;
DROP TABLE IF EXISTS PlantLookup;

CREATE TABLE EmployeeData (
    EmployeeCode TEXT NOT NULL,
    FirstName TEXT NOT NULL,
    LastName TEXT NOT NULL
);

CREATE TABLE PlantLookup (
    CountryPlantID TEXT PRIMARY KEY,
    PlantType TEXT NOT NULL,
    ExpectedPayFrequency TEXT NOT NULL
);

-- INSERT INTO adds the source rows. These values come from the modified
-- classroom workbook; they are intentionally not the original Case 3 data.

INSERT INTO EmployeeData (EmployeeCode, FirstName, LastName) VALUES
    ('Japan177-3Mo', 'Carl', 'Rodriguez'),
    ('AUS551-2W', 'Anne', 'Wright'),
    ('AUS316-2W', 'Patrick', 'Rivera'),
    ('GER160-2W', 'Ruby', 'Walker'),
    ('GER265-1M', 'Teresita', 'Guillen'),
    ('ARG363-4M', 'Earl', 'Morgan'),
    ('Canada351-3Mo', 'Joella', 'Causey'),
    ('Japan195-5Mo', 'Gregg', 'Kelly'),
    ('ARG529-1Mo', 'William', 'Reed'),
    ('ENG301-6W', 'Julia', 'Johnson'),
    ('AUS60-2W', 'Tonya', 'Ruiz'),
    ('ARG102-7W', 'Wayne', 'Howard'),
    ('US219-8M', 'Samuel', 'Goodman'),
    ('Canada342-9W', 'Sean', 'Morgan'),
    ('US476-10W', 'Julie', 'Johnson'),
    ('MEX93-5W', 'Samuel', 'Perry'),
    ('ENG442-9W', 'Jarrod', 'Beckett'),
    ('Canada17-7W', 'Lillian', 'Nelson'),
    ('ARG559-10W', 'Delfina', 'Brandon'),
    ('ENG389-10Mo', 'Shaun', 'Jacobs'),
    ('MEX121-11M', 'Theresa', 'Barnes'),
    ('ENG489-12Mo', 'Stephen', 'Powell'),
    ('AUS88-10W', 'Queenie', 'Thibodeau'),
    ('AUS455-3W', 'Juan', 'King'),
    ('AUS491-13Mo', 'Laureen', 'Varney'),
    ('ENG193-10Mo', 'Anthony', 'Griffin'),
    ('ARG508-14M', 'Olga', 'Rowe'),
    ('GER345-5Mo', 'Alyce', 'Rafferty'),
    ('Japan428-2Mo', 'Janella', 'Lacey'),
    ('ARG116-9M', 'Lyndsay', 'Landry'),
    ('Canada213-4Mo', 'Elvina', 'Dickens'),
    ('ENG208-2W', 'Lois', 'Flores'),
    ('MEX7-9M', 'Gonzalo', 'Rigby'),
    ('ARG56-15M', 'John', 'Parker'),
    ('US404-6M', 'Olive', 'Romero'),
    ('ARG43-9M', 'Emmitt', 'Valles'),
    ('GER188-9W', 'Vernia', 'Mccrary'),
    ('AUS275-8W', 'Michelle', 'Campbell'),
    ('ENG563-9W', 'Demarcus', 'Mcgregor'),
    ('ENG543-14Mo', 'Jeremy', 'Rogers'),
    ('ENG23-6W', 'Michelle', 'Peters'),
    ('MEX490-7W', 'Dian', 'Winchester'),
    ('Japan114-1M', 'Steven', 'Russell'),
    ('ENG444-4Mo', 'Hank', 'Thorpe'),
    ('AUS331-2W', 'Lori', 'Ward'),
    ('Canada118-14W', 'Lori', 'Price'),
    ('Japan572-15M', 'Norma', 'Steele'),
    ('Canada122-5Mo', 'Jaye', 'Wick'),
    ('US526-12W', 'Terry', 'Coleman'),
    ('Japan585-6Mo', 'Kathleen', 'Garcia'),
    ('ENG398-15Mo', 'Raul', 'Brewer'),
    ('Japan320-14M', 'Peter', 'Thompson'),
    ('US141-2W', 'Theo', 'Vo'),
    ('Canada329-4M', 'Luanne', 'Farr'),
    ('ARG421-16Mo', 'Larry', 'Ward'),
    ('ARG427-13W', 'Linda', 'Peterson'),
    ('GER220-4Mo', 'Titus', 'Maclean'),
    ('MEX223-8M', 'Norman', 'Henderson'),
    ('US257-17Mo', 'Elmira', 'Sommers'),
    ('Canada289-15Mo', 'Kelly', 'Mitchell'),
    ('US98-6M', 'Minnie', 'Snyder'),
    ('AUS24-7W', 'Selina', 'Varela'),
    ('ENG557-4Mo', 'Lelia', 'Wentz'),
    ('AUS34-16W', 'Jaunita', 'Laird'),
    ('GER38-15Mo', 'Leona', 'Thompson'),
    ('GER79-15M', 'Regina', 'Hodges'),
    ('AUS385-1Mo', 'Clarence', 'Collins'),
    ('AUS581-9W', 'Marie', 'Barnes'),
    ('US349-9Mo', 'Jennifer', 'Cox'),
    ('Canada429-8Mo', 'Virginia', 'Brooks'),
    ('Canada99-3Mo', 'Cecile', 'Veal'),
    ('US373-14W', 'Harry', 'Clark'),
    ('US210-3Mo', 'Rebecca', 'Gomez'),
    ('GER366-5Mo', 'Delilah', 'Eason'),
    ('ARG30-10W', 'Victor', 'Smith'),
    ('Japan132-16W', 'Marjory', 'Lovelace'),
    ('AUS130-17Mo', 'Matthew', 'Brown'),
    ('Japan512-1Mo', 'Audrey', 'Briggs'),
    ('AUS377-11M', 'Collin', 'Haskins'),
    ('AUS449-13W', 'Columbus', 'Fuqua'),
    ('Canada158-4M', 'Faye', 'Turner'),
    ('ARG468-11W', 'Tina', 'Carlson'),
    ('Japan597-8W', 'Laura', 'Edwards'),
    ('GER540-7W', 'Rolf', 'Schrader'),
    ('GER407-4Mo', 'Tiara', 'Pridgen'),
    ('Canada423-1W', 'Ed', 'Pena'),
    ('MEX401-8Mo', 'Ellan', 'Braswell'),
    ('GER21-2W', 'Garfield', 'Bigelow'),
    ('US561-15W', 'Horace', 'Robertson'),
    ('ARG417-7W', 'Shawn', 'Allen'),
    ('AUS28-10W', 'Beaulah', 'Willard'),
    ('GER291-3W', 'Jose', 'Baker'),
    ('MEX452-4Mo', 'Elizabeth', 'Parker'),
    ('Canada337-1W', 'Carolyn', 'Anderson'),
    ('AUS255-11Mo', 'Edna', 'Harvey'),
    ('ARG458-3Mo', 'Jeanmarie', 'Haywood'),
    ('Japan388-17W', 'Maribeth', 'Kiser'),
    ('Japan312-3Mo', 'Elza', 'Devito'),
    ('ENG438-5W', 'Jarvis', 'Lund'),
    ('Japan247-6Mo', 'Debra', 'Butler');

INSERT INTO EmployeeData (EmployeeCode, FirstName, LastName) VALUES
    ('MEX44-17W', 'Janell', 'Orozco'),
    ('ARG532-14Mo', 'Salvador', 'Copeland'),
    ('MEX579-17M', 'Dave', 'Sherman'),
    ('Japan338-12W', 'Philip', 'Bryant'),
    ('US270-17Mo', 'Geraldine', 'Kelly'),
    ('US144-15W', 'Madelaine', 'Moriarty'),
    ('Japan139-14Mo', 'Andrea', 'Murphy'),
    ('AUS299-11Mo', 'Sonny', 'Ragland'),
    ('Canada71-15M', 'Susan', 'Long'),
    ('Japan50-17M', 'Keneth', 'Roper'),
    ('Canada27-3Mo', 'Ronald', 'Carter'),
    ('Canada566-10W', 'Eric', 'Cooper'),
    ('AUS194-5W', 'Alethia', 'Law'),
    ('Japan582-13Mo', 'Adrian', 'Hughes'),
    ('MEX496-7W', 'Leo', 'Barber'),
    ('Canada32-1W', 'Janet', 'Jones'),
    ('Canada113-8M', 'Julie', 'Bennett'),
    ('US203-17M', 'Lyle', 'Cummings'),
    ('US242-7Mo', 'William', 'Gonzalez'),
    ('ARG20-3Mo', 'Harry', 'Sanchez'),
    ('ARG520-9Mo', 'Kathy', 'Green'),
    ('US292-10W', 'Alayna', 'Wahl'),
    ('Canada315-8Mo', 'Henry', 'Davis'),
    ('Canada269-5M', 'Shelley', 'Price'),
    ('US52-8Mo', 'Rose', 'Walker'),
    ('GER14-13M', 'Amy', 'Wood'),
    ('US110-4Mo', 'Drew', 'Schofield'),
    ('Canada271-5M', 'Armando', 'Ballard'),
    ('Canada205-14W', 'Brain', 'Beckham'),
    ('Canada425-3Mo', 'Margaret', 'Bell'),
    ('Canada518-13W', 'Loretta', 'Daniels'),
    ('Canada568-6W', 'Frank', 'Gray'),
    ('ARG335-1W', 'Maryann', 'Reed'),
    ('US392-7M', 'Jan', 'Henry'),
    ('Canada287-1W', 'Sharon', 'Richardson'),
    ('AUS311-7W', 'Rafael', 'Simon'),
    ('Japan183-10M', 'Joe', 'Ramirez'),
    ('Canada77-8Mo', 'Cornelius', 'Francis'),
    ('ENG80-15Mo', 'Crissy', 'Horn'),
    ('MEX206-6W', 'Dawna', 'Beals'),
    ('Japan5-3Mo', 'Wilma', 'Richardson'),
    ('AUS450-3W', 'Judy', 'Norris'),
    ('Japan474-16W', 'Joyce', 'White'),
    ('AUS481-6M', 'Carla', 'Patrick'),
    ('AUS37-15W', 'Karl', 'Fleming'),
    ('MEX471-15M', 'Brandon', 'Evans'),
    ('US339-15W', 'Dianne', 'Salazar'),
    ('Japan584-5M', 'Gaynell', 'Mckeown'),
    ('GER246-7W', 'Cameron', 'Mccoy'),
    ('GER297-1M', 'Darrin', 'Cox'),
    ('MEX222-17W', 'Juliann', 'Simonson'),
    ('ENG569-7W', 'Douglas', 'Flores'),
    ('AUS253-7W', 'Margot', 'Olmstead'),
    ('US45-15W', 'Allyson', 'Marlowe'),
    ('GER248-2Mo', 'Maria', 'Cook'),
    ('US432-11M', 'Betty', 'Gonzales'),
    ('US469-2W', 'Johanna', 'Peterson'),
    ('US1-9Mo', 'Michelle', 'Clark'),
    ('US218-10W', 'Albert', 'Hampton'),
    ('ARG546-1Mo', 'Cheryl', 'Kelly'),
    ('GER517-4M', 'Scott', 'Robinson'),
    ('US104-11M', 'Emanuel', 'Craig'),
    ('MEX13-14W', 'Kathleen', 'Moss'),
    ('ENG457-2W', 'Laverne', 'Salazar'),
    ('ARG145-16Mo', 'Margaret', 'Doyle'),
    ('ENG243-5W', 'Rea', 'Irby'),
    ('GER465-8W', 'Shirley', 'Torres'),
    ('US73-11Mo', 'Buster', 'Shively'),
    ('ARG390-17M', 'Deirdre', 'Lentz'),
    ('Canada542-3M', 'Lisha', 'Nunn'),
    ('ENG92-15M', 'Terica', 'Mayo'),
    ('ARG101-6M', 'Tynisha', 'Mckee'),
    ('Japan430-16M', 'Phil', 'Guerrero'),
    ('US485-15W', 'Randy', 'Hall'),
    ('ARG39-14Mo', 'Lorenzo', 'Fowler'),
    ('AUS250-5W', 'Rachel', 'Reed'),
    ('Canada580-5M', 'Moises', 'Mcbee'),
    ('GER550-10Mo', 'Matthew', 'Hill'),
    ('MEX238-15M', 'Van', 'Mcguire'),
    ('GER419-13M', 'Tina', 'Howard'),
    ('MEX280-15M', 'Jane', 'Phillips'),
    ('MEX480-8Mo', 'Norma', 'Watson'),
    ('ARG186-4Mo', 'Judith', 'White'),
    ('US85-15W', 'Aaron', 'Gray'),
    ('Japan200-14Mo', 'Rudy', 'Alvarez'),
    ('Canada362-6W', 'Sharonda', 'Farley'),
    ('US477-1Mo', 'Maisha', 'Calvin'),
    ('GER531-5M', 'Bonnie', 'Abbott'),
    ('GER89-16Mo', 'Miranda', 'Young'),
    ('ENG235-9W', 'Thomas', 'Edwards'),
    ('AUS11-14M', 'Lee', 'Wright'),
    ('ARG313-10W', 'Lee', 'Wolfe'),
    ('US463-13W', 'Dianna', 'Cox'),
    ('GER286-8W', 'Edna', 'Green'),
    ('GER2-14W', 'Frederick', 'Morton'),
    ('US123-9M', 'Cynthia', 'Cole'),
    ('MEX500-4Mo', 'Lorena', 'Williams'),
    ('GER370-5M', 'Percy', 'Young'),
    ('Canada298-8M', 'Patricia', 'Perez'),
    ('Japan276-11M', 'Elizabeth', 'Neal');

INSERT INTO EmployeeData (EmployeeCode, FirstName, LastName) VALUES
    ('ARG456-17Mo', 'Stuart', 'Lane'),
    ('US86-6M', 'Adam', 'Vasquez'),
    ('Japan327-15Mo', 'Alisa', 'Corbett'),
    ('ARG323-16Mo', 'Enriqueta', 'Lopes'),
    ('GER524-15M', 'Kirk', 'Reese'),
    ('MEX394-13W', 'Jose', 'Green'),
    ('AUS587-4M', 'Rex', 'Howard'),
    ('Canada76-4Mo', 'Ronald', 'Cox'),
    ('AUS576-6Mo', 'Johnny', 'Simmons'),
    ('GER567-17Mo', 'Alessandra', 'Vogt'),
    ('ENG593-13W', 'Steven', 'Foster'),
    ('GER368-9W', 'Stephaine', 'Pacheco'),
    ('US112-14W', 'Lory', 'Herrmann'),
    ('Canada108-3M', 'Simonne', 'Kemp'),
    ('ARG48-14M', 'Mui', 'Mcewen'),
    ('GER254-15M', 'Bobby', 'Stephens'),
    ('GER504-12M', 'Madalene', 'Moreland'),
    ('ENG137-6W', 'Heidi', 'Collins'),
    ('GER55-1Mo', 'Inez', 'Mcbride'),
    ('GER396-10Mo', 'Ed', 'Rowe'),
    ('GER514-9W', 'Yvonne', 'Nelson'),
    ('Canada386-9W', 'Billy', 'Lee'),
    ('US260-4Mo', 'Jeffrey', 'Griffin'),
    ('Canada284-4M', 'Cora', 'Fletcher'),
    ('ARG259-11W', 'Sharon', 'Parker'),
    ('US574-4M', 'Wanda', 'Wood'),
    ('Japan424-6Mo', 'Chantell', 'Forrest'),
    ('US533-7M', 'Lavada', 'Satterfield'),
    ('GER143-5M', 'Christeen', 'Hardwick'),
    ('Canada466-1W', 'Dorla', 'Dupuis'),
    ('MEX590-8Mo', 'Lisabeth', 'Everett'),
    ('Japan237-9W', 'Patience', 'Lindsay'),
    ('Japan182-3Mo', 'Jennette', 'Mcnamara'),
    ('Japan454-5M', 'Tanya', 'Cummings'),
    ('US41-1M', 'Alan', 'Patterson'),
    ('Japan211-12W', 'Venessa', 'Bean'),
    ('US409-7Mo', 'Jessie', 'Spencer'),
    ('MEX91-17W', 'Sung', 'Pippin'),
    ('ENG332-5W', 'Scott', 'Phillips'),
    ('AUS231-17Mo', 'Charles', 'Perry'),
    ('MEX555-7W', 'Waldo', 'Dempsey'),
    ('GER63-12Mo', 'William', 'Wong'),
    ('US198-15W', 'George', 'Hughes'),
    ('US134-2W', 'Martin', 'Sanders'),
    ('MEX138-17W', 'Vincent', 'Harris'),
    ('US527-9M', 'Tawnya', 'Goodrich'),
    ('MEX22-15Mo', 'Marcella', 'West'),
    ('ENG165-5W', 'Brian', 'Cooper'),
    ('AUS545-7W', 'Allen', 'Hicks'),
    ('US306-5W', 'Antonetta', 'Gilchrist'),
    ('AUS369-13M', 'Luciana', 'Andrus'),
    ('Canada40-2W', 'Eula', 'Jensen'),
    ('GER217-5Mo', 'Svetlana', 'Manuel'),
    ('ARG309-3M', 'Domenic', 'Wayne'),
    ('AUS169-16W', 'Teresa', 'Harris'),
    ('GER336-2W', 'Jon', 'Rodriguez'),
    ('AUS324-5W', 'Derick', 'Laird'),
    ('AUS181-14Mo', 'Ashley', 'Alexander'),
    ('ENG295-10M', 'Janise', 'Denning'),
    ('AUS305-2W', 'Larry', 'Richardson'),
    ('GER371-1M', 'Joanne', 'Stevens'),
    ('US462-4M', 'Deandre', 'Conaway'),
    ('US197-3M', 'Angela', 'Perez'),
    ('ENG406-11Mo', 'Latina', 'Hyman'),
    ('Japan399-14M', 'Venus', 'Ripley'),
    ('Japan505-2M', 'Katrina', 'Douglas'),
    ('AUS215-16W', 'Carmine', 'Toler'),
    ('ARG67-14Mo', 'Lindsy', 'Haskins'),
    ('ENG565-9W', 'Ruby', 'Perez'),
    ('MEX330-1Mo', 'Carolyn', 'Sanchez'),
    ('ENG107-2W', 'Maxima', 'Oneil'),
    ('MEX58-10Mo', 'Jimmy', 'Collins'),
    ('US161-11M', 'Tina', 'Washington'),
    ('MEX156-9Mo', 'Paula', 'Delgado'),
    ('Japan497-4Mo', 'Elizabeth', 'Morris'),
    ('ARG201-16Mo', 'Warren', 'Briggs'),
    ('US111-5W', 'Virgil', 'Shinn'),
    ('Japan147-9W', 'Winifred', 'Cross'),
    ('GER272-2W', 'Zelma', 'Humes'),
    ('ENG592-13W', 'Terrence', 'Wong'),
    ('ARG241-14Mo', 'Chanda', 'Nickel'),
    ('ENG503-14W', 'Amelia', 'Santos'),
    ('GER125-7W', 'Trinidad', 'Egan'),
    ('US249-1Mo', 'Essie', 'Lawrence'),
    ('US278-6Mo', 'Ryan', 'Clark'),
    ('MEX534-16W', 'Genaro', 'Sales'),
    ('Japan426-5M', 'Lori', 'Thornton'),
    ('AUS356-6Mo', 'Ezekiel', 'Banda'),
    ('GER277-1M', 'Luis', 'Wood'),
    ('ENG440-17M', 'Albert', 'Miller'),
    ('US367-11Mo', 'Maxine', 'Hamilton'),
    ('ENG155-9W', 'Candace', 'Weaver'),
    ('ENG562-7W', 'Debra', 'Patterson'),
    ('ARG142-15M', 'Dominque', 'Packer'),
    ('ENG83-7W', 'Alice', 'Mitchell'),
    ('AUS553-11M', 'Erma', 'Porter'),
    ('ARG588-7W', 'Martha', 'Rivera'),
    ('AUS100-8W', 'Agnes', 'Cooper'),
    ('MEX355-6W', 'Margie', 'Robbins'),
    ('ARG240-6Mo', 'Mazie', 'Whittle');

INSERT INTO EmployeeData (EmployeeCode, FirstName, LastName) VALUES
    ('MEX26-7W', 'Chris', 'Mathis'),
    ('ARG319-17M', 'Modesto', 'Centeno'),
    ('ARG446-2W', 'Hye', 'Fenton'),
    ('GER558-8W', 'Kaci', 'Naquin'),
    ('MEX87-10W', 'Howard', 'Coleman'),
    ('ENG445-2W', 'Kimberly', 'Anderson'),
    ('MEX75-11M', 'Karla', 'Cunningham'),
    ('ARG162-7W', 'Bessie', 'Mccormick'),
    ('Japan397-3Mo', 'Nancy', 'Henderson'),
    ('Japan36-13Mo', 'Judy', 'Carter'),
    ('AUS290-3W', 'Nikole', 'Mancini'),
    ('US322-16Mo', 'Keith', 'Martin'),
    ('AUS135-14M', 'Joshua', 'Bailey'),
    ('US229-8Mo', 'Wen', 'Huynh'),
    ('Japan69-17M', 'Leonora', 'Florence'),
    ('ARG513-12W', 'Adaline', 'Cochrane'),
    ('US538-1M', 'Tami', 'Cobb'),
    ('MEX274-1Mo', 'Etsuko', 'Battles'),
    ('US90-4M', 'Sheri', 'Clayton'),
    ('Canada226-4Mo', 'Mimi', 'Tidwell'),
    ('US314-1M', 'Larita', 'Messina'),
    ('US441-7Mo', 'Trula', 'Back'),
    ('GER146-12Mo', 'Dominique', 'Beaty'),
    ('US19-4M', 'George', 'Martinez'),
    ('ARG379-17M', 'Louis', 'Reed'),
    ('Canada57-9W', 'Len', 'Otto'),
    ('ENG473-16Mo', 'Brandy', 'Buchanan'),
    ('ARG387-10W', 'Clinton', 'Edwards'),
    ('ENG152-11Mo', 'Shirley', 'Robinson'),
    ('US174-12W', 'Carman', 'Baylor'),
    ('GER346-13M', 'Eunice', 'Mcdonald'),
    ('GER129-15M', 'Gretchen', 'Hale'),
    ('Japan207-12W', 'Catherine', 'Stewart'),
    ('GER261-6W', 'Hazel', 'Walsh'),
    ('Canada541-16Mo', 'Bruce', 'Torres'),
    ('MEX583-7W', 'Laticia', 'Sands'),
    ('Japan49-7W', 'Evelyn', 'Martin'),
    ('Canada570-11M', 'Andrea', 'Scott'),
    ('Canada175-11W', 'Regan', 'Key'),
    ('US106-6M', 'Diane', 'Allen'),
    ('Japan511-6M', 'Cindi', 'Mcclanahan'),
    ('ENG537-12M', 'Keeley', 'Correia'),
    ('ARG484-5W', 'Andrew', 'Bennett'),
    ('ARG435-17Mo', 'Wynona', 'Neville'),
    ('AUS391-6Mo', 'Mark', 'Long'),
    ('GER251-14W', 'Anthony', 'Nelson'),
    ('Japan176-10M', 'Lynn', 'Brady'),
    ('Japan61-11M', 'Kristi', 'Wilkerson'),
    ('AUS410-15W', 'Jean', 'Williams'),
    ('Japan596-10M', 'Kimberly', 'Hernandez'),
    ('MEX353-4M', 'Geneva', 'Ryan'),
    ('ENG46-16Mo', 'Caroyln', 'Kerr'),
    ('GER202-10M', 'Lizabeth', 'Perron'),
    ('MEX224-16W', 'Wayne', 'Bryant'),
    ('US281-3Mo', 'Sarah', 'Hill'),
    ('MEX549-9W', 'Donnie', 'Martinez'),
    ('AUS62-1W', 'Randall', 'Osborne'),
    ('Canada66-16Mo', 'Ilda', 'Mcadams'),
    ('ARG393-6M', 'Katherine', 'Lee'),
    ('ENG153-8W', 'Yvette', 'Walsh'),
    ('ENG380-14W', 'Heather', 'Young'),
    ('ENG318-9W', 'Christine', 'Bishop'),
    ('AUS472-2W', 'Jeanette', 'Knight'),
    ('ENG460-5W', 'Fred', 'Henderson'),
    ('Japan420-11M', 'Garrett', 'Bishop'),
    ('Canada189-14W', 'Henry', 'Miller'),
    ('ENG54-4M', 'Orlando', 'Montgomery'),
    ('ARG383-5W', 'Marylin', 'Burch'),
    ('Japan515-5M', 'Bradford', 'Jackson'),
    ('GER433-13M', 'Waldo', 'Hoyle'),
    ('ARG252-12W', 'Spencer', 'Lucas'),
    ('AUS478-1W', 'Herlinda', 'Millard'),
    ('MEX556-17W', 'Lucilla', 'Dickens'),
    ('Japan264-1M', 'Marilyn', 'Horton'),
    ('ARG244-8W', 'Adelia', 'Bachman'),
    ('Canada321-12Mo', 'Joseph', 'Peterson'),
    ('ARG343-15Mo', 'Alexis', 'Hayes'),
    ('ENG109-8W', 'Evelyn', 'Bass'),
    ('GER35-1M', 'Janice', 'Garcia'),
    ('ARG347-17M', 'Cheryl', 'Davis'),
    ('ARG506-8W', 'Ryan', 'Butler'),
    ('ARG279-6Mo', 'Chris', 'Smith'),
    ('AUS42-12W', 'Ruth', 'Morris'),
    ('MEX115-11M', 'Kirk', 'Waters'),
    ('Japan65-2M', 'Tiera', 'Jolley'),
    ('US530-17Mo', 'Marilynn', 'Pyle'),
    ('ENG578-17Mo', 'Elvira', 'Reynolds'),
    ('US126-4M', 'Lizeth', 'Adame'),
    ('AUS482-12W', 'Joe', 'Russell'),
    ('ENG120-11M', 'Ashley', 'Russell'),
    ('Japan448-3Mo', 'Azzie', 'Boston'),
    ('ENG350-2W', 'Frederica', 'House'),
    ('US595-2W', 'Nicole', 'Diaz'),
    ('AUS225-10W', 'Edmundo', 'Beckham'),
    ('ARG375-13W', 'Gena', 'Barajas'),
    ('MEX415-8Mo', 'Alma', 'Stephens'),
    ('MEX443-12W', 'Sarah', 'Powell'),
    ('ENG3-2W', 'Rebecca', 'Turner'),
    ('ENG483-6W', 'Meredith', 'Estrada'),
    ('Canada344-11W', 'Kurtis', 'Farris');

INSERT INTO EmployeeData (EmployeeCode, FirstName, LastName) VALUES
    ('ARG136-1M', 'Todd', 'Campbell'),
    ('Canada357-14W', 'Jonathon', 'Dunn'),
    ('US15-13W', 'Shery', 'Ludwig'),
    ('Japan216-5M', 'Scotty', 'Lerma'),
    ('ARG400-10W', 'Isreal', 'Childress'),
    ('Canada411-7W', 'Alethea', 'Humphreys'),
    ('Canada307-5M', 'Caleb', 'Mendez'),
    ('US340-15W', 'Kevin', 'Jenkins'),
    ('ARG416-17M', 'Noel', 'Caldwell'),
    ('AUS487-8W', 'Jermaine', 'Rodriquez'),
    ('Japan486-14Mo', 'Tabitha', 'Sullivan'),
    ('AUS84-2W', 'Tamara', 'Sims'),
    ('Canada300-7W', 'Chrissy', 'Hadden'),
    ('Japan317-9W', 'Joseph', 'Wilson'),
    ('Japan372-2M', 'Brianna', 'Seitz'),
    ('Japan522-13Mo', 'Kenia', 'Craft'),
    ('ARG173-12W', 'Teresita', 'Schafer'),
    ('Japan170-17M', 'Irene', 'Price'),
    ('MEX180-16W', 'Albert', 'Martinez'),
    ('AUS589-8W', 'Lana', 'Hill'),
    ('AUS82-1W', 'Nieves', 'Dew'),
    ('ENG285-5W', 'Stacey', 'Alexander'),
    ('AUS140-13Mo', 'Kenneth', 'Taylor'),
    ('MEX467-2W', 'Diana', 'Davis'),
    ('MEX461-15M', 'Shirl', 'Whitt'),
    ('GER434-1Mo', 'Catherine', 'Roberts'),
    ('US151-15W', 'Kevin', 'Cobb'),
    ('US519-3M', 'Remona', 'Jarrett'),
    ('MEX374-10W', 'Dede', 'Potts'),
    ('GER381-4M', 'Shelia', 'Owens'),
    ('US348-14W', 'Jean', 'Gonzalez'),
    ('Canada268-15Mo', 'Martin', 'Carpenter'),
    ('MEX304-4Mo', 'Roy', 'Jones'),
    ('MEX547-3W', 'Amanda', 'Wilson'),
    ('AUS178-5W', 'Andrew', 'Allison'),
    ('Canada96-16Mo', 'Sabrina', 'Rodriguez'),
    ('Japan365-13Mo', 'Laurie', 'Bowman'),
    ('ARG499-13W', 'Nettie', 'George'),
    ('ARG148-2W', 'Leroy', 'Mclaughlin'),
    ('ARG239-17Mo', 'Gloria', 'Roberts'),
    ('Japan25-17M', 'Kayla', 'Ingram'),
    ('GER191-15M', 'Kelvin', 'Jordan'),
    ('ARG9-9Mo', 'Jeremy', 'Ramirez'),
    ('ENG334-7W', 'Douglas', 'Lopez'),
    ('ENG4-5W', 'Myra', 'Bryant'),
    ('MEX212-6W', 'Kari', 'Nichols'),
    ('AUS78-7W', 'Eric', 'Lewis'),
    ('MEX402-10W', 'Glenda', 'Thomas'),
    ('MEX507-17W', 'Opal', 'Malone'),
    ('Japan59-11Mo', 'Lillie', 'May'),
    ('Canada128-14W', 'Johnny', 'Young'),
    ('Canada262-15Mo', 'Jason', 'Pearson'),
    ('AUS214-11M', 'Toni', 'Quinn'),
    ('GER479-10Mo', 'Brian', 'Ross'),
    ('MEX422-1Mo', 'Byron', 'Watson'),
    ('Canada296-7W', 'Shawn', 'Vargas'),
    ('Japan273-11M', 'Denise', 'Hughes'),
    ('US521-15W', 'Jamie', 'Welch'),
    ('Canada192-5Mo', 'Arthur', 'Harris'),
    ('ARG325-17M', 'Bobby', 'James'),
    ('AUS352-6Mo', 'Donald', 'Thompson'),
    ('Japan256-2M', 'Beatrice', 'Alvarado'),
    ('ARG157-1M', 'Emily', 'Nash'),
    ('GER267-5M', 'Joline', 'Chin'),
    ('MEX47-2W', 'Cleora', 'Concepcion'),
    ('AUS437-7W', 'Donetta', 'Walls'),
    ('US149-2W', 'Brady', 'Trent'),
    ('US185-16M', 'Nicholas', 'Washington'),
    ('ENG288-14W', 'Boyce', 'Carlisle'),
    ('GER190-3M', 'Jody', 'Barnes'),
    ('MEX591-7W', 'Lynne', 'Flores'),
    ('Japan172-13M', 'Phyllis', 'Thomas'),
    ('ARG234-17M', 'Clarence', 'Turner'),
    ('US310-4M', 'Caroline', 'Sharp'),
    ('Canada575-11W', 'Tijuana', 'Leblanc'),
    ('ARG544-4Mo', 'Jeanna', 'Sawyers'),
    ('ARG124-13W', 'Chauncey', 'Bottoms'),
    ('MEX376-12W', 'Kelley', 'Palmer'),
    ('GER164-5Mo', 'Janice', 'Moore'),
    ('AUS384-3W', 'Bradford', 'Potter'),
    ('US523-7Mo', 'Kathryn', 'Bailey'),
    ('ENG53-2W', 'Lori', 'Robinson'),
    ('ENG560-15M', 'Melissa', 'Stewart'),
    ('US133-1Mo', 'Genevive', 'Mejia'),
    ('ENG232-11Mo', 'Irene', 'Lopez'),
    ('ARG283-9M', 'Patty', 'Jimenez'),
    ('US228-16M', 'Lindsey', 'Warren'),
    ('MEX577-15M', 'Randy', 'Baker'),
    ('US74-13Mo', 'Kayleigh', 'Goss'),
    ('Japan436-16W', 'Priscilla', 'Chavez'),
    ('ARG548-10W', 'Mabel', 'Schwartz'),
    ('ENG293-9W', 'Zona', 'Sykes'),
    ('ENG263-7W', 'Angelena', 'Loftis'),
    ('Japan364-3M', 'Michael', 'Cook'),
    ('MEX72-12W', 'Kurt', 'Dennis'),
    ('Canada488-4Mo', 'Mercedes', 'Herrera'),
    ('Japan395-5W', 'Adella', 'Hargis'),
    ('Canada564-13W', 'Valeri', 'Kimball'),
    ('AUS29-3W', 'Israel', 'Lewis'),
    ('Canada510-6W', 'Ruth', 'Brown');

INSERT INTO EmployeeData (EmployeeCode, FirstName, LastName) VALUES
    ('Japan470-11M', 'Maryanna', 'Schroeder'),
    ('GER95-9W', 'Elbert', 'Paul'),
    ('ARG354-2W', 'Issac', 'Nagy'),
    ('AUS70-9W', 'Trudie', 'Waite'),
    ('Japan361-16W', 'Jerrod', 'Easter'),
    ('ARG266-13W', 'Kelly', 'Jackson'),
    ('ARG413-8W', 'Martin', 'Wright'),
    ('AUS245-10W', 'Gerald', 'Taylor'),
    ('Canada31-11W', 'Terri', 'Higgins'),
    ('Japan412-10M', 'Mercy', 'Solano'),
    ('Japan382-9W', 'Devora', 'Braxton'),
    ('Canada403-13W', 'Lakiesha', 'Lange'),
    ('MEX68-13W', 'Kasandra', 'Strange'),
    ('ARG414-12W', 'Caitlin', 'Utley'),
    ('ARG451-1M', 'Jennifer', 'Thomas'),
    ('ENG51-6W', 'Joline', 'Catalano'),
    ('Japan10-13W', 'Anna', 'Evans'),
    ('ARG536-17Mo', 'Kamala', 'Hallman'),
    ('US204-3Mo', 'Janett', 'Watt'),
    ('MEX105-6W', 'Abel', 'Erickson'),
    ('AUS154-2W', 'Augusta', 'Hiatt'),
    ('ARG131-11W', 'Jamie', 'Barker'),
    ('AUS502-1W', 'Stella', 'Elliott'),
    ('ENG16-9W', 'Keila', 'Seifert'),
    ('GER179-11W', 'Danita', 'Jude'),
    ('AUS159-14Mo', 'Krystyna', 'Ferry'),
    ('MEX573-8Mo', 'Arletha', 'Smothers'),
    ('GER554-4M', 'Harry', 'Gray'),
    ('Canada166-4Mo', 'Bruce', 'Alexander'),
    ('ARG525-15M', 'Annett', 'Braun'),
    ('US33-5W', 'Alma', 'Leonard'),
    ('MEX236-5W', 'Angela', 'Rodriguez'),
    ('AUS464-10W', 'Rafael', 'Bryan'),
    ('US359-12W', 'Ricky', 'Cohen'),
    ('AUS167-2W', 'Johnna', 'Silver'),
    ('ARG18-3Mo', 'Jo', 'Elliott'),
    ('AUS94-6Mo', 'Donald', 'Sherman'),
    ('US308-16Mo', 'Tyree', 'Dubose'),
    ('ENG360-4M', 'Cythia', 'Michael'),
    ('MEX8-3W', 'Earl', 'Diaz'),
    ('ARG150-16M', 'Dominick', 'Holloway'),
    ('AUS168-3W', 'Jack', 'Lewis'),
    ('US509-12W', 'Yuette', 'Reddick'),
    ('MEX535-11M', 'Benny', 'Marsh'),
    ('US119-2W', 'Amanda', 'Williams'),
    ('Canada552-9W', 'Lawrence', 'James'),
    ('Canada103-2W', 'Anne', 'Rice'),
    ('GER302-5M', 'Liza', 'Benefield'),
    ('ARG516-16M', 'Jeannie', 'Dunn'),
    ('ARG439-10W', 'Eugene', 'Jenkins'),
    ('Japan495-8W', 'Shona', 'Tillery'),
    ('ENG187-14W', 'Doyle', 'Baldwin'),
    ('Canada528-4Mo', 'Jesse', 'Foster'),
    ('ARG408-8W', 'Meredith', 'Burke'),
    ('ENG333-16Mo', 'Tameika', 'Nance'),
    ('Canada127-9W', 'Donette', 'Mccarty'),
    ('Japan328-8W', 'Porsche', 'Greiner'),
    ('ARG498-8W', 'Carol', 'Hernandez'),
    ('GER6-1M', 'Ann', 'Moore'),
    ('Japan199-10Mo', 'Janet', 'Ortiz'),
    ('ARG493-6Mo', 'James', 'Watson'),
    ('ENG303-14W', 'Misti', 'Humphrey'),
    ('ARG494-1M', 'Gary', 'Bell'),
    ('AUS453-7W', 'Timothy', 'Bolt'),
    ('GER594-5Mo', 'Mitsue', 'Klinger'),
    ('US447-4M', 'Olimpia', 'Rapp'),
    ('AUS492-9W', 'Isaias', 'Lehman'),
    ('ENG171-7W', 'Cornelius', 'Pittman'),
    ('Japan571-16W', 'Terence', 'Herrera'),
    ('Japan12-6Mo', 'Cynthia', 'King'),
    ('Canada64-13W', 'Tammy', 'Simmons'),
    ('AUS405-16W', 'Susan', 'Kelly'),
    ('Japan163-12W', 'Gregory', 'Sanders'),
    ('US117-11M', 'Marilyn', 'Rogers'),
    ('US341-16M', 'Paul', 'Boone'),
    ('ARG209-6M', 'Kathe', 'Meier'),
    ('GER378-11Mo', 'Pasquale', 'Dortch'),
    ('GER258-7Mo', 'Raymond', 'Ross'),
    ('Canada501-12M', 'Elizabeth', 'Murphy'),
    ('MEX586-10W', 'Diana', 'Hall'),
    ('ENG418-15Mo', 'Darrell', 'Obrien'),
    ('MEX294-5W', 'Beverly', 'Adams'),
    ('Japan227-4Mo', 'Peter', 'Adams'),
    ('MEX184-11Mo', 'Salome', 'Dolan'),
    ('Japan81-12W', 'Nicholas', 'Brooks'),
    ('ENG539-15Mo', 'Vania', 'Nadeau'),
    ('Japan233-14M', 'Samantha', 'Phillips'),
    ('MEX358-6W', 'Rolando', 'Hanson'),
    ('MEX221-16W', 'Sadie', 'Reyes'),
    ('ENG475-17M', 'Tricia', 'Barrett'),
    ('Canada97-7W', 'Joan', 'Jackson'),
    ('Japan196-2M', 'Lloyd', 'Christensen'),
    ('GER230-10W', 'Carmelia', 'Aguilera'),
    ('Canada459-11W', 'Barbara', 'Scott'),
    ('US431-3M', 'Heather', 'Gonzales'),
    ('Japan282-11Mo', 'Aleta', 'Foss'),
    ('Japan326-11Mo', 'Mary', 'Baker');

INSERT INTO PlantLookup (CountryPlantID, PlantType, ExpectedPayFrequency) VALUES
    ('ARG-1', 'Manufacturing', 'Monthly'),
    ('ARG-10', 'Research', 'Weekly'),
    ('ARG-11', 'Distribution', 'Weekly'),
    ('ARG-12', 'Distribution', 'Weekly'),
    ('ARG-13', 'Administration', 'Weekly'),
    ('ARG-14', 'Research', 'Monthly'),
    ('ARG-15', 'Manufacturing', 'Monthly'),
    ('ARG-16', 'Administration', 'Monthly'),
    ('ARG-17', 'Distribution', 'Monthly'),
    ('ARG-2', 'Distribution', 'Weekly'),
    ('ARG-3', 'Research', 'Monthly'),
    ('ARG-4', 'Distribution', 'Monthly'),
    ('ARG-5', 'Research', 'Weekly'),
    ('ARG-6', 'Manufacturing', 'Monthly'),
    ('ARG-7', 'Research', 'Weekly'),
    ('ARG-8', 'Manufacturing', 'Weekly'),
    ('ARG-9', 'Distribution', 'Monthly'),
    ('AUS-1', 'Research', 'Weekly'),
    ('AUS-10', 'Manufacturing', 'Weekly'),
    ('AUS-11', 'Administration', 'Monthly'),
    ('AUS-12', 'Administration', 'Weekly'),
    ('AUS-13', 'Distribution', 'Monthly'),
    ('AUS-14', 'Administration', 'Monthly'),
    ('AUS-15', 'Administration', 'Weekly'),
    ('AUS-16', 'Administration', 'Weekly'),
    ('AUS-17', 'Administration', 'Monthly'),
    ('AUS-2', 'Manufacturing', 'Weekly'),
    ('AUS-3', 'Manufacturing', 'Weekly'),
    ('AUS-4', 'Research', 'Monthly'),
    ('AUS-5', 'Manufacturing', 'Weekly'),
    ('AUS-6', 'Research', 'Monthly'),
    ('AUS-7', 'Manufacturing', 'Weekly'),
    ('AUS-8', 'Manufacturing', 'Weekly'),
    ('AUS-9', 'Administration', 'Weekly'),
    ('CAN-1', 'Administration', 'Weekly'),
    ('CAN-10', 'Distribution', 'Weekly'),
    ('CAN-11', 'Research', 'Weekly'),
    ('CAN-12', 'Manufacturing', 'Monthly'),
    ('CAN-13', 'Research', 'Weekly'),
    ('CAN-14', 'Administration', 'Weekly'),
    ('CAN-15', 'Distribution', 'Monthly'),
    ('CAN-16', 'Manufacturing', 'Monthly'),
    ('CAN-2', 'Distribution', 'Weekly'),
    ('CAN-3', 'Research', 'Monthly'),
    ('CAN-4', 'Manufacturing', 'Monthly'),
    ('CAN-5', 'Research', 'Monthly'),
    ('CAN-6', 'Research', 'Weekly'),
    ('CAN-7', 'Research', 'Weekly'),
    ('CAN-8', 'Manufacturing', 'Monthly'),
    ('CAN-9', 'Administration', 'Weekly'),
    ('ENG-10', 'Research', 'Monthly'),
    ('ENG-11', 'Distribution', 'Monthly'),
    ('ENG-12', 'Administration', 'Monthly'),
    ('ENG-13', 'Manufacturing', 'Weekly'),
    ('ENG-14', 'Distribution', 'Weekly'),
    ('ENG-15', 'Manufacturing', 'Monthly'),
    ('ENG-16', 'Research', 'Monthly'),
    ('ENG-17', 'Research', 'Monthly'),
    ('ENG-2', 'Distribution', 'Weekly'),
    ('ENG-4', 'Distribution', 'Monthly'),
    ('ENG-5', 'Research', 'Weekly'),
    ('ENG-6', 'Research', 'Weekly'),
    ('ENG-7', 'Manufacturing', 'Weekly'),
    ('ENG-8', 'Research', 'Weekly'),
    ('ENG-9', 'Manufacturing', 'Weekly'),
    ('GER-1', 'Research', 'Monthly'),
    ('GER-10', 'Research', 'Monthly'),
    ('GER-11', 'Manufacturing', 'Monthly'),
    ('GER-12', 'Distribution', 'Monthly'),
    ('GER-13', 'Administration', 'Monthly'),
    ('GER-14', 'Manufacturing', 'Weekly'),
    ('GER-15', 'Manufacturing', 'Monthly'),
    ('GER-16', 'Distribution', 'Monthly'),
    ('GER-17', 'Distribution', 'Monthly'),
    ('GER-2', 'Administration', 'Weekly'),
    ('GER-3', 'Distribution', 'Weekly'),
    ('GER-4', 'Manufacturing', 'Monthly'),
    ('GER-5', 'Administration', 'Monthly'),
    ('GER-6', 'Research', 'Weekly'),
    ('GER-7', 'Manufacturing', 'Weekly'),
    ('GER-8', 'Research', 'Weekly'),
    ('GER-9', 'Distribution', 'Weekly'),
    ('JAP-1', 'Administration', 'Monthly'),
    ('JAP-10', 'Distribution', 'Monthly'),
    ('JAP-11', 'Research', 'Monthly'),
    ('JAP-12', 'Research', 'Weekly'),
    ('JAP-13', 'Administration', 'Monthly'),
    ('JAP-14', 'Distribution', 'Monthly'),
    ('JAP-15', 'Research', 'Monthly'),
    ('JAP-16', 'Research', 'Weekly'),
    ('JAP-17', 'Research', 'Monthly'),
    ('JAP-2', 'Research', 'Monthly'),
    ('JAP-3', 'Research', 'Monthly'),
    ('JAP-4', 'Manufacturing', 'Monthly'),
    ('JAP-5', 'Administration', 'Monthly'),
    ('JAP-6', 'Administration', 'Monthly'),
    ('JAP-7', 'Research', 'Weekly'),
    ('JAP-8', 'Manufacturing', 'Weekly'),
    ('JAP-9', 'Distribution', 'Weekly'),
    ('MEX-1', 'Administration', 'Monthly');

INSERT INTO PlantLookup (CountryPlantID, PlantType, ExpectedPayFrequency) VALUES
    ('MEX-10', 'Research', 'Weekly'),
    ('MEX-11', 'Distribution', 'Monthly'),
    ('MEX-12', 'Distribution', 'Weekly'),
    ('MEX-13', 'Administration', 'Weekly'),
    ('MEX-14', 'Manufacturing', 'Weekly'),
    ('MEX-15', 'Administration', 'Monthly'),
    ('MEX-16', 'Research', 'Weekly'),
    ('MEX-17', 'Research', 'Weekly'),
    ('MEX-2', 'Manufacturing', 'Weekly'),
    ('MEX-3', 'Manufacturing', 'Weekly'),
    ('MEX-4', 'Administration', 'Monthly'),
    ('MEX-5', 'Research', 'Weekly'),
    ('MEX-6', 'Manufacturing', 'Weekly'),
    ('MEX-7', 'Manufacturing', 'Weekly'),
    ('MEX-8', 'Administration', 'Monthly'),
    ('MEX-9', 'Manufacturing', 'Monthly'),
    ('USA-1', 'Manufacturing', 'Monthly'),
    ('USA-10', 'Distribution', 'Weekly'),
    ('USA-11', 'Administration', 'Monthly'),
    ('USA-12', 'Distribution', 'Weekly'),
    ('USA-13', 'Distribution', 'Weekly'),
    ('USA-14', 'Manufacturing', 'Weekly'),
    ('USA-15', 'Administration', 'Weekly'),
    ('USA-16', 'Distribution', 'Monthly'),
    ('USA-17', 'Distribution', 'Monthly'),
    ('USA-2', 'Distribution', 'Weekly'),
    ('USA-3', 'Research', 'Monthly'),
    ('USA-4', 'Research', 'Monthly'),
    ('USA-5', 'Manufacturing', 'Weekly'),
    ('USA-6', 'Distribution', 'Monthly'),
    ('USA-7', 'Manufacturing', 'Monthly'),
    ('USA-8', 'Manufacturing', 'Monthly'),
    ('USA-9', 'Distribution', 'Monthly');


-- PART 2 | Inspect the inputs.
-- COUNT(*) counts records. A GROUP BY is not needed for a whole-table count.
SELECT 'EmployeeData' AS TableName, COUNT(*) AS RowCount FROM EmployeeData
UNION ALL
SELECT 'PlantLookup', COUNT(*) FROM PlantLookup;

-- Preview a few source records.
SELECT * FROM EmployeeData LIMIT 10;
SELECT * FROM PlantLookup LIMIT 10;

-- PART 3 | A staged transformation using common table expressions (CTEs).
-- WITH gives a name to each temporary result. The CTEs are NOT saved tables.
-- Read from top to bottom: parts -> parsed -> normalized -> matched -> flagged.
--
-- EmployeeCode example: Japan177-3Mo
--   Japan  = country label (variable length)
--   177    = employee identifier (variable length)
--   -      = delimiter
--   3      = plant identifier (variable length)
--   Mo     = monthly pay code; M also means monthly; W means weekly
--
-- INSTR(text, '-') finds the dash's 1-based position.
-- SUBSTR(text, start, length) extracts a substring; length is optional.
-- RTRIM(text, chars) removes ANY trailing characters listed in chars.
-- LENGTH(text) returns the number of characters.
-- UPPER(text) standardizes letter case.
-- CASE WHEN / CASE value maps one category to another.
-- || concatenates strings in SQLite (unlike DAX, where & concatenates).
-- LEFT JOIN retains every employee even when no lookup record matches.
-- IS NULL is required to test missing values; = NULL is not valid testing.
-- <> means 'not equal'; AND/OR combine logical conditions.
--
-- Why RTRIM works HERE: all employee codes follow the provided pattern;
-- the head ends in digits, the tail starts with plant digits and ends in
-- W, M, or Mo. For arbitrary real-world codes, add stronger validation.

WITH
parts AS (
    SELECT
        EmployeeCode,
        FirstName,
        LastName,
        SUBSTR(EmployeeCode, 1, INSTR(EmployeeCode, '-') - 1) AS Head,
        SUBSTR(EmployeeCode, INSTR(EmployeeCode, '-') + 1) AS CodeTail
    FROM EmployeeData
),
parsed AS (
    SELECT
        *,
        RTRIM(Head, '0123456789') AS RawLocation,
        SUBSTR(Head, LENGTH(RTRIM(Head, '0123456789')) + 1) AS EmpID,
        RTRIM(CodeTail, 'WMo') AS PlantID,
        SUBSTR(CodeTail, LENGTH(RTRIM(CodeTail, 'WMo')) + 1) AS PayCode
    FROM parts
),
normalized AS (
    SELECT
        *,
        CASE UPPER(RawLocation)
            WHEN 'JAPAN' THEN 'JAP'
            WHEN 'CANADA' THEN 'CAN'
            WHEN 'US' THEN 'USA'
            WHEN 'AUS' THEN 'AUS'
            WHEN 'GER' THEN 'GER'
            WHEN 'ENG' THEN 'ENG'
            WHEN 'ARG' THEN 'ARG'
            WHEN 'MEX' THEN 'MEX'
            ELSE NULL  -- Unknown country: investigate instead of guessing.
        END AS CountryCode,
        CASE UPPER(PayCode)
            WHEN 'W' THEN 'Weekly'
            WHEN 'M' THEN 'Monthly'
            WHEN 'MO' THEN 'Monthly'
            ELSE NULL  -- Unrecognized pay code: investigate.
        END AS ActualPayFrequency
    FROM parsed
),
matched AS (
    SELECT
        n.*,
        n.CountryCode || '-' || n.PlantID AS CountryPlantID,
        p.PlantType,
        p.ExpectedPayFrequency,
        p.CountryPlantID AS MatchedLookupKey
    FROM normalized AS n
    LEFT JOIN PlantLookup AS p
        ON (n.CountryCode || '-' || n.PlantID) = p.CountryPlantID
),
flagged AS (
    SELECT
        *,
        CASE
            WHEN CountryCode IS NULL
              OR EmpID = ''
              OR PlantID = ''
              OR ActualPayFrequency IS NULL
              OR MatchedLookupKey IS NULL
              OR ExpectedPayFrequency IS NULL
                THEN 'CHECK / UNMATCHED'
            WHEN ActualPayFrequency <> ExpectedPayFrequency
                THEN 'EXCEPTION'
            ELSE 'OK'
        END AS ExceptionFlag
    FROM matched
)
SELECT
    EmployeeCode,
    FirstName,
    LastName,
    CountryPlantID,
    PlantType,
    ActualPayFrequency,
    ExpectedPayFrequency,
    ExceptionFlag
FROM flagged
WHERE ExceptionFlag = 'EXCEPTION'
ORDER BY CountryPlantID, EmployeeCode;

-- PART 4 | Validation: how many records have each outcome?
-- We use the same transformation in a VIEW so it can be queried repeatedly.
-- A VIEW stores SQL logic, not a second copy of the data.
-- Note: SQLite CREATE VIEW cannot be declared inside the WITH query above.

DROP VIEW IF EXISTS Case3_AuditResults;
CREATE VIEW Case3_AuditResults AS
WITH
parts AS (
    SELECT EmployeeCode, FirstName, LastName,
           SUBSTR(EmployeeCode, 1, INSTR(EmployeeCode, '-') - 1) AS Head,
           SUBSTR(EmployeeCode, INSTR(EmployeeCode, '-') + 1) AS CodeTail
    FROM EmployeeData
),
parsed AS (
    SELECT *,
           RTRIM(Head, '0123456789') AS RawLocation,
           SUBSTR(Head, LENGTH(RTRIM(Head, '0123456789')) + 1) AS EmpID,
           RTRIM(CodeTail, 'WMo') AS PlantID,
           SUBSTR(CodeTail, LENGTH(RTRIM(CodeTail, 'WMo')) + 1) AS PayCode
    FROM parts
),
normalized AS (
    SELECT *,
           CASE UPPER(RawLocation)
               WHEN 'JAPAN' THEN 'JAP' WHEN 'CANADA' THEN 'CAN'
               WHEN 'US' THEN 'USA' WHEN 'AUS' THEN 'AUS'
               WHEN 'GER' THEN 'GER' WHEN 'ENG' THEN 'ENG'
               WHEN 'ARG' THEN 'ARG' WHEN 'MEX' THEN 'MEX'
               ELSE NULL END AS CountryCode,
           CASE UPPER(PayCode)
               WHEN 'W' THEN 'Weekly'
               WHEN 'M' THEN 'Monthly'
               WHEN 'MO' THEN 'Monthly'
               ELSE NULL END AS ActualPayFrequency
    FROM parsed
),
matched AS (
    SELECT n.*, n.CountryCode || '-' || n.PlantID AS CountryPlantID,
           p.PlantType, p.ExpectedPayFrequency,
           p.CountryPlantID AS MatchedLookupKey
    FROM normalized AS n
    LEFT JOIN PlantLookup AS p
      ON n.CountryCode || '-' || n.PlantID = p.CountryPlantID
)
SELECT *,
       CASE
           WHEN CountryCode IS NULL OR EmpID = '' OR PlantID = ''
                OR ActualPayFrequency IS NULL OR MatchedLookupKey IS NULL
                OR ExpectedPayFrequency IS NULL THEN 'CHECK / UNMATCHED'
           WHEN ActualPayFrequency <> ExpectedPayFrequency THEN 'EXCEPTION'
           ELSE 'OK'
       END AS ExceptionFlag
FROM matched;

-- Check 1: all employees should appear exactly once in the results.
SELECT COUNT(*) AS TotalRows FROM Case3_AuditResults;

-- Check 2: identify the exception counts.
SELECT ExceptionFlag, COUNT(*) AS EmployeeCount
FROM Case3_AuditResults
GROUP BY ExceptionFlag
ORDER BY ExceptionFlag;

-- Check 3: detect employees without a matching plant reference record.
SELECT COUNT(*) AS UnmatchedPlantRows
FROM Case3_AuditResults
WHERE MatchedLookupKey IS NULL;

-- Check 4: display exceptions (this is the final result of the script).
SELECT EmployeeCode, FirstName, LastName, CountryPlantID,
       PlantType, ActualPayFrequency, ExpectedPayFrequency, ExceptionFlag
FROM Case3_AuditResults
WHERE ExceptionFlag = 'EXCEPTION'
ORDER BY CountryPlantID, EmployeeCode;

-- DISCUSSION
-- 1. Why is a LEFT JOIN preferable to an INNER JOIN for an audit test?
-- 2. Why do 'M' and 'Mo' not constitute an exception after normalization?
-- 3. If a record has no lookup match, should it be excluded from the audit?
-- 4. Does an exception prove that the payroll entry is incorrect? What
--    additional evidence would you request from HR or payroll operations?
-- 5. Why should the output row count be reconciled to the source count?
-- ============================================================================
