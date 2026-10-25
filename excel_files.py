import pandas as pd

df = pd.read_excel(r"Excel/sales_report.xlsx")
#print(df.head(50))

#print("\nDataset Info:")
#print(df.info())

#print("\nSUmmary Statistics:")
#print(df.describe())

west_sales = df[df["Region"] == "West"]
#print(west_sales.head(10))

#region_sales = df.groupby("Region")["SalesAmount"].sum().reset_index()
#print("\nTotal Sales by Region:")
#print(region_sales)

west_sales.to_excel("west_region_sales.xlsx", index=False)
print("Filtered data saved sucesfully!")