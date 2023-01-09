#create database
drop database if exists HydroFarm;
create database HydroFarm;
use HydroFarm;



#Create Greenhouse table to store greenhouse information
#Stores sensor values of greenhouses
create table Greenhouse (
	GH_Id INT PRIMARY KEY AUTO_INCREMENT,
	Humidity INT NOT NULL
    CHECK(Humidity >= 0 AND Humidity <= 100),
    Temperature INT NOT NULL #In Farenheit
);



#Create Habitat table
#Stores information on ideal environment for each greenhouse
create table Habitat (
	GH_Id INT NOT NULL,
    Tmin INT NOT NULL,
    Tmax INT NOT NULL,
    Hmax INT NOT NULL,
    Hmin INT NOT NULL,
    
    #Foreign Key Constraint
    CONSTRAINT Habitat_fk_GH
    FOREIGN KEY (GH_Id)
		REFERENCES Greenhouse(GH_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
##   Boundary Values Constraints   ##	
    #Maximum temperature (F)
    CONSTRAINT Tmax_bounds
    CHECK (Tmin >= 40 AND Tmin < Tmax),
	
    #Minimum temperature (F)
    CONSTRAINT bounds_Tmin
    CHECK (Tmax > Tmin AND Tmax < 212),
	
    #Minimum Humidity
	CONSTRAINT Hmin_bounds
    CHECK (Hmin >= 0 AND Hmin<Hmax),
	
    #Maximum Humidity
	CONSTRAINT Hmax_bounds
    CHECK (Hmax > Hmin AND Hmax <= 100)
);



#Create Species Table
#stores information about the optimal environment for the plant grown in each unit
create table Species (
	S_Name VARCHAR(100) PRIMARY KEY,
    pH_Min FLOAT NOT NULL,
    pH_Max FLOAT NOT NULL,
    Ideal_Light INT NOT NULL, #Daily Light Interval
    
##   Boundary Values Contraints   ##	
    #Maximum pH
	CONSTRAINT pH_Min_bounds
    CHECK (pH_Min >= 0 AND pH_Min < pH_Max),
	
    #Minimum pH
	CONSTRAINT pH_Max_bounds
    CHECK (pH_Max > pH_Min AND pH_Max <= 14),
	
    #Ideal Light
	CONSTRAINT Ideal_Light_bounds
    CHECK (Ideal_Light >= 0)
);



#create Unit Table
#stores information sensor values of greenhouse units
create table Unit (
	U_Id INT PRIMARY KEY AUTO_INCREMENT,
    GH_Id INT NOT NULL,
    S_Name VARCHAR(100) NOT NULL,
    Light_Level INT NOT NULL,
    pH FLOAT NOT NULL,
    
##   Foreign Key Constraints   ##	
    #Greenhouse
    constraint Unit_fk_GH
    FOREIGN KEY (GH_Id)
		REFERENCES Greenhouse(GH_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

	#Species
    constraint Unit_fk_Species
    FOREIGN KEY (S_Name)
		REFERENCES Species(S_Name)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        
##   Boundary Constraints   ###	
    #pH
    CONSTRAINT pH_bounds
    CHECK (pH >= 0 AND pH <= 14),
    
    #Light Level
    CONSTRAINT Light_Level
    CHECK (Light_Level >= 0)
);



#create Plant table
#stores data for plants grown in each unit
create table Plant (
	P_Id BIGINT PRIMARY KEY AUTO_INCREMENT, #There will likely be a LOT of plants
    U_Id INT NOT NULL,
    Days_Grown INT DEFAULT 0,
    
##   Foreign Key Constraint ##
	#Unit Id
	CONSTRAINT Plant_fk_Unit
    FOREIGN KEY (U_Id)
		REFERENCES Unit(U_Id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

##   Bounds Constraint   ##
	#Days Grown
    CONSTRAINT Days_Grown_bounds
    CHECK (Days_Grown >= 0)
);
        
    
    
    

    
###				Add Functions			###

#Function to add greenhouse and bounds cell all at once
DELIMITER $$ 
CREATE PROCEDURE Add_Greenhouse (Temperature_ int, Humidity_ int, Tmax_ int, Tmin_ int, Hmax_ int, Hmin_ int)
BEGIN
	DECLARE GH_Newest_ID int;
	INSERT INTO Greenhouse (Temperature, Humidity) VALUES (Temperature_, Humidity_);
    SET GH_Newest_ID = (SELECT max(GH_Id) FROM Greenhouse);
    INSERT INTO Habitat (GH_Id, Tmax, Tmin, Hmax, Hmin) VALUES(GH_Newest_ID, Tmax_, Tmin_, Hmax_, Hmin_);
END $$ 

#Function to add species cell
CREATE PROCEDURE Add_Species (S_Name_ VARCHAR(100), pH_Min_ FLOAT, pH_Max_ FLOAT, Ideal_Light_ INT)
BEGIN
	INSERT INTO Species (S_Name, pH_Min, pH_Max, Ideal_Light) VALUES (S_Name_, pH_Min_, pH_Max_, Ideal_Light_);
END$$

#Function to add Unit cell
CREATE PROCEDURE Add_Unit (GH_Id_ INT, S_Name_ VARCHAR(100), pH_ FLOAT, Light_Level_ INT)
BEGIN
	INSERT INTO Unit (GH_Id, S_Name, pH, Light_Level) VALUES (GH_Id_, S_Name_, pH_, Light_Level_);
END $$

#Function to add Plant cell
CREATE PROCEDURE Add_Plant (U_Id_ BIGINT, Days_Grown_ INT)
BEGIN
	INSERT INTO Plant(U_Id, Days_Grown) VALUES (U_Id_, Days_Grown_);
END $$



###				Remove Functions			###

#Function to remove cell from plant table
CREATE PROCEDURE Remove_Plant(Plant_ID bigint)
BEGIN
	DELETE FROM Plant
    WHERE P_Id = Plant_ID;
END $$

#Function to remove cell from species and associated cells in other tables
CREATE PROCEDURE Remove_Species(Species_Name varchar(100))
BEGIN
	DELETE FROM Species
    WHERE S_Name = Species_Name;
END $$

#Function to remove cell from Unit and associated cells in other tables
CREATE PROCEDURE Remove_Unit(Unit_ID int)
BEGIN
	DELETE FROM UNIT
    WHERE U_Id = Unit_ID;
END $$

#Function to remove cell from Greenhouse and associated cells in other tables 
CREATE PROCEDURE Remove_Greenhouse(Greenhouse_ID int)
BEGIN
	DELETE FROM Greenhouse
    WHERE GH_Id = Greenhouse_ID;
END $$




##			Modify Functions			##

#Function to modify Unit table
CREATE PROCEDURE Modify_Unit(Unit_ID int, New_pH float, New_Light_Level int)
BEGIN
	UPDATE Unit
    SET pH = New_pH, Light_Level = New_Light_Level
    WHERE U_Id = Unit_ID;
END $$

#Function to modify Greenhouse table
CREATE PROCEDURE Modify_Greenhouse(Greenhouse_ID int, New_Temperature int, New_Humidity int)
BEGIN
	UPDATE Greenhouse
    SET Temperature = New_Temperature, Humidity = New_Humidity
    WHERE GH_Id = Greenhouse_ID;
END $$

#Function to modify Habitat table
CREATE PROCEDURE Modify_Habitat(Greenhouse_ID int, New_Hmin int, New_Hmax int, New_Tmin int, New_Tmax int)
BEGIN
	UPDATE Habitat
    SET Hmin = New_Hmin, Hmax = New_Hmax, Tmin = New_Tmin, Tmax = New_Tmax
    WHERE GH_Id = Greenhouse_ID;
END $$

#Function to modify Species table
CREATE PROCEDURE Modify_Species(Species_Name varchar(100), New_pH_Min float, New_pH_Max float, New_Ideal_Light int)
BEGIN
	UPDATE Species
    SET pH_Min = New_pH_Min, pH_Max = New_pH_Max, Ideal_Light = New_Ideal_Light
    WHERE S_Name = Species_Name;
END $$

#Function to modify Plant table
CREATE PROCEDURE Modify_Plant(Plant_ID int, New_Days_Grown int)
BEGIN
	UPDATE Plant
    SET Days_Grown = New_Days_Grown
    WHERE P_Id = Plant_ID;
END $$




##			Newest ID search functions			##
#For numeric id only

#Greenhouse
CREATE FUNCTION Get_Latest_Greenhouse_ID() returns int
DETERMINISTIC
BEGIN
    return (SELECT MAX(GH_Id) FROM Greenhouse);
END $$

#Unit
CREATE FUNCTION Get_Latest_Unit_ID() returns int
DETERMINISTIC
BEGIN
    return (SELECT MAX(U_Id) FROM Unit);
END $$

#Plant
CREATE FUNCTION Get_Latest_Plant_ID() returns bigint
DETERMINISTIC
BEGIN
    return (SELECT MAX(P_Id) FROM Plant);
END $$



##			Query Information Functions			##

#Species
CREATE PROCEDURE Get_Species_Info(Species_Name VARCHAR(100))
BEGIN
	SELECT * FROM Species
    WHERE S_Name = Species_Name;
END $$

#Plant
CREATE PROCEDURE Get_Plant_Info(Plant_ID INT)
BEGIN
	SELECT * FROM Plant
    WHERE P_Id = Plant_ID;
END $$

#Habitat
CREATE PROCEDURE Get_Habitat_Info(Greenhouse_ID INT)
BEGIN
	SELECT * FROM Habitat
    WHERE GH_Id = Greenhouse_ID;
END $$


#Unit
#0 for summary stats, 1 for joined table (Unit, Species, Plant)
CREATE PROCEDURE Get_Unit_Info(Unit_ID INT, show_everything BOOLEAN)
BEGIN
	#Summary Statistic variables
    DECLARE Plant_Count, Min_Days_Grown, Max_Days_Grown int;
    DECLARE Avg_Days_Grown float;
    
    #Show summary statistics
	IF show_everything = 0 OR show_everything IS NULL THEN
		#Summary statistic variables
        SELECT COUNT(*), MIN(Days_Grown), AVG(Days_Grown), MAX(Days_Grown) 
        INTO Plant_Count, Min_Days_Grown, Avg_Days_Grown, Max_Days_Grown
        FROM Plant WHERE U_Id = Unit_ID;
        
        #query statement
		SELECT *, Plant_Count, Avg_Days_Grown, Min_Days_Grown, Max_Days_Grown
		FROM Unit
		WHERE Unit.U_Id = Unit_ID;
        
	#Show joined unit, species, and plant table
	ELSE
		SELECT * FROM Unit
        JOIN Species USING (S_Name)
        LEFT JOIN Plant USING (U_Id)
        WHERE U_Id = Unit_ID;
	END IF;
END $$

#Greenhouse
#0 for summary stats, 1 for joined table
#(Greenhouse, Habitat, Unit) w/ unit summary stats
CREATE PROCEDURE Get_Greenhouse_Info(Greenhouse_ID INT, show_everything BOOLEAN)
BEGIN
	#Variable declarations
	DECLARE Num_Units, Num_Plants, Min_pH, Max_pH, Min_Light_Level, Max_Light_Level int default 0;
    DECLARE Unit_ID_Counter, i, Plant_Count, Min_Days_Grown, Max_Days_Grown int default 0;
	DECLARE Avg_pH, Avg_Days_Grown, Avg_Light_Level float;
    
    IF show_everything = 0 OR show_everything IS NULL THEN
		#Summary Statistic variables
		SELECT count(*), MIN(pH), AVG(pH), MAX(pH), MIN(Light_Level), AVG(Light_Level), MAX(Light_Level)
        INTO Num_Units, Min_pH, Avg_pH, Max_pH, Min_Light_Level, Avg_Light_Level, Max_Light_Level
        FROM Unit WHERE GH_Id = Greenhouse_ID;
        SET Num_Plants = (SELECT count(*) FROM Unit JOIN Plant USING (U_Id) WHERE GH_Id = Greenhouse_ID);
        
        #query statement
        SELECT *, Num_Units, Num_Plants, Min_pH, Avg_pH, Max_pH,  Min_Light_Level, Avg_Light_Level, Max_Light_Level
        FROM Greenhouse
        WHERE GH_Id = Greenhouse_ID;
    ELSE
		#It was too difficult getting summary stats for each unit
        #So I simplified the query
        SELECT *
        FROM Greenhouse
        LEFT JOIN Unit USING (GH_Id)
        WHERE GH_Id = Greenhouse_ID;
    END IF;
END $$


#Search for Units
#Where sensor values are outside Species bounds
CREATE PROCEDURE Find_Unideal_Units()
BEGIN
	SELECT *
    FROM Unit
    JOIN Species USING (S_Name)
    WHERE (pH < pH_Min OR pH > pH_Max OR Light_Level != Ideal_Light);
END $$

#Search for greenhouses
#where the sensor values are out of habitat bounds
CREATE PROCEDURE Find_Unideal_Greenhouses()
BEGIN
	SELECT *
    FROM Greenhouse
    JOIN Habitat USING (GH_Id)
    WHERE (Temperature < Tmin OR Temperature > Tmax OR Humidity > Hmax OR Humidity < Hmin);
END $$	




##			Quick Fill Functions			##

#Fill specified unit with num_plants amount of plants,
#With days grown being between min_days_grown and max_days_grown
CREATE PROCEDURE Fill_Unit(Unit_ID int, num_plants int, max_days_grown int, min_days_grown int)
BEGIN
	#Temporary variables
	DECLARE counter int default 0;
    DECLARE days_grown int default 0;
    
    #While loop
	WHILE counter < num_plants DO
		#Create random number between min_days_grown and max_days_grown
		SET days_grown = ( select FLOOR(RAND() * (max_days_grown-min_days_grown)+1) );
        #Add plant with that number as days plant has grown
        call Add_Plant(Unit_ID, days_grown);
        SET counter = counter + 1;
	END WHILE;
END $$

DELIMITER ; #put at end of functions block
 
 
 
 
 
 
 
 
 
 
#Greenhouse
#Temp, Humidity, Tmax, Tmin, Hmax, Hmin    
call Add_Greenhouse(80, 55, 100, 70, 80, 30);
SET @GH_ID_1 := Get_Latest_Greenhouse_ID();
call Add_Greenhouse(55, 15, 90, 70, 70, 40);
SET @GH_ID_2 := Get_Latest_Greenhouse_ID();
call Add_Greenhouse(75, 60, 85, 65, 65, 30);
SET @GH_ID_3 = Get_Latest_Greenhouse_ID();

#Species
#Name, pH Min, pH Max, Ideal Light
call Add_Species("Lettuce", 5.5, 6.0, 14);
call Add_Species("Cabbage", 6.2, 6.6, 10);
call Add_Species("Basil", 5.6, 6.4, 13);
call Add_Species("Cilantro", 5.7, 6.7, 15);



#Unit
#Greenhouse ID, Species Name , pH , Light_Level
call Add_Unit(@GH_ID_1, "Lettuce", 5.7, 14);
SET @U_ID_1 = Get_Latest_Unit_ID();
call Add_Unit(@GH_ID_1, "Cabbage", 7.5, 10);
SET @U_ID_2 = Get_Latest_Unit_ID();
call Add_Unit(@GH_ID_1, "Basil", 6.0, 12);
SET @U_ID_3 = Get_Latest_Unit_ID();
call Add_Unit(@GH_ID_1, "Lettuce", 5.7, 14); #Duplicate value
SET @U_ID_4 = Get_Latest_Unit_ID();

call Add_Unit(@GH_ID_2, "Cilantro", 6.3, 15);
SET @U_ID_5 = Get_Latest_Unit_ID();
call Add_Unit(@GH_ID_2, "Cilantro", 6.3, 14); #Duplicate value
SET @U_ID_6 = Get_Latest_Unit_ID();
call Add_Unit(@GH_ID_2, "Cilantro", 6.3, 14); #Duplicate value
SET @U_ID_7 = Get_Latest_Unit_ID();


#Unit ID, number of plants, max days grown, min_days_grown
call Fill_Unit(@U_ID_1, 10, 50, 0);
call Fill_Unit(@U_ID_2, 15, 60, 20);
call Fill_Unit(@U_ID_4, 5, 40, 40);
call Fill_Unit(@U_ID_5, 50, 75, 0);
call Fill_Unit(@U_ID_7, 20, 120, 75);

#Test info queries
#call Get_Plant_Info(50);
#call Get_Species_Info("Lettuce");
#call Get_Unit_Info(1, 1);
#call Get_Greenhouse_Info(@GH_ID_1, 0);

#Test out of bounds queries
#call Find_Unideal_Greenhouses();
#call Find_Unideal_Units();