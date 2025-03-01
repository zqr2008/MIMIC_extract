WITH gcs_final AS
(SELECT
gc.*,
ROW_NUMBER () OVER (PARTITION BY gc.stay_id ORDER BY gc.charttime) as gcs_seq,
FIRST_VALUE(gcs) OVER ( PARTITION BY gc.stay_id ORDER BY 
       CASE WHEN gcs IS NULL then 0 ELSE 1 END DESC,
       gc.charttime) as first_gcs,
 FROM `physionet-data.mimic_derived.gcs` gc
),

gcs_first AS 
(
SELECT
ie.subject_id,
ie.stay_id,
first_gcs AS gcs,
FROM `physionet-data.mimic_icu.icustays` ie
LEFT JOIN gcs_final gs
ON ie.stay_id = gs.stay_id
AND gs.gcs_seq = 1
),

vital_final AS
(SELECT
vital.*, 
ROW_NUMBER () OVER (PARTITION BY vital.stay_id ORDER BY vital.charttime) as vf_seq,
FIRST_VALUE(resp_rate) OVER ( PARTITION BY vital.stay_id ORDER BY 
       CASE WHEN resp_rate IS NULL then 0 ELSE 1 END DESC,
      vital.charttime) as first_resp_rate,
FIRST_VALUE(heart_rate) OVER ( PARTITION BY vital.stay_id ORDER BY 
       CASE WHEN heart_rate IS NULL then 0 ELSE 1 END DESC,
      vital.charttime) as first_heart_rate,
FIRST_VALUE(sbp) OVER ( PARTITION BY vital.stay_id ORDER BY 
       CASE WHEN sbp IS NULL then 0 ELSE 1 END DESC,
      vital.charttime) as first_sbp,
FIRST_VALUE(spo2) OVER ( PARTITION BY vital.stay_id ORDER BY 
       CASE WHEN spo2 IS NULL then 0 ELSE 1 END DESC,
      vital.charttime) as first_spo2,

FROM `physionet-data.mimic_derived.vitalsign` vital
),

vital_first AS
(
SELECT
ie.subject_id,
ie.stay_id,
first_heart_rate AS heart_rate,
first_sbp AS sbp,
first_resp_rate AS resp_rate,
first_spo2 AS spo2,
FROM `physionet-data.mimic_icu.icustays` ie
LEFT JOIN vital_final vf
ON ie.stay_id = vf.stay_id
AND vf.vf_seq = 1
),

cbc_final AS
(SELECT
ie.stay_id,
le.*,
ROW_NUMBER () OVER (PARTITION BY ie.stay_id ORDER BY le.charttime) as le_seq,
FIRST_VALUE(hemoglobin) OVER ( PARTITION BY ie.stay_id ORDER BY 
       CASE WHEN hemoglobin IS NULL then 0 ELSE 1 END DESC, le.charttime) as first_hemoglobin,
FIRST_VALUE(platelet) OVER ( PARTITION BY ie.stay_id ORDER BY 
       CASE WHEN platelet IS NULL then 0 ELSE 1 END DESC, le.charttime) as first_platelet,
FIRST_VALUE(wbc) OVER ( PARTITION BY ie.stay_id ORDER BY 
       CASE WHEN wbc IS NULL then 0 ELSE 1 END DESC, le.charttime) as first_wbc
FROM `physionet-data.mimic_icu.icustays` ie
LEFT JOIN `physionet-data.mimic_derived.complete_blood_count` le
ON le.subject_id = ie.subject_id
),

cbc_first AS
(
SELECT
ie.subject_id,
ie.stay_id,
first_hemoglobin AS hemoglobin,
first_platelet AS platelet,
first_wbc AS wbc
FROM `physionet-data.mimic_icu.icustays` ie
LEFT JOIN cbc_final cf
ON ie.stay_id = cf.stay_id
AND cf.le_seq = 1
),

chem_final AS
(SELECT
ie.stay_id,
le.*,
ROW_NUMBER () OVER (PARTITION BY ie.stay_id ORDER BY le.charttime) as le_seq,
FIRST_VALUE(creatinine) OVER ( PARTITION BY ie.stay_id ORDER BY 
       CASE WHEN creatinine IS NULL then 0 ELSE 1 END DESC, le.charttime) as first_creatinine,
FIRST_VALUE(glucose) OVER ( PARTITION BY ie.stay_id ORDER BY 
       CASE WHEN glucose IS NULL then 0 ELSE 1 END DESC, le.charttime) as first_glucose,
FIRST_VALUE(sodium) OVER ( PARTITION BY ie.stay_id ORDER BY 
       CASE WHEN sodium IS NULL then 0 ELSE 1 END DESC, le.charttime) as first_sodium,
FIRST_VALUE(potassium) OVER ( PARTITION BY ie.stay_id ORDER BY 
       CASE WHEN potassium IS NULL then 0 ELSE 1 END DESC, le.charttime) as first_potassium,
FIRST_VALUE(bun) OVER ( PARTITION BY ie.stay_id ORDER BY 
       CASE WHEN bun IS NULL then 0 ELSE 1 END DESC, le.charttime) as first_bun      
FROM `physionet-data.mimic_icu.icustays` ie
LEFT JOIN `physionet-data.mimic_derived.chemistry` le
ON le.subject_id = ie.subject_id
),

