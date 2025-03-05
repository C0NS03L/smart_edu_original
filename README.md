# Smart Edu

This README documents the steps necessary to get the Smart Edu application up and running.

## Ruby Version

- Ruby 3.4.1

## System Dependencies

- Rails 8.0.1
- Node.js
- Bun

## Configuration

1. Clone the repository:

   ```sh
   git clone https://github.com/C0NS03L/smart_edu_original
   cd smart_edu_original
   ```

2. Run the setup scripts:
   ```sh
   bun setup
   ```

## Repo setup

1. Install chrome driver:
   ```sh
   sudo apt-get install chromium-chromedriver
   ```

## Database Creation

1. Create and set up the database:
   ```sh
   bin/rails db:create
   bin/rails db:migrate
   ```

## How to Run the Test Suite

1. Run the unit tests:

   ```sh
   bin/rails test
   ```

2. Run the system tests:
   ```sh
   bin/rails test:system
   ```
