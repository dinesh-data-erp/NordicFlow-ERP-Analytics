# -------------------------------------------------
# NordicFlow ERP Data Loader
# Reusable functions for Project 5 analytics
# -------------------------------------------------

import sqlite3
import pandas as pd
from pathlib import Path


def connect_database(db_path):
    """
    Create a connection to the NordicFlow SQLite database.
    """
    return sqlite3.connect(Path(db_path))


def load_table(conn, table_name):
    """
    Load one SQLite table into a pandas DataFrame.
    """
    query = f"SELECT * FROM {table_name}"

    return pd.read_sql_query(
        query,
        conn
    )


def clean_currency(series):
    """
    Convert ERP-formatted currency text into numeric values.

    Example:
    '€5 120.00' -> 5120.00
    """
    return pd.to_numeric(
        series
        .astype(str)
        .str.replace(r"[^\d.-]", "", regex=True),
        errors="coerce"
    )


def convert_boolean_flag(series):
    """
    Convert common ERP TRUE/FALSE formats into 1/0.
    """
    return (
        series
        .astype(str)
        .str.strip()
        .str.upper()
        .map({
            "TRUE": 1,
            "FALSE": 0,
            "1": 1,
            "0": 0
        })
    )


def load_core_erp_data(db_path):
    """
    Load all seven NordicFlow ERP tables.

    Returns:
        Dictionary of pandas DataFrames.
    """

    conn = connect_database(db_path)

    tables = {
        "material": load_table(
            conn,
            "material_master"
        ),

        "supplier": load_table(
            conn,
            "supplier_master"
        ),

        "plant": load_table(
            conn,
            "plant_master"
        ),

        "bom": load_table(
            conn,
            "bom"
        ),

        "inventory": load_table(
            conn,
            "inventory_snapshot"
        ),

        "purchase_orders": load_table(
            conn,
            "purchase_order_lines"
        ),

        "production": load_table(
            conn,
            "production_orders"
        )
    }

    return tables