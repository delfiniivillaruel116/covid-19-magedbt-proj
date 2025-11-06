# 🛠️ Setup Instructions for Mage.ai with Docker, WSL, Python, dbt, and DuckDB

1. **Install Docker Desktop**  
   - Download from: [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)  
   - Ensure WSL 2 is enabled during setup.

2. **Install Ubuntu 24.04 via Microsoft Store**  
   - Open Microsoft Store  
   - Search for "Ubuntu 24.04"  
   - Click Install

3. **Configure Windows for WSL**  
   a. Open PowerShell as Administrator  
   - Press `Windows + X` → Select "Windows Terminal (Admin)"

   b. Enable WSL via Windows Features GUI  
   - Press `Windows + S` → Type "Windows Features"  
   - Click "Turn Windows features on or off"  
   - Enable:  
     ✅ Windows Subsystem for Linux  
     ✅ Virtual Machine Platform  
   - Click OK and restart if prompted

   c. Run WSL Install Command  
   ```bash
   wsl --install
   ```

   d. Verify WSL Installation  
   ```bash
   wsl --list --verbose
   ```

4. **Install Python in WSL**  
   a. Open WSL Terminal  
   ```bash
   wsl
   ```

   b. Install Python  
   ```bash
   sudo apt update
   sudo apt install python3 python3-pip
   ```

   c. Verify Installation  
   ```bash
   python3 --version
   pip3 --version
   ```

5. **Install Mage.ai in WSL**  
   ```bash
   pip3 install mage-ai
   mage start my_project
   ```

6. **(Optional) Create a Virtual Environment**  
   ```bash
   # Windows
   python -m venv mage-env
   mage-env\Scriptsctivate

   # WSL/Linux
   python3 -m venv mage-env
   source mage-env/bin/activate
   ```

