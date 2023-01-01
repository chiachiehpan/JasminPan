SELECT * FROM PortfolioProject.`nashville housing data`;

---Populate Property Address data
SELECT PropertyAddress
FROM PortfolioProject.`nashville housing data`
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.`nashville housing data` a
JOIN PortfolioProject.`nashville housing data` b
 ON a.ParcelID = b.ParcelID
 AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

---Breaking out address into individual columns (Address, City, State)
SELECT PropertyAddress
FROM PortfolioProject.`nashville housing data`

SELECT 
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)- 1 ) as Address,
 SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+ 1, LENGTH(PropertyAddress)) as Address

FROM PortfolioProject.`nashville housing data`

ALTER TABLE `nashville housing data`
ADD PropertySplitAddress NVARCHAR(255);

UPDATE `nashville housing data`
 SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)- 1 )
 
ALTER TABLE `nashville housing data`
ADD PropertySplitCity NVARCHAR(255);

UPDATE `nashville housing data`
 SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+ 1, LENGTH(PropertyAddress))

SELECT *
FROM PortfolioProject.`nashville housing data`

----Owner address
SELECT 
SUBSTRING_INDEX(OwnerAddress, ',', 1), 
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1),
SUBSTRING_INDEX(OwnerAddress, ',', -1) 

FROM PortfolioProject.`nashville housing data`

ALTER TABLE `nashville housing data`
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE `nashville housing data`
 SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1)

ALTER TABLE `nashville housing data`
ADD OwnerSplitCity NVARCHAR(255);

UPDATE `nashville housing data`
 SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)
 
ALTER TABLE `nashville housing data`
ADD OwnerSplitState NVARCHAR(255);

UPDATE `nashville housing data`
 SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1)

SELECT *
FROM PortfolioProject.`nashville housing data`

----Change Y and N to Yes and No in "sold as vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.`nashville housing data`
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
 WHEN SoldAsVacant = 'N' THEN 'No'
 ELSE SoldAsVacant
 END
FROM PortfolioProject.`nashville housing data`; 

----

UPDATE `nashville housing data`
 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
 WHEN SoldAsVacant = 'N' THEN 'No'
 ELSE SoldAsVacant
 END;


-----Remove Duplicates
SELECT *, 
ROW_NUMBER()OVER (PARTITION BY ParcelID, 
                               SalePrice,
                               LegalReference
                               ORDER BY 
                               UniqueID
                                ) row_num
FROM PortfolioProject.`nashville housing data`


SELECT UniqueID
FROM ( 
  SELECT UniqueID, 
  ROW_NUMBER()OVER (PARTITION BY ParcelID, 
                               SalePrice,
                               LegalReference
                               ORDER BY 
                               UniqueID
                                ) row_num
	FROM PortfolioProject.`nashville housing data`) t
    WHERE row_num > 1

DELETE FROM PortfolioProject.`nashville housing data`
 WHERE UniqueID IN ( 
  SELECT UniqueID
  FROM ( 
  SELECT UniqueID, 
  ROW_NUMBER()OVER (PARTITION BY ParcelID, 
                               SalePrice,
                               LegalReference
                               ORDER BY 
                               UniqueID
                                ) row_num
	FROM PortfolioProject.`nashville housing data`) t
    WHERE row_num > 1
 );

----Delete Unused Columns

SELECT *
FROM PortfolioProject.`nashville housing data`

ALTER TABLE PortfolioProject.`nashville housing data`
 DROP COLUMN OwnerAddress,
 DROP COLUMN TaxDistrict,
 DROP COLUMN PropertyAddress,

ALTER TABLE PortfolioProject.`nashville housing data`
 DROP COLUMN SaleDate;
