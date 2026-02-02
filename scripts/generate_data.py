from faker import Faker
import pandas as pd
import random
from datetime import timedelta
import unicodedata
import re

# -----------------------
# CLEAN FUNCTION
# -----------------------
def clean_text(text):
    if text is None:
        return None
    text = unicodedata.normalize('NFKD', str(text))
    text = text.encode('ascii', 'ignore').decode('ascii')
    text = re.sub(r"[^a-zA-Z0-9 .,_-]", "", text)
    return text.strip()

fake = Faker("fr_FR")
random.seed(42)

# VOLUMES
N_PATIENTS = 1000
N_DOCTORS = 50
N_VISITS = 10000

# -----------------------
# DEPARTMENTS
# -----------------------
departments = [
    "Cardiology", "Neurology", "Pediatrics", "Orthopedics",
    "Dermatology", "Oncology", "Gynecology", "Emergency"
]

df_departments = pd.DataFrame({
    "department_id": range(1, len(departments) + 1),
    "department_name": departments
})

# -----------------------
# PATIENTS
# -----------------------
patients = []

for i in range(1, N_PATIENTS + 1):
    patients.append({
        "patient_id": i,
        "first_name": clean_text(fake.first_name()),
        "last_name": clean_text(fake.last_name()),
        "gender": random.choice(["M", "F"]),
        "birth_date": fake.date_of_birth(minimum_age=1, maximum_age=90),
        "city": clean_text(fake.city()),
        "insurance_type": random.choice(["Public", "Private", "None"]),
        "registration_date": fake.date_between(start_date="-5y", end_date="today")
    })

df_patients = pd.DataFrame(patients)

# -----------------------
# DOCTORS
# -----------------------
doctors = []

for i in range(1, N_DOCTORS + 1):
    doctors.append({
        "doctor_id": i,
        "full_name": clean_text(fake.name()),
        "specialty": random.choice(departments),
        "department_id": random.randint(1, len(departments)),
        "hire_date": fake.date_between(start_date="-15y", end_date="-1y")
    })

df_doctors = pd.DataFrame(doctors)

# -----------------------
# VISITS
# -----------------------
visits = []

for i in range(1, N_VISITS + 1):
    visits.append({
        "visit_id": i,
        "patient_id": random.randint(1, N_PATIENTS),
        "doctor_id": random.randint(1, N_DOCTORS),
        "visit_date": fake.date_between(start_date="-3y", end_date="today"),
        "visit_type": random.choice(["Consultation", "Emergency", "Follow-up"]),
        "diagnosis": random.choice([
            "Hypertension", "Diabetes", "Flu",
            "Back Pain", "Fracture", "Migraine",
            "Skin Infection", "Routine Check"
        ])
    })

df_visits = pd.DataFrame(visits)

# -----------------------
# TREATMENTS
# -----------------------
treatments = []
treatment_id = 1

for visit in visits:
    for _ in range(random.randint(1, 3)):
        treatments.append({
            "treatment_id": treatment_id,
            "visit_id": visit["visit_id"],
            "treatment_name": random.choice([
                "Medication", "XRay", "MRI",
                "Blood Test", "Physiotherapy", "Surgery"
            ]),
            "treatment_cost": round(random.uniform(20, 2000), 2)
        })
        treatment_id += 1

df_treatments = pd.DataFrame(treatments)

# -----------------------
# PAYMENTS
# -----------------------
payments = []

for visit in visits:
    payments.append({
        "payment_id": visit["visit_id"],
        "visit_id": visit["visit_id"],
        "payment_date": visit["visit_date"] + timedelta(days=random.randint(0, 30)),
        "amount_paid": round(random.uniform(30, 3000), 2),
        "payment_status": random.choice(["Paid", "Pending", "Rejected"])
    })

df_payments = pd.DataFrame(payments)

# -----------------------
# EXPORT CSV (SAFE)
# -----------------------
df_departments.to_csv("data/departments.csv", index=False, encoding="utf-8")
df_patients.to_csv("data/patients.csv", index=False, encoding="utf-8")
df_doctors.to_csv("data/doctors.csv", index=False, encoding="utf-8")
df_visits.to_csv("data/visits.csv", index=False, encoding="utf-8")
df_treatments.to_csv("data/treatments.csv", index=False, encoding="utf-8")
df_payments.to_csv("data/payments.csv", index=False, encoding="utf-8")

print("✅ CSV generated WITHOUT accents (SQL-safe)")