chem_first AS
(
SELECT
ie.subject_id,
ie.stay_id,
first_creatinine AS creatinine,
first_glucose AS glucose,
first_sodium AS sodium,
first_potassium AS potassium,
first_bun AS bun
FROM `physionet-data.mimic_icu.icustays` ie
LEFT JOIN chem_final cf
ON ie.stay_id = cf.stay_id
AND cf.le_seq = 1
),

art_final AS
(
SELECT
ie.subject_id,
ie.stay_id,
bg.*,
ROW_NUMBER () OVER (PARTITION BY ie.stay_id ORDER BY bg.charttime) as le_seq,
FIRST_VALUE(ph) OVER ( PARTITION BY ie.stay_id ORDER BY 
       CASE WHEN ph IS NULL then 0 ELSE 1 END DESC, bg.charttime) as first_ph,
FIRST_VALUE(so2) OVER ( PARTITION BY ie.stay_id ORDER BY 
       CASE WHEN so2 IS NULL then 0 ELSE 1 END DESC, bg.charttime) as first_so2,
FIRST_VALUE(pao2fio2ratio) OVER ( PARTITION BY ie.stay_id ORDER BY 
       CASE WHEN pao2fio2ratio IS NULL then 0 ELSE 1 END DESC, bg.charttime) as first_pao2fio2ratio,
FIRST_VALUE(po2) OVER ( PARTITION BY ie.stay_id ORDER BY 
       CASE WHEN po2 IS NULL then 0 ELSE 1 END DESC, bg.charttime) as first_po2,
FIRST_VALUE(pco2) OVER ( PARTITION BY ie.stay_id ORDER BY 
       CASE WHEN pco2 IS NULL then 0 ELSE 1 END DESC, bg.charttime) as first_pco2 
FROM `physionet-data.mimic_icu.icustays` ie
LEFT JOIN `physionet-data.mimic_derived.bg` bg
ON ie.subject_id = bg.subject_id
),

art_first AS
(SELECT
ie.subject_id,
ie.stay_id,
first_ph AS ph,
first_so2 AS so2,
first_po2 AS po2,
first_pco2 AS pco2,
FROM `physionet-data.mimic_icu.icustays` ie
LEFT JOIN art_final af
ON ie.stay_id = af.stay_id
AND af.le_seq = 1
),

enz_final AS
(SELECT
ie.stay_id,
le.*,
ROW_NUMBER () OVER (PARTITION BY ie.stay_id ORDER BY le.charttime) as le_seq,
FIRST_VALUE(bilirubin_total) OVER ( PARTITION BY ie.stay_id ORDER BY 
       CASE WHEN bilirubin_total IS NULL then 0 ELSE 1 END DESC, le.charttime) as first_bilirubin_total,
FROM `physionet-data.mimic_icu.icustays` ie
LEFT JOIN `physionet-data.mimic_derived.enzyme` le
ON le.subject_id = ie.subject_id
),

enz_first AS
(SELECT
ie.subject_id,
ie.stay_id,
first_bilirubin_total AS bilirubin_total
FROM `physionet-data.mimic_icu.icustays` ie
LEFT JOIN enz_final ef
ON ie.stay_id = ef.stay_id
AND ef.le_seq = 1
),

stag_1 AS
(SELECT * FROM 
(SELECT 
art.subject_id AS subject_id,
icu.hadm_id AS hadm_id,
art.stay_id AS stay_id,
admittime,
dischtime,
dod,
los_hospital,
admission_age,	
gcs,
resp_rate,
heart_rate,
sbp,
so2,
ph,
po2,
wbc,
(creatinine*88.4) AS Creatinine,
potassium, 
sodium,
(bun/2.80) AS bun,
(glucose/18) AS Glucose,
(hemoglobin*10) AS Hemoglobin,
platelet,
(bilirubin_total*17.1) AS bilirubin_total,
(heart_rate/sbp) AS xiuke_first,

    CASE WHEN dod IS NOT NULL AND icu.dod <= DATETIME_ADD(icu.admittime, INTERVAL '7' DAY)
         THEN 0 ELSE 1
         END AS alive_7day,

    CASE WHEN dod IS NOT NULL AND icu.dod <= DATETIME_ADD(icu.admittime, INTERVAL '30' DAY)
         THEN 0 ELSE 1
         END AS alive_30day,

row_number() over (PARTITION by icu.subject_id ORDER BY admittime) AS chart_order

FROM art_first art
INNER JOIN chem_first 
ON  art.stay_id=chem_first.stay_id
INNER JOIN cbc_first 
ON  art.stay_id=cbc_first.stay_id
INNER JOIN enz_first 
ON  art.stay_id=enz_first.stay_id
INNER JOIN gcs_first
ON art.stay_id=gcs_first.stay_id
INNER JOIN vital_first vs
ON art.stay_id=vs.stay_id
INNER JOIN `physionet-data.mimic_derived.icustay_detail` icu
ON icu.stay_id=art.stay_id
)
WHERE chart_order=1 AND admission_age>=16
),

