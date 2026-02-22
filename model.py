import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier

# 1. Load the data (In reality, this comes from your SQL database)
# We are simulating the features: [Order_Value, Customer_Age, Has_Evidence]
data = pd.DataFrame({
    'order_value': [100, 50, 500, 20, 1000, 45, 300],
    'customer_age_days': [365, 10, 5, 500, 2, 600, 15],
    'has_evidence': [1, 0, 1, 1, 0, 1, 0],
    'dispute_won': [1, 0, 0, 1, 0, 1, 0]  # The 'Target' we want to predict
})

# 2. Split data into 'Features' (X) and 'Target' (y)
X = data.drop('dispute_won', axis=1)
y = data['dispute_won']

# 3. Train the Model
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2)
model = RandomForestClassifier()
model.fit(X_train, y_train)

# 4. Predict Win Probability for a new $200 dispute from a new customer
new_dispute = [[200, 5, 1]] # $200 value, 5 days old account, has evidence
probability = model.predict_proba(new_dispute)[0][1]

print(f"Win Probability: {probability * 100}%")
