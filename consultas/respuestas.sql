-- 1. Consultar la tablas de la base de datos
SELECT name
FROM sqlite_master
WHERE type = 'table';
-- Hallazgo: Las tablas son crime_scene_report, drivers_license,  facebook_event_checkin, interview, get_fit_now_member, get_fit_now_check_in, solution, income y person.

-- 2. Consultar el reporte del crimen en `crime_scene_report` para la fecha, ciudad y tipo de crimen indicados
SELECT *
FROM crime_scene_report
WHERE date = 20180115
	AND city = 'SQL City'
	AND type = 'murder';
-- Hallazgo: Hay 2 testigos, el primero vive en la última calle en "Northwestern Dr", el segundo se llama "Annabel" y vivel en algún lugar de "Franklin Ave"

-- 3. Consultar los detalles del segundo testigo
SELECT *
FROM person
WHERE name LIKE '%Annabel%'
	AND address_street_name = 'Franklin Ave';
-- Hallazgo:
--   - id: 16371
--   - name: Anabel Miller
--   - license_id: 490173
--   - address_number: 103
--   - address_street_name: Franklin Ave
--   - ssn: 318771143

-- 4. Consultar los detalles del primer testigo
SELECT *
FROM person
WHERE address_street_name = 'Northwestern Dr'
ORDER BY address_number DESC
LIMIT 1;
-- Hallazgo:
--   - id: 14887
--   - name: Morty Schapiro
--   - license_id: 118009
--   - address_number: 4919
--   - address_street_name: Northwestern Dr
--   - ssn: 111564949

-- 5. Consultar las entrevistas
SELECT *
FROM interview
WHERE person_id in (16371, 14887);
-- Hallazgo: 
--   - Morty Schapiro: Dijo que escuchó un disparo y vio a un **hombre** salir corriendo, este hombre tenía un bolso del gimnasio "Get Fit Now Gym", al parecer era un miembro de categoría gold, porque el identificador de su bolso comenzaba por "48Z", finalmente se subió en un automovil que tiene contiene "H42W" en su placa.
--   - Anabel Miller: Vio el asesinato suceder y reconoció al asesino de su gimnasio, donde estuvo entrenando en Enero 9.

-- 6. Consultar los miembros de "Get Fit Now Gym" (GFNG) que pueden ser sospechosos
SELECT *
FROM get_fit_now_member
INNER JOIN person
ON person.id = get_fit_now_member.person_id
WHERE get_fit_now_member.id LIKE '48Z%'
	AND membership_status = 'gold';
-- Hallazgo:
--   - Joe Germuska (SSN: 138909730, Person Id: 28819, GFNG Id: 48Z7A, License Id: 173289)
--   - Jeremy Bowers (SSN: 871539279, Person Id: 67318, GFNG Id: 48Z55, License Id: 423327)

-- 7. Consultar las licencias que hagan match con la placa y los sospechosos que tenemos
SELECT *
FROM drivers_license
INNER JOIN person
ON person.license_id = drivers_license.id
WHERE plate_number LIKE '%H42W%'
	AND gender = 'male'
	AND drivers_license.id IN (173289, 423327);
-- Hallazgo: Jeremy Bowers, es el sospechoso principal, quien conduce un Chevrolet Spark LS con placas 0H42W2. El sujeto tiene 30 años, mide 70 in, tiene ojos y cabello cafés y es de género masculino.

-- 8. Consultar el los ingresos a GFNG en Enero 9 relacionados a nuestros sospechosos
SELECT person.name,
	get_fit_now_check_in.check_in_date,
	get_fit_now_check_in.check_in_time,
	get_fit_now_check_in.check_out_time
FROM get_fit_now_check_in
INNER JOIN get_fit_now_member
ON get_fit_now_check_in.membership_id = get_fit_now_member.id
INNER JOIN person
ON get_fit_now_member.person_id = person.id
WHERE check_in_date = 20180109
	AND membership_id IN ('48Z7A', '48Z55');
-- Hallazgo: Ambos sospechosos, tanto el principal, como Jeremy Bowers, estuvieron en el gimnasio el dia que Anabel dice haber visto al asesino
--   - Jeremy Bowers: Ingresó a las 15:30 y salió a las 17:00
--   - Joe Germuska: Ingresó a las 16:00 y salió a las 17:30

-- 9. Consultamos si existen entrevistas a los dos sospechosos
SELECT person.name,
	interview.transcript
FROM interview
INNER JOIN person
ON interview.person_id = person.id
WHERE person.id IN (28819, 67318);
-- Hallazgo: Jeremy Bowers confiesa haber sido contratado y describe a quien lo contrató: Mujer, muy pudiente, entre 65 in y 67 in, con cabello rojo, conduce un Tesla Model S y asistió al SQL Symphony Concert 3 veces en Diciembre 2017

-- 10. Creamos un query completo para hallar a la autora intelectual
SELECT person.name AS name,
	income.annual_income AS income,
	license.height AS height,
	license.hair_color AS hair_color,
	license.car_make AS car_make,
	license.car_model AS car_model,
	COUNT(*) AS num_concerts
FROM drivers_license AS license
INNER JOIN person
ON license.id = person.license_id
INNER JOIN income
ON person.ssn = income.ssn
INNER JOIN facebook_event_checkin AS events
ON person.id = events.person_id
WHERE gender = 'female'
	AND license.height BETWEEN 65 AND 67
	AND license.hair_color = 'red'
	AND license.car_make = 'Tesla'
	AND license.car_model = 'Model S'
	AND events.date BETWEEN 20171201 AND 20171231;
-- Hallazgo: La autora intelectual fue Miranda Priestly, quien tiene un ingreso deo US $ 310.000, 66 años, mide 66 in, tiene cabello rojo, conduce un Tesla Model S y fué 3 veces al evento mencionado en la confesión.
