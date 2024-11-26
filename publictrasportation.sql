-- Vehicle Table
CREATE TABLE Vehicle (
    Vehicle_ID INT PRIMARY KEY,
    Route_ID INT NOT NULL,
    Capacity INT NOT NULL,
    Type VARCHAR(50),
    FOREIGN KEY (Route_ID) REFERENCES Route(Route_ID)
);

-- Route Table
CREATE TABLE Route (
    Route_ID INT PRIMARY KEY,
    Route_name VARCHAR(100) NOT NULL,
    Start_location VARCHAR(100) NOT NULL,
    Distance DECIMAL(10, 2),
    End_location VARCHAR(100) NOT NULL
);

-- Passenger Table
CREATE TABLE Passenger (
    Passenger_ID INT PRIMARY KEY,
    Preferred_route_ID INT,
    Contact_info VARCHAR(150),
    Name VARCHAR(100),
    FOREIGN KEY (Preferred_route_ID) REFERENCES Route(Route_ID)
);

-- Schedule Table
CREATE TABLE Schedule (
    Schedule_ID INT PRIMARY KEY,
    Vehicle_ID INT NOT NULL,
    Route_ID INT NOT NULL,
    Departure_time TIMESTAMP,
    Arrival_time TIMESTAMP,
    Traffic_condition VARCHAR(100),
    FOREIGN KEY (Vehicle_ID) REFERENCES Vehicle(Vehicle_ID),
    FOREIGN KEY (Route_ID) REFERENCES Route(Route_ID)
);

-- Ticket Table
CREATE TABLE Ticket (
    Ticket_ID INT PRIMARY KEY,
    Passenger_ID INT NOT NULL,
    Schedule_ID INT NOT NULL,
    Fare DECIMAL(10, 2),
    FOREIGN KEY (Passenger_ID) REFERENCES Passenger(Passenger_ID),
    FOREIGN KEY (Schedule_ID) REFERENCES Schedule(Schedule_ID)
);

-- Maintenance Table
CREATE TABLE Maintenance (
    Maintenance_ID INT PRIMARY KEY,
    Vehicle_ID INT NOT NULL,
    Maintenance_status VARCHAR(50),
    Maintenance_date DATE,
    Issue_details VARCHAR(200),
    FOREIGN KEY (Vehicle_ID) REFERENCES Vehicle(Vehicle_ID)
);
-- Insert into Route
INSERT INTO Route (Route_ID, Route_name, Start_location, Distance, End_location)
VALUES 
(1, 'Route A', 'Downtown', 15.5, 'Uptown'),
(2, 'Route B', 'Westside', 25.3, 'Eastside');

-- Insert into Vehicle
INSERT INTO Vehicle (Vehicle_ID, Route_ID, Capacity, Type)
VALUES 
(101, 1, 50, 'Bus'),
(102, 2, 30, 'Van');

-- Insert into Passenger
INSERT INTO Passenger (Passenger_ID, Preferred_route_ID, Contact_info, Name)
VALUES 
(201, 1, 'john.doe@example.com', 'John Doe'),
(202, 2, 'jane.smith@example.com', 'Jane Smith');

-- Insert into Schedule
INSERT INTO Schedule (Schedule_ID, Vehicle_ID, Route_ID, Departure_time, Arrival_time, Traffic_condition)
VALUES 
(301, 101, 1, '2024-11-26 08:00:00', '2024-11-26 08:45:00', 'Moderate'),
(302, 102, 2, '2024-11-26 09:00:00', '2024-11-26 09:50:00', 'Heavy');

-- Insert into Ticket
INSERT INTO Ticket (Ticket_ID, Passenger_ID, Schedule_ID, Fare)
VALUES 
(401, 201, 301, 3.50),
(402, 202, 302, 4.00);

-- Insert into Maintenance
INSERT INTO Maintenance (Maintenance_ID, Vehicle_ID, Maintenance_status, Maintenance_date, Issue_details)
VALUES 
(501, 101, 'Completed', '2024-11-25', 'Oil change'),
(502, 102, 'Pending', '2024-11-28', 'Brake inspection');

