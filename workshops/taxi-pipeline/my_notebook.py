import marimo

__generated_with = "0.20.2"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo
    from dlt.helpers.marimo import render, load_package_viewer, pipeline_selector

    return load_package_viewer, mo, pipeline_selector, render


@app.cell
async def _(pipeline_selector, render):
    await render(pipeline_selector)
    return


@app.cell
async def _(load_package_viewer, render):
    await render(load_package_viewer, pipeline_path="./")
    return


@app.cell
def _():
    import dlt
    pipeline = dlt.attach(pipeline_name="taxi_pipeline")
    dataset = pipeline.dataset()
    df = dataset["trips"].df()
    df.head()
    return (df,)


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    Question 1: What is the start date and end date of the dataset?
    + 2009-01-01 to 2009-01-31
    + 2009-06-01 to 2009-07-01
    + 2024-01-01 to 2024-02-01
    + 2024-06-01 to 2024-07-01
    """)
    return


@app.cell
def _(df):
    pickup_date_max = df.trip_pickup_date_time.max()
    pickup_date_min = df.trip_pickup_date_time.min()
    dropoff_date_max = df.trip_dropoff_date_time.max()
    dropoff_date_min = df.trip_dropoff_date_time.min()
    max_date = pickup_date_max if pickup_date_max > dropoff_date_max else dropoff_date_max
    min_date = pickup_date_min if pickup_date_min < dropoff_date_min else dropoff_date_min
    print(min_date, max_date)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    Question 2: What proportion of trips are paid with credit card?
    + 16.66%
    + 26.66%
    + 36.66%
    + 46.66%
    """)
    return


@app.cell
def _(df):
    len(df[df.payment_type == "Credit"]) * 100 / len(df)
    return


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    Question 3: What is the total amount of money generated in tips?
    + $4,063.41
    + $6,063.41
    + $8,063.41
    + $10,063.41
    """)
    return


@app.cell
def _(df):
    df.tip_amt.sum()
    return


@app.cell
def _(df):
    (df["total_amt"] - df["fare_amt"] - df["tolls_amt"] - df["surcharge"]).sum()
    return


if __name__ == "__main__":
    app.run()
