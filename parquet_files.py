import pandas as pd
import numpy as np
import os

'''
df = pd.read_csv("Parquet/sales_report+(1).csv")
df.to_parquet(
    "sales_report.parquet",
    engine="pyarrow",
    index=False
)
print("Sales dataset saved as Parquet")
'''

'''
data = pd.read_parquet("sales_report.parquet", engine="pyarrow")
print("Dataset loaded from Parquet")
print(data.head(30))

df_small = pd.read_parquet(
    "sales_report.parquet",
    columns=["OrderID", "SalesAmount"]
)
print(df_small.head(10))
'''


'''
data = {
    "OrderId": range(1, 101),
    "Product": np.random.choice(["Laptop", "Phone", "Tablet", "Monitor"], 100),
    "Category": np.random.choice(["Electronics", "Accessories"], 100),
    "Quantity": np.random.randint(1, 10, 100),
    "Price": np.random.randint(200, 2000, 100),
    "Region": np.random.choice(["North", "South", "East", "West"], 100),
    "Salesperson": np.random.choice(["Alice", "Bob", "Noah", "Diana"], 100)
}
df_new = pd.DataFrame(data)
df_new["SalesAmount"] = df_new["Quantity"] * df_new["Price"]
df_new.to_parquet("sales_report2.parquet", engine="pyarrow", index=False)
print("New Parquet dataset created.")
'''

'''
df_check = pd.read_parquet("sales_report2.parquet")
print(df_check.tail(10))
'''

'''
df_old = pd.read_parquet("sales_report2.parquet")
new_data = {
    "OrderId": range(df_old["OrderId"].max() + 1, df_old["OrderId"].max() + 11),
    "Product": np.random.choice(["Laptop", "Phone", "Tablet", "Monitor"], 10),
    "Category": np.random.choice(["Electronics", "Accessories"], 10),
    "Quantity": np.random.randint(1, 10, 10),
    "Price": np.random.randint(200, 2000, 10),
    "Region": np.random.choice(["North", "South", "East", "West"], 10),
    "Salesperson": np.random.choice(["Alice", "Bob", "Noah", "Diana"], 10)
}
df_append = pd.DataFrame(new_data)
df_append["SalesAmount"] = df_append["Quantity"] * df_append["Price"]
df_combined = pd.concat([df_old, df_append], ignore_index=True)
df_combined.to_parquet("sales_report2.parquet", engine="pyarrow", index=False)
print("New rows added and Parquet file rewritten.")
'''

'''
csv_size = os.path.getsize("Parquet/sales_report+(1).csv") / 1024 / 1024
pq_size = os.path.getsize("sales_report.parquet") /1024 / 1024
print(f"CSV size: {csv_size:.2f} MB")
print(f"Parquet size: {pq_size:.2f} MB")
'''

'''
df = pd.read_csv("Parquet/sales_report+(1).csv")

df["Date"] = pd.to_datetime(df["Date"])

output_dir = r"partitioned_sales"
os.makedirs(output_dir, exist_ok=True)

df.to_parquet(
    output_dir,
    engine="pyarrow",
    partition_cols=["Region"],
    index=False,
    coerce_timestamps="us",
    allow_truncated_timestamps=True
)

print("Partitioned Parquet dataset saved.")
'''

'''
from urllib.request import urlretrieve
from pathlib import Path

url = "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2024-01.parquet"
file_path = Path("yellow_tripdata_2024-01.parquet")

if not file_path.exists():
    urlretrieve(url, file_path)
    print("Parquet file downloaded.")
else:
    print("Parquet file already exists.")

print(file_path)
'''


import pyarrow.parquet as pq

parquet_file = pq.ParquetFile("yellow_tripdata_2024-01.parquet")

#print(type(parquet_file))
#print(parquet_file.schema_arrow)

metadata = parquet_file.metadata

'''print("Number of rows:", metadata.num_rows)
print("Number of columns:", metadata.num_columns)
print("Number of row groups:", metadata.num_row_groups)
print("Created by:", metadata.created_by)'''

'''row_group = metadata.row_group(0)
print("Rows:", row_group.num_rows)
print("Columns:", row_group.num_columns)
print("Total byte size:", row_group.total_byte_size)'''

