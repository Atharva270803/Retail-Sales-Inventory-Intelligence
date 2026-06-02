USE retail_intelligence;
INSERT IGNORE INTO brands (brand_id, brand_name) VALUES
(1,'Electra'),(2,'Haro'),(3,'Heller'),(4,'Pure Cycles'),
(5,'Ritchey'),(6,'Strider'),(7,'Sun Bicycles'),(8,'Surly'),(9,'Trek');

INSERT IGNORE INTO categories (category_id, category_name) VALUES
(1,'Children Bicycles'),(2,'Comfort Bicycles'),(3,'Cruisers Bicycles'),
(4,'Cyclocross Bicycles'),(5,'Electric Bikes'),(6,'Mountain Bikes'),(7,'Road Bikes');

INSERT IGNORE INTO stores (store_id,store_name,phone,email,street,city,state,zip_code) VALUES
(1,'Santa Cruz Bikes','(831) 476-4321','santacruz@bikes.shop','3700 Portola Drive','Santa Cruz','CA','95060'),
(2,'Baldwin Bikes','(516) 379-8888','baldwin@bikes.shop','4200 Chestnut Lane','Baldwin','NY','11432'),
(3,'Rowlett Bikes','(972) 530-5555','rowlett@bikes.shop','8000 Fairway Avenue','Rowlett','TX','75088');

INSERT IGNORE INTO staffs (staff_id,first_name,last_name,email,phone,active,store_id,manager_id) VALUES
(1,'Fabiola','Jackson','fabiola.jackson@bikes.shop','(831) 555-5554',1,1,NULL),
(5,'Jannette','David','jannette.david@bikes.shop','(516) 379-4444',1,2,NULL),
(8,'Kali','Vargas','kali.vargas@bikes.shop','(972) 530-5555',1,3,NULL);

INSERT IGNORE INTO staffs (staff_id,first_name,last_name,email,phone,active,store_id,manager_id) VALUES
(2,'Mireya','Copeland','mireya.copeland@bikes.shop','(831) 555-5555',1,1,1),
(3,'Genna','Serrano','genna.serrano@bikes.shop','(831) 555-5556',1,1,2),
(4,'Virgie','Wiggins','virgie.wiggins@bikes.shop','(831) 555-5557',1,1,2),
(6,'Marcelene','Boyer','marcelene.boyer@bikes.shop','(516) 379-4445',1,2,5),
(7,'Venita','Daniel','venita.daniel@bikes.shop','(516) 379-4446',1,2,5),
(9,'Layla','Terrell','layla.terrell@bikes.shop','(972) 530-5556',1,3,8),
(10,'Bernardine','Houston','bernardine.houston@bikes.shop','(972) 530-5557',1,3,8);