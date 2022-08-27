# Reproduce Prisma Set Role Error
SET LOCAL ROLE to another in `$transaction` causes error messages to miss

## Setup

1. Run
    ```bash
    $ yarn
    $ yarn prisma migrate dev
    ```

2. `cp .env.sample .env` and fill

## Run

```bash
$ yarn dev
```

Go to:

- Error **correctly** in transaction `localhost:3000/api/passCreateInTransaction`
- Error **correctly** in transaction AFTER SET ROLE to self `localhost:3000/api/passSetRoleToSelf`
- Error **WRONGLY** in transaction AFTER SET ROLE to other `localhost:3000/api/failSetRoleToPrisma`

### Other cases

The issue also occurs if `@@map` is used.

Reproduce by: 

1. Move `prisma/migrations_old` to `prisma/migrations`
2. Move `prisma/schema for @map.prisma` to `prisma/schema.prisma`