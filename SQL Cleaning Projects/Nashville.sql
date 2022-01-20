---Overview of data
Select *
From Portfolio_Project_1..Nashville_Housing

-- Standardizing your Date
Select SaleDate_Format
From Portfolio_Project_1.dbo.Nashville_Housing

Select SaleDate,
Convert(Date,SaleDate) AS SaleDate_Reformated
From Portfolio_Project_1.dbo.Nashville_Housing

Update Portfolio_Project_1..Nashville_Housing
SET SaleDate_Format =CONVERT(Date,SaleDate)

--------------------------
--Populate Property Address

Select PropertyAddress
From Portfolio_Project_1.dbo.Nashville_Housing
Where PropertyAddress is null

-- Evaluating again
Select *
From Portfolio_Project_1..Nashville_Housing
Order by ParcelID
-- From what we've observed from the ParcelID and Address - similar ParcelID pertains to similar PropertyAddress - Hence we can use this to find or lessen the null values
-- To do this, we will use JOIN.

--Joining ParcelID
Select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNUll(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project_1..Nashville_Housing a
JOIN Portfolio_Project_1..Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ] 

-- We will check if Nulls were addressed by the join function
Where a.PropertyAddress is null
-- IS null - what do we want to check if it's null. 
-- WE want to update the table with the code above 


Update a
SET PropertyAddress = ISNUll(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project_1..Nashville_Housing a
JOIN Portfolio_Project_1..Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Now to check 
Select PropertyAddress
From Portfolio_Project_1..Nashville_Housing a

--- Breaking out Address into Individual Columns(Address, City, State)

Select PropertyAddress
From Portfolio_Project_1..Nashville_Housing
Order by ParcelID

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address 
From Portfolio_Project_1..Nashville_Housing
-- To get rid of the comma, you minus the position hence the "-1"

--ADD two columns and add value in

ALTER TABLE Portfolio_Project_1..Nashville_Housing
Add PropertySplitAddress Nvarchar(255);

UPDATE Portfolio_Project_1..Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Portfolio_Project_1..Nashville_Housing
Add PropertySplitCity Nvarchar(255);

UPDATE Portfolio_Project_1..Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

Select *
From Portfolio_Project_1..Nashville_Housing    

-- Looking at the Owner's Address (Address, City, State)

Select *
From Portfolio_Project_1..Nashville_Housing   

Select OwnerAddress
From Portfolio_Project_1..Nashville_Housing

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From Portfolio_Project_1..Nashville_Housing

-- Add columns, add values

ALTER TABLE Portfolio_Project_1..Nashville_Housing
Add OwnerSplitAddress Nvarchar(255);

UPDATE Portfolio_Project_1..Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Portfolio_Project_1..Nashville_Housing
Add OwnerSplitCity Nvarchar(255);

UPDATE Portfolio_Project_1..Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Portfolio_Project_1..Nashville_Housing
Add OwnerSplitState Nvarchar(255);

UPDATE Portfolio_Project_1..Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From Portfolio_Project_1..Nashville_Housing   

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio_Project_1..Nashville_Housing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldASVacant
		END
From Portfolio_Project_1..Nashville_Housing

UPDATE Portfolio_Project_1..Nashville_Housing
SET SoldASVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldASVacant
		END

-- Removing Duplicates 

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
			UniqueID)
			row_num
From Portfolio_Project_1..Nashville_Housing)


SELECT *
From RowNumCTE
Where row_num > 1


-- Delete Unused Columns--

Select *
From Portfolio_Project_1..Nashville_Housing

ALTER TABLE Portfolio_Project_1..Nashville_Housing
DROP COLUMN SaleDate,OwnerAddress,PropertyAddress,TaxDistrict
