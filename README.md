# Reproduce Prisma No hint returned Error
Turning on RLS causes Postgresql to not return Hint. By changing ROLE, it causes the issue to happen because the new role does not `bypassRLS` param.

<details>

<summary>Sample log with difference shown:</summary>

Notice how `"Key (name)=(A) already exists."` is missing with RLS

```
# error log without rls
2022-08-27 15:57:39.311 UTC,"prisma","postgres",435,"172.29.0.1:32946",630a3ef3.1b3,4,"INSERT",2022-08-27 15:57:39 UTC,6/361,1227,ERROR,23505,"duplicate key value violates unique constraint ""locations_name_key""","Key (name)=(A) already exists.",,,,,"INSERT INTO ""public"".""locations"" (""name"",""abbr"") VALUES ($1,$2) RETURNING ""public"".""locations"".""id""",,,"","client backend",,-681463095680429449
# error log with rls
2022-08-27 15:58:27.844 UTC,"prisma","postgres",448,"172.29.0.1:33014",630a3f23.1c0,4,"INSERT",2022-08-27 15:58:27 UTC,8/87,1229,ERROR,23505,"duplicate key value violates unique constraint ""locations_name_key""",,,,,,"INSERT INTO ""public"".""locations"" (""name"",""abbr"") VALUES ($1,$2) RETURNING ""public"".""locations"".""id""",,,"","client backend",,-681463095680429449
```

</details>

Tested on 
- Postgresql Supabase Local v14.1
- DigitalOcean v14.4.

Note: Was told on Postgresql IRC that this problem does not appear in v15 beta.

In this repo, we try to cause a unique constraint error by inserting duplicate `name`.

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

- Error **correctly** without transaction `localhost:3000/api/passNoTransaction`
    ```
    Clearing locations table
    First time running
    Second time running
    PrismaClientKnownRequestError: 
    Invalid `prisma.location.create()` invocation:


    Unique constraint failed on the fields: (`name`)
    ```

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
- Error **correctly** in transaction AFTER SET local variable `localhost:3000/api/passSetClaim`
    ```
    Clearing locations table
    First time running
    Second time running
    PrismaClientKnownRequestError: 
    Invalid `prisma.$executeRaw()` invocation:


    Unique constraint failed on the fields: (`name`)
    ```
- Error **WRONGLY** in transaction AFTER SET ROLE to prisma `localhost:3000/api/failRlsUsingPrismaRole`
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