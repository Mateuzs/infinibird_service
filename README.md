# InfinibirdService

A microservice fully built in Elixir. It's a part of system which analyzes, computes, aggregates and visualizes the telematics data gathered while driving a car, on interactive charts and geographic map.

Communicates with distributed system TANGO which gathers the data from a huge amount of users.

Supported for every major browser and prepared for desktops and mobile devices, according to the responsive web design.

Application is build from two main components:

- `infinibird_service`: a microservice responsible for backend functionality, communication layer and database.
- `infinibird_web`: Phoenix app responsible for routing, user session and presentation layer.

## Testing

The best way to see this application in action is to visit the website:

[`https://infinibird.gigalixirapp.com`](https://infinibird.gigalixirapp.com)

And use the testing token: `549af9e4`

To see the microservice is working, check the endpoint [`https://infinibird-service.gigalixirapp.com/health`](https://infinibird-service.gigalixirapp.com/health)

## Building local environment

To start the app:

- Download the project.
- Install dependencies with `mix deps.get`
- Prepare PostgreSQL database `infinibird_db`
- Create user `infinibird` with password `infinibird`, grant the user full rights to the database `infinibird_db`
- Create database structure with command `mix ecto.migrate`
- Start the microservice with `mix run --no-halt`

Now you can visit endpoint [`localhost:4000/health`](http://localhost:4000/health) from your browser, to check the microservice is working.
