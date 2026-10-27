import pandas as pd
import numpy as np

file_path = "sales_data_dirty.csv"

try:
    df = pd.read_csv(file_path)
    if df.empty:
        raise ValueError("Súbor je prázdny a neobsahuje žiadne dáta")
    print(f"Súbor '{file_path}' bol úspešne načítaný")
    print(f"Počet riadkov: {df.shape[0]}, Počet stĺpcov: {df.shape[1]}\n")
    print(df.head(5))
    
except FileNotFoundError:
    print(f"Chyba: Súbor nebol nájdený.")
except pd.errors.EmptyDataError:
    print(f"Chyba: Súbor je prázdny.")
except pd.errors.ParserError:
    print(f"Chyba: Súbor je poškodený")
except Exception as e:
    print(f"Chyba: {e}")

'''
    2. Úloha
'''

print("Columns:\n", df.info())
print("Info:\n", df.describe(include="all"))
print("Missing values:\n", df.isna().sum())
print("Region values:\n",df["Region"].value_counts(dropna=False))
print("Product values:\n", df["Product"].value_counts(dropna=False))

'''
    3. Úloha
'''

required = ["OrderID", "Region", "Product", "Quantity", "SalesAmount", "Discount", "OrderDate", "DeliveryDate", "PhoneNumber"]

missing = [col for col in required if col not in df.columns]

if missing:
    raise ValueError(f"Chyba: chýbajú povinné stĺpce: {missing}")

'''
    4. Úloha
'''

invalid_format = ~df["OrderID"].astype(str).str.match(r"^ORD\d{4}$", na=False)
duplicate = df.duplicated(subset=["OrderID"], keep=False)
order_id_issues = invalid_format | duplicate

print(f"Počet záznamov s neplatným formátom OrderID: {invalid_format_mask.sum()}")
print(f"Počet duplicitných záznamov OrderID: {duplicate_mask.sum()}")

df_order_issues = df[order_id_issues]
print(df_order_issues.head())

'''
    5. Úloha
'''

allowed_regions = ["North", "South", "East", "West"]
allowed_products = ["Laptop", "Mouse", "Keyboard", "Monitor", "Printer"]

df["Region_clean"] = df["Region"].astype(str).str.strip().str.capitalize()

region_mapping = {
    "N": "North",
    "S": "South",
    "E": "East",
    "W": "West",
    "Northh": "North"
}
df["Region_clean"] = df["Region_clean"].replace(region_mapping)

invalid_region_mask = ~df["Region_clean"].isin(allowed_regions)
df.loc[invalid_region_mask, "Region_clean"] = np.nan

print("Zjednotené hodnoty v stĺpci Region:")
print(df["Region_clean"].value_counts(dropna=False))

'''
    6. Úloha
'''

def clean_numeric(series):
    cleaned = series.astype(str).str.replace("$", "", regex=False).str.strip()
    return pd.to_numeric(cleaned, errors="coerce")

df["Quantity_clean"] = clean_numeric(df["Quantity"])
invalid_quantity = df["Quantity_clean"].isna() | (df["Quantity_clean"] <= 0) | (df["Quantity_clean"] % 1 != 0)

df["SalesAmount_clean"] = clean_numeric(df["SalesAmount"])
invalid_sales = df["SalesAmount_clean"].isna() | (df["SalesAmount_clean"] <= 0)

df["Discount_clean"] = clean_numeric(df["Discount"])
invalid_discount = df["Discount_clean"].isna() | (df["Discount_clean"] < 0) | (df["Discount_clean"] > 100)

print(f"Počet neplatných Quantity: {invalid_quantity.sum()}")
print(f"Počet neplatných SalesAmount: {invalid_sales.sum()}")
print(f"Počet neplatných Discount: {invalid_discount.sum()}")

'''
    7. Úloha
'''

df["OrderDate_clean"] = pd.to_datetime(df["OrderDate"], errors="coerce")
df["DeliveryDate_clean"] = pd.to_datetime(df["DeliveryDate"], errors="coerce")

invalid_order_date = df["OrderDate"].notna() & df["OrderDate_clean"].isna()
invalid_delivery_date = df["DeliveryDate"].notna() & df["DeliveryDate_clean"].isna()

invalid_date_logic = df["DeliveryDate_clean"] < df["OrderDate_clean"]

