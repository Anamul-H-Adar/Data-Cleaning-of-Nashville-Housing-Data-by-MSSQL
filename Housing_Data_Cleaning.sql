-- Explore the dataset first
SELECT  * 
FROM HousingDB..HousingData;

-- Count the no of records
SELECT  COUNT(*) total_records
FROM HousingDB..HousingData;

-- 1. Our SaleDate column holding datetime data where time is not appropiate
-- So I formated the data datetime to only date.
SELECT SaleDate, CONVERT(date, SaleDate) formated_date
FROM HousingDB..HousingData;

UPDATE HousingDB..HousingData
SET SaleDate = CAST(SaleDate AS DATE );

-- Check the SaleDate column after updating
SELECT SaleDate
FROM HousingDB..HousingData;

-- Avobe code is not working because our SaleDate column datatype is datetime.
-- We have add another date column
ALTER TABLE HousingDB..HousingData
ADD sales_date DATE;

UPDATE HousingDB..HousingData
SET sales_date = CAST(SaleDate AS DATE );

-- Remove SaleDate column
ALTER TABLE HousingDB..HousingData
DROP column SaleDate;

--- Check where property adderss is null
SELECT l.ParcelID, l.PropertyAddress, r.ParcelID, r.PropertyAddress, ISNULL(l.PropertyAddress, r.PropertyAddress)
FROM HousingDB..HousingData l
JOIN HousingDB..HousingData r
  ON l.ParcelID = r.ParcelID
  AND l.[UniqueID ]!= r.[UniqueID ]
WHERE l.PropertyAddress IS NULL
ORDER BY l.ParcelID;

--- UPDATE property address
UPDATE l
SET l.PropertyAddress = ISNULL(l.PropertyAddress, r.PropertyAddress)
FROM HousingDB..HousingData l
JOIN HousingDB..HousingData r
  ON l.ParcelID = r.ParcelID
  AND l.[UniqueID ]!= r.[UniqueID ]
WHERE l.PropertyAddress IS NULL;

-- Here property address is messy which is include city address
SELECT ParcelID, PropertyAddress, SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress )-1) Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) city
FROM HousingDB..HousingData;

ALTER TABLE HousingDB..HousingData
ADD propAddress NVARCHAR(255);

ALTER TABLE HousingDB..HousingData
ADD propCity NVARCHAR(255);

-- Split out Property Address column to propAddress and propCity column
UPDATE HousingDB..HousingData
SET propAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress )-1);

UPDATE HousingDB..HousingData
SET propCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress));

-- Here Owner address is messy which is include city address and state
SELECT OwnerAddress, PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM HousingDB..HousingData;

-- Split out Owner Address column to propAddress and propCity column
ALTER TABLE HousingDB..HousingData
ADD OwnerAddr NVARCHAR(255);

ALTER TABLE HousingDB..HousingData
ADD OwnerCity NVARCHAR(255);

ALTER TABLE HousingDB..HousingData
ADD OwnerState NVARCHAR(255);

UPDATE HousingDB..HousingData
SET OwnerAddr  = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
    OwnerCity  = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

SELECT * 
FROM HousingDB..HousingData;

-- Looking at SoldAsVacant column. Here SoldAsVacant store same data in multiple format

SELECT  SoldAsVacant, COUNT(*)
FROM HousingDB..HousingData
GROUP BY SoldAsVacant;

SELECT  SoldAsVacant, CASE SoldAsVacant WHEN 'Y' THEN 'Yes'
                                        WHEN 'N' THEN 'No' 
					  ELSE SoldAsVacant END
FROM HousingDB..HousingData
WHERE SoldAsVacant IN ('Y','N');

UPDATE HousingDB..HousingData
SET SoldAsVacant = CASE SoldAsVacant WHEN 'Y' THEN 'Yes'
                                        WHEN 'N' THEN 'No' 
					  ELSE SoldAsVacant END;

-- Cheking Duplicates records on table
SELECT ParcelID, COUNT(*)
FROM HousingDB..HousingData
GROUP BY ParcelID
HAVING COUNT(*) >1
ORDER BY ParcelID;

-- Find out all the duplicate records
SELECT l.ParcelID, l.PropertyAddress, r.ParcelID, r.PropertyAddress
FROM HousingDB..HousingData l
JOIN HousingDB..HousingData r
     ON  l.ParcelID = r.ParcelID
	 AND l.UniqueID <> r.UniqueID
WHERE l.UniqueID > r.UniqueID;

--- Delete All the duplicate records
DELETE r
FROM HousingDB..HousingData l
JOIN HousingDB..HousingData r
     ON  l.ParcelID = r.ParcelID
	 AND l.UniqueID <> r.UniqueID
WHERE l.UniqueID > r.UniqueID;


SELECT l.*, ROW_NUMBER() OVER(PARTITION BY ParcelID ORDER BY UniqueID)
FROM HousingDB..HousingData l;

-- Delete the unnessesary column
ALTER TABLE HousingDB..HousingData
DROP COLUMN PropertyAddress, OwnerName;

--- Check the records
SELECT * 
FROM HousingDB..HousingData
ORDER BY ParcelID;