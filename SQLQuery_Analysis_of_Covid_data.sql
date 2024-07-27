SELECT * FROM [Covid Data Analysis Project]..CovidDeaths;

--SELECT * FROM [Covid Data Analysis Project]..CovidVaccinations

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM [Covid Data Analysis Project]..CovidDeaths
order by 1,2;


--  Total cases vs Total Deaths countrywise
select location,total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from [Covid Data Analysis Project]..CovidDeaths
where location like '%ndia'
order by 1,2;

-- Total cases vs Population
	select location,total_cases,population, (total_cases/population)*100 as percentage_infected
	from [Covid Data Analysis Project]..CovidDeaths
	where location like '%state%'
	order by 1,2;

--Looking at countries with hoghest infection rate compared to population
select location,max(total_cases) as highest_infection_count,population, max((total_cases/population)*100) as percentage_infected
from [Covid Data Analysis Project]..CovidDeaths
group by location, population
order by 4 DESC,1,2;

-- countries with highest death count
select location, max(cast(total_deaths as int)) as Highest_Death_count
from [Covid Data Analysis Project]..CovidDeaths
where continent is not null
group by location
order by 2 DESC;

-- Understanding picture by Continent
select location, max(cast(total_deaths as int)) as Highest_Death_count
from [Covid Data Analysis Project]..CovidDeaths
where continent is null
group by location
order by 2 DESC;

-- Understanding death count, new cases and death percentage on basis of date
select date, sum(new_cases) as cases, sum(cast(new_deaths as int)) as deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from [Covid Data Analysis Project]..CovidDeaths
where continent is not NULL
group by date
order by 1;

--Global death count, total cases and death percentage
select sum(new_cases) as cases, sum(cast(new_deaths as int)) as deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from [Covid Data Analysis Project]..CovidDeaths
where continent is not NULL;

select location,date,sum(new_cases) as cases, sum(cast(new_deaths as int)) as deaths,
case when sum(new_cases) = 0 then 0 
else (sum(cast(new_deaths as int))/sum(new_cases))*100 end as death_percentage
from [Covid Data Analysis Project]..CovidDeaths
where continent is not NULL
group by location, date
order by location,date;



--Looking total_vaccinations, population and total_cases for India
select d.location,d.date, d.total_cases, v.total_vaccinations 
from [Covid Data Analysis Project]..CovidDeaths as d
join
[Covid Data Analysis Project]..CovidVaccinations as v
on d.location=v.location and d.date=v.date
where d.continent is not null and d.location like '%india%'
order by v.location,v.date;


--Looking total_vaccinations, population and total_cases globally
select d.continent,d.location,d.date,d.population,d.new_cases ,d.total_cases,v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as cumulative_vaccinations
from [Covid Data Analysis Project]..CovidDeaths as d
join
[Covid Data Analysis Project]..CovidVaccinations as v
on d.location=v.location and d.date=v.date
where d.continent is not null 
order by d.location,d.date


--Looking total_vaccinations, population and total_cases and percentage vaccinated for India
with cte(continent,location,date,population,new_cases,total_cases,new_vaccinations,cumulative_vaccinations)
as
(
select d.continent,d.location,d.date,d.population,d.new_cases ,d.total_cases,v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as cumulative_vaccinations
from [Covid Data Analysis Project]..CovidDeaths as d
join
[Covid Data Analysis Project]..CovidVaccinations as v
on d.location=v.location and d.date=v.date
where d.continent is not null and d.location like '%india%'
)
select *, (cumulative_vaccinations/population)*100 as percentage_vaccinated
from cte



-- TEMP TABLE
create table Percentage_Vaccinated
(continent nvarchar(255) ,location nvarchar(255),date datetime,population numeric,new_cases numeric,total_cases numeric ,new_vaccinations numeric,cumulative_vaccinations numeric)

insert into Percentage_Vaccinated
select d.continent,d.location,d.date,d.population,d.new_cases ,d.total_cases,v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as cumulative_vaccinations
from [Covid Data Analysis Project]..CovidDeaths as d
join
[Covid Data Analysis Project]..CovidVaccinations as v
on d.location=v.location and d.date=v.date
select *, (cumulative_vaccinations/population)*100 as percentage_vaccinated
from Percentage_Vaccinated


-- view for creating visualizations later
create view Percentage_Population_Vaccinated as 
select d.continent,d.location,d.date,d.population,d.new_cases ,d.total_cases,v.new_vaccinations,
sum(convert(int,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as cumulative_vaccinations
from [Covid Data Analysis Project]..CovidDeaths as d
join
[Covid Data Analysis Project]..CovidVaccinations as v
on d.location=v.location and d.date=v.date
where d.continent is not null


select * from Percentage_Population_Vaccinated