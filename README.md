# 📺 Amazon Prime Video SQL Analysis

A SQL-based exploratory data analysis project to uncover content trends on Amazon Prime Video, including content types, ratings, age-group distribution, seasonal release patterns, genre popularity, and regional presence.

---

## 📌 Project Objective

To analyze Amazon Prime Video’s content catalog and derive actionable insights for content strategy optimization — helping understand viewer preferences, market focus, and platform growth trends.

---

## 📊 Dataset Overview

- **Source**: Kaggle – https://www.kaggle.com/datasets/shivamb/amazon-prime-movies-and-tv-shows
- **Format**: CSV
- **Size**: ~9,000 titles

### Key Columns:
- `show_id`: Unique ID
- `type`: Movie / TV Show
- `title`, `director`, `cast`
- `country`, `date_added`, `release_year`
- `rating`: TV-MA, PG-13, etc.
- `duration`: e.g., 1h 30min or 2 Seasons
- `listed_in`: Genres
- `description`: Synopsis

---

## 🧹 Data Cleaning (MySQL)

- Replaced empty strings with `NULL`
- Converted `date_added` to `DATE` type
- Extracted `year_added`, `month_added` from date
- Removed formatting inconsistencies

---

## 📈 Analysis & SQL Techniques Used

| Insight Area                     | SQL Techniques                           |
|----------------------------------|------------------------------------------|
| Movies vs TV Shows              | GROUP BY, COUNT                          |
| Rating distribution             | GROUP BY, ORDER BY                       |
| Age Group Segmentation          | CASE WHEN + CTE + RANK                   |
| Seasonal Release Trends         | DATE_FORMAT + GROUP BY month             |
| Content Growth Over Decades     | CASE WHEN (decade bucket)                |
| Genre Popularity                | UNION + LIKE + RANK                      |
| Country-wise Title Count        | UNION + LIKE + Ranking                   |

> 💡 *CTEs, Window Functions (RANK), Aggregate Functions, CASE statements were heavily used.*

---

## 📊 Key Insights

- **Movies dominate** (80%) over TV shows (20%) — suggesting short-form preference.
- **18+ adult content** is most common — targeting mature audiences.
- **Top content release months**: September, June, August — seasonal content drops.
- **Decade growth trend**: Sharp surge in 2010s and 2020s — expansion phase.
- **Top genres**: Drama, Comedy, Action dominate.
- **Top countries**: USA and India lead the catalog — strong regional investments.

---

## 📌 Business Recommendations

- Diversify content for under-served age groups (e.g., kids, young teens).
- Expand content drops during off-peak months for engagement uplift.
- Invest in regional language content — especially in India and APAC.
- Grow niche genres (e.g., Horror, Documentary) to expand audience variety.
- Use recent content data for future genre/format experimentation.

---

## 🛠️ Tools Used

- **Database**: MySQL 8.0
- **Platform**: Local (Windows)
- **Editor**: MySQL Workbench
- **Optional**: Visuals created in PowerPoint

---

## 📂 Folder Structure

