CREATE OR REPLACE SECRET storage_secret (
  TYPE        S3,
  KEY_ID      getenv('STORAGE_ACCESS_KEY'),
  SECRET      getenv('STORAGE_SECRET_KEY'),
  ENDPOINT    'localhost:9000',
  REGION      getenv('STORAGE_REGION'),
  URL_STYLE   'path',
  USE_SSL     false
);
