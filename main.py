import pandas as pd
import psycopg2
from sqlalchemy import create_engine

# Database connection parameters
db_params = {
    'host': 'localhost',
    'database': 'Housing',
    'user': 'user',
    'password': 'password',
    'port': 'port'
}

# Read the CSV file and skip faulty lines
df = pd.read_csv('C:\\Users\sarp_\Desktop\X\Projects\Data Analyst Portfolio Project 2\housing _data.csv', delimiter=';', on_bad_lines='skip')

# # Explore the data
# pd.set_option('display.max_columns', None)
# pd.set_option('display.expand_frame_repr', False)
# print(df)

try:
    db_connection = psycopg2.connect(**db_params)

    # Check if the database connection is established
    if db_connection:
        # If connected, print a message indicating a successful connection
        print("Connected")

        # Create a SQLAlchemy engine for PostgreSQL using the db_params dictionary
        engine = create_engine(f"postgresql://{db_params['user']}:{db_params['password']}@{db_params['host']}:{db_params['port']}/{db_params['database']}")

        # Write the DataFrame to the PostgreSQL table 'table_name'
        df.to_sql('housing', con=engine, if_exists='append', index=False)

        # Close the database connection
        db_connection.close()

except Exception as e:
    # If there is an exception during the database connection attempt, print a more specific error message
    print(f"Error during database connection: {e}")

