-- Създай си схема (ако още нямаш)
CREATE DATABASE IF NOT EXISTS bus_tickets
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE bus_tickets;

-- Таблица с градове
CREATE TABLE Cities (
  city_id   INT AUTO_INCREMENT PRIMARY KEY,
  name      VARCHAR(50) NOT NULL,
  CONSTRAINT uq_cities_name UNIQUE (name)
);

-- Маршрути между градове
CREATE TABLE Routes (
  route_id        INT AUTO_INCREMENT PRIMARY KEY,
  direction       ENUM('one_way', 'round_trip') NOT NULL,
  duration        VARCHAR(20) NOT NULL,
  depart_city_id  INT NOT NULL,
  arrive_city_id  INT NOT NULL,
  CONSTRAINT fk_routes_depart_city
    FOREIGN KEY (depart_city_id) REFERENCES Cities(city_id),
  CONSTRAINT fk_routes_arrive_city
    FOREIGN KEY (arrive_city_id) REFERENCES Cities(city_id),
  CONSTRAINT ck_routes_depart_not_arrive
    CHECK (depart_city_id <> arrive_city_id)
);

-- Конкретни пътувания (заминавания) по маршрут
CREATE TABLE Trips (
  trip_id     INT AUTO_INCREMENT PRIMARY KEY,
  route_id    INT NOT NULL,
  dep_date    DATE NOT NULL,
  dep_time    TIME NOT NULL,
  arr_time    TIME NOT NULL,
  price       DECIMAL(8,2) NOT NULL CHECK (price > 0),
  free_seats  INT NOT NULL CHECK (free_seats >= 0),
  status      ENUM('active','cancelled','full','limited') NOT NULL DEFAULT 'active',
  CONSTRAINT fk_trips_route
    FOREIGN KEY (route_id) REFERENCES Routes(route_id)
);

-- Места за конкретно пътуване (seat_map)
CREATE TABLE Seats (
  seat_id      INT AUTO_INCREMENT PRIMARY KEY,
  trip_id      INT NOT NULL,
  seat_number  INT NOT NULL,
  preference   ENUM('window','aisle','other') DEFAULT 'other',
  CONSTRAINT fk_seats_trip
    FOREIGN KEY (trip_id) REFERENCES Trips(trip_id),
  CONSTRAINT uq_seats_trip_seatnumber
    UNIQUE (trip_id, seat_number),
  CONSTRAINT ck_seats_number_positive
    CHECK (seat_number > 0)
);

-- Резервации/покупки за конкретно пътуване
CREATE TABLE Reservations (
  reservation_id INT AUTO_INCREMENT PRIMARY KEY,
  trip_id        INT NOT NULL,
  currency       ENUM('BGN','EUR') NOT NULL DEFAULT 'BGN',
  total_amount   DECIMAL(10,2) NOT NULL CHECK (total_amount > 0),
  status         ENUM('calculated','pending','paid') NOT NULL DEFAULT 'calculated',
  CONSTRAINT fk_reservations_trip
    FOREIGN KEY (trip_id) REFERENCES Trips(trip_id)
);

-- Конкретни места по резервация (много към много между Reservations и Seats)
CREATE TABLE ReservationSeats (
  resseat_id     INT AUTO_INCREMENT PRIMARY KEY,
  reservation_id INT NOT NULL,
  seat_id        INT NOT NULL,
  ticket_price   DECIMAL(8,2) NOT NULL CHECK (ticket_price > 0),
  CONSTRAINT fk_resseat_reservation
    FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id),
  CONSTRAINT fk_resseat_seat
    FOREIGN KEY (seat_id) REFERENCES Seats(seat_id),
  CONSTRAINT uq_resseat_seat
    UNIQUE (seat_id)  -- едно място да не се продава два пъти
);
