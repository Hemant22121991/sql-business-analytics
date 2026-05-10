# Database Schema — Maven Fuzzy Factory

## About This Database
Custom ecommerce database built for the Udemy course:
**"Advanced SQL: MySQL for Ecommerce Data Analysis"** by John Pauler

## How to Set Up Locally
1. Log in to your Udemy account
2. Go to the course → Resources section
3. Download the setup script
4. Open MySQL Workbench
5. Run the downloaded script
6. Database is ready to query

## Tables
| Table | Description |
|---|---|
| website_sessions | All user sessions with UTM source tracking |
| orders | Completed transactions |
| order_items | Line items per order |
| website_pageviews | Page-level traffic data |
| products | Product catalogue |
| order_item_refunds | Refund records |

## Note on File Size
The full setup script with data rows is 109MB — too large
for GitHub's 100MB limit. Only the schema structure and
this reference guide are stored here.
Raw data is available via the Udemy course resources.
