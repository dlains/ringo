# Ringo

This is my version of the Lox language from [Crafting Interpreters](http://craftinginterpreters.com). It is just a fun little side project for learning how interpreters and compilers work.

## Installation

Stop! If you are looking for installation instructions for this project you are doing something wrong. I used the Bundler gem template simply for the handy project structure. This is not a live gem, and the language implemented is NOWHERE NEAR production ready.

## Usage

If you are just poking around for fun you can test the interpreter with the simple.lox file. It was one of the final code examples from the tree walk section of the book. Follow the instructions below to install the dependencies and then run:

```bash
bundle exec ringo simple.lox
```

You can also start an interactive session like so:

```bash
bundle exec ringo
```

Enter 'exit' at the prompt to leave the interactive session.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.