print(f"Neplatný formát OrderDate: {invalid_order_date.sum()}")
print(f"Neplatný formát DeliveryDate: {invalid_delivery_date.sum()}")
print(f"Nelogické dátumy (Delivery < Order): {invalid_date_logic.sum()}")

'''
    8. Úloha
'''

phone_str = df["PhoneNumber"].astype(str)
is_phone_filled = df["PhoneNumber"].notna() & (phone_str.str.strip() != "") & (phone_str.str.lower() != "nan")

phone_digits = phone_str.str.replace(r"\D", "", regex=True)
phone_len = phone_digits.str.len()

invalid_phone = is_phone_filled & ~phone_len.between(10, 15)

print(f"Počet vyplnených telefónnych čísel: {is_phone_filled.sum()}")
print(f"Počet neplatných telefónnych čísel: {invalid_phone.sum()}")

'''
    9. Úloha
'''

validation_flags = pd.DataFrame({
    "err_order_id_format": invalid_format,
    "err_order_id_duplicate": duplicate,
    "err_region": invalid_region_mask,
    "err_quantity": invalid_quantity,
    "err_sales_amount": invalid_sales,
    "err_discount": invalid_discount,
    "err_order_date": invalid_order_date,
    "err_delivery_date": invalid_delivery_date,
    "err_date_logic": invalid_date_logic,
    "err_phone": invalid_phone
})

validation_report = validation_flags.sum().reset_index()
validation_report.columns = ["Validation_Rule", "Error_Count"]
print(validation_report)

'''
    10. Úloha
'''

critical_rules = [
    "err_order_id_format", 
    "err_order_id_duplicate", 
    "err_region", 
    "err_quantity", 
    "err_sales_amount", 
    "err_discount", 
    "err_order_date", 
    "err_delivery_date", 
    "err_date_logic"
]

has_critical_error = validation_flags[critical_rules].any(axis=1)

df_with_flags = pd.concat([df, validation_flags], axis=1)

rejected_records = df_with_flags[has_critical_error].copy()
clean_data = df_with_flags[~has_critical_error].copy()

print(f"Počet validných záznamov: {len(clean_data)}")
print(f"Počet zamietnutých záznamov: {len(rejected_records)}")

'''
    11. Úloha
'''

final_clean_df = pd.DataFrame({
    "OrderID": clean_data["OrderID"],
    "Region": clean_data["Region_clean"],
    "Product": clean_data["Product"],
    "Quantity": clean_data["Quantity_clean"].astype(int),
    "SalesAmount": clean_data["SalesAmount_clean"],
    "Discount": clean_data["Discount_clean"],
    "OrderDate": clean_data["OrderDate_clean"],
    "DeliveryDate": clean_data["DeliveryDate_clean"],
    "PhoneNumber": clean_data["PhoneNumber"]
})

final_clean_df.info()
print(final_clean_df.head())

'''
    12. Úloha
'''

class DataValidationError(Exception):
    pass

def post_cleaning_validation(df_final):
    if not df_final["OrderID"].is_unique:
        raise DataValidationError("Chyba: OrderID vo vyčistených dátach nie je unikátne")
    
    if (df_final["Quantity"] <= 0).any():
        raise DataValidationError("Chyba: Vo vyčistených dátach sa nachádza nekladné množstvo Quantity")
        
    if (df_final["SalesAmount"] <= 0).any():
        raise DataValidationError("Chyba: Vo vyčistených dátach sa nachádza nekladná suma SalesAmount")
        
    if not df_final["Discount"].between(0, 100).all():
        raise DataValidationError("Chyba: Zľava Discount mimo povoleného rozsahu 0-100")
        
    if (df_final["DeliveryDate"] < df_final["OrderDate"]).any():
        raise DataValidationError("Chyba: Nájdené záznamy, kde dodanie predchádza objednávke")

try:
    post_cleaning_validation(final_clean_df)
    print("Opätovná validácia prebehla úspešne. Dáta sú pripravené na uloženie.")
except DataValidationError as e:
    print(e)

'''
    13. Úloha
'''

final_clean_df.to_csv("sales_data_clean.csv", index=False)
rejected_records.to_csv("sales_data_rejected.csv", index=False)
validation_report.to_csv("validation_report.csv", index=False)

print("Všetky výstupy boli úspešne uložené.")