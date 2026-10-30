#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
DBT_PROJECT="$PROJECT_ROOT/market_regime_dbt"

echo "==============================="
echo "Running dbt..."
echo "==============================="

cd "$DBT_PROJECT" || exit 1

dbt run

if [ $? -ne 0 ]; then
    echo "dbt failed."
    exit 1
fi

echo "==============================="
echo "Exporting Power BI parquet..."
echo "==============================="

cd "$PROJECT_ROOT" || exit 1

python scripts/export_powerbi.py

if [ $? -ne 0 ]; then
    echo "Parquet export failed."
    exit 1
fi

echo "==============================="
echo "Done!"
echo "==============================="