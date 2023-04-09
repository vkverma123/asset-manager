# AssetManager

## Requirements

- Elixir 1.11.3
- Docker

## Setup

1. Install dependencies:

```shell
$ mix deps.get
```

2. Start Postgres with Docker:

```shell
$ docker-compose up -d
```

3. Create the database and run migrations:

```shell
$ mix ecto.setup
```

4. Create an initialise the event store:

```shell
$ mix es.setup
```

5. Start your Phoenix server:

```shell
$ mix phx.server
```

It will be available on [`localhost:10000`](http://localhost:10000)


## Endpoints

| Endpoint             | Request(Action) |
| -------------------- | --------------- |
| `/api/deposit`       | Deposit         |
| `/api/list-balances` | ListBalances    |
