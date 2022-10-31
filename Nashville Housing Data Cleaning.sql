/* 
cleaning Nashville Housing data in SQL queries 

--tasks involved inlcude:
			1. standardizing the date column
			2. populating the null property address cells using (self)joins
			3. breaking out propertyaddress into individual columns (address, city and state) for easier use
				 method 1 - use substring and characterindex(charindex)
				 method 2 - use parsename and replace (the comma with a period)
			4. change the Y and N to Yes and No in the column "Sold as vacant"
			5.  Remove duplicates in the table - create a CTE
			6. delete unused/unhelpful columns

*/


--select *
--from PortfolioProject.dbo.[Nashville Housing]

--standardize date format

select SaleDateConverted, convert(date,SaleDate) --as datesold
from PortfolioProject.dbo.[Nashville Housing]

--update [Nashville Housing]
--set SaleDate = convert(date,SaleDate)

alter table [Nashville Housing]
add SaleDateConverted Date;

update [Nashville Housing]
set SaleDateConverted = convert(date,SaleDate)

--populate property addresss

select *
from PortfolioProject.dbo.[Nashville Housing]
--where PropertyAddress is null
order by ParcelID

--do a self join

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.[Nashville Housing] a
join PortfolioProject.dbo.[Nashville Housing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--update alias table a
--isnull finds null values and populates with a specified value/ string eg."No Address"
--in this case populate property address a with property adderess in table b if the ParcelID is same

update a 
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.[Nashville Housing] a
join PortfolioProject.dbo.[Nashville Housing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out Address into individual columns (Address, City, State)
--Method 1 (Property Address)
--In the raw data the delimiter is a comma between data

select PropertyAddress
from PortfolioProject.dbo.[Nashville Housing]
--where PropertyAddress is null
--order by ParcelID

--substring and character index(charindex)

select 
SUBSTRING( PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address--(-1) counts upto before the comma
,SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as Address --(+1) counts from after the comma onwards
from PortfolioProject.dbo.[Nashville Housing]


alter table [Nashville Housing]
add PropertySplitaddress nvarchar(255);

update [Nashville Housing]
set PropertySplitaddress = SUBSTRING( PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

alter table [Nashville Housing]
add PropertySplitCity nvarchar(255);

update [Nashville Housing]
set PropertySplitCity = SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) 

select *
from PortfolioProject.dbo.[Nashville Housing]


--Method 2 for Splitting the OwnerAddress column


select OwnerAddress
from PortfolioProject.dbo.[Nashville Housing]

select
PARSENAME(replace(OwnerAddress, ',','.'), 3)
,PARSENAME(replace(OwnerAddress, ',','.'), 2)
,PARSENAME(replace(OwnerAddress, ',','.'), 1)
from PortfolioProject.dbo.[Nashville Housing]

alter table [Nashville Housing]
add OwnerSplitaddress nvarchar(255);

update [Nashville Housing]
set OwnerSplitaddress = PARSENAME(replace(OwnerAddress, ',','.'), 3)

alter table [Nashville Housing]
add OwnerSplitCity nvarchar(255);

update [Nashville Housing]
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',','.'), 2)

alter table [Nashville Housing]
add OwnerSplitState nvarchar(255);

update [Nashville Housing]
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',','.'), 1)

select *
from PortfolioProject.dbo.[Nashville Housing]

--change the Y and N to Yes and No in the column "Sold as vacant"

select distinct(SoldAsVacant), count(SoldAsVacant) --check if all responses are similar and how many they are.
from PortfolioProject.dbo.[Nashville Housing]
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from PortfolioProject.dbo.[Nashville Housing]


update [Nashville Housing]
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

-- Remove duplicates in the table
--create a CTE
-- this part of the query identifies how many duplicates are in the dataset

with RowNumCTE as(
select*,
	ROW_NUMBER() over(
	partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				   UniqueID) row_num
from PortfolioProject.dbo.[Nashville Housing]
)


--this query deletes all the 104 duplicates
delete
from RowNumCTE
where row_num > 1
--order by PropertyAddress

select*
from RowNumCTE
where row_num > 1
order by PropertyAddress

--only the unique remain
select *
from PortfolioProject.dbo.[Nashville Housing]


--delete unused columns

select *
from PortfolioProject.dbo.[Nashville Housing]

alter table PortfolioProject.dbo.[Nashville Housing]
drop column PropertyAddress, SaleDate, OwnerAddress,TaxDistrict


