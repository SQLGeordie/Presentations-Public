import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

# Begin variables to customize with your information
glue_source_database = "ugdemo"
glue_source_table = "beers_complex_json"
glue_temp_storage = "s3://<<s3BucketNameHere>>/Beers/Demo/UG/temporary"
glue_relationalize_output_s3_path = "s3://<<s3BucketNameHere>>/Beers/Demo/UG/output/orc"
dfc_root_table_name = "root" #default value is "roottable"
# End variables to customize with your information

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

datasource0 = glueContext.create_dynamic_frame.from_catalog(database = glue_source_database, table_name = glue_source_table, transformation_ctx = "datasource0")

dfc = Relationalize.apply(frame = datasource0, staging_path = glue_temp_storage, name = dfc_root_table_name, transformation_ctx = "dfc")

complexdata = dfc.select(dfc_root_table_name)

complexdataoutput = glueContext.write_dynamic_frame.from_options(frame = complexdata, connection_type = "s3", connection_options ={"path": glue_relationalize_output_s3_path}, format = "orc", transformation_ctx = "complexdataoutput")

job.commit()