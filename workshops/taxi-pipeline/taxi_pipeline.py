"""Template for building a `dlt` pipeline to ingest data from a REST API."""
import dlt
from dlt.sources.rest_api import rest_api_source


# if no argument is provided, `access_token` is read from `.dlt/secrets.toml`
def taxi_source():
    """DLT source for the NYC taxi trip API."""
    return rest_api_source({
        "client": {
            "base_url": "https://us-central1-dlthub-analytics.cloudfunctions.net/data_engineering_zoomcamp_api",

        },
        "resources": [
            {
                "name": "trips",
                "endpoint": {
                    # the endpoint returns a plain list of trip records
                    "path": "trips",
                    # pagination is controlled by a `page` query parameter
                    "paginator": {
                        "type": "page_number",
                        # start at page 1 since the API returns an empty list for page=0
                        "base_page": 1,
                        # the endpoint returns a plain list (no total count),
                        # so disable the default total_path lookup
                        "total_path": None,
                    },
                },
            }
        ],
    })

if __name__ == "__main__":
    pipeline = dlt.pipeline(
    pipeline_name="taxi_pipeline",
    destination="duckdb",
    dataset_name="taxi_data",
    progress="log",
)


    load_info = pipeline.run(taxi_source())
    print(load_info)
