-- ------------------------------------------------------------------
-- This query extracts first oxygen status based on the mimic_derived.oxygen_delivery
-- Converted into O2_DEVICE_FIRST that match code in JI program 
-- code for mimic_derived.oxygen_delivery: https://github.com/zqr2008/mimic-code/blob/main/mimic-iv/concepts/measurement/oxygen_delivery.sql
-- ------------------------------------------------------------------

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
