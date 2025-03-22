-- # After the database has been created for the project, the tables were created using the following SQL commands:
# countries
CREATE TABLE countries (
    country_id SERIAL PRIMARY KEY,
    country_name VARCHAR(100) UNIQUE NOT NULL,
    country_code CHAR(3) UNIQUE NOT NULL
);

# economic indicators 
CREATE TABLE economic_indicators (
    indicator_id SERIAL PRIMARY KEY,
    country_id INT REFERENCES countries(country_id),
    year INT NOT NULL,
    gdp NUMERIC(15,2),
    inflation_rate NUMERIC(5,2),
    trade_balance NUMERIC(15,2),
    UNIQUE (country_id, year)
);

# exchange rates

CREATE TABLE exchange_rates (
    rate_id SERIAL PRIMARY KEY,
    country_id INT REFERENCES countries(country_id),
    currency_code CHAR(3) NOT NULL,
    year INT NOT NULL,
    exchange_rate NUMERIC(10,4),
    UNIQUE (country_id, currency_code, year)
);


# stock_price 

CREATE TABLE stock_prices (
    stock_id SERIAL PRIMARY KEY,
    company_name VARCHAR(100),
    country_id INT REFERENCES countries(country_id),
    stock_symbol VARCHAR(20) NOT NULL,
    trade_date DATE NOT NULL,
    open_price NUMERIC(10,2),
    close_price NUMERIC(10,2),
    volume BIGINT,
    market_index BIGINT, -- New column
    volatility DECIMAL(5,2), -- New column
    UNIQUE (stock_symbol, trade_date) -- Ensures no duplicate symbols per day
);



# financial reports 

CREATE TABLE financial_reports (
    report_id SERIAL PRIMARY KEY,
    company_name VARCHAR(100),
    year INT NOT NULL,
    revenue NUMERIC(15,2),
    net_income NUMERIC(15,2),
    assets NUMERIC(15,2),
    liabilities NUMERIC(15,2)
);
