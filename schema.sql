CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE countries (
    id SERIAL PRIMARY KEY,
    name VARCHAR(60) NOT NULL UNIQUE
);

CREATE TABLE tour_operators (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(254) NOT NULL UNIQUE,
    address TEXT NOT NULL UNIQUE,
    notes TEXT NOT NULL
);

CREATE TABLE carriers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    transport_type VARCHAR(50) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(254) NOT NULL,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'not active')),
    notes TEXT NOT NULL
);

CREATE TABLE promo_codes (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    discount_value INTEGER NOT NULL CHECK (discount_value BETWEEN 1 AND 100),
    date_start DATE NOT NULL,
    date_end DATE NOT NULL,
    usage_limit INTEGER NOT NULL,
    CHECK (date_end > date_start)
);

CREATE TABLE clients (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(254) NOT NULL UNIQUE,
    notes TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    CHECK (created_at > birth_date)
);

CREATE TABLE cities (
    id SERIAL PRIMARY KEY,
    country_id INTEGER NOT NULL REFERENCES countries(id),
    name VARCHAR(100) NOT NULL
);

CREATE TABLE hotels (
    id SERIAL PRIMARY KEY,
    city_id INTEGER NOT NULL REFERENCES cities(id),
    name VARCHAR(100) NOT NULL UNIQUE,
    address TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL,
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(254) NOT NULL
);

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    role_id INTEGER NOT NULL REFERENCES roles(id),
    full_name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(254) NOT NULL UNIQUE,
    hire_date DATE NOT NULL,
    dismissal_date DATE,
    notes TEXT NOT NULL,
    CHECK (hire_date > birth_date),
    CHECK (dismissal_date IS NULL OR dismissal_date > hire_date)
);

CREATE TABLE tours (
    id SERIAL PRIMARY KEY,
    tour_operator_id INTEGER NOT NULL REFERENCES tour_operators(id),
    hotel_id INTEGER NOT NULL REFERENCES hotels(id),
    created_by_employee_id INTEGER NOT NULL REFERENCES employees(id),
    name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    duration_days INTEGER NOT NULL CHECK (duration_days > 0),
    base_price numeric(12, 2) NOT NULL CHECK (base_price > 0)
);

CREATE TABLE tour_departures (
    id SERIAL PRIMARY KEY,
    tour_id INTEGER NOT NULL REFERENCES tours(id),
    departure_date DATE NOT NULL,
    return_date DATE NOT NULL,
    price numeric(12, 2) NOT NULL CHECK (price > 0),
    carrier_id INTEGER NOT NULL REFERENCES carriers(id), 
    CHECK (return_date > departure_date)   
);

CREATE TABLE applications (
    id SERIAL PRIMARY KEY,
    tour_id INTEGER NOT NULL REFERENCES tours(id),
    comment TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL
);

CREATE TABLE tourists (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('Male', 'Female', 'Other')),
    passport_data VARCHAR(10) UNIQUE,
    citizenship VARCHAR(100) NOT NULL,
    notes TEXT NOT NULL
);

CREATE TABLE bookings (
    id SERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL REFERENCES clients(id),
    tour_departure_id INTEGER NOT NULL REFERENCES tour_departures(id),
    manager_id INTEGER NOT NULL REFERENCES employees(id),
    booking_date TIMESTAMP NOT NULL,
    total_price numeric(12, 2) NOT NULL CHECK (total_price > 0),
    paid_amount numeric(12, 2) NOT NULL DEFAULT 0 CHECK (paid_amount >= 0),
    notes TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'pending', 'confirmed', 'paid', 'partially_paid', 'cancelled', 'completed'))
);

CREATE TABLE contracts (
    id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL UNIQUE REFERENCES bookings(id),
    contract_number VARCHAR(50) NOT NULL UNIQUE,
    contract_date DATE NOT NULL,
    file_path VARCHAR(255) NOT NULL
);

CREATE TABLE change_requests (
    id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL REFERENCES bookings(id),
    request_type VARCHAR(50) NOT NULL CHECK (request_type IN ('cancellation', 'date_change', 'hotel_change', 'flight_change', 'refund_request')),
    description TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'in_progress', 'rejected', 'resolved', 'cancelled')),
    created_at TIMESTAMP NOT NULL,
    resolved_at TIMESTAMP,
    penalty_amount numeric(12, 2),
    refund_amount numeric(12, 2),
    comment TEXT NOT NULL, 
    CHECK (resolved_at IS NULL OR resolved_at > created_at)
);

CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    tourist_id INTEGER NOT NULL REFERENCES tourists(id),
    document_type VARCHAR(50) NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    upload_date TIMESTAMP NOT NULL,
    comment TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'uploaded' CHECK (status IN ('uploaded', 'pending_review', 'approved', 'rejected', 'expired'))
);

CREATE TABLE refunds (
    id SERIAL PRIMARY KEY,
    booking_id INTEGER NOT NULL REFERENCES bookings(id),
    amount numeric(12, 2) NOT NULL CHECK (amount >= 0),
    refund_date DATE NOT NULL,
    reason TEXT NOT NULL,
    comment TEXT NOT NULL
);

CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id),
    entity_type VARCHAR(50) NOT NULL,
    action_type VARCHAR(50) NOT NULL,
    old_value TEXT,
    new_value TEXT NOT NULL,
    action_date TIMESTAMP NOT NULL
);

CREATE TABLE booking_tourists (
    booking_id INTEGER NOT NULL REFERENCES bookings(id),
    tourist_id INTEGER NOT NULL REFERENCES tourists(id),
    PRIMARY KEY (booking_id, tourist_id)
);

CREATE TABLE bookings_promo_codes (
    bookings_id INTEGER PRIMARY KEY NOT NULL REFERENCES bookings(id),
    promo_codes_id INTEGER NOT NULL REFERENCES promo_codes(id)
);

CREATE TABLE clients_applications (
    clients_id INTEGER NOT NULL REFERENCES clients(id),
    applications_id INTEGER PRIMARY KEY NOT NULL REFERENCES applications(id)
);

CREATE TABLE employees_change_requests (
    change_requests_id INTEGER NOT NULL REFERENCES change_requests(id),
    employees_id INTEGER NOT NULL REFERENCES employees(id),
    PRIMARY KEY (change_requests_id, employees_id)
);
