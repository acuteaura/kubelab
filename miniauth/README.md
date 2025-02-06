# miniauth

go stateless service to point nginx subrequest auth at

## GET /barekey/:key

Will return 200 if `:key` is supplied as Bearer token (`Authorization: Bearer :key`).
Will return 403 otherwise.
