# 1. Use an official lightweight Python image as the base
FROM python:3.9-slim

# 2. Set the working directory inside the container
WORKDIR /app

# 3. Copy the dependency file first (for caching)
COPY requirements.txt .

# 4. Install dependencies inside the container
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copy the rest of the application code
COPY . .

# 6. Command to run the app when the container starts
CMD ["python3", "app.py"]