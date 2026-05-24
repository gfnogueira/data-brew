USE poc_lake;

CREATE TABLE IF NOT EXISTS users (
  user_id      UUID         NOT NULL,
  email        VARCHAR      NOT NULL,
  signup_at    TIMESTAMP    NOT NULL,
  country      VARCHAR      NOT NULL,
  tier         VARCHAR      NOT NULL
);

CREATE TABLE IF NOT EXISTS events (
  event_id     UUID            NOT NULL,
  event_time   TIMESTAMP       NOT NULL,
  user_id      UUID            NOT NULL,
  event_type   VARCHAR         NOT NULL,
  platform     VARCHAR         NOT NULL,
  region       VARCHAR         NOT NULL,
  amount       DECIMAL(12, 2)  NOT NULL DEFAULT 0,
  status_code  SMALLINT        NOT NULL DEFAULT 0
);
