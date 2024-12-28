select *
FROM housing


-- Standardize Date Format --
ALTER TABLE housing
ALTER COLUMN "SaleDate" TYPE DATE USING TO_DATE("SaleDate", 'FMMonth DD, YYYY');


-- Populate Property Address data --
Select *
From housing
-- WHERE "PropertyAddress" is null
ORDER BY "ParcelID"

SELECT a."ParcelID", a."PropertyAddress", b."ParcelID", b."PropertyAddress", COALESCE(a."PropertyAddress", b."PropertyAddress") AS "MergedPropertyAddress"
FROM housing AS a
JOIN housing AS b
ON a."ParcelID" = b."ParcelID"
AND a."UniqueID " <> b."UniqueID "
WHERE a."PropertyAddress" IS NULL;

UPDATE housing AS a
SET "PropertyAddress" = CASE
   WHEN a."PropertyAddress" IS NULL THEN b."PropertyAddress"
   ELSE a."PropertyAddress"
END
FROM housing AS b
WHERE a."ParcelID" = b."ParcelID"
  AND a."UniqueID " <> b."UniqueID "
  AND a."PropertyAddress" IS NULL;


-- Breaking out Address into Individual Columns (Address, City, State) --
Select "PropertyAddress"
From housing
-- WHERE "PropertyAddress" is null
-- ORDER BY "ParcelID"

SELECT
SUBSTRING("PropertyAddress", 1, POSITION(',' IN "PropertyAddress") - 1) as Address,
SUBSTRING("PropertyAddress", POSITION(',' IN "PropertyAddress") + 1, LENGTH("PropertyAddress")) as Address
FROM housing;


ALTER TABLE housing
Add SplitAddress VARCHAR(255);

UPDATE housing
SET SplitAddress = SUBSTRING("PropertyAddress", 1, POSITION(',' IN "PropertyAddress") - 1)

ALTER TABLE housing
Add SplitCity VARCHAR(255);

UPDATE housing
SET SplitCity = SUBSTRING("PropertyAddress", POSITION(',' IN "PropertyAddress") + 1, LENGTH("PropertyAddress"))

SELECT *
FROM housing;

SELECT "OwnerAddress"
FROM housing;

SELECT
split_part("OwnerAddress", ',', 1) AS Address,
split_part("OwnerAddress", ',', 2) AS City,
split_part("OwnerAddress", ',', 3) AS State
FROM housing;

ALTER TABLE housing
ADD COLUMN OwnerSplitAddress VARCHAR(255),
ADD COLUMN OwnerSplitCity VARCHAR(255),
ADD COLUMN OwnerSplitState VARCHAR(255);

UPDATE housing
SET
  OwnerSplitAddress = split_part("OwnerAddress", ',', 1),
  OwnerSplitCity = split_part("OwnerAddress", ',', 2),
  OwnerSplitState = split_part("OwnerAddress", ',', 3);

SELECT *
FROM housing;


-- Change Y and N to Yes and No in "Sold as Vacant" field --
SELECT DISTINCT("SoldAsVacant"), COUNT("SoldAsVacant")
FROM housing
GROUP BY "SoldAsVacant"
ORDER BY 2;

SELECT "SoldAsVacant",
CASE
	WHEN "SoldAsVacant" = 'Y' THEN 'Yes'
	WHEN "SoldAsVacant" = 'N' THEN 'No'
	ELSE "SoldAsVacant"
	END
FROM housing;

UPDATE housing
SET "SoldAsVacant" = CASE
	WHEN "SoldAsVacant" = 'Y' THEN 'Yes'
	WHEN "SoldAsVacant" = 'N' THEN 'No'
	ELSE "SoldAsVacant"
	END


-- Remove Duplicates --
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY "ParcelID",
				 "PropertyAddress",
				 "SalePrice",
				 "SaleDate",
				 "LegalReference"
				 ORDER BY
					"UniqueID "
					) row_num

From housing
--order by ParcelID
)
select *
From RowNumCTE
Where row_num > 1
--Order by "PropertyAddress"

-- DELETE --
WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY "ParcelID",
                         "PropertyAddress",
                         "SalePrice",
                         "SaleDate",
                         "LegalReference"
            ORDER BY "UniqueID "
        ) AS row_num
    FROM housing
)
DELETE FROM housing
WHERE ("ParcelID", "PropertyAddress", "SalePrice", "SaleDate", "LegalReference", "UniqueID ") IN (
    SELECT "ParcelID", "PropertyAddress", "SalePrice", "SaleDate", "LegalReference", "UniqueID "
    FROM RowNumCTE
    WHERE row_num > 1
);

Select *
From housing


-- Delete Unused Columns --
Select *
From housing;


ALTER TABLE housing
DROP COLUMN "OwnerAddress",
DROP COLUMN "TaxDistrict",
DROP COLUMN "PropertyAddress";