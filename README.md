# Reproduce Prisma Set Role Error
SET LOCAL ROLE to another in `$transaction` causes error messages to miss metadata. In this case, we try to cause a unique constraint error by inserting duplicate `name`.

Each api route:

1. Clears `Location` table
2. Insert `{name: 'A', abbr: 'a'}`
2. Insert `{name: 'A', abbr: 'b'}` <-- error should happen here

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
    ```
    Clearing locations table
    First time running
    Second time running
    PrismaClientKnownRequestError: 
    Invalid `prisma.location.create()` invocation:


    Unique constraint failed on the fields: (`name`)
    ```
- Error **correctly** in transaction AFTER SET ROLE to self `localhost:3000/api/passSetRoleToSelf`
    ```
    Clearing locations table
    First time running
    Second time running
    PrismaClientKnownRequestError: 
    Invalid `prisma.$executeRaw()` invocation:


    Unique constraint failed on the fields: (`name`)
    ```
- Error **WRONGLY** in transaction AFTER SET ROLE to other `localhost:3000/api/failSetRoleToPrisma`
    ```
    Clearing locations table
    First time running
    Second time running
    PrismaClientKnownRequestError: 
    Invalid `prisma.$executeRaw()` invocation:


    Unique constraint failed on the (not available)
  ```

### Other cases

The issue also occurs if `@@map` is used.

Reproduce by: 

1. Move `prisma/migrations_old` to `prisma/migrations`
2. Move `prisma/schema for @map.prisma` to `prisma/schema.prisma`