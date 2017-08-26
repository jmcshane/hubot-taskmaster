# hubot-taskmaster

A hubot script that provides an easy way to track tasks that need to be done and
ping users as scheduled tasks must be completed.

## Installation

In hubot project repo, run:

`npm install hubot-taskmaster --save`

Then add **hubot-taskmaster** to your `external-scripts.json`:

```json
[
  "hubot-taskmaster"
]
```

## Sample Interaction

```
user> hubot task create A fairly simple task
hubot> @user Task (A fairly simple task) successfully created
user> hubot task start A fairly simple task
hubot> @user Task (A fairly simple task) started
user> hubot task list
hubot> 1: A fairly simple task, IN PROGRESS
user> hubot task details 1
hubot> description: A fairly simple task
status: IN PROGRESS
start-time: <TIME STRING>
task-owner: user
user> hubot task complete 1
hubot> @user Task (A fairly simple task) completed
user> hubot task archive A fairly simple task
hubot> @user Task (A fairly simple task) archived. There are 0 remaining tasks.
```

## NPM Module

https://www.npmjs.com/package/hubot-taskmaster