-- ------------------------------------------------------------------
-- This query(vent1) extracts first ventilation status based on the mimic_derived.ventilation
-- Converted into O2_DEVICE_FIRST that JI program 
-- O2_DEVICE_FIRST：
-- NASAL CANNULE:0   Oxygen
-- NONE(ROOM AIR):0
-- OXYGEN MASK:1
-- VENTILATOR:3  NonInvasiveVent;Trach;InvasiveVent
-- VENTURI MASK:2  HighFlow

-- ------------------------------------------------------------------

vent_1 AS

(
SELECT * FROM
(SELECT 
stay_id,
starttime,
endtime,
ventilation_status,
row_number() over (PARTITION by stay_id ORDER BY starttime) AS chart_order
FROM `physionet-data.mimic_derived.ventilation` vent
)WHERE chart_order=1
),

vent_2 AS
(SELECT 
stag_1.subject_id  AS subject_id,

         CASE WHEN ventilation_status='Oxygen' 
         AND  starttime<= DATETIME_ADD(stag_1.admittime, INTERVAL '24' hour)
         THEN 0
         WHEN ventilation_status='HighFlow' 
         AND  starttime<= DATETIME_ADD(stag_1.admittime, INTERVAL '24' hour)
         THEN 2
         WHEN ventilation_status='Trach' 
         AND  starttime<= DATETIME_ADD(stag_1.admittime, INTERVAL '24' hour)
         THEN 3
         WHEN ventilation_status='NonInvasiveVent' 
         AND  starttime<= DATETIME_ADD(stag_1.admittime, INTERVAL '24' hour)
         THEN 3
         WHEN ventilation_status='InvasiveVent' 
         AND  starttime<= DATETIME_ADD(stag_1.admittime, INTERVAL '24' hour)
         THEN 3 
         ELSE 0 END AS O2_DEVICE_FIRST,

FROM vent_1
RIGHT JOIN stag_1 
ON stag_1.stay_id =vent_1.stay_id
),

oxygen_1 AS
(SELECT * FROM 
(SELECT 
subject_id,
stay_id,
o2_flow,
o2_delivery_device_1,
row_number() over (PARTITION by oxy.stay_id ORDER BY charttime) AS chart_order
FROM `physionet-data.mimic_derived.oxygen_delivery` oxy
) WHERE chart_order=1
),

oxygen_2 AS 
(SELECT 
stag_1.subject_id  AS subject_id,
o2_flow, 
FROM oxygen_1
RIGHT JOIN stag_1 
ON stag_1.stay_id =oxygen_1.stay_id
),


fio2_1 AS
(SELECT * FROM 
(SELECT 
subject_id,
stay_id,
fio2,
row_number() over (PARTITION by setting.stay_id ORDER BY charttime) AS chart_order
FROM `physionet-data.mimic_derived.ventilator_setting` setting
) WHERE chart_order=1
),

fio2_2 AS
(SELECT 
oxygen_1.subject_id  AS subject_id,
oxygen_1.stay_id AS stay_id,
o2_delivery_device_1,
fio2,

         CASE WHEN o2_delivery_device_1='Tracheostomy tube'
         THEN fio2
         WHEN o2_delivery_device_1='Endotracheal tube'
         THEN fio2  
         WHEN o2_delivery_device_1='CPAP mask'
         THEN fio2  
         WHEN o2_delivery_device_1='T-piece'
         THEN fio2 
         WHEN o2_delivery_device_1='High flow neb'
         THEN fio2
         WHEN o2_delivery_device_1='High flow nasal cannula'
         THEN fio2
         WHEN o2_delivery_device_1='Venti mask'
         THEN fio2
         WHEN o2_delivery_device_1='Bipap mask'
         THEN fio2
         WHEN o2_delivery_device_1='Tracheostomy tube'
         THEN fio2
         WHEN o2_delivery_device_1='Trach mask'
         THEN fio2
         WHEN o2_delivery_device_1='Nasal cannula'
         THEN (21+4*o2_flow)
         WHEN o2_delivery_device_1='Oxymizer'
         THEN (21+4*o2_flow)
         ELSE NULL END AS fio2_first,

FROM oxygen_1 FULL JOIN fio2_1 on oxygen_1.stay_id=fio2_1.stay_id 
),


fio2_3 AS 
(SELECT 
fio2_2.subject_id  AS subject_id,
fio2_FIRST AS fio2
FROM fio2_2 
RIGHT JOIN stag_1 
ON stag_1.stay_id =fio2_2.stay_id
),
-- ------------------------------------------------------------------
-- This query extracts comorbidity based on the recorded ICD-9 and ICD-10 codes.
-- JI program comorbidities are the desired list.
-- ------------------------------------------------------------------

diag AS
(
SELECT 
hadm_id, 
         CASE WHEN icd_version = 9 THEN icd_code ELSE NULL END AS icd9_code,
         CASE WHEN icd_version = 10 THEN icd_code ELSE NULL END AS icd10_code
    FROM `physionet-data.mimic_hosp.diagnoses_icd` diag
), 


