--1. Select all data

SELECT *
FROM DataCleaning..Housing

--Standarize Date Format

ALTER TABLE Housing
Add SaleDateConverted Date;

UPDATE DataCleaning..Housing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted
FROM DataCleaning..Housing


--2. Populate Property Address Data


--Check for NULLs

SELECT *
FROM DataCleaning..Housing
WHERE PropertyAddress is null
ORDER BY ParcelID

--Corroborate that each PropertyAddress has its own ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM DataCleaning..Housing a
JOIN DataCleaning..Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--If a.Property Address is NULL, create another column with the data we want (b.PropertyAddress) with ISNULL function

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaning..Housing a
JOIN DataCleaning..Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Update the table with SET function

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM DataCleaning..Housing a
JOIN DataCleaning..Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
--WHERE a.PropertyAddress is null we don't need this one to run the query


--3. Breaking out address into individual columns

--Check the data

SELECT PropertyAddress
FROM DataCleaning..Housing

--Select only the address, inlcluding the ','

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
--CHARINDEX Gives us the position for that characterm if we put -1, we delete that character
FROM DataCleaning..Housing

--To select the city we have to start from one space after the ','

SELECT
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM DataCleaning..Housing

--We cant separate two values from one column without creating two other columns,
--so we are creating two new columns and add the values in.

--Create the column for the address and its data type

ALTER TABLE Housing
Add RealAddress nvarchar(255);

--Update the table we just created

UPDATE Housing
SET RealAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

--Create the column for the city and its data type

ALTER TABLE Housing
Add RealCity nvarchar(255);

--Update the table we just created

UPDATE Housing
SET RealCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


--Change OwnerAddress using PARSENAME
--We use replace because PARSENAME functions with periods '.', not commas ','
--We start from 3 because PARSENAME functions from the end to the beginning

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM DataCleaning..Housing

ALTER TABLE Housing
Add OwnerRealAddress nvarchar(255);

ALTER TABLE Housing
Add OwnerCity nvarchar(255);

ALTER TABLE Housing
Add OwnerState nvarchar(255);


Update HOUSING
SET OwnerRealAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

UPDATE Housing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

UPDATE Housing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)


--4 Change Y and N to Yes and No in "Sold as Vacant" field

--Check the data and count the values

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
--DISTINCT returns only distinct (different) values
FROM DataCleaning..Housing
GROUP BY SoldAsVacant
ORDER BY 2 desc

--Using CASE goes through conditions and returns a value when the condition is met

SELECT SoldAsVacant, 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM DataCleaning..Housing

--We update the table

UPDATE DataCleaning..Housing
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


--5. Remove duplicates (its not a standard practice to remove data, usually you store it somewhere else or you use temp tables)

--Identify the duplicates

SELECT *,
	ROW_NUMBER() OVER (
	--We need to do the partition on things that should be unique to each row
	--ROW_NUMBER assigns a sequential rank number to each new record in a partition, if detects two identical values in the same partition,
	--it assigns different rank numbers to both
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference,
	ORDER BY
	--ORDER BY something that should be unique
		UniqueID
		) row_num
FROM DataCleaning..Housing
ORDER BY ParcelID

--After run the query, if row_num > 1 there is a duplicate

--Lets use a CTE to check the duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY
			UniqueID
		) row_num
FROM DataCleaning..Housing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY [UniqueID ]

--Now we delete the duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY
			UniqueID
		) row_num
FROM DataCleaning..Housing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1


--6. Delete unused columns (usually dont delete anything, talk to someone before doing it, dont delete raw data)

ALTER TABLE DataCleaning..Housing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict

SELECT *
FROM DataCleaning..Housing