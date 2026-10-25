import pandas as pd

df = pd.read_csv(r"CSV/employees.csv")

#print(df.head(20))
#print(df.info())

#avg_salary = df.groupby("department")["salary"].mean()
#print("Average Salary by Department:")
#print(avg_salary)

#gender_count = df["gender"].value_counts()
#print("Count by Gender:")
#print(gender_count)

it_employees = df[df["department"] == "IT"]
it_employees.to_csv("it_employees.csv", index=False)
high_salary = df[df["salary"] > 80000]
high_salary.to_csv("high_salary.csv", index=False)
print("Files Created successfully: it_employees.csv and high_salary.csv")