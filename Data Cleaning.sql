/*

Cleaning Data in Sql Queires

*/

Select *
From Portfolio.dbo.NashwilleHousing

-------------------------------------------------------------------


--Standartise Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate) AS original_date
From Portfolio.dbo.[NashwilleHousing]

Update [NashwilleHousing]
SET SaleDate = CONVERT(Date,SaleDate)

Alter Table NashwilleHousing
Add SaleDateConverted Date;

Update [NashwilleHousing]
SET SaleDateConverted = CONVERT(Date,SaleDate)

-----------------------------------------------------------------

--Populate property Address Data

Select PropertyAddress
From Portfolio.dbo.[NashwilleHousing]
Where PropertyAddress is null

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress) AS new_address
From Portfolio.dbo.[NashwilleHousing] a
JOIN Portfolio.dbo.[NashwilleHousing] b
    on a.ParcelID = b.ParcelID
	AND a.[UNIQUEID] <> b.[UNIQUEID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio.dbo.NashwilleHousing a
JOIN Portfolio.dbo.NashwilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-----------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From Portfolio.dbo.NashwilleHousing

Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1  , LEN(PropertyAddress)) as Address


From dbo.NashwilleHousing

Alter Table NashwilleHousing
Add PropertySplitAddress Nvarchar(255);

Update [NashwilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)


Alter Table NashwilleHousing
Add PropertySplitCity Nvarchar(255);

Update [NashwilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1  , LEN(PropertyAddress))




Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address
,PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City
,PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State

From dbo.NashwilleHousing


Alter Table NashwilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update [NashwilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


Alter Table NashwilleHousing
Add OwnerSplitCity Nvarchar(255);

Update [NashwilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table NashwilleHousing
Add OwnerSplitState Nvarchar(255);

Update [NashwilleHousing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
From dbo.NashwilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
,CASE When SoldAsVacant = 'Y' Then 'Yes'
      When SoldAsVacant = 'N' Then 'No'
	  ELSE SoldAsVacant
	  END

From dbo.NashwilleHousing

Update NashwilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
      When SoldAsVacant = 'N' Then 'No'
	  ELSE SoldAsVacant
	  END
--------------------------------------------------------------------

--Remove Dupllicates
WITH RowNumCTE AS(
Select *,
    ROW_NUMBER() OVER(
	PARTITION BY ParcelId,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				   UniqueID
				   ) row_num



From Portfolio.dbo.NashwilleHousing
)

Select *
From RowNumCTE
Where row_num > 1
order by PropertyAddress


-------------------------------------------------------------------------

--Delete Unused Columns

ALTER TABLE Portfolio.dbo.NashwilleHousing
DROP COLUMN PropertyAddress,SaleDate,OwnerAddress,TaxDistrict

select *
From Portfolio.dbo.NashwilleHousing