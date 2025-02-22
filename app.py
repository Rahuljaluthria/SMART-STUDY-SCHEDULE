from flask import Flask, request, jsonify
import pandas as pd

app = Flask(__name__)

@app.route('/generate_schedule', methods=['POST'])
def generate_schedule():
    data = request.json
    
    subjects = data["subjects"]
    difficulty = data["difficulty"]
    hours_per_day = data["hours_per_day"]
    
    # Allocate time based on difficulty
    time_allocation = {"Easy": 1, "Medium": 1.5, "Hard": 2}
    
    # Calculate total study time per subject
    study_schedule = {}
    total_weight = sum(time_allocation[d] for d in difficulty)
    hours_per_subject = [round((time_allocation[d] / total_weight) * hours_per_day, 2) for d in difficulty]
    
    for i, subject in enumerate(subjects):
        study_schedule[subject] = f"{hours_per_subject[i]} hours"
    
    return jsonify({"study_schedule": study_schedule})

if __name__ == '__main__':
    app.run(debug=True)
