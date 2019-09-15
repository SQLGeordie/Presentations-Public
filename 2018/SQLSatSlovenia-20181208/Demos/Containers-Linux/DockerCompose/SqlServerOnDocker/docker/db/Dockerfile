#FROM microsoft/mssql-server-linux:latest
FROM sqlgeordie/sqlonlinuxdemo:demo

RUN apt-get update && apt-get install -y  \
	curl \
	apt-transport-https

# https://docs.microsoft.com/en-us/sql/connect/odbc/linux/installing-the-microsoft-odbc-driver-for-sql-server-on-linux
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

RUN apt-get install -y locales \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

ENV PATH="/opt/mssql-tools/bin:${PATH}"

# Create sql script directory
RUN mkdir -p /usr/src/sqlscript
WORKDIR /usr/src/sqlscript

# Bundle script source
COPY ./shell /usr/src/sqlscript

# Grant permissions for the import-data script to be executable
RUN chmod +x /usr/src/sqlscript/callcreatedocker2dbscript.sh
RUN chmod 755 /usr/src/sqlscript

CMD /bin/bash ./entrypoint.sh
