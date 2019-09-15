FROM sqlgeordie/sqlonlinuxdemo:demo

# Create sql script directory
RUN mkdir -p /usr/src/sqlscript
WORKDIR /usr/src/sqlscript

# Bundle script source
COPY ./shell /usr/src/sqlscript

# Grant permissions for the import-data script to be executable
RUN chmod +x /usr/src/sqlscript/restoredbs.sh
# RUN chmod 755 /usr/src/sqlscript

#Set SQL Server Config, limit container (not SQL Instance) memory to 3000MB
#Changed default port from 1433 to 15105
ENV ACCEPT_EULA="Y"  \
	MSSQL_SA_PASSWORD="P@ssword1"  \
	MSSQL_MEMORY_LIMIT_MB="3000"  \ 
	MSSQL_TCP_PORT="15105"  \
	MSSQL_PID="Standard" 

CMD /bin/bash ./entrypoint.sh