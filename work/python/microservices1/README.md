https://www.youtube.com/watch?v=ddrucr_aAzA

django-admin startproject admin
cd admin
python3 manage.py runserver

Create Dockerfile

FROM python:3.9
ENV PYTHONUNBUFFERED 1
WORKDIR /app
COPY requirements.txt /app/requirements.txt
RUN pip install -r requirements.txt
COPY . /app

CMD python manage.py runserver 0.0.0.0:8000

Create docker-compose.yml

version: '3.3'
services:
  backend:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - 8000:8000
    volumes:
      - .:/app
