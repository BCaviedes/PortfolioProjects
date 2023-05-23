/*
Cleaning Data in SQL using queries
*/

SELECT *
FROM PortfolioProject..[Nashville Housing Data]


-- Review date format and correct any issues

SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM PortfolioProject..NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD SalesDateConverted DATE

UPDATE NashvilleHousingData
SET SalesDateConverted = CONVERT(DATE, SaleDate)

-- 

SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM PortfolioProject..NashvilleHousingData

/*
Populate Property Adress Data.
*/

-- If de ParcelID is the same of the row above then the PropertyAddress is also the same.
-- To do this we need to find weather or not the ParcelID is the same and contain the PropertyAddress

SELECT [UniqueID ], ParcelID, PropertyAddress
FROM PortfolioProject..NashvilleHousingData


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousingData a
JOIN PortfolioProject..NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousingData a
JOIN PortfolioProject..NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Separe PropertyAddress into their differente parts (Adress, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousingData

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousingData
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


-- Separe OwnerAddress into their differente parts (Adress, City, State)
-- Using parsename to divide each part by delimiter '.'

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousingData

SELECT
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
FROM PortfolioProject..NashvilleHousingData
 
ALTER TABLE NashvilleHousingData
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)

ALTER TABLE NashvilleHousingData
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)

ALTER TABLE NashvilleHousingData
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)

SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM PortfolioProject..NashvilleHousingData

-- Change Y and N to YES and No ins Sold as Vacant column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousingData 
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END
FROM PortfolioProject..NashvilleHousingData 



UPDATE NashvilleHousingData
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'N' THEN 'No'
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	ELSE SoldAsVacant
END

-- DELETE Unsued columns

SELECT *
FROM PortfolioProject..NashvilleHousingData

ALTER TABLE PortfolioProject..NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

