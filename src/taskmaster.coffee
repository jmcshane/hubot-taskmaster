# Description:
#   Hubot reminder engine
#
# Commands:
#   task create [TASK DESCRIPTION]- Create a tasks
#   task list [USER]- gets all tasks
#   task start [TASK NUMBER]
#   task complete [TASK NUMBER]
#   what are my tasks - gets tasks assigned to you
#   Starting task [NUMBER] - starts task
#   I'm done with [NUMBER] - completes in-progress task
#   I'm not doing [NUMBER] - cancels task
#
# Author:
#   @jmcshane

TASKMASTER_CONFIGURATION = "hubot-taskmaster-configuration"
DESCRIPTION = "description"

class Taskmaster

  # Initialize the taskmaster
  # robot - A Robot instance.
  constructor : (@robot) ->
    @config = {}
    @robot.brain.on 'loaded', =>
      @_loadData()
    @_configureRobot()

  _loadData: () ->
    @config = robot.brain.get TASKMASTER_CONFIGURATION

  _createTask: (msg) ->
    room = @_getRoom(msg)
    task = {}
    task[DESCRIPTION] = msg.match[1]
    if !@config[room]
      @config[room] = []
    @config[room].push task

  _listTasks: (msg) ->
    room = @_getRoom(msg)
    roomTasks = @config[room]
    if !roomTasks || roomTasks.length == 0
      msg.reply "No tasks currently in this room!"

    response = "\/code ";
    for task, index in roomTasks
      response += "\n"
      response += "#{index}: #{task[DESCRIPTION]}"
    msg.send response

  _startTask: (msg) ->

  _completeTask: (msg) ->

  _getRoom: (msg) ->
    return msg.message.user.reply_to

  tasksFor: (room) ->
    return @config[room];

  _configureRobot: () ->
    context = this
    @robot.respond /task create (.*)/i, (msg) ->
      context._createTask(msg)
    @robot.respond /task list(\s?.*)/i, (msg) ->
      context._listTasks(msg)
    @robot.respond /task start (.*)/i, (msg) ->
      context._startTask(msg)
    @robot.respond /task complete (.*)/i, (msg) ->
      context._completeTask(msg)

module.exports = (robot) ->
  new Taskmaster(robot)
