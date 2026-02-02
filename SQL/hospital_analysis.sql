create database hospital_operations;


CREATE TABLE hospital_operations.patients (
    patient_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender CHAR(1),
    birth_date DATE,
    city VARCHAR(100),
    insurance_type VARCHAR(50),
    registration_date DATE
)CHARACTER SET utf8mb4;

CREATE TABLE hospital_operations.departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
)CHARACTER SET utf8mb4;


CREATE TABLE hospital_operations.doctors (
    doctor_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    specialty VARCHAR(100),
    department_id INT,
    hire_date DATE,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
)CHARACTER SET utf8mb4;



CREATE TABLE hospital_operations.visits (
    visit_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    visit_date DATE,
    visit_type VARCHAR(50), -- Consultation / Urgence / Suivi
    diagnosis VARCHAR(255),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
)CHARACTER SET utf8mb4;


CREATE TABLE hospital_operations.treatments (
    treatment_id INT PRIMARY KEY,
    visit_id INT,
    treatment_name VARCHAR(100),
    treatment_cost DECIMAL(10,2),
    FOREIGN KEY (visit_id) REFERENCES visits(visit_id)
)CHARACTER SET utf8mb4;


CREATE TABLE hospital_operations.payments (
    payment_id INT PRIMARY KEY,
    visit_id INT,
    payment_date DATE,
    amount_paid DECIMAL(10,2),
    payment_status VARCHAR(50), -- Paid / Pending / Rejected
    FOREIGN KEY (visit_id) REFERENCES visits(visit_id)
)CHARACTER SET utf8mb4;

### A. ANALYSE DES PATIENTS. 
# Nombre total de patients

SELECT COUNT(*) AS total_patients
FROM hospital_operations.patients;
# Taille de la base patient → indicateur de capacité de l’hôpital.

# Répartition par type d’assurance

SELECT insurance_type, COUNT(*) AS nb_patients
FROM hospital_operations.patients
GROUP BY insurance_type;

#Public → dépendance aux financements publics
#private → potentiel de rentabilité
# None → risque d’impayés

# Âge moyen des patients
SELECT ROUND(AVG(TIMESTAMPDIFF(YEAR, birth_date, CURDATE())),1) AS avg_age
FROM hospital_operations.patients;
#Permet d’adapter les spécialités dominantes (gériatrie, pédiatrie).

###. B. ACTIVITÉ HOSPITALIÈRE

# Nombre de visites par an 
SELECT YEAR(visit_date) AS year, COUNT(*) AS total_visits
FROM hospital_operations.visits
GROUP BY year
ORDER BY year;

# Évolution de l’activité (croissance, stabilité, surcharge). 

# Répartition des types de visites
SELECT visit_type, COUNT(*) AS nb_visits
FROM hospital_operations.visits
GROUP BY visit_type;
# Emergency élevé → pression sur les urgences
#Follow-up → qualité du suivi patient

### C. PERFORMANCE DES SERVICES

# Visites par département
SELECT d.department_name, COUNT(v.visit_id) AS total_visits
FROM hospital_operations.visits v
JOIN hospital_operations.doctors doc ON v.doctor_id = doc.doctor_id
JOIN hospital_operations.departments d ON doc.department_id = d.department_id
GROUP BY d.department_name
ORDER BY total_visits DESC;
#Identification des services les plus sollicités
#Aide à répartir les budgets et le personnel

# Charge moyenne par médecin
SELECT doc.full_name, COUNT(v.visit_id) AS visits_handled
FROM hospital_operations.doctors doc
LEFT JOIN hospital_operations.visits v ON doc.doctor_id = v.doctor_id
GROUP BY doc.full_name
ORDER BY visits_handled DESC;
# Détection des médecins surchargés
# Argument RH (recrutement

### D. ANALYSE FINANCIÈRE

# Coût total des traitements
SELECT ROUND(SUM(treatment_cost),2) AS total_treatment_cost
FROM hospital_operations.treatments;
#Coût réel de l’activité médicale.

# Coût moyen par visite
SELECT ROUND(AVG(treatment_cost),2) AS avg_cost_per_treatment
FROM hospital_operations.treatments;
#Indicateur clé pour pilotage budgétaire.

# Revenus encaissés
SELECT ROUND(SUM(amount_paid),2) AS total_revenue
FROM hospital_operations.payments
WHERE payment_status = 'Paid';
#Argent réellement perçu par l’hôpital.

#Taux d’impayés
SELECT 
ROUND(
    100 * SUM(CASE WHEN payment_status != 'Paid' THEN 1 ELSE 0 END) / COUNT(*)
,2) AS unpaid_rate
FROM hospital_operations.payments;
# Risque financier
# Indicateur critique pour la direction










