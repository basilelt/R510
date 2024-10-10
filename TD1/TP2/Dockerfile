# Builder stage
FROM alpine:3.20 AS builder

# Install unzip utility - r15 not in alpine 3.20
RUN apk add --no-cache unzip=6.0-r14 && \
    apk cache clean

# Create app directory
WORKDIR /app

# Copy the project files and unzip
COPY django-model-master.zip .
RUN unzip django-model-master.zip && \
    rm django-model-master.zip && \
    mv django-model-master/* . && \
    rm -rf .idea django-model-master __MACOSX && \
    find . -name '*.DS_Store' -type f -delete

# Final stage
FROM python:3.13-alpine

# Use an unprivileged user
RUN adduser -D appuser
USER appuser

# Copy the project files from the builder stage
COPY --from=builder --chown=appuser:appuser /app /app
COPY requirements.txt /app

# Install the dependencies and clean the cache
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir --requirement /app/requirements.txt && \
    rm -rf /app/requirements.txt && \
    apk cache clean

# Set the environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set the volume directory
VOLUME ["/app/modele"]

# Expose the port
EXPOSE 8000

# Set the working directory
WORKDIR /app/modele

# Run the server
ENTRYPOINT ["python", "manage.py", "runserver", "0.0.0.0:8000"]