/* V1 and V2 are immutable on databases already managed by Flyway.
   Google sign-in keeps the provider subject in accounts; OAuth access and
   refresh tokens are no longer persisted in the AURA database. */
DROP TABLE google_oauth_tokens;
