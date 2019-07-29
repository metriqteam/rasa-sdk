FROM python:3.6.8-slim

SHELL ["/bin/bash", "-c"]

RUN apt-get update -qq && \
  apt-get install -y --no-install-recommends \
  build-essential && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  mkdir /app

# install SQL Server drivers
RUN apt-get update && \
  apt-get install -y gnupg && \
  apt-get install -y gnupg2 && \
  apt-get install -y gnupg1 && \
  apt-get install -y curl

RUN apt-get update \
    && apt-get -y install unixodbc-dev \
    && pip install pyodbc \
    && apt-get -y install apt-transport-https \
    && apt-get -y install gnupg \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql17 unixodbc-dev

WORKDIR /app

# Copy as early as possible so we can cache ...
COPY requirements.txt .

RUN pip install -r requirements.txt --no-cache-dir

COPY . .

RUN pip install -e . --no-cache-dir

VOLUME ["/app/actions"]

EXPOSE 5055

ENTRYPOINT ["./entrypoint.sh"]

CMD ["start", "--actions", "actions.actions"]