7. **Connect Mage.ai to Docker**  
   a. Pull Mage.ai Docker Image  
   ```bash
   docker pull mageai/mageai
   ```

   b. Run Mage.ai in Docker  
   ```bash
   docker run -it -p 6789:6789 -v C:\Users\YourUsername\mage_project:/home/src mageai/mageai mage start mage_project
   ```

   c. Check Docker Desktop  
   - Confirm the container is running

   d. Access Mage.ai in Browser  
   - Open: [http://localhost:6789](http://localhost:6789)

8. **Install dbt and DuckDB**  
   a. Open PowerShell or WSL Terminal  
   b. Install packages  
   ```bash
   pip install dbt-duckdb duckdb
   ```

   c. Verify Installation  
   ```bash
   dbt --version
   python -c "import duckdb; print(duckdb.query('SELECT 42').fetchall())"
   ```

9. **Extend Mage Docker Image to Include dbt and DuckDB**  
   a. Create a Dockerfile  
   ```Dockerfile
   FROM mageai/mageai:latest
   RUN pip install dbt-duckdb duckdb
   ```

   b. Build Docker Image  
   ```bash
   docker build -t mageai-with-dbt .
   ```

   c. Run Extended Image  
   ```bash
   docker run -it -p 6789:6789 -v C:\Path\To\Your\Project:/home/src mageai-with-dbt mage start .
   ```

10. **Connect dbt to DuckDB**  
   a. Create `profiles.yml` in your dbt folder  
   ```yaml
   duckdb:
     target: dev
     outputs:
       dev:
         type: duckdb
         path: /home/src/db/my_duckdb.db
   ```

   - Place in:  
     `%USERPROFILE%\.dbt\profiles.yml` (Windows)  
     `~/.dbt/profiles.yml` (WSL/Linux)

11. **Run Your Pipeline**  
   ```bash
   mage start .
   ```
   - Open: [http://localhost:6789](http://localhost:6789)  
   - Trigger pipeline from Mage UI or CLI




## 📊 Analysis

### 🔍 Top 5 Most Common Values in a Column
I developed queries to analyze different case types at varying frequencies, focusing on a one-week timeframe. These queries identify the top five provinces in Mainland China based on case counts since the onset of COVID-19, with particular emphasis on Hubei, the initial epicenter of the outbreak.

#### Confirmed Cases
```sql
SELECT state_country, SUM(case_count) AS sum_case_count, COUNT(*) AS frequency
FROM covid19.main.covid_fact_tbl
WHERE update_date BETWEEN DATE '2020-01-21' AND DATE '2020-01-28'
  AND country = 'Mainland China'
  AND case_type = 'confirmed_case'
  AND case_count <> 0
GROUP BY state_country
ORDER BY 2 DESC
LIMIT 5;
```

#### Suspected Cases
```sql
SELECT state_country, SUM(case_count) AS sum_case_count, COUNT(*) AS frequency
FROM covid19.main.covid_fact_tbl
WHERE update_date BETWEEN DATE '2020-01-21' AND DATE '2020-01-28'
  AND country = 'Mainland China'
  AND case_type = 'suspected_case'
  AND case_count <> 0
GROUP BY state_country
ORDER BY 2 DESC
LIMIT 5;
```

#### Deaths
```sql
SELECT state_country, SUM(case_count) AS sum_case_count, COUNT(*) AS frequency
FROM covid19.main.covid_fact_tbl
WHERE update_date BETWEEN DATE '2020-01-21' AND DATE '2020-01-28'
  AND country = 'Mainland China'
  AND case_type = 'deaths_case'
  AND case_count <> 0
GROUP BY state_country
ORDER BY 2 DESC
LIMIT 5;
```

#### Recovered Cases
```sql
SELECT state_country, SUM(case_count) AS sum_case_count, COUNT(*) AS frequency
FROM covid19.main.covid_fact_tbl
WHERE update_date BETWEEN DATE '2020-01-21' AND DATE '2020-01-28'
  AND country = 'Mainland China'
  AND case_type = 'recovered_case'
  AND case_count <> 0
GROUP BY state_country
ORDER BY 2 DESC
LIMIT 5;
```

---

### 📈 Metric Change Over Time
This query answers the question by producing a daily trend of confirmed cases, showing how the metric evolves over time. In layman’s terms, it tells us: “For each day in the given period, how many confirmed COVID-19 cases were reported in Mainland China?” This approach provides a clear picture of the outbreak’s progression and helps identify patterns such as spikes or steady increases.

#### Confirmed Cases Over Time
```sql
SELECT 
    update_date::DATE AS date,
    SUM(case_count) AS total_confirmed_cases
FROM covid19.main.covid_fact_tbl
WHERE case_type = 'confirmed_case'
  AND country = 'Mainland China'
  AND update_date BETWEEN DATE '2020-01-21' AND DATE '2020-02-14'
GROUP BY date
ORDER BY date;
```

#### Recovered Cases Over Time
```sql
SELECT 
    update_date::DATE AS date,
    SUM(case_count) AS total_confirmed_cases
FROM covid19.main.covid_fact_tbl
WHERE case_type = 'recovered_case'
  AND country = 'Mainland China'
  AND update_date BETWEEN DATE '2020-01-21' AND DATE '2020-02-14'
GROUP BY date
ORDER BY date;
```

#### Deaths Over Time
```sql
SELECT 
    update_date::DATE AS date,
    SUM(case_count) AS total_confirmed_cases
FROM covid19.main.covid_fact_tbl
WHERE case_type = 'deaths_case'
  AND country = 'Mainland China'
  AND update_date BETWEEN DATE '2020-01-21' AND DATE '2020-02-14'
GROUP BY date
ORDER BY date;
```

---

### 📊 Correlation Between Metrics
The analysis shows a very strong positive correlation between confirmed cases and deaths in Mainland China during the period from January 21 to February 14, 2020.

- **Pearson correlation coefficient**: 0.9953  
- **p-value**: < 0.0001

A correlation of 0.9953 is extremely close to 1, indicating that as the number of confirmed cases increases, the number of deaths also rises almost proportionally. The very low p-value confirms that this relationship is statistically significant and not due to random chance.

#### Interpretation
This makes sense in the context of an outbreak: more confirmed infections generally lead to more fatalities, especially in the early stages when treatment protocols are still evolving. However, correlation does not imply causation—other factors like healthcare capacity and reporting practices also play a role.

#### Correlation Query
```sql
WITH daily_cases AS (
    SELECT 
        update_date::DATE AS date,
        SUM(CASE WHEN case_type = 'confirmed_case' THEN case_count ELSE 0 END) AS confirmed_cases,
        SUM(CASE WHEN case_type = 'deaths_case' THEN case_count ELSE 0 END) AS deaths_cases
    FROM covid19.main.covid_fact_tbl
    WHERE country = 'Mainland China'
      AND update_date BETWEEN DATE '2020-01-21' AND DATE '2020-02-14'
    GROUP BY date
)
SELECT 
    CORR(confirmed_cases, deaths_cases) AS correlation
FROM daily_cases;
```



## 📊 Analysis

### 🔍 Top 5 Most Common Values in a Column
I developed queries to analyze different case types at varying frequencies, focusing on a one-week timeframe. These queries identify the top five provinces in Mainland China based on case counts since the onset of COVID-19, with particular emphasis on Hubei, the initial epicenter of the outbreak.

#### Confirmed Cases
```sql
SELECT state_country, SUM(case_count) AS sum_case_count, COUNT(*) AS frequency
FROM covid19.main.covid_fact_tbl
WHERE update_date BETWEEN DATE '2020-01-21' AND DATE '2020-01-28'
  AND country = 'Mainland China'
  AND case_type = 'confirmed_case'
  AND case_count <> 0
GROUP BY state_country
ORDER BY 2 DESC
LIMIT 5;
```

#### Suspected Cases
```sql
SELECT state_country, SUM(case_count) AS sum_case_count, COUNT(*) AS frequency
FROM covid19.main.covid_fact_tbl
WHERE update_date BETWEEN DATE '2020-01-21' AND DATE '2020-01-28'
  AND country = 'Mainland China'
  AND case_type = 'suspected_case'
  AND case_count <> 0
GROUP BY state_country
ORDER BY 2 DESC
LIMIT 5;
```

#### Deaths
```sql
SELECT state_country, SUM(case_count) AS sum_case_count, COUNT(*) AS frequency
FROM covid19.main.covid_fact_tbl
WHERE update_date BETWEEN DATE '2020-01-21' AND DATE '2020-01-28'
  AND country = 'Mainland China'
  AND case_type = 'deaths_case'
  AND case_count <> 0
GROUP BY state_country
ORDER BY 2 DESC
LIMIT 5;
```

#### Recovered Cases
```sql
SELECT state_country, SUM(case_count) AS sum_case_count, COUNT(*) AS frequency
FROM covid19.main.covid_fact_tbl
WHERE update_date BETWEEN DATE '2020-01-21' AND DATE '2020-01-28'
  AND country = 'Mainland China'
  AND case_type = 'recovered_case'
  AND case_count <> 0
GROUP BY state_country
ORDER BY 2 DESC
LIMIT 5;
```

---

### 📈 Metric Change Over Time
This query answers the question by producing a daily trend of confirmed cases, showing how the metric evolves over time. In layman’s terms, it tells us: “For each day in the given period, how many confirmed COVID-19 cases were reported in Mainland China?” This approach provides a clear picture of the outbreak’s progression and helps identify patterns such as spikes or steady increases.

#### Confirmed Cases Over Time
```sql
SELECT 
    update_date::DATE AS date,
    SUM(case_count) AS total_confirmed_cases
FROM covid19.main.covid_fact_tbl
WHERE case_type = 'confirmed_case'
  AND country = 'Mainland China'
  AND update_date BETWEEN DATE '2020-01-21' AND DATE '2020-02-14'
GROUP BY date
ORDER BY date;
```

#### Recovered Cases Over Time
```sql
SELECT 
    update_date::DATE AS date,
    SUM(case_count) AS total_confirmed_cases
FROM covid19.main.covid_fact_tbl
WHERE case_type = 'recovered_case'
  AND country = 'Mainland China'
  AND update_date BETWEEN DATE '2020-01-21' AND DATE '2020-02-14'
GROUP BY date
ORDER BY date;
```

#### Deaths Over Time
```sql
SELECT 
    update_date::DATE AS date,
    SUM(case_count) AS total_confirmed_cases
FROM covid19.main.covid_fact_tbl
WHERE case_type = 'deaths_case'
  AND country = 'Mainland China'
  AND update_date BETWEEN DATE '2020-01-21' AND DATE '2020-02-14'
GROUP BY date
ORDER BY date;
```

---

### 📊 Correlation Between Metrics
The analysis shows a very strong positive correlation between confirmed cases and deaths in Mainland China during the period from January 21 to February 14, 2020.

- **Pearson correlation coefficient**: 0.9953  
- **p-value**: < 0.0001

A correlation of 0.9953 is extremely close to 1, indicating that as the number of confirmed cases increases, the number of deaths also rises almost proportionally. The very low p-value confirms that this relationship is statistically significant and not due to random chance.

#### Interpretation
This makes sense in the context of an outbreak: more confirmed infections generally lead to more fatalities, especially in the early stages when treatment protocols are still evolving. However, correlation does not imply causation—other factors like healthcare capacity and reporting practices also play a role.

#### Correlation Query
```sql
WITH daily_cases AS (
    SELECT 
        update_date::DATE AS date,
        SUM(CASE WHEN case_type = 'confirmed_case' THEN case_count ELSE 0 END) AS confirmed_cases,
        SUM(CASE WHEN case_type = 'deaths_case' THEN case_count ELSE 0 END) AS deaths_cases
    FROM covid19.main.covid_fact_tbl
    WHERE country = 'Mainland China'
      AND update_date BETWEEN DATE '2020-01-21' AND DATE '2020-02-14'
    GROUP BY date
)
SELECT 
    CORR(confirmed_cases, deaths_cases) AS correlation
FROM daily_cases;
```


## 🧪 B. Design Decisions and Technologies Used

### 🛠️ Technologies

1. **Docker Desktop**  
   Utilized for building, running, and managing containers locally. It provides an isolated environment for running Mage.ai and associated services.

2. **DuckDB**  
   Chosen as the analytical database for storing COVID-19 sample data. DuckDB is lightweight, easy to integrate, and ideal for small to medium-sized projects with local storage.

3. **Mage.ai**  
   Employed as the orchestration tool for managing the data pipeline. Mage.ai simplifies integration with databases and supports data loading, transformation, and exporting.

4. **dbt (Data Build Tool)**  
   Used as the primary ETL/ELT framework for transforming data, performing type conversions, joining tables, and creating the final fact table. dbt enables modular, version-controlled, and testable transformations.

### 📐 Design Specification / Approach (High-Level)

1. **Data Source Acquisition**  
   The pipeline begins by downloading daily COVID-19 case data in CSV format from the [CSSEGISandData GitHub repository](https://github.com/CSSEGISandData/COVID-19/tree/master/archived_data/archived_daily_case_updates), covering the period from January 1, 2020 to February 14, 2020.

2. **Raw Data Consolidation**  
   All CSV files are stored in a local folder named `Datasource`. These files are then consolidated and loaded into a staging table without any initial transformation.

3. **Data Loading with Mage.ai**  
   A Python-based Data Loader block reads the consolidated CSV files into a DataFrame.

4. **Staging Table Export**  
   The Data Export block saves the DataFrame to a DuckDB database as a staging table. This table is refreshed with each new data load—existing data is deleted and replaced with the latest dataset.

5. **Data Transformation with dbt**  
   A dbt block within Mage.ai performs data cleansing and transformation. This includes standardizing date formats and handling inconsistent data entries. An incremental strategy is used to append only new records to the historical table.

6. **Final Table Creation**  
   The final dbt block organizes and deduplicates the transformed data, ensuring the output table is clean, reliable, and ready for downstream analytics and reporting.