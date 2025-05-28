# Layoffs SQL Data Cleaning and Analysis

This project focuses on end-to-end data preparation and exploratory analysis of a real-world tech layoffs dataset using SQL. It includes two main stages:

1. **Data Cleaning** – Preparing the raw dataset for analysis by handling duplicates, formatting inconsistencies, null values, and more.
2. **Exploratory Data Analysis (EDA)** – Extracting key insights on layoffs trends across years, companies, industries, countries, and funding status.

---

## 🧠 About the Dataset

**Source:** Collected from platforms like Bloomberg, TechCrunch, NYTimes, and others.  
**Date Range:** From the declaration of COVID-19 as a pandemic (March 11, 2020) to April 21, 2025.  
**Focus:** The dataset tracks tech layoffs as companies respond to economic slowdowns, interest rate changes, and reduced consumer spending.

Examples of major layoff events include:

- Meta laying off 13% of its workforce (11,000+ employees)
- Similar actions across major tech firms like Amazon, Google, and Salesforce

This dataset is well-suited for analyzing the impact of global crises on the tech sector workforce.

---

## 📂 Files Included

| File                             | Description                                                                                                                                                                            |
| -------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `data_cleaning_layoffs.sql`      | SQL scripts for cleaning and preparing the layoff dataset. Tasks include removing duplicates, standardizing text fields, fixing date formats, handling nulls, and cleaning categories. |
| `exploratory _data_analysis.sql` | SQL queries for exploring the dataset. Includes aggregations by year, company, country, industry, and stage; rolling monthly totals; and identifying top companies by layoffs.         |

---

## 🧰 Tools & Techniques

- SQL (MySQL syntax)
- Window functions and CTEs
- Data type conversions
- Text normalization and trimming
- Aggregation and ranking functions
- Rolling sums and yearly breakdowns

---

## 🔍 Sample Insights Discovered

- 2020 saw the highest layoffs due to the onset of the pandemic
- U.S. companies were the most affected overall
- Consumer and retail sectors led the layoff counts
- Some companies laid off 100% of their staff despite raising millions in funding
- Layoff activity peaked again in 2022

---

## 🎯 Goal

To demonstrate how SQL can be used not only for basic querying, but also for real-world data wrangling and insights generation in a professional data analyst workflow.

---
