# WD Text Demo

This project requires Redis, Bun.js, and Dart SDK to run.

## Running the Project

### 1. Start Redis Server
First, start the Redis server on port 6644:

```bash
redis-server --port 6644
```

### 2. Start the Bun Server
Navigate to the web/server directory and start the Bun server:

```bash
cd web/server
bun index.js
```

### 3. Run the Dart Application
In a new terminal, navigate to the wdtxt directory and run the Dart application:

```bash
cd wdtxt
dart run
```

Each component should be started in the order listed above to ensure proper functionality.