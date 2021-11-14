-- ------------------------------------------------------------------
-- Plese note that this query's logic is different from others due to clinical reality.
-- The reason for different logic:
                                  1.fiO2 extract from `physionet-data.mimic_derived.ventilator_setting` only represent fio2 of ventilator
                                    ,those who are not on ventilator may be missing;
                                  2.The fio2 of oxygen in nasal cannula and oxymizer is 21+4*o2_flow in clinical setting; 
                                  3.To obtain fio2 for all patients,fio2 needs be recalculated considering different oxygen status;
-- code for mimic_derived.ventilation: https://github.com/zqr2008/mimic-code/blob/main/mimic-iv/concepts/treatment/ventilation.sql
-- code for mimic_derived.oxygen_delivery: https://github.com/zqr2008/mimic-code/blob/main/mimic-iv/concepts/measurement/oxygen_delivery.sql
-- ------------------------------------------------------------------

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