com AS
(
SELECT
ad.hadm_id,

        -- TRAUMA_YN
         MAX(CASE WHEN
            SUBSTR(icd9_code, 1, 3) IN ('959')
            OR
            SUBSTR(icd10_code,1, 4) IN ('T149','T148')
            THEN 1 
            ELSE 0 END) AS TRAUMA_YN,

        -- DISCH_DX_RESP
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 3) BETWEEN'460' AND '519'
            OR
            SUBSTR(icd10_code, 1, 3) BETWEEN 'J00' AND 'J99'
            THEN 1 
            ELSE 0 END) AS DISCH_DX_RESP, 

        -- DISCH_DX_INJURY
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 3)  BETWEEN 'E00' AND 'E99'
            OR
            icd10_code LIKE 'S%'
            OR
            SUBSTR(icd10_code, 1, 3) BETWEEN 'V00' AND 'V99' OR
            SUBSTR(icd10_code, 1, 3) BETWEEN 'W01' AND 'W99' OR
            SUBSTR(icd10_code, 1, 3) BETWEEN 'X01' AND 'X99' OR
            SUBSTR(icd10_code, 1, 3) BETWEEN 'Y01' AND 'Y99' 
            THEN 1 
            ELSE 0 END) AS DISCH_DX_INJURY,

        -- DISCH_DX_NEOPLASMS
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 3) BETWEEN '140' AND '172'
            OR
            SUBSTR(icd9_code, 1, 4) BETWEEN '1740' AND '1958'
            OR
            SUBSTR(icd9_code, 1, 3) BETWEEN '200' AND '208'
            OR
            SUBSTR(icd9_code, 1, 4) = '2386'
            OR
            SUBSTR(icd10_code, 1, 3) IN ('C43','C88')
            OR
            SUBSTR(icd10_code, 1, 3) BETWEEN 'C00' AND 'C26'
            OR
            SUBSTR(icd10_code, 1, 3) BETWEEN 'C30' AND 'C34'
            OR
            SUBSTR(icd10_code, 1, 3) BETWEEN 'C37' AND 'C41'
            OR
            SUBSTR(icd10_code, 1, 3) BETWEEN 'C45' AND 'C58'
            OR
            SUBSTR(icd10_code, 1, 3) BETWEEN 'C60' AND 'C76'
            OR
            SUBSTR(icd10_code, 1, 3) BETWEEN 'C81' AND 'C85'
            OR
            SUBSTR(icd10_code, 1, 3) BETWEEN 'C90' AND 'C97'
            THEN 1 
            ELSE 0 END) AS DISCH_DX_NEOPLASMS,
        
        -- Cancer_Therapy
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 4) IN ('V580')
            OR 
            SUBSTR(icd9_code, 1, 5) IN ('V5811','V5812')
            OR
            SUBSTR(icd10_code, 1, 4) IN ('Z510','Z511')
            THEN 1 
            ELSE 0 END) AS Cancer_Therapy,
            

        -- ACTIVE_MALIGNANCY(It is hard to tell active by icd_code,so it is coded same as
        -- 'Metastatic solid tumor')
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 3) IN ('196','197','198','199')
            OR 
            SUBSTR(icd10_code, 1, 3) IN ('C77','C78','C79','C80')
            THEN 1 
            ELSE 0 END) AS ACTIVE_MALIGNANCY,

        
        -- Hematologic cancer
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 3) BETWEEN '200' AND '208'
            OR 
            SUBSTR(icd10_code, 1, 3) IN ('C81','C82','C83','C84','C85','C86','C88',
            'C90','C91','C92','C93','C94','C95','C96')
            THEN 1 
            ELSE 0 END) AS Hematologic_cancer,
        
        -- Metastatic solid tumor
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 3) IN ('196','197','198','199')
            OR 
            SUBSTR(icd10_code, 1, 3) IN ('C77','C78','C79','C80')
            THEN 1 
            ELSE 0 END) AS metastatic_solid_tumor,

        -- DISCH_DX_ABNORMAL_NOS
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 3) IN ('796')
            OR 
            SUBSTR(icd10_code, 1, 3) BETWEEN 'R00' AND 'R99'
            THEN 1 
            ELSE 0 END) AS DISCH_DX_ABNORMAL_NOS,

        -- Cerebrovascular disease
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 3) BETWEEN '430' AND '438'
            OR
            SUBSTR(icd9_code, 1, 5) = '36234'
            OR
            SUBSTR(icd10_code, 1, 3) IN ('G45','G46')
            OR 
            SUBSTR(icd10_code, 1, 3) BETWEEN 'I60' AND 'I69'
            OR
            SUBSTR(icd10_code, 1, 4) = 'H340'
            THEN 1 
            ELSE 0 END) AS cerebrovascular_disease,
        
        -- DISCH_DX_FLU_PNEUMONIA
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 3) BETWEEN '480' AND '488'
            OR 
            SUBSTR(icd10_code, 1, 3) IN ('J09','J10','J11','J12','J13','J14','J15','J16'
            ,'J17','J18')
            THEN 1 
            ELSE 0 END) AS DISCH_DX_FLU_PNEUMONIA,

        -- DISCH_DX_CHRONIC_LOWER_RESP(CHRONIC_LOWER_RESP adopted concept of Charlson Comorbidity Index 
        -- of chronic pulmonary disease)
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 3) BETWEEN '490' AND '505'
            OR
            SUBSTR(icd9_code, 1, 4) IN ('4168','4169','5064','5081','5088')
            OR 
            SUBSTR(icd10_code, 1, 3) BETWEEN 'J40' AND 'J47'
            OR 
            SUBSTR(icd10_code, 1, 3) BETWEEN 'J60' AND 'J67'
            OR
            SUBSTR(icd10_code, 1, 4) IN ('I278','I279','J684','J701','J703')
            THEN 1 
            ELSE 0 END) AS DISCH_DX_CHRONIC_LOWER_RESP,


        -- DISCH_DX_CIRC_DISEASE(Diseases of the circulatory system (excluding
        -- cerebrovascular diseases (430-438,I60‐I69))
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 3) BETWEEN '390' AND '459'
            AND 
            SUBSTR(icd9_code, 1, 3) NOT IN ('430','431','432','433','434','435','436','437'
            ,'438')
            OR
            SUBSTR(icd10_code, 1, 3) BETWEEN 'I00' AND 'I99'
            AND 
            SUBSTR(icd10_code, 1, 3) NOT IN ('I60','I61','I62','I63','I64','I65','I66','I67'
            ,'I68','I69')
            THEN 1 
            ELSE 0 END) AS DISCH_DX_CIRC_DISEASE,

        -- chronic heart failureIV
        -- ICD code do not have details for NYHA grade, so all chronic heart failure is labelled
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 3) IN ('428')
            OR
            SUBSTR(icd10_code, 1, 3) IN ('I50')
            THEN 1 
            ELSE 0 END) AS chronic_heart_failureIV,

        -- DISCH_DX_DIGESTIVE_DISEASE
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 3) BETWEEN '520' AND '579'
            OR
            SUBSTR(icd10_code, 1, 3) BETWEEN 'K00' AND 'K93'
            THEN 1 
            ELSE 0 END) AS DISCH_DX_DIGESTIVE_DISEASE,

        -- Cirrhosis
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 4) IN ('5712','5715','5716')
            OR
            SUBSTR(icd10_code, 1, 3) IN ('K74')
            OR
            SUBSTR(icd10_code, 1, 4) IN ('K703')
            OR
            SUBSTR(icd10_code, 1, 5) IN ('P7881')
            THEN 1 
            ELSE 0 END) AS Cirrhosis,

        -- DISCH_DX_GU_DISEASE
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 3) BETWEEN '580' AND '629'
            OR
            SUBSTR(icd10_code, 1, 3) BETWEEN 'N00' AND 'N99'
            THEN 1
            ELSE 0 END) AS DISCH_DX_GU_DISEASE,


        -- DISCH_DX_OTHER_DISEASE(icd9_code do not have a corresponding like icd10_code )
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 3) = '290'
            OR
            SUBSTR(icd9_code, 1, 4) IN ('2941','3312')
            OR
            SUBSTR(icd10_code, 1, 3) BETWEEN 'Q00' AND 'Q99'
            OR
            SUBSTR(icd10_code, 1, 3) BETWEEN 'D50' AND 'D89'
            OR
            SUBSTR(icd10_code, 1, 3) BETWEEN 'E00' AND 'E90'
            OR
            SUBSTR(icd10_code, 1, 3) BETWEEN 'F00' AND 'F99'
            THEN 1 
            ELSE 0 END) AS DISCH_DX_OTHER_DISEASE,


        -- STEROID_THERAPY
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 5) IN ('V5865')
            OR
            SUBSTR(icd10_code, 1, 4) IN ('Z795')
            THEN 1 
            ELSE 0 END) AS STEROID_THERAPY,

        -- DISCH_DX_AIDS
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 3) IN ('042','043','044')
            OR 
            SUBSTR(icd10_code, 1, 3) IN ('B20','B21','B22','B24')
            THEN 1 
            ELSE 0 END) AS DISCH_DX_AIDS,

        --Shock code is referred to the following:
        --Hunley C, Murphy S M E, Bershad M, et al. 
        --Utilization of Medical Codes for Hypotension in Shock Patients: 
        --A Retrospective Analysis[J]. Journal of Multidisciplinary Healthcare, 2021, 14: 861.
        
        
        --Hypovolemic_hemorrhagic_shock
        
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 5) IN ('78559')
            OR 
            SUBSTR(icd10_code, 1, 4) IN ('R571')
            THEN 1 
            ELSE 0 END) AS Hypovolemic_hemorrhagic_shock,
        
        --Hypovolemic_non-hemorrhagic_shock
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 5) IN ('78550')
            OR 
            SUBSTR(icd10_code, 1, 4) IN ('R578','R579')
            THEN 1 
            ELSE 0 END) AS Hypovolemic_non_hemorrhagic_shock,

        --Septic_shock
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 5) IN ('78552')
            OR 
            SUBSTR(icd10_code, 1, 5) IN ('R6521')
            THEN 1 
            ELSE 0 END) AS Septic_shock,
        
        --Anaphylactic_shock
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 4) IN ('9950')
            OR 
            SUBSTR(icd10_code, 1, 4) IN ('T782')
            THEN 1 
            ELSE 0 END) AS Anaphylactic_shock,

        --Liver_failure
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 4) IN ('4560','4561','4562')
            OR
            SUBSTR(icd9_code, 1, 4) BETWEEN '5722' AND '5728'
            OR
            SUBSTR(icd10_code, 1, 4) IN ('I850','I859','I864','I982','K704','K711',
                                                   'K721','K729','K765','K766','K767')
            THEN 1 
            ELSE 0 END) AS Liver_failure,
                
        --Seizures
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 4) IN ('7803')
            OR
            SUBSTR(icd10_code, 1, 3) IN ('R56')
            THEN 1 
            ELSE 0 END) AS Seizures,
        
        --coma(GCS<8)
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 5) IN ('78001')
            OR
            SUBSTR(icd10_code, 1, 4) IN('R4020')
            OR
            SUBSTR(icd10_code, 1, 5) IN ('R40243','R40244')
            THEN 1 
            ELSE 0 END) AS coma,

        --stupor
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 5) IN ('78009')
            OR
            SUBSTR(icd10_code, 1, 4) IN ('R401')
            THEN 1 
            ELSE 0 END) AS stupor,

        --obtunded(state similar to lethargy )
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 5) IN ('78079')
            OR
            SUBSTR(icd10_code, 1, 5) IN ('R5383')
            THEN 1 
            ELSE 0 END) AS obtunded,
        
        --Agitation
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 4) IN ('3079')
            OR
            SUBSTR(icd10_code, 1, 4) IN ('R451')
            THEN 1 
            ELSE 0 END) AS Agitation,

        --Vigilance disturbance
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 5) IN ('79954')
            OR
            SUBSTR(icd10_code, 1, 6) IN ('R41843')
            THEN 1 
            ELSE 0 END) AS Vigilance_disturbance,
        
        --Confusion
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 5) IN  ('2982')
            OR
            SUBSTR(icd10_code, 1, 4) IN ('R410')
            THEN 1 
            ELSE 0 END) AS Confusion,
        
        --Focal_neurologic_deficit
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 3) IN ('433','434','436')
            OR
            SUBSTR(icd9_code, 1, 3) IN ('430','431','432')
            OR
            SUBSTR(icd10_code, 1, 4) IN ('F444')
            THEN 1 
            ELSE 0 END) AS Focal_neurologic_deficit,
        
        --Intracranial_effect(Compression of brain)
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 4) IN ('3484')
            OR
            SUBSTR(icd10_code, 1, 4) IN ('G935')
            THEN 1 
            ELSE 0 END) AS Intracranial_effect,

        --Acute_Abdomen
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 4) IN ('7890')
            OR
            SUBSTR(icd10_code, 1, 4) IN ('R100')
            THEN 1 
            ELSE 0 END) AS Acute_Abdomen,

        
        --SAP(severe is not graded here)
         MAX(CASE WHEN 
            SUBSTR(icd9_code, 1, 4) IN ('5770')
            OR
            SUBSTR(icd10_code, 1, 4) IN ('K859')
            THEN 1 
            ELSE 0 END) AS SAP,
        
   
  
