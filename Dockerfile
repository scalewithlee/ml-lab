# syntax=docker/dockerfile:1.0
FROM python:3.13-alpine
WORKDIR /code

# Install deps for some of the python libraries
RUN apk add --no-cache gcc g++

COPY requirements.txt .
RUN pip install -r requirements.txt

# Configure prefect
RUN prefect config set PREFECT_API_URL=http://127.0.0.1:4200/api
EXPOSE 4200

# Copy source code
COPY pipelines .

# Run it!
CMD ["sh"]
