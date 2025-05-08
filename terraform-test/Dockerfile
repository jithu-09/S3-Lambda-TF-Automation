FROM python:3.11-slim

WORKDIR /app

COPY src/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY src/* .

EXPOSE 5000 
#5000 is the default port for Flask

CMD ["python", "app.py"]