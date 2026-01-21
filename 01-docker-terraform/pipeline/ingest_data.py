import click
import pandas as pd
import pyarrow.parquet as pq
from sqlalchemy import create_engine
from tqdm.auto import tqdm
import time

@click.command()
@click.option('--pg-user', default='postgres', help='PostgreSQL user')
@click.option('--pg-pass', default='postgres', help='PostgreSQL password')
@click.option('--pg-host', default='postgres', help='PostgreSQL host')
@click.option('--pg-port', default=5432, type=int, help='PostgreSQL port')
@click.option('--pg-db', default='ny_taxi', help='PostgreSQL database name')
@click.option('--year', default=2025, type=int, help='Year of the data')
@click.option('--month', default=11, type=int, help='Month of the data')
@click.option('--target-table', default='green_taxi_data', help='Target table name')
@click.option('--chunksize', default=100000, type=int, help='Chunk size for insertion')
@click.option('--zones-url', default='https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv', 
              help='URL for taxi zones CSV')
def run(pg_user, pg_pass, pg_host, pg_port, pg_db, year, month, target_table, chunksize, zones_url):
    """Ingest NYC taxi data from Parquet into PostgreSQL database."""

# Create database engine
    engine = create_engine(f'postgresql://{pg_user}:{pg_pass}@{pg_host}:{pg_port}/{pg_db}')

# Ingest taxi zones data 
    click.echo("Ingesting taxi zones data...")
    try:
        zones_df = pd.read_csv(zones_url)
        zones_df.to_sql(
            name='taxi_lookup_zones',
            con=engine,
            if_exists='replace',
            index=False
        )
        click.echo(f"Succesfuly Ingested {len(zones_df)} rows to taxi_lookup_zones table")
    except Exception as e:
        click.echo(f"Failed to ingest taxi zones: {e}")
        return
     
# Construct URL for parquet file
    prefix = 'https://d37ci6vzurychx.cloudfront.net/trip-data'
    url = f'{prefix}/green_tripdata_{year}-{month:02d}.parquet'
    
    click.echo(f"Reading taxi_data from: {url}")
# Read parquet file directly from URL using pyarrow
    try:
        click.echo("Opening parquet file...")
        parquet_file = pq.ParquetFile(url)
        num_row_groups = parquet_file.num_row_groups
        
        click.echo(f"✓ File loaded: {num_row_groups} row groups")
        
    except Exception as e:
        click.echo(f"Failed to read parquet file directly from url: {e}")
        click.echo("Trying to load to pandas then ingest...")
        
# Fallback load parquet file first: Use pandas with storage_options
        try:
            df = pd.read_parquet(url, storage_options={'anon': True})
            num_row_groups = 1  # Treat as single chunk
            
# We'll handle this differently below
            parquet_file = None
        except Exception as e2:
            click.echo(f" Both parquet ingesting methods FAILED : {e2}")
            return
    
    first = True
    total_rows_inserted = 0
    start_time = time.time()
    
    if parquet_file:
# Process row groups from pyarrow
        with tqdm(total=num_row_groups, 
                  desc=f"Inserting to {target_table}", 
                  unit="row_group") as pbar:
            
            for i in range(num_row_groups):
                table = parquet_file.read_row_group(i)
                df_chunk = table.to_pandas()
                process_chunk(df_chunk, engine, target_table, first)
                first = False
                total_rows_inserted += len(df_chunk)
                pbar.update(1)
                pbar.set_postfix({"rows": f"{total_rows_inserted:,}"})
    else:
# Process entire DataFrame in chunks
        total_rows = len(df)
        num_chunks = (total_rows + chunksize - 1) // chunksize
        
        click.echo(f"Processing {total_rows:,} rows in {num_chunks} chunks...")
        
# Create table first
        df.head(0).to_sql(
            name=target_table,
            con=engine,
            if_exists='replace',
            index=False
        )
        first = False
        
# Insert in chunks
        for start in tqdm(range(0, total_rows, chunksize), 
                          desc="Inserting chunks", 
                          unit="chunk"):
            end = min(start + chunksize, total_rows)
            df_chunk = df.iloc[start:end]
            process_chunk(df_chunk, engine, target_table, False)  # first=False
            total_rows_inserted += len(df_chunk)
    
    total_time = time.time() - start_time
    click.echo(f"\n SUCCESS inserted {total_rows_inserted:,} rows in {total_time:.1f} seconds")

def process_chunk(df_chunk, engine, target_table, first):
    """Process a single chunk of data."""
    
# Convert dtypes
    dtypes_to_change = {
        "RatecodeID": "Int64",
        "store_and_fwd_flag": "string", 
        "PULocationID": "Int64",
        "DOLocationID": "Int64",
        "payment_type": "Int64"
    }
    
    for col, dtype in dtypes_to_change.items():
        if col in df_chunk.columns:
            df_chunk[col] = df_chunk[col].astype(dtype)
    
# Create table if first chunk, otherwise append
    df_chunk.to_sql(
        name=target_table,
        con=engine,
        if_exists='replace' if first else 'append',
        index=False
    )

if __name__ == '__main__':
    run()