SELECT Schedule_ID, Departure_time, Arrival_time, Vehicle_ID
FROM Schedule;

SELECT Passenger.Name, Ticket.Fare 
FROM Passenger
JOIN Ticket ON Passenger.Passenger_ID = Ticket.Passenger_ID
WHERE Ticket.Schedule_ID = 301;

SELECT Vehicle_ID, Maintenance_status, Maintenance_date, Issue_details
FROM Maintenance;

SELECT Route.Route_name, SUM(Ticket.Fare) AS Total_Revenue
FROM Ticket
JOIN Schedule ON Ticket.Schedule_ID = Schedule.Schedule_ID
JOIN Route ON Schedule.Route_ID = Route.Route_ID
WHERE Route.Route_ID = 1
GROUP BY Route.Route_name;

SELECT Route.Route_name, Vehicle.Type, Vehicle.Capacity
FROM Route
JOIN Vehicle ON Route.Route_ID = Vehicle.Route_ID;
UPDATE Schedule
SET Traffic_condition = 'Light'
WHERE Schedule_ID = 301;

ALTER TABLE Schedule ADD Driver_Name VARCHAR(100);

--Delete outdated maintenance records
DELETE FROM Maintenance
WHERE Maintenance_date < '2024-11-01';

--Interface Implementation
--Retrieve the schedule and fare details for a preferred route
SELECT Schedule.Schedule_ID, Route.Route_name, Schedule.Departure_time, Schedule.Arrival_time, Ticket.Fare
FROM Schedule
JOIN Route ON Schedule.Route_ID = Route.Route_ID
JOIN Ticket ON Schedule.Schedule_ID = Ticket.Schedule_ID
WHERE Route.Route_name = 'Route A';

--Fetch real-time vehicle status, including location and capacity usage
SELECT Vehicle.Vehicle_ID, Route.Route_name, Schedule.Departure_time, Vehicle.Capacity - COUNT(Ticket.Ticket_ID) AS Remaining_Seats
FROM Vehicle
JOIN Schedule ON Vehicle.Vehicle_ID = Schedule.Vehicle_ID
JOIN Route ON Schedule.Route_ID = Route.Route_ID
LEFT JOIN Ticket ON Schedule.Schedule_ID = Ticket.Schedule_ID
WHERE NOW() BETWEEN Schedule.Departure_time AND Schedule.Arrival_time
GROUP BY Vehicle.Vehicle_ID, Route.Route_name, Schedule.Departure_time;

--Summarize maintenance history for vehicles over the past month
SELECT Vehicle.Vehicle_ID, 
       COUNT(Maintenance.Maintenance_ID) AS Total_Maintenance, 
       MAX(Maintenance.Maintenance_date) AS Last_Maintenance_Date
FROM Vehicle
JOIN Maintenance ON Vehicle.Vehicle_ID = Maintenance.Vehicle_ID
WHERE Maintenance.Maintenance_date > CURRENT_DATE - INTERVAL '1 month'
GROUP BY Vehicle.Vehicle_ID;

--Data Confidentiality Measures
--Define different roles for data access and manage permissions
CREATE USER passenger_user WITH PASSWORD 'secure_password';
CREATE USER operator_user WITH PASSWORD 'secure_password';
CREATE USER admin_user WITH PASSWORD 'secure_password';

-- Grant Passenger Role (Read-Only Access)
GRANT SELECT ON ALL TABLES IN SCHEMA public TO passenger_user;

-- Grant Operator Role (Read and Write Access to Schedules and Tickets)
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO operator_user;


-- Grant Admin Role (Full Access)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO operator_user;

--Encrypt passenger contact information during storage
CREATE TABLE Encrypted_Passenger (
    Passenger_ID INT PRIMARY KEY,
    Encrypted_Email BYTEA, 
    Encrypted_Phone BYTEA,  
    Name VARCHAR(100)
);