'''for i in range(metadata.num_row_groups):
    rg = metadata.row_group(i)
    print(
        f"Row group {i}: "
        f"rows={rg.num_rows:,}, "
        f"columns={rg.num_columns}, "
        f"size={rg.total_byte_size / 1024 / 1024:.2f} MB"
    )'''

#column = metadata.row_group(0).column(0)

'''print("Column:", column.path_in_schema)
print("Physical type:", column.physical_type)
print("Compression:", column.compression)
print("Number of values:", column.num_values)
print("Compressed size:", column.total_compressed_size)
print("Uncompressed size:", column.total_uncompressed_size)'''

'''stats = column.statistics
print(stats)

column_names = parquet_file.schema_arrow.names
trip_distance_index = column_names.index("trip_distance")

trip_column = metadata.row_group(0).column(trip_distance_index)
stats = trip_column.statistics

print("Column:", trip_column.path_in_schema)
print("Compression:", trip_column.compression)

if stats is not None:
    print("Min:", stats.min)
    print("Max:", stats.max)
    print("Null count:", stats.null_count)
else:
    print("Statistics are not available.")'''

'''table = parquet_file.read_row_group(
    0,
    columns=[
        "tpep_pickup_datetime",
        "trip_distance",
        "fare_amount",
        "total_amount"
    ]
)

print(type(table))
print(table.schema)

df_row_group = table.to_pandas()

print(type(df_row_group))
print(df_row_group.head(10))'''

'''df_small = pd.read_parquet(
    "yellow_tripdata_2024-01.parquet",
    columns=[
        "tpep_pickup_datetime",
        "trip_distance",
        "fare_amount",
        "total_amount"
    ]
)

print(df_small.head())
print(df_small.info())

summary = df_small[[
    "trip_distance",
    "fare_amount",
    "total_amount"
]].mean()

print(summary)'''

#import pyarrow.parquet as pq

#data = pq.ParquetFile("green_tripdata_2024-01.parquet")
#metadata = data.metadata

'''print(f"Number of rows: {metadata.num_rows}")
print(f"Number of columns: {metadata.num_columns}")
print(f"Number of row groups: {metadata.num_row_groups}")
print(f"File schema: {data.schema_arrow}")
print(f"Created by: {metadata.created_by}")'''

'''for i in range(metadata.num_row_groups):
    rg = metadata.row_group(i)

    print(f"Index: {i}")
    print(f"Number of rows: {rg.num_rows}")
    print(f"Number of columns: {rg.num_columns}")
    print(f"Size: {os.path.getsize("green_tripdata_2024-01.parquet") / 1024 / 1024:.2f} MB")'''

#column = metadata.row_group(0).column(0)
#stats = column.statistics

'''print("Column:", column.path_in_schema)
print("Physical type:", column.physical_type)
print("Compression:", column.compression)
print("Number of values:", column.num_values)
print("Compressed size:", column.total_compressed_size)
print("Uncompressed size:", column.total_uncompressed_size)
if stats is not None:
    print("Minimum:", stats.min)
    print("Maximum:", stats.max)
    print("NULLs:", stats.null_count)
else:
    print("Statistics are not aviable")'''

#data = pd.read_parquet(r"green_tripdata_2024-01.parquet", columns=['lpep_pickup_datetime', 'VendorID', 'PULocationID', 'DOLocationID'])

'''print(data.head(10))
print(data.dtypes)
print(data.isnull().sum().sum())
print(data[['VendorID', 'PULocationID', 'DOLocationID']].describe())'''

'''p = pq.ParquetFile("green_tripdata_2024-01.parquet")
rg = p.read_row_group(0, columns=['VendorID', 'PULocationID', 'DOLocationID'])
print(type(rg))
print(rg.num_rows)
print(rg.schema)

dataFrame = pd.read_parquet(rg, engine="pyarrow")
print(dataFrame.head(5))'''

df = pd.read_parquet('green_tripdata_2024-01.parquet', columns=['payment_type', 'tip_amount'])
result = df.groupby('payment_type')['tip_amount'].mean().reset_index()
print(result)