/*
Cleaning Data in SQL Queries
*/


Select JDOP_DB.dbo.NashvilleHousing.SaleDateConverted,SaleDate
From JDOP_DB.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDate Converted, CONVERT(Date,SaleDate)
From JDOP_DB.dbo.NashvilleHousing


Update JDOP_DB.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)




-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDateConverted2

SELECT SaleDateConverted
FROM JDOP_DB.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDateConverted2 = CONVERT(Date,SaleDate)

SELECT SaleDate,SaleDateConverted,SaleDateConverted2
FROM NashvilleHousing

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select A.Parcelid,A.PropertyAddress,B.Parcelid,B.PropertyAddress  
FROM
JDOP_DB.dbo.NashvilleHousing A
JOIN
JDOP_DB.dbo.NashvilleHousing B
ON A.ParcelID = B.ParcelID
WHERE A.PropertyAddress IS NULL

update a
set A.PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
from
NashvilleHousing a
join
NashvilleHousing b
on
a.[UniqueID ] <> b.[UniqueID ]
and
a.ParcelID = b.ParcelID
where
A.PropertyAddress is null






Select *
From JDOP_DB.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

/*

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

*/


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From JDOP_DB.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

--METHOD 1
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From JDOP_DB.dbo.NashvilleHousing

--METHOD 1

-- PARSENAME WORKS ONLY WITH CARACTER '.'  (DOT)
SELECT PropertyAddress,
PARSENAME(REPLACE(PropertyAddress,',','.'), 2),
PARSENAME(REPLACE(PropertyAddress,',','.'), 1)
From JDOP_DB.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From JDOP_DB.dbo.NashvilleHousing





Select OwnerAddress
From JDOP_DB.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From --METHOD 1
.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From JDOP_DB.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From JDOP_DB.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From --METHOD 1
.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates WITH CTE ( CTE => TEMP TABLE )

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

From JDOP_DB.dbo.NashvilleHousing
--order by ParcelID
)
SELECT * --DELETE -- Select * --- SELECT / DELETE TO REMOVET
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress ON SELECT REMOVE COMMENT



Select *
From JDOP_DB.dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From JDOP_DB.dbo.NashvilleHousing


ALTER TABLE JDOP_DB.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate















-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO






