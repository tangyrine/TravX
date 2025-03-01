

import joblib
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import mean_absolute_error

# 🔹 Sample Synthetic Data (Replace with real Firebase data later)
data = {
    "traffic": ["low", "moderate", "high", "moderate", "high", "low", "high", "moderate"],
    "distance": [5.2, 10.3, 15.1, 8.5, 20.0, 4.8, 25.3, 12.4],
    "available_seats": [10, 15, 5, 20, 3, 25, 2, 18],
    "route_id": ["route_1", "route_2", "route_3", "route_2", "route_3", "route_1", "route_3", "route_2"]  # Document IDs
}

# 🔹 Convert to DataFrame
df = pd.DataFrame(data)

# 🔹 Encode Categorical Features
traffic_mapping = {"low": 0, "moderate": 1, "high": 2}
df["traffic"] = df["traffic"].map(traffic_mapping)

# 🔹 Assign numerical indexes for route IDs
route_id_mapping = {route: idx for idx, route in enumerate(df["route_id"].unique())}
df["route_index"] = df["route_id"].map(route_id_mapping)  # Instead of Label Encoding

# 🔹 Calculate Route Score: Lower traffic and smaller distance should have higher scores
df["route_score"] = (3 - df["traffic"]) * 2 - df["distance"]  # Higher is better

# 🔹 Split Data
X = df[["traffic", "distance", "available_seats"]]
y = df["route_score"]  # Train to predict the best route score

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# 🔹 Normalize distance & available_seats
scaler = StandardScaler()
X_train[["distance", "available_seats"]] = scaler.fit_transform(X_train[["distance", "available_seats"]])
X_test[["distance", "available_seats"]] = scaler.transform(X_test[["distance", "available_seats"]])

# 🔹 Train Model
model = RandomForestRegressor(n_estimators=500, random_state=42)  # Regression to predict route score
model.fit(X_train, y_train)

# 🔹 Save Model
joblib.dump(model, "route_model.pkl")
joblib.dump(route_id_mapping, "route_id_mapping.pkl")  # Save mapping for retrieval
joblib.dump(scaler, "scaler.pkl")

print("✅ Model training complete! Saved as 'route_model.pkl'")

