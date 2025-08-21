# Voting app for interview exercises

This Rails and React application is the starting point for our Voting app
interview exercise. You may not need all the various files included to complete
the assignment, but they are here in case they help you move faster! Please
modify anything you need to in order to meet the requirements and show us your
own approach.

## Grant's notes
- I kept all project dependencies the same, save for making a few minor changes to the Gemfile and Dockerfile to enable deploying this to fly.io (you can see it at https://actblue-voting-app.fly.dev/. You may have to wait a few seconds and/or try loading it two or three times, as it has to launch a new VM if it's been idle for 5 minutes).
- Password and zip code are in the wireframes, but the backend ignores both. The instructions say to ignore password, and made no mention of how to use zip code. YAGNI!
- I added a logout link just to make my testing easier.
- I decided not to make the UI responsive or WCAG compliant, for lack of time. But I do think both of those are very important, in general!
- I wasn't totally sure how interpret this part of the assignment: "Account for things like omitted middle initials/names, typos, or any other reason why a good faith but inaccurate write-in entry could lead to problems". Omitted middle initials? At a music festival? I guess this is talking about...coming up with a way to "undo" your write-in, if you make a typo? I wasn't sure, so I decided not to pursue that.
- Also wasn't sure about this line: "Assume that votes are done in good faith and Votey McVoterson will not be entered as a candidate." Maybe an out-of-date line? "Votey McVoterson" hasn't come up in this codebase.
- A few small instances where it seems like the code doesn't match the version of Rails/Rspec included in this project. See [here](https://github.com/gw/actblue-voting-app/commit/7474276aba551358acb7d1c60577f5ff38a3987c) and [here](https://github.com/gw/actblue-voting-app/commit/1a9177503294e1df953ee03b847a1146aec57242).
- I spent a touch over 2 hours on this (but not much more) over several days.

## Installation

Your development environment should have:

* Ruby v3.1.2
* [Bundler](https://bundler.io/)
* Node v20.18.2
* Yarn v1.22.19
* git
* [SQLite3](https://www.sqlite.org/)

Initialize git, install the application, and initialize the database:

```sh
# First, download the zip file, unzip the directory,
# and navigate into the project directory. Then:
git init
git add .
git commit -m "Initial files provided"
bundle install
bundle exec rake db:migrate

# Install JS packages, including React
yarn install
```

## Running the app

```sh
bundle exec rails server
```

Visit [http://localhost:3000](http://localhost:3000) in your browser

For asset live reloading, run:
```sh
./bin/shakapacker-dev-server
```

If the assets ever get out of sync, delete `/public/packs` and restart your
Rails server (and your shakapacker-dev-server if it was running).

## Running tests

The included test suite uses Rspec and Capybara.

Check out `spec/requests/` for example tests.

```sh
# Run all tests
bundle exec rspec

# Run one test file
bundle exec rspec <path/to/the/file.rb>

# Run one test case inside a test file
bundle exec rspec <path/to/the/file.rb>:<line_number>
```

## Accessing the Rails console

```sh
bundle exec rails console
```

## Debugging

You can open up a debugging console by adding `binding.pry` anywhere in test or
application code.

Example:

```rb
def show
  binding.pry
  render json: { data: @my_object }, status: :ok
end
```

In this example, when the `show` method is hit during click testing or a test,
a debugger will open up in the terminal, where you can inspect values:

```rb
@my_object.id
@my_object.valid?
```

Step to the next line with `next`. Resume regular code execution or tests with
`continue`.
