#!/bin/sh

set -e

# Function to check if migrations are complete
check_migrations() {
    python manage.py showmigrations --plan | grep -q "\\[ \\]" && return 1
    return 0
}

# Wait for migrations to complete
echo "Waiting for migrations to complete..."
while ! check_migrations; do
    sleep 5
done
echo "Migrations completed."

# Start the main application
exec gunicorn modele.wsgi:application --bind 0.0.0.0:8000
