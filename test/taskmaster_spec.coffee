chai = require 'chai'
assert = chai.assert
sinon = require 'sinon'
chai.use require 'sinon-chai'
Taskmaster = require('../src/taskmaster')
expect = chai.expect

describe 'taskmaster', ->
  beforeEach ->
    @robot =
      respond: sinon.spy()
      hear: sinon.spy()
      brain: {
        on: sinon.spy()
      }

    @taskmaster = Taskmaster(@robot)

  it 'registers appropriate respond listeners', ->
    expect(@robot.respond).to.have.been.calledWith(/task create (.*)/i)
    expect(@robot.respond).to.have.been.calledWith(/task list(\s?.*)/i)
    expect(@robot.respond).to.have.been.calledWith(/task start (.*)/i)
    expect(@robot.respond).to.have.been.calledWith(/task complete (.*)/i)

  it 'registers a function on the message object', ->
    msg =
      match : ["no-data","My Task"]
      message: user: reply_to: "room"
    @taskmaster._createTask(msg)
    assert.lengthOf(@taskmaster.tasksFor("room"), 1)
