# Description:
#   Hubot reminder engine
#
# Commands:
#   task create [TASK DESCRIPTION] - Create a tasks
#   task list - gets all tasks
#   task detail [TASK NUMBER/TASK DESCRIPTION] -
#   task start [TASK NUMBER/TASK DESCRIPTION] - starts task
#   task complete [TASK NUMBER/TASK DESCRIPTION] - completes task
#   task archive [TASK NUMBER/TASK DESCRIPTION] - archives task from room to brain archive
#
# Author:
#   @jmcshane

TASKMASTER_CONFIGURATION = "hubot-taskmaster-configuration"
TASKMASTER_ARCHIVED_TASKS = "hubot-taskmaster-archived"
DESCRIPTION = "description"
STATUS = "status"
START_TIME = "start-time"
STATUS_ARRAY = ["NOT STARTED", "IN PROGRESS", "COMPLETE"]
STATUS_VERBS = ["", "started", "completed"]
OWNER = "task-owner"
COMPLETED_TIME = "complete-time"
TIME_KEY_FOR_STATUS = ["", START_TIME, COMPLETED_TIME]

class Taskmaster

  # Initialize the taskmaster
  # robot - A Robot instance.
  constructor : (@robot) ->
    @config = {}
    @robot.brain.on 'loaded', =>
      @_loadData()
    @_configureRobot()

  _loadData: () ->
    @config = @robot.brain.get TASKMASTER_CONFIGURATION
    if !@config
      @config = {}

  _createTask: (msg) ->
    room = @_getRoom(msg)
    task = {}
    task[DESCRIPTION] = msg.match[1]
    task[STATUS] = STATUS_ARRAY[0]
    if !@config[room]
      @config[room] = []
    @config[room].push task
    msg.reply "Task (#{task[DESCRIPTION]}) successfully created"
    @_save()

  _listTasks: (msg) ->
    roomTasks = @_nonEmptyRoomValidation(msg)
    if roomTasks
      response = "\/code ";
      for task, index in roomTasks
        response += "\n"
        response += "#{index}: #{task[DESCRIPTION]}, #{task[STATUS]}"
      msg.send response

  _deleteTask: (msg) ->
    roomTask = @_taskIndexValidation(msg)
    if roomTasks
      room = @_getRoom(msg)
      index = @config[room].indexOf(roomTask)
      @config[room].splice(index, 1)
      @_save()

  _startTask: (msg) ->
    @_incrementStatus(1, msg)

  _completeTask: (msg) ->
    @_incrementStatus(2, msg)

  _incrementStatus : (targetStatusIndex, msg) ->
    task = @_taskIndexValidation(msg)
    if task
      if STATUS_ARRAY.indexOf(task[STATUS]) != targetStatusIndex - 1
        msg.reply """Task (#{task[DESCRIPTION]}) is in state #{task[STATUS]}.
Cannot proceed from #{task[STATUS]} to #{STATUS_ARRAY[targetStatusIndex]}"""
      else
        task[TIME_KEY_FOR_STATUS[targetStatusIndex]] = new Date()
        task[STATUS] = STATUS_ARRAY[targetStatusIndex]
        if targetStatusIndex == 1
          task[OWNER] = msg.message.user.name
        msg.reply "Task (#{task[DESCRIPTION]}) #{STATUS_VERBS[targetStatusIndex]}"
        @_save()

  _getRoom: (msg) ->
    return msg.message.room

  _taskDetails: (msg) ->
    if !msg.match[1]
      return @_roomDetails(msg)
    task = @_taskIndexValidation(msg)
    if task
      reply = "\/code"
      for key, value of task
        reply += "\n#{key}: #{value}"
      msg.send reply

  _roomDetails: (msg) ->
    room = @_getRoom(msg)
    msg.send "\/code #{JSON.stringify(@config[room])}"

  _taskIndexValidation: (msg) ->
    roomTasks = @_nonEmptyRoomValidation(msg)
    if roomTasks
      requestedIndex = parseInt(msg.match[1])
      if isNaN(requestedIndex)
        requestedTaskName = msg.match[1]
        for task in roomTasks
          if task[DESCRIPTION].indexOf(requestedTaskName) > -1
            return task
      else
        if roomTasks.length <= requestedIndex || requestedIndex < 0
          msg.reply "There is no task with that index, see task list for the appropriate indexes"
        else
          return roomTasks[requestedIndex]
    return undefined

  tasksFor: (room) ->
    return @config[room];

  _nonEmptyRoomValidation: (msg) ->
    room = @_getRoom(msg)
    roomTasks = @config[room]
    if !roomTasks || roomTasks.length == 0
      msg.reply "No tasks currently in this room!"
      return undefined
    return roomTasks

  _save: () ->
    @robot.brain.set TASKMASTER_CONFIGURATION, @config

  _archiveTask: (msg) ->
    task = @_taskIndexValidation(msg)
    room = @_getRoom(msg)
    index = @config[room].indexOf(task)
    archivedTasks = @robot.brain.get TASKMASTER_ARCHIVED_TASKS
    if !archivedTasks
      archivedTasks = []
    archivedTasks.push(task)
    @robot.brain.set TASKMASTER_ARCHIVED_TASKS, archivedTasks
    @config[room].splice(index, 1)
    len = @config[room].length
    msg.reply "Task (#{task[DESCRIPTION]}) successfully archived. There are #{len} remaining tasks."
    @_save()

  _configureRobot: () ->
    @robot.respond /task create (.*)/i, (msg) =>
      @_createTask(msg)
    @robot.respond /task delete (.*)/i, (msg) =>
      @_deleteTask(msg)
    @robot.respond /task detail(?:(?:s)?(?: (.*))?)?/i, (msg) =>
      @_taskDetails(msg)
    @robot.respond /task list(\s?.*)/i, (msg) =>
      @_listTasks(msg)
    @robot.respond /task start (.*)/i, (msg) =>
      @_startTask(msg)
    @robot.respond /task complete (.*)/i, (msg) =>
      @_completeTask(msg)
    @robot.respond /task archive (.*)/i, (msg) =>
      @_archiveTask(msg)

module.exports = (robot) ->
  new Taskmaster(robot)
