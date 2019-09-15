FROM microsoft/mssql-server-linux:2017-GA

RUN mkdir -p /usr/src/sqlscript
WORKDIR /usr/src/sqlscript

# Bundle script source
COPY ./shell/*.sh /usr/src/sqlscript/
COPY ./shell/*.*df /var/opt/mssql/data/

ENV SA_PASSWORD=P@ssword1
ENV	ACCEPT_EULA=Y

RUN chmod 755 /var/opt/mssql/data

HEALTHCHECK --interval=10s  \
	CMD /opt/mssql-tools/bin/sqlcmd -S . -U sa -P P@ssword1 \
		-Q "CREATE DATABASE [AdventureWorks2012] ON (FILENAME = '/var/opt/mssql/data/AdventureWorks2012_Data.mdf'),(FILENAME = '/var/opt/mssql/data/AdventureWorks2012_log.ldf') FOR ATTACH"

CMD /bin/bash ./entrypoint.sh