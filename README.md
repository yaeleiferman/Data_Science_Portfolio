# Data Science Portfolio

Welcome to my data science portfolio - these are projects I did over the course of a full-time in-person Data Science bootcamp I completed.

Of note is my [capstone project](#capstone-startup-analysis), which was entirely self-directed. 

Some projects are not as polished as I would have liked, but still demonstrate my skills despite the intense time constraints.

## Project Overviews

### Big Data Wrangling with Google Books Ngrams

Loaded, filtered, and visualized a large dataset of digitized texts in a cloud-based distributed computing environment using Hadoop, Spark, and Amazon's S3 buckets.

### Capstone Startup Analysis

The goal was to predict the success of any given startup company. The challenge is that finding data on any private company can be difficult, especially a company in the first stages of operations. Therefore, I used a couple novel methods to tackle this problem such as incorporating companies' descriptions and logos to see if they produce more accurate or robust machine learning models.

There were essentially two attempts at solving this problem. For both I used numpy, pandas, and seaborn to clean and explore the data, then used various functions from scikit-learn, such as train test split, GridSearchCV, and scalers to prepare the data for proper modelling. I tried different models like random forests, SVC, and K nearest neighbors to test for the most accurate combination. I also utilized TensorFlow and neural networks in Keras for the same purpose. The scikit-learn metrics of precision score, f1 score, and recall score were used to determine accuracy of different models. 

#### Attempt 1
Sourced data from Kaggle (although I suspect that it was originally from Crunchbase) that contained all sorts of data for about 63,000 companies. Separately sourced data from Data.world that had more limited data for about 42,000 companies, but did contain descriptions which the first dataset did not. My analysis and machine learning work has been done in [this notebook](https://github.com/yaeleiferman/Data_Science_Portfolio/blob/90692a220c006796e72dededc6f8f9bcefee1096/Capstone%20Startup%20Analysis/Attempt%201%20-%20Random%20Data%20from%20the%20Internet/Startup_Analysis.ipynb). This folder also contains presentations I gave to my data science cohort over the course of the bootcamp.

#### Attempt 2
After struggling endlessly to make the previous messy data workable I ended up deciding it was too untrustworthy for the analysis to really mean anything. So for [this](https://github.com/yaeleiferman/Data_Science_Portfolio/blob/90692a220c006796e72dededc6f8f9bcefee1096/Capstone%20Startup%20Analysis/Attempt%202%20-%20Y%20Combinator%20Scrape/YC_Analysis.ipynb) last minute attempt at a coherent project, I scraped Y Combinator’s website to obtain information on all the companies they’ve worked with, and repeated essentially the same analysis on that dataset.  [Here](https://prezi.com/view/LYSUp5QBeuqK2v5Axbae/?referral_token=twKf0dlnB3FN) is the presentation I gave at the bootcamp’s Demo Day which summarizes my journey throughout this project, depicted in prezi as a literal journey.


### NLP with Hotel Reviews

Processed a large dataset of hotel reviews (and other details about the stay) using NLP techniques such as CountVectorizer and tokenizers from scikit-learn in order to prepare the text data for modelling, including logistic regression and a pipeline to combine PCA with a decision tree classifier.

### SQL and Tableau Air Traffic Analysis

Conducted SQL queries and analysis in MySQL Workbench to answer specific business questions about flight and airport data. Then used this same data to create an interactive Tableau presentation to convey actionable insights and allow others to derive new insights in real time. 

### Statistics and Public Health

Used mosquito data from Chicago to compute the probability of finding West Nile Virus at any particular time and location. I cleaned the data and did thorough EDA using numpy, pandas, matplotlib, and seaborn, then conducted a statistical analysis using scipy and statsmodels.
