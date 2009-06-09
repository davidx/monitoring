require 'drb'
require 'drb/observer'
require 'monitoring'

worker = Monitoring::Worker.new
DRb.start_service("druby://127.0.0.1:1337", worker)
DRb.thread.join