FROM `physionet-data.mimic_core.admissions` ad
LEFT JOIN diag
ON ad.hadm_id = diag.hadm_id
GROUP BY ad.hadm_id
),

infection_1 AS
(SELECT * FROM
(SELECT 
infe.subject_id AS subject_id,
infe.stay_id AS stay_id,
suspected_infection_time,
row_number() over (PARTITION by infe.subject_id ORDER BY suspected_infection_time) AS chart_order 
FROM  `physionet-data.mimic_derived.suspicion_of_infection` infe 
) WHERE chart_order=1
),

infection_2 AS
(SELECT 
stag_1.subject_id AS subject_id,

    CASE WHEN suspected_infection_time IS NOT NULL AND suspected_infection_time>= DATETIME_ADD(stag_1.admittime, INTERVAL '2' DAY)
    THEN 1 ELSE 0
    END AS in_hospital_infection,

FROM infection_1
RIGHT JOIN stag_1 
ON stag_1.subject_id=infection_1.subject_id

),

-- ------------------------------------------------------------------
-- This query(Use_Vasoactive_Drugs_1) extracts whether 
-- Use_Vasoactive_Drugs(including dobutamine,dopamine,epinephrine
-- norepinephrine,phenylephrine,vasopressin)

-- ------------------------------------------------------------------

