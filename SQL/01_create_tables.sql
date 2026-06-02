DROP DATABASE IF EXISTS retail_intelligence;
CREATE DATABASE retail_intelligence
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE retail_intelligence;

CREATE TABLE brands (
    brand_id    INT          NOT NULL AUTO_INCREMENT,
    brand_name  VARCHAR(100) NOT NULL,
    PRIMARY KEY (brand_id)
);

CREATE TABLE categories (
    category_id   INT          NOT NULL AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (category_id)
);

CREATE TABLE stores (
    store_id   INT          NOT NULL AUTO_INCREMENT,
    store_name VARCHAR(100) NOT NULL,
    phone      VARCHAR(25)  NULL,
    email      VARCHAR(150) NULL,
    street     VARCHAR(255) NULL,
    city       VARCHAR(100) NULL,
    state      CHAR(10)     NULL,
    zip_code   VARCHAR(10)  NULL,
    PRIMARY KEY (store_id)
);

CREATE TABLE products (
    product_id   INT            NOT NULL AUTO_INCREMENT,
    product_name VARCHAR(255)   NOT NULL,
    brand_id     INT            NOT NULL,
    category_id  INT            NOT NULL,
    model_year   SMALLINT       NOT NULL,
    list_price   DECIMAL(10,2)  NOT NULL,
    PRIMARY KEY (product_id),
    FOREIGN KEY (brand_id)    REFERENCES brands(brand_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE staffs (
    staff_id   INT          NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50)  NOT NULL,
    last_name  VARCHAR(50)  NOT NULL,
    email      VARCHAR(150) NOT NULL UNIQUE,
    phone      VARCHAR(25)  NULL,
    active     TINYINT(1)   NOT NULL DEFAULT 1,
    store_id   INT          NOT NULL,
    manager_id INT          NULL,
    PRIMARY KEY (staff_id),
    FOREIGN KEY (store_id)   REFERENCES stores(store_id),
    FOREIGN KEY (manager_id) REFERENCES staffs(staff_id)
);

CREATE TABLE customers (
    customer_id INT          NOT NULL AUTO_INCREMENT,
    first_name  VARCHAR(50)  NOT NULL,
    last_name   VARCHAR(50)  NOT NULL,
    phone       VARCHAR(25)  NULL,
    email       VARCHAR(150) NULL,
    street      VARCHAR(255) NULL,
    city        VARCHAR(100) NULL,
    state       CHAR(10)     NULL,
    zip_code    VARCHAR(10)  NULL,
    PRIMARY KEY (customer_id)
);

CREATE TABLE orders (
    order_id      INT     NOT NULL AUTO_INCREMENT,
    customer_id   INT     NOT NULL,
    order_status  TINYINT NOT NULL,
    order_date    DATE    NOT NULL,
    required_date DATE    NOT NULL,
    shipped_date  DATE    NULL,
    store_id      INT     NOT NULL,
    staff_id      INT     NOT NULL,
    PRIMARY KEY (order_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (store_id)    REFERENCES stores(store_id),
    FOREIGN KEY (staff_id)    REFERENCES staffs(staff_id)
);

CREATE TABLE order_items (
    order_id   INT            NOT NULL,
    item_id    INT            NOT NULL,
    product_id INT            NOT NULL,
    quantity   INT            NOT NULL DEFAULT 1,
    list_price DECIMAL(10,2)  NOT NULL,
    discount   DECIMAL(4,2)   NOT NULL DEFAULT 0.00,
    PRIMARY KEY (order_id, item_id),
    FOREIGN KEY (order_id)   REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE stocks (
    store_id   INT NOT NULL,
    product_id INT NOT NULL,
    quantity   INT NOT NULL DEFAULT 0,
    PRIMARY KEY (store_id, product_id),
    FOREIGN KEY (store_id)   REFERENCES stores(store_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);