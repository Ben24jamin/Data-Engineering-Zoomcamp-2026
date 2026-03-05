"""@bruin
name: ingestion.trips
type: python
image: python:3.11

connection: duckdb-default

materialization:
  type: table
  strategy: append

@bruin"""

"""
NYC Taxi Trip Data Ingestion Asset

This Python asset fetches NYC taxi trip data from the TLC public endpoint.
It uses Bruin's materialization to load data directly into DuckDB.

Data Source: https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page
File Format: Parquet files, one per taxi type per month
URL Pattern: https://d37ci6vzurychx.cloudfront.net/trip-data/<taxi_type>_tripdata_<year>-<month>.parquet
"""

import os
import json
import pandas as pd
import requests
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta
from io import BytesIO
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def generate_month_urls(taxi_type, start_date, end_date):
    """
    Generate URLs for each month between start_date and end_date.
    
    Args:
        taxi_type: Type of taxi (yellow, green, etc.)
        start_date: Start date string in YYYY-MM-DD format
        end_date: End date string in YYYY-MM-DD format
    
    Returns:
        List of URLs to fetch
    """
    start = datetime.strptime(start_date, "%Y-%m-%d")
    end = datetime.strptime(end_date, "%Y-%m-%d")
    
    urls = []
    current = start.replace(day=1)  # Start from first day of month
    
    while current <= end:
        # Format: yellow_tripdata_2022-01.parquet
        filename = f"{taxi_type}_tripdata_{current.year}-{current.month:02d}.parquet"
        url = f"https://d37ci6vzurychx.cloudfront.net/trip-data/{filename}"
        urls.append(url)
        
        # Move to next month
        current += relativedelta(months=1)
    
    return urls


def fetch_parquet_from_url(url):
    """
    Fetch a parquet file from URL and return as DataFrame.
    
    Args:
        url: URL to fetch
    
    Returns:
        DataFrame with the data, or None if fetch fails
    """
    try:
        logger.info(f"Fetching: {url}")
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        
        # Read parquet from response content
        df = pd.read_parquet(BytesIO(response.content))
        logger.info(f"Successfully fetched {len(df)} rows from {url}")
        return df
    
    except requests.exceptions.RequestException as e:
        logger.error(f"Error fetching {url}: {e}")
        return None
    except Exception as e:
        logger.error(f"Error processing parquet from {url}: {e}")
        return None


def materialize():
    """
    Main materialization function for Bruin.
    
    Uses environment variables:
    - BRUIN_START_DATE: Start date for ingestion (YYYY-MM-DD)
    - BRUIN_END_DATE: End date for ingestion (YYYY-MM-DD)
    - BRUIN_VARS: JSON string with pipeline variables (e.g., taxi_types)
    """
    
    # Get date range from Bruin environment variables
    start_date = os.environ.get("BRUIN_START_DATE")
    end_date = os.environ.get("BRUIN_END_DATE")
    
    if not start_date or not end_date:
        raise ValueError("BRUIN_START_DATE and BRUIN_END_DATE must be set")
    
    logger.info(f"Running ingestion for date range: {start_date} to {end_date}")
    
    # Get taxi_types from pipeline variables
    bruin_vars = os.environ.get("BRUIN_VARS", "{}")
    try:
        vars_dict = json.loads(bruin_vars)
        taxi_types = vars_dict.get("taxi_types", ["yellow"])  # Default to yellow if not specified
        logger.info(f"Taxi types to ingest: {taxi_types}")
    except json.JSONDecodeError:
        logger.warning("Could not parse BRUIN_VARS, using default taxi_types=['yellow']")
        taxi_types = ["yellow"]
    
    all_dfs = []
    
    # Fetch data for each taxi type
    for taxi_type in taxi_types:
        # Generate URLs for each month in the range
        urls = generate_month_urls(taxi_type, start_date, end_date)
        logger.info(f"Generated {len(urls)} URLs for taxi type '{taxi_type}'")
        
        # Fetch each URL
        for url in urls:
            df = fetch_parquet_from_url(url)
            if df is not None and not df.empty:
                # Add metadata columns for lineage
                df['taxi_type'] = taxi_type
                df['source_file'] = url.split('/')[-1]
                df['extracted_at'] = datetime.now().isoformat()
                
                all_dfs.append(df)
    
    # Combine all dataframes
    if not all_dfs:
        logger.warning("No data fetched for the given parameters")
        # Return empty DataFrame with expected columns to avoid breaking downstream assets
        return pd.DataFrame()
    
    final_df = pd.concat(all_dfs, ignore_index=True, sort=False)
    logger.info(f"Total rows ingested: {len(final_df)}")
    
    # Log some basic statistics
    if not final_df.empty:
        logger.info(f"Columns in final dataset: {list(final_df.columns)}")
        logger.info(f"Date range in data: {final_df['tpep_pickup_datetime'].min()} to {final_df['tpep_pickup_datetime'].max()}")
    
    return final_df