Use_Vasoactive_Drugs_1 AS
(SELECT * FROM(
SELECT 
subject_id, 
rate,
starttime,
endtime,
row_number() over (PARTITION by subject_id ORDER BY starttime) AS chart_order
FROM `physionet-data.mimic_icu.inputevents`
WHERE itemid IN (221653,   -- dobutamine
                 221662,   -- dopamine
                 221289,   -- epinephrine
                 221906,   -- norepinephrine
                 221749,   -- phenylephrine
                 222315)   -- vasopressin 
                  AND rate != 0 AND rate IS NOT NULL 
)WHERE chart_order=1
),



Use_Vasoactive_Drugs_2 AS
(
SELECT 
stag_1.subject_id,
    CASE WHEN rate IS NOT NULL AND starttime<= DATETIME_ADD(stag_1.admittime,  INTERVAL '6' hour)
    THEN 1 ELSE 0
    END AS Use_Vasoactive_Drugs

FROM Use_Vasoactive_Drugs_1
RIGHT JOIN stag_1 
ON stag_1.subject_id=Use_Vasoactive_Drugs_1.subject_id
),



-- ------------------------------------------------------------------
-- This query(arrhythmia) extracts whether arrhythmia
-- Patients with SR (Sinus Rhythm) OR NULL record are label as 
-- normal (0), all other rhythms are consider as arrhythmia(1)
-- ------------------------------------------------------------------

