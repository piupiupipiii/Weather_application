from flask import Flask, jsonify, request
from flask_cors import CORS, cross_origin
from pymongo import MongoClient

app = Flask(__name__)
cors = CORS(app) # allow CORS for all domains on all routes.
app.config['CORS_HEADERS'] = 'Content-Type'


# Koneksi ke MongoDB
client = MongoClient("mongodb://localhost:27017/")
db = client.sensor_database
sensor_collection = db.sensor_data

@app.route('/sensor-data', methods=['POST'])
def receive_data():
    data = request.json
    if data:
        sensor_collection.insert_one(data)
        print(f"Data berhasil disimpan: {data}")  # Notifikasi di terminal Flask
        return jsonify({"message": "Data received"}), 201
    print("Gagal menerima data: Data kosong atau format salah")  # Log error
    return jsonify({"message": "No data received"}), 400

@app.route('/sensor-data', methods=['GET'])
@cross_origin()
def get_data():
    data = list(sensor_collection.find(projection={"_id": 0}))  # Ambil semua data tanpa menyertakan "_id"
    if data:
        return jsonify(data), 200
    return jsonify({"message": "No data available"}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
