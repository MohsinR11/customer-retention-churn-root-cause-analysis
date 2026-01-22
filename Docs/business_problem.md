Business Context:
The company operates an e-commerce business with steady customer acquisition but slowing revenue growth. While new customers continue to place first-time orders, repeat purchases have declined over time.

Problem Statement:
Leadership suspects that customer churn is increasing, but does not clearly understand which customer behaviors, experiences, or operational issues are driving customers to stop purchasing.

Objective:
To identify the root causes of customer churn using transactional and customer support data, quantify the revenue at risk, and recommend prioritized, data-backed actions to improve customer retention and lifetime value.

Business Questions:
1. Which customer segments churn the most?
2. What behavioral signals appear before churn?
3. How do customer support issues influence churn?
4. Which churn drivers are controllable by the business?
5. What actions will deliver the highest retention impact?


Churn Definition:
A customer is classified as churned if they have not made any purchase in the last 90 days from the most recent transaction date available in the dataset.

Rationale:
In retail and e-commerce analytics, a 90-day inactivity window is commonly used to identify disengaged customers while avoiding premature churn classification.


Success Criteria:
The project will be considered successful if it:
- Identifies the top 3 behavioral or operational drivers of churn
- Quantifies total revenue at risk due to churn
- Recommends at least 3 actionable retention interventions
- Estimates the potential revenue or retention lift from each intervention


Data Limitation Note:
The customer support dataset contains a single support record per customer. As a result, support interactions are modeled as presence and quality signals rather than frequency-based measures. This reflects common real-world data extraction limitations and is explicitly accounted for in the analysis.


Customer Identity Assumption:
Customer Email is used as the primary linking key between transactional and customer support datasets. It is assumed that each email uniquely represents a single customer across systems.


Support Data Limitation:
Customer-level joins between transactional and support systems were not possible due to the absence of a shared customer identifier. As a result, support experience impact is analyzed at a population level rather than per-customer level. This reflects a common early-stage startup data limitation and is explicitly acknowledged in the analysis.