arrhythmia_1 AS
( 
SELECT * FROM
(SELECT 
subject_id,
heart_rhythm,
charttime,
row_number() over (PARTITION by subject_id ORDER BY charttime) AS chart_order,
FROM `physionet-data.mimic_derived.rhythm` 
WHERE heart_rhythm NOT IN ('SR (Sinus Rhythm)')
) 
WHERE chart_order=1
),

arrhythmia_2 AS
(
SELECT 
stag_1.subject_id,

    CASE WHEN heart_rhythm IS NOT NULL AND charttime <DATETIME_ADD(stag_1.admittime, INTERVAL '6' hour)
    THEN 1 ELSE 0
    END AS arrhythmia

FROM arrhythmia_1
RIGHT JOIN stag_1 
ON stag_1.subject_id =arrhythmia_1.subject_id 
),

stag_2 AS 
(SELECT 
stag_1.subject_id AS subject_idd,
stag_1.admittime AS admittimee,
stag_1.*,
ad.*,
com.*,
vent_2.*,
oxygen_2.*,
fio2_3.*,
infection_2.*,
Use_Vasoactive_Drugs_2.*,
arrhythmia_2.*,

     CASE WHEN Hypovolemic_hemorrhagic_shock+Hypovolemic_non_hemorrhagic_shock+
     Septic_shock+Anaphylactic_shock>=2
    THEN 1 ELSE 0
    END AS Mix_shock,

FROM `physionet-data.mimic_core.admissions` ad
LEFT JOIN com
ON ad.hadm_id = com.hadm_id
INNER JOIN stag_1 
ON stag_1.hadm_id =com.hadm_id 
INNER JOIN vent_2 
ON stag_1.subject_id  =vent_2.subject_id
INNER JOIN oxygen_2  
ON stag_1.subject_id  =oxygen_2.subject_id
INNER JOIN fio2_3 
ON stag_1.subject_id  =fio2_3.subject_id
INNER JOIN infection_2 
ON stag_1.subject_id =infection_2.subject_id 
INNER JOIN Use_Vasoactive_Drugs_2
ON stag_1.subject_id=Use_Vasoactive_Drugs_2.subject_id
INNER JOIN arrhythmia_2 
ON stag_1.subject_id =arrhythmia_2.subject_id
),

chief AS (
SELECT 
chief.subject_id AS subject_id,
chief.stay_id AS stay_id,
intime AS emergecny_intime,
chiefcomplaint,
heartrate,
resprate,
o2sat,
sbp as bloodpressure,	
CASE WHEN UPPER (chiefcomplaint) LIKE UPPER ('%chest pain%') THEN 1 
     ELSE 0 END AS chest_pain,
CASE WHEN UPPER (chiefcomplaint) LIKE UPPER  ('%abdominal pain%') OR
          UPPER (chiefcomplaint) LIKE UPPER('%abd pain%') THEN 1 
     ELSE 0 END AS abdominal_pain,
CASE WHEN UPPER (chiefcomplaint) LIKE UPPER ('%chest tightness%') THEN 1
     ELSE 0 END AS chest_tightness,
CASE WHEN UPPER (chiefcomplaint) LIKE UPPER ('%dyspnea%') OR
          UPPER (chiefcomplaint) LIKE UPPER('%Difficulty breath%') OR 
		  UPPER (chiefcomplaint) LIKE UPPER ('%SOB%') OR
		  UPPER (chiefcomplaint) LIKE UPPER ('SHORTNESS OF BREATH') OR
		  UPPER (chiefcomplaint) LIKE UPPER ('Respiratory distress') THEN 1 
     ELSE 0 END AS dyspnea,
CASE WHEN UPPER (chiefcomplaint) LIKE UPPER ('%fever%') THEN 1 
     ELSE 0 END AS fever,
CASE WHEN UPPER (chiefcomplaint) LIKE UPPER ('%syncope%') THEN 1 
     ELSE 0 END AS syncope,
CASE WHEN UPPER (chiefcomplaint) LIKE UPPER ('%fatigue%') OR 
                (chiefcomplaint) LIKE UPPER ('%weakness%') THEN 1 
     ELSE 0 END AS fatigue,
CASE WHEN UPPER (chiefcomplaint) LIKE UPPER ('%palpitation%') THEN 1 
     ELSE 0 END AS palpitation,
CASE WHEN UPPER (chiefcomplaint) LIKE UPPER ('%Hematemesis%') OR
          UPPER (chiefcomplaint) LIKE UPPER('%vomiting blood%') THEN 1 
     ELSE 0 END AS Hematemesis,	 
CASE WHEN UPPER (chiefcomplaint) LIKE UPPER ('%bloody stool%') OR 
          UPPER (chiefcomplaint) LIKE UPPER('%melena%') THEN 1 
     ELSE 0 END AS bloody_stool,
CASE WHEN UPPER (chiefcomplaint) LIKE UPPER ('%altered mental status%') OR 
          UPPER (chiefcomplaint) LIKE UPPER('%Confusion%') THEN 1      
	 ELSE 0 END AS altered_mental_status,
CASE WHEN UPPER (chiefcomplaint) LIKE UPPER ('%headache%') OR
          UPPER (chiefcomplaint) LIKE UPPER ('%HA%') THEN 1 
     ELSE 0 END AS headache,
CASE WHEN UPPER (chiefcomplaint) LIKE UPPER ('%vomit%') OR 
          UPPER (chiefcomplaint) LIKE UPPER('%N/V/D%') OR 
          UPPER (chiefcomplaint) LIKE UPPER('%N/V%')  THEN 1 
     ELSE 0 END AS vomit

FROM `physionet-data.mimic_ed.triage` chief 
INNER JOIN `physionet-data.mimic_ed.edstays` edstay 
ON edstay.stay_id=chief.stay_id
WHERE chiefcomplaint IS NOT NULL
),