--Enable the pgcrypto Extension
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Insert data with encryption
INSERT INTO Encrypted_Passenger (Passenger_ID, Encrypted_Email, Encrypted_Phone, Name)
VALUES (
    1,
    pgp_sym_encrypt('john.doe@example.com', 'encryption_key'), -- Encrypt email
    pgp_sym_encrypt('1234567890', 'encryption_key'),          -- Encrypt phone
    'John Doe'
);

-- Retrieve and decrypt data
SELECT Passenger_ID, 
       pgp_sym_decrypt(Encrypted_Email, 'encryption_key') AS Email, 
       pgp_sym_decrypt(Encrypted_Phone, 'encryption_key') AS Phone, 
       Name
FROM Encrypted_Passenger;

--Innovative Features Implementation
--Environmental Insights
--a CASE Statement for Mapping
SELECT Route.Route_ID, 
       Route.Route_name, 
       AVG(
           CASE 
               WHEN Schedule.Traffic_condition = 'Light' THEN 1
               WHEN Schedule.Traffic_condition = 'Moderate' THEN 2
               WHEN Schedule.Traffic_condition = 'Heavy' THEN 3
               ELSE NULL -- Exclude unclassified conditions
           END
       ) AS Average_Traffic
FROM Route
JOIN Schedule ON Route.Route_ID = Schedule.Route_ID
GROUP BY Route.Route_ID, Route.Route_name;

--calculate the days since the last maintenance.
SELECT Vehicle.Vehicle_ID, 
       COUNT(Maintenance.Maintenance_ID) AS Maintenance_Count, 
       MAX(Maintenance.Maintenance_date) AS Last_Maintenance_Date,
       CURRENT_DATE - MAX(Maintenance.Maintenance_date) AS Days_Since_Last_Maintenance
FROM Vehicle
JOIN Maintenance ON Vehicle.Vehicle_ID = Maintenance.Vehicle_ID
GROUP BY Vehicle.Vehicle_ID
HAVING CURRENT_DATE - MAX(Maintenance.Maintenance_date) > 30;

--retrieve tickets purchased within the last month
SELECT Passenger.Passenger_ID, 
       Passenger.Name, 
       COUNT(Ticket.Ticket_ID) AS Tickets_Bought
FROM Passenger
JOIN Ticket ON Passenger.Passenger_ID = Ticket.Passenger_ID
WHERE Ticket.Purchase_Date > CURRENT_DATE - INTERVAL '1 month'
GROUP BY Passenger.Passenger_ID, Passenger.Name
HAVING COUNT(Ticket.Ticket_ID) >= 10;

ALTER TABLE Ticket
ADD COLUMN Purchase_Date TIMESTAMP;

INSERT INTO Ticket (Ticket_ID, Passenger_ID, Schedule_ID, Fare, Purchase_Date)
VALUES 
(101, 201, 301, 3.50, '2024-11-01 08:00:00'),
(102, 202, 302, 4.00, '2024-11-05 09:15:00'),
(103, 201, 302, 3.50, '2024-11-10 11:30:00'),
(104, 202, 301, 3.00, '2024-11-15 14:00:00'),
(105, 201, 301, 4.50, '2024-11-20 16:45:00');


SELECT Ticket_ID, Passenger_ID, Schedule_ID, Fare, Purchase_Date
FROM Ticket;

SELECT * FROM Ticket;

--calculate the available seats for each schedule
SELECT Available_Seats_Data.Route_name, 
       SUM(Available_Seats_Data.Available_Seats * 0.2) AS Estimated_Car_Emission_Saving
FROM (
    SELECT Vehicle.Vehicle_ID,
           Route.Route_name,
           Vehicle.Capacity - COUNT(Ticket.Ticket_ID) AS Available_Seats
    FROM Vehicle
    JOIN Schedule ON Vehicle.Vehicle_ID = Schedule.Vehicle_ID
    JOIN Route ON Schedule.Route_ID = Route.Route_ID
    LEFT JOIN Ticket ON Schedule.Schedule_ID = Ticket.Schedule_ID
    GROUP BY Vehicle.Vehicle_ID, Route.Route_name
) AS Available_Seats_Data
GROUP BY Available_Seats_Data.Route_name;


