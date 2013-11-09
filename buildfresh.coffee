# Attempts to build coffeescript using the 'global' coffeescript compiler. 
# Useful if you've broken the main one.

fs            = require 'fs'
path          = require 'path'
{spawn, exec} = require 'child_process'


runGlobal = (args, cb)->
  console.log [].concat(args)
  proc = spawn 'coffee', [].concat(args)
  proc.stderr.on 'data', (buffer) -> console.log buffer.toString()
  proc.on        'exit', (status) ->
    process.exit(1) if status != 0
    cb() if typeof cb is 'function'

# Build the CoffeeScript language from source.
build = (cb, global) ->
  files = fs.readdirSync 'src'
  files = ('src/' + file for file in files when file.match(/\.(lit)?coffee$/))

  for file in files
    console.log file

  if not global 
    console.log 'running local...'
    run ['-c', '-o', 'lib/coffee-script'].concat(files), cb
  else 
    console.log 'running global...'
    runGlobal ['-c', '-o', 'lib/coffee-script'].concat(files), cb

# Run a CoffeeScript through our node/coffee interpreter.
run = (args, cb) ->
  proc =         spawn 'node', ['bin/coffee'].concat(args)
  proc.stderr.on 'data', (buffer) -> console.log buffer.toString()
  proc.on        'exit', (status) ->
    process.exit(1) if status != 0
    cb() if typeof cb is 'function'




build(null, true)