stag_3 AS 
(
SELECT 
admission_age AS age,
chief.*,
stag_2.*,
row_number() over (PARTITION by chief.subject_id ORDER BY emergecny_intime) AS chart_order_final,

    CASE WHEN admittimee<= DATETIME_ADD(emergecny_intime, INTERVAL '1' day)
    THEN 1 ELSE 0
    END AS time_interval,
    
    CASE WHEN admittimee<= DATETIME_ADD(emergecny_intime, INTERVAL '2' hour)
    THEN 1 ELSE 0
    END AS Planed_Admit_ERD,

 FROM chief INNER JOIN stag_2 ON stag_2.subject_idd=chief.subject_id
)



SELECT 
age,
chest_pain,
abdominal_pain,
chest_tightness,
dyspnea,
fever,
syncope,
fatigue,
palpitation,
Hematemesis,	 
bloody_stool,
altered_mental_status,
headache,
vomit,
TRAUMA_YN,
DISCH_DX_RESP,
DISCH_DX_INJURY,
DISCH_DX_NEOPLASMS,
Cancer_Therapy,
ACTIVE_MALIGNANCY,
Hematologic_cancer,
metastatic_solid_tumor,
DISCH_DX_ABNORMAL_NOS,
cerebrovascular_disease,
DISCH_DX_FLU_PNEUMONIA,
DISCH_DX_CHRONIC_LOWER_RESP,
DISCH_DX_CIRC_DISEASE,
chronic_heart_failureIV,
DISCH_DX_DIGESTIVE_DISEASE,
Cirrhosis,
DISCH_DX_GU_DISEASE,
DISCH_DX_OTHER_DISEASE,
STEROID_THERAPY,
DISCH_DX_AIDS,
in_hospital_infection,
Use_Vasoactive_Drugs,
Planed_Admit_ERD,
arrhythmia,
Hypovolemic_hemorrhagic_shock,
Hypovolemic_non_hemorrhagic_shock,
Septic_shock,
Anaphylactic_shock,
Mix_shock,
Liver_failure,
Seizures,
coma,
stupor,
obtunded,
Agitation,
Vigilance_disturbance,
Confusion,
Focal_neurologic_deficit,
Intracranial_effect,
Acute_Abdomen,
SAP,
gcs,
coalesce(resprate,resp_rate) AS first_resprate,
coalesce(heartrate,heart_rate) AS first_heartrate,
coalesce(bloodpressure, sbp) AS first_sbp,
coalesce(o2sat,so2) AS first_o2sat,
fio2,
O2_DEVICE_FIRST,
o2_flow,
ph,
po2,
wbc,
Creatinine,
potassium,
sodium,
bun,
Glucose,
Hemoglobin,
platelet,
bilirubin_total,
(coalesce(heartrate,heart_rate)) / (coalesce(sbp,sbp)) AS xiuke_first,
alive_7day,
FROM stag_3 
WHERE time_interval=1 and chart_order_final=1
AND 
admission_age IS NOT NULL AND 
O2_DEVICE_FIRST IS NOT NULL	AND 
ph IS NOT NULL	AND 
po2	IS NOT NULL AND 
fio2 IS NOT NULL AND 
wbc IS NOT NULL AND	
Creatinine IS NOT NULL AND 
potassium IS NOT NULL AND 	
sodium IS NOT NULL AND 
bun IS NOT NULL AND 
Glucose	IS NOT NULL AND 
Hemoglobin	IS NOT NULL AND 
platelet IS NOT NULL AND 
bilirubin_total	IS NOT NULL AND 
xiuke_first IS NOT NULL AND 
gcs IS NOT NULL AND 
coalesce(o2sat,so2) IS NOT NULL AND
o2_flow IS NOT NULL
