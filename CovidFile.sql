select * 
FROM covidDeath
WHERE continent is not NULL
order by 3,4

--select * 
--FROM covidVaccanation
--order by 3,4

select location,date,total_cases,new_cases, total_deaths,population
FROM covidDeath
ORDER BY 1,2


--looking at total cases vs total deaths\
-- Shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM covidDeath
WHERE location like '%bangla%'
ORDER BY 1,2

--Looking at total cases vs population

select location,date,total_cases,population, (total_cases/population)*100 as casePercentage
FROM covidDeath
--WHERE location = 'Bangladesh'
ORDER BY 1,2

--looing at countries with higher infection ratr compare to population

select location,population,MAX (total_cases) as HighestInfectinCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM covidDeath
--WHERE location = 'Bangladesh'
GROUP BY location,population
ORDER BY PercentagePopulationInfected desc


--This is showing Contries with highest death count per Population

select location,MAX (cast (total_deaths as int)) as TotalDeathCount
FROM covidDeath
--WHERE location = 'Bangladesh'
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount desc


--LETS BREAK THINGS DOWN BY CONTINENT
--Sowing continents with the highest death count per population

select continent,MAX (cast (total_deaths as int)) as TotalDeathCount
FROM covidDeath
--WHERE location = 'Bangladesh'
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global numbers

Select date,SUM(new_cases) as totalCases, SUM(cast(new_deaths as int)) as TotalDeath, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM covidDeath
WHERE continent is not null
Group BY date
ORDER BY 1 





--Looking at total Polpulation vs vaccination
--USSE CTE

with PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as(
Select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,SUM(cast(vac.new_vaccinations as BIGINT)) 
OVER (Partition By dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated

FROM [Portfolio Database]..covidDeath dea
JOIN [Portfolio Database]..covidVaccanation vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3
)

select *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac


--Creare View for later

Create View percentagePopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,SUM(cast(vac.new_vaccinations as BIGINT)) 
OVER (Partition By dea.location Order by dea.location,dea.date) 
as RollingPeopleVaccinated

FROM [Portfolio Database]..covidDeath dea
JOIN [Portfolio Database]..covidVaccanation vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 


Select *
FROM percentagePopulationVaccinated