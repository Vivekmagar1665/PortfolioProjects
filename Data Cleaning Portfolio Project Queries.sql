/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM PortfolioProjets..NashvilleHousing

--standardize data format
SELECT SaleDate
FROM PortfolioProjets..NashvilleHousing

SELECT SaleDate,CONVERT(Date,SaleDate)
FROM PortfolioProjets..NashvilleHousing

ALTER TABLE PortfolioProjets..NashvilleHousing
ALTER COLUMN SaleDate DATE

--Populate property address
SELECT parcelID,PropertyAddress,OwnerName,OwnerAddress,[UniqueID ]
FROM PortfolioProjets..NashvilleHousing 
ORDER BY PropertyAddress

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress--,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProjets..NashvilleHousing a
JOIN PortfolioProjets..NashvilleHousing b
  on a.parcelID=b.ParcelID
  and a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is  NULL

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProjets..NashvilleHousing a
JOIN PortfolioProjets..NashvilleHousing b
  on a.parcelID=b.ParcelID
  and a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is  NULL

--Breaking out address into individual columns (Address,City,State)
SELECT PropertyAddress
FROM  PortfolioProjets..NashvilleHousing


SELECT 
SUBSTRING(REPLACE(PropertyAddress, '.', ','), 1, CHARINDEX(',', REPLACE(PropertyAddress, '.', ',')) - 1) AS Address
,SUBSTRING(PropertyAddress,CHARINDEX(',', REPLACE(PropertyAddress, '.', ','))+1,LEN(PropertyAddress)) AS Address
FROM PortfolioProjets..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress= SUBSTRING(REPLACE(PropertyAddress, '.', ','), 1, CHARINDEX(',', REPLACE(PropertyAddress, '.', ',')) - 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity= SUBSTRING(PropertyAddress,CHARINDEX(',', REPLACE(PropertyAddress, '.', ','))+1,LEN(PropertyAddress))

--

SELECT *
FROM PortfolioProjets..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProjets..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',','.'),1)


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjets..NashvilleHousing
Group by SoldAsVacant
order by 2



Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProjets..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProjets..NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


Select *
From PortfolioProjets..NashvilleHousing



-- Delete Unused Columns


Select *
From PortfolioProjets..NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate





