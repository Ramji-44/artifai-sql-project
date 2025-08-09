
-- Blood Donation Management System - MySQL Project


-- 1. Create Database
CREATE DATABASE IF NOT EXISTS BloodDonationDB;
USE BloodDonationDB;

-- Create Tables


-- Donors Table
CREATE TABLE Donors (
    DonorID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Age INT,
    BloodGroup VARCHAR(5),
    Contact VARCHAR(15),
    LastDonationDate DATE
);

-- Recipients Table
CREATE TABLE Recipients (
    RecipientID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Age INT,
    BloodGroup VARCHAR(5),
    Contact VARCHAR(15),
    BloodRequired INT
);

-- Blood Inventory Table
CREATE TABLE BloodInventory (
    BloodGroup VARCHAR(5) PRIMARY KEY,
    UnitsAvailable INT DEFAULT 0
);

-- Donations Table
CREATE TABLE Donations (
    DonationID INT PRIMARY KEY AUTO_INCREMENT,
    DonorID INT,
    BloodGroup VARCHAR(5),
    DonationDate DATE,
    FOREIGN KEY (DonorID) REFERENCES Donors(DonorID)
);

-- Requests Table
CREATE TABLE Requests (
    RequestID INT PRIMARY KEY AUTO_INCREMENT,
    RecipientID INT,
    BloodGroup VARCHAR(5),
    UnitsRequested INT,
    RequestDate DATE,
    Status ENUM('Pending','Approved','Rejected') DEFAULT 'Pending',
    FOREIGN KEY (RecipientID) REFERENCES Recipients(RecipientID)
);

--  Initial Blood Inventory Data

INSERT INTO BloodInventory (BloodGroup, UnitsAvailable) VALUES
('O+', 5), ('A+', 5), ('B+', 3), ('AB+', 6),
('O-', 2), ('A-', 1), ('B-', 0), ('AB-', 0);


-- Triggers

-- Trigger: Increase stock after donation
DELIMITER //
CREATE TRIGGER after_donation_insert
AFTER INSERT ON Donations
FOR EACH ROW
BEGIN
    UPDATE BloodInventory
    SET UnitsAvailable = UnitsAvailable + 1
    WHERE BloodGroup = NEW.BloodGroup;
END;
//
DELIMITER ;

-- Trigger: Decrease stock after approved request
DELIMITER //
CREATE TRIGGER after_request_update
AFTER UPDATE ON Requests
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Approved' THEN
        UPDATE BloodInventory
        SET UnitsAvailable = UnitsAvailable - NEW.UnitsRequested
        WHERE BloodGroup = NEW.BloodGroup;
    END IF;
END;
//
DELIMITER ;

--  Sample Data for Donors & Recipients

INSERT INTO Donors (Name, Age, BloodGroup, Contact, LastDonationDate)
VALUES 
('Rahul Sharma', 28, 'O+', '9876543210', '2025-03-01'),
('Pooja Nair', 32, 'A+', '9998887776', '2025-03-10');

INSERT INTO Recipients (Name, Age, BloodGroup, Contact, BloodRequired)
VALUES 
('Aditi Verma', 35, 'O+', '9898989898', 2);

-- Example Queries


-- Register new donor
INSERT INTO Donors (Name, Age, BloodGroup, Contact, LastDonationDate)
VALUES ('John Doe', 29, 'B+', '9123456789', '2025-03-15');

-- Record a donation (stock auto-updates)
INSERT INTO Donations (DonorID, BloodGroup, DonationDate)
VALUES (1, 'O+', '2025-03-20');

-- Check inventory
SELECT * FROM BloodInventory;

-- Record a recipient request
INSERT INTO Requests (RecipientID, BloodGroup, UnitsRequested, RequestDate)
VALUES (1, 'O+', 2, CURDATE());

-- Approve a request (stock auto-decreases)
UPDATE Requests SET Status = 'Approved' WHERE RequestID = 1;

-- Reports


-- Blood availability report
SELECT * FROM BloodInventory;

-- Donation history
SELECT D.Name, DN.BloodGroup, DN.DonationDate
FROM Donations DN
JOIN Donors D ON DN.DonorID = D.DonorID;

-- Pending requests
SELECT R.Name, Q.BloodGroup, Q.UnitsRequested
FROM Requests Q
JOIN Recipients R ON Q.RecipientID = R.RecipientID
WHERE Q.Status = 'Pending';
