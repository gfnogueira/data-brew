ATTACH 'ducklake:postgres:dbname=' || getenv('CATALOG_DB')
       || ' host=' || getenv('CATALOG_HOST')
       || ' port=' || getenv('CATALOG_PORT')
       || ' user=' || getenv('CATALOG_USER')
       || ' password=' || getenv('CATALOG_PASSWORD')
  AS poc_lake (DATA_PATH 's3://lakehouse/data/');

USE poc_lake;
