import pandas as pd
import numpy as np

# Sample data
data = {'Order_ID': [1, 2, 3, 4, 5],
        'Product_ID': [101, 102, 103, 101, 104],
        'Price': [10.99, 29.99, 15.99, np.nan, 22.99],
        'Quantity': [2, 1, 3, 2, 4]}

df = pd.DataFrame(data)

# 1. Handling Missing Values
df['Price'].fillna(df['Price'].mean(), inplace=True)

# 2. Removing Duplicates
df.drop_duplicates(inplace=True)

# 3. Data Transformation
df['Total_Price'] = df['Price'] * df['Quantity']

# 4. Data Normalization (Min-Max Scaling)
df['Normalized_Price'] = (df['Price'] - df['Price'].min()) / (df['Price'].max() - df['Price'].min())

# 5. Data Discretization
bins = [0, 10, 20, 30]
labels = ['Low', 'Medium', 'High']
df['Price_Category'] = pd.cut(df['Price'], bins=bins, labels=labels)

print(df)