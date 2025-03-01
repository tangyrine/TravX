


# from fastapi import FastAPI
# from pydantic import BaseModel
# import joblib
# import pandas as pd
# import firebase_admin
# from firebase_admin import credentials, firestore
# from fastapi.middleware.cors import CORSMiddleware

# # Load AI Model & Preprocessing Tools
# model = joblib.load("route_model.pkl")
# route_id_mapping = joblib.load("route_id_mapping.pkl")
# scaler = joblib.load("scaler.pkl")

# # Reverse mapping: Convert index back to route_id
# index_to_route = {idx: route for route, idx in route_id_mapping.items()}

# # Initialize Firebase
# cred = credentials.Certificate("menuvista-cebae-firebase-adminsdk-3700j-271da9b963.json")
# firebase_admin.initialize_app(cred)
# db = firestore.client()

# app = FastAPI()
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],  # Allow all origins (use specific domains for security)
#     allow_credentials=True,
#     allow_methods=["*"],  # Allow all HTTP methods
#     allow_headers=["*"],  # Allow all headers
# )


# # Define Request Model
# class RouteRequest(BaseModel):
#     source_name: str
#     destination_name: str

# @app.post("/predict_route")
# def predict_route(request: RouteRequest):
#     source_name = request.source_name
#     destination_name = request.destination_name

#     buses = db.collection("bus").where("source_name", "==", source_name).where("destination_name", "==", destination_name).stream()

#     bus_data = []
#     route_ids = []

#     for bus in buses:
#         bus_info = bus.to_dict()
#         route_info = db.collection("bus").document(bus.id).collection("route").stream()

#         for route in route_info:
#             route_data = route.to_dict()
#             route_ids.append(route.id)

#             bus_data.append({
#                 "traffic": route_data.get("traffic", "unknown"),
#                 "distance": float(route_data.get("distance", 0.0)),
#                 "available_seats": bus_info.get("available_seats", 0)
#             })

#             # Get coordinates
#             source_coords = bus_info.get("source_coordinates", "")
#             dest_coords = bus_info.get("dest_coordinates", "")

#     if not bus_data:
#         return {"message": "No bus found for this route"}

#     traffic_mapping = {"low": 0, "moderate": 1, "high": 2}
#     for data in bus_data:
#         data["traffic"] = traffic_mapping.get(str(data["traffic"]).lower(), 1)

#     input_data = pd.DataFrame(bus_data)
#     input_data[["distance", "available_seats"]] = scaler.transform(input_data[["distance", "available_seats"]])

#     route_scores = model.predict(input_data)
#     best_route_index = route_scores.argmax()
#     best_route_id = route_ids[best_route_index]

#     bus_ref = db.collection("bus").where("source_name", "==", source_name).where("destination_name", "==", destination_name).stream()

#     for bus in bus_ref:
#         db.collection("bus").document(bus.id).update({"route_id": best_route_id})

#     return {
#         "recommended_route_id": best_route_id,
#         "source_coordinates": source_coords,
#         "dest_coordinates": dest_coords
#     }


from fastapi import FastAPI
from pydantic import BaseModel
import joblib
import pandas as pd
import firebase_admin
from firebase_admin import credentials, firestore
from fastapi.middleware.cors import CORSMiddleware

# Load AI Model & Preprocessing Tools
try:
    model = joblib.load("route_model.pkl")
    route_id_mapping = joblib.load("route_id_mapping.pkl")
    scaler = joblib.load("scaler.pkl")
except Exception as e:
    print("Error loading AI models:", e)
    model = None
    route_id_mapping = {}
    scaler = None

# Reverse mapping: Convert index back to route_id
index_to_route = {idx: route for route, idx in route_id_mapping.items()}

# Initialize Firebase
cred = credentials.Certificate("menuvista-cebae-firebase-adminsdk-3700j-271da9b963.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins (use specific domains for security)
    allow_credentials=True,
    allow_methods=["*"],  # Allow all HTTP methods
    allow_headers=["*"],  # Allow all headers
)

# Define Request Model
class RouteRequest(BaseModel):
    source_name: str
    destination_name: str

@app.post("/predict_route")
def predict_route(request: RouteRequest):
    source_name = request.source_name
    destination_name = request.destination_name

    buses = db.collection("bus").where("source_name", "==", source_name).where("destination_name", "==", destination_name).stream()

    bus_data = []
    route_ids = []
    stop_coordinates = []
    source_coords = ""
    dest_coords = ""

    for bus in buses:
        bus_info = bus.to_dict()
        source_coords = bus_info.get("source_coordinates", "")
        dest_coords = bus_info.get("dest_coordinates", "")

        route_info = db.collection("bus").document(bus.id).collection("route").stream()

        for route in route_info:
            route_data = route.to_dict()
            route_ids.append(route.id)

            bus_data.append({
                "traffic": route_data.get("traffic", "moderate"),  # Default to "moderate"
                "distance": float(route_data.get("distance", 0.0)),
                "available_seats": bus_info.get("available_seats", 0)
            })

            # Get stop coordinates correctly
            stops = route_data.get("stops", [])
            for stop in stops:
                stop_coords = stop.get("coordinates", "")
                if stop_coords:
                    stop_coordinates.append(stop_coords.strip())

    if not bus_data:
        return {"message": "No bus found for this route"}

    # Convert traffic levels into numerical values
    traffic_mapping = {"low": 0, "moderate": 1, "high": 2}
    for data in bus_data:
        data["traffic"] = traffic_mapping.get(str(data["traffic"]).lower(), 1)

    # Convert data into DataFrame and normalize
    input_data = pd.DataFrame(bus_data)
    input_data[["distance", "available_seats"]] = scaler.transform(input_data[["distance", "available_seats"]])

    # Predict the best route
    route_scores = model.predict(input_data)
    best_route_index = route_scores.argmax()
    best_route_id = route_ids[best_route_index]

    # Update best route in Firestore
    bus_ref = db.collection("bus").where("source_name", "==", source_name).where("destination_name", "==", destination_name).stream()
    for bus in bus_ref:
        db.collection("bus").document(bus.id).update({"route_id": best_route_id})

    return {
        "recommended_route_id": best_route_id,
        "source_coordinates": source_coords,
        "stop_coordinates": stop_coordinates,
        "dest_coordinates": dest_coords
    }
