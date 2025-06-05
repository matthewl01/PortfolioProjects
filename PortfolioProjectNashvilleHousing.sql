Select SaleDate
From PortfolioProject..NashvilleHousing

-- Standardizing Date Format. Original data had a time format of 0:00:00 
-- Adding another Column without the time, and only the date 

Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted
FROM PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------

--Populate Property Address Data

Select *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is NULL
Order by ParcelID

--Self Joining the Table in order to make sure that ParcelId = PropertyAddress
--Running this code now will not show any data as all the propertyaddress's that were NULL before in this code were updated
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Updating all NULL PropertyAddress information that matches the same ParcelID
Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is NULL
--Order by ParcelID


--The Address splits between the city and state through use of commas. CHARINDEX used to only show the address 
-- -1 is used to remove the comma from the query when we run it 
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress)) as City
FROM PortfolioProject..NashvilleHousing



-- Adding the values of the address and city split 

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, Len(PropertyAddress))

SELECT *
FROM PortfolioProject..NashvilleHousing

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',', '.') , 3), --Address
PARSENAME(REPLACE(OwnerAddress,',', '.') , 2), -- City
PARSENAME(REPLACE(OwnerAddress,',', '.') , 1) -- State
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',' , '.') , 3) 

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitCity nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.') , 2)

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitState nvarchar(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.') , 1) 


-----------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold in Vacant" field 

Select DISTINCT(SoldasVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2 

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'	
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SoldAsVacant = 
	CASE When SoldAsVacant = 'Y' THEN 'Yes'	
	 When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject..NashvilleHousing


----------------------------------------------------------------------------------------

--Remove Duplicates 


-- Check the data table for any duplicates first
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
From PortfolioProject..NashvilleHousing
Order by ParcelID

-- CTE to Query off Data to check how many duplicates we have, and delete as a result 

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
From PortfolioProject..NashvilleHousing
--Order by ParcelID
)
SELECT * --Changed to DELETE once we verified that all duplicates were shown with SELECT 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



-------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate 