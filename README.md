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


## Description

As per the discussion, I have completed this project using Elixir and Phoenix Framework and submitted on the link also with all the details as below. Please forward or loop the engineering team also in this email for easier context.

I have implemented the project using event sourcing and implemented the CQRS pattern (Command Query Responsibility Segregation). It relates to the concept of Domain Driven Design. It is a pattern that separates the responsibilities of reading and writing data in a system into separate components. As per the CQRS concept, I have implemented commands, aggregates, router, events, and projector. Aggregates can be seen as holders of state, receiving commands and emitting events after mutating their internal state.  Once those events are emitted, the aggregate runs its apply functions that mutate the internal state informed by the event’s values. Routers match commands to aggregates that will handle them. Events are just like commands but they will be put in past tense. There is an event store to store the events. Projectors are the components that subscribe to events and change the read model. Here the read model is the DepositTransaction Table. I have added an index for created_at (datetime) column for faster queries for api/list-balances API. This API will return the total wallet balance every hour between start_datetime and end_datetime. API api/deposit will accept datetime and amount. Since the time zones can be different I have converted them to UTC Time Zone, since API api/list-balances returns JSON response in UTC Time Zone only.

Please refer to snapshots for more details in the snapshots folder in the code repo. Please let me know if there are any queries.

Github Link : https://github.com/vkverma123/asset-manager
Snapshots Folder Link: https://github.com/vkverma123/asset-manager/tree/main/snapshots

Further, please refer the following details :

 - Yes I have used Git.
 - The code is very clear and segregated into modules.
 - My APIs can handle incorrect data and return responses accordingly (Refer snapshots).
 - I have followed the best practices and coding patterns.
 - Code and architecture is expandable.
 - I have followed Domain Driven Design (DDD) and submodules.
 - Implemented CQRS pattern to segregate read and write operations.
 - Implemented Unit Tests also and they are passed.
 - It can be tested locally. I have thoroughly tested in my local machine with different test scenarios and it's working fine. I have mentioned the steps in README.md and refer to snapshots for payload info.
 - Please refer to router.ex in the code for API Paths.



Note: 
There can be one more way to return the sum every hour from the write model.
So, I have also raised a small PR : https://github.com/vkverma123/asset-manager/pull/1 (Pull Request) for rolling sum logic. If this app is facing huge amount of traffic, then while inserting the data in the write model, we can firstly fetch the existing amount and update the entry of amount by doing the sum of existing amount and upcoming new amount for that hour. PR is not yet merged.
It will be more efficient. It's just one more way to make it bit faster even though I already have index on created_at column.
 
<img width="884" alt="Screen Shot 2566-04-20 at 00 36 31" src="https://user-images.githubusercontent.com/87823879/233382095-f3fbb44b-309d-44d4-b818-61b66b3d5b62.png">
<img width="896" alt="Screen Shot 2566-04-20 at 00 36 49" src="https://user-images.githubusercontent.com/87823879/233382153-71977611-3e41-4c83-9de1-eed853f8ac03.png">
<img width="920" alt="Screen Shot 2566-04-20 at 20 28 14" src="https://user-images.githubusercontent.com/87823879/233382161-15a1cef8-7a16-4929-8bae-b4d62ddd03d1.png">
<img width="933" alt="Screen Shot 2566-04-20 at 20 28 26" src="https://user-images.githubusercontent.com/87823879/233382167-05993d21-ff04-42d8-b9dd-5eed23d0e8e1.png">
<img width="932" alt="Screen Shot 2566-04-20 at 20 28 34" src="https://user-images.githubusercontent.com/87823879/233382172-06d7ede3-0f8f-447a-9eb1-b5e556e1ded2.png">
