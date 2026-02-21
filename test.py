import mysql.connector

conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="",
    database="fleetflow"
)

if(conn):
    print("Connected OK")
