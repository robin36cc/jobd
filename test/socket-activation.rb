#!/usr/bin/env ruby
#
# Copyright (c) 2015 Mark Heily <mark@heily.com>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

require 'socket'

if ARGV[0] == 'setup'
  pwd = `pwd`.chomp
  plist = "socket-activation.json"
  f = File.open(plist, "w")
  f.puts <<"__MANIFEST__"
{
  "UserName": "nobody",
  "GroupName": "nogroup",
  "Program": "#{pwd}/socket-activation.rb",
  "ProgramArguments": ["activate"],
  "EnableGlobbing": true,
  "WorkingDirectory": "/",
  "RootDirectory": "/",
  "StandardInPath": "/dev/null",
  "StandardOutPath": "#{pwd}/socket-activate.out",
  "StandardErrorPath": "#{pwd}/socket-activate.err",
  "Sockets": {
    "MyService": {
      "SockServiceName": "8088",
    },
  },
  "Label": "test.sockets",
}
__MANIFEST__
  f.close
  system "../launchctl load #{plist}" or raise "launchctl failed"
  sleep 2
  File.unlink plist
else
  system "env"
  fd = ENV['LAUNCHD_SOCKET_MyService'].to_i
  obj = Socket.for_fd(fd)
  if obj.stat.socket?
    server = TCPServer.for_fd(fd)
    session = server.accept
    session.puts 'hello world'
    session.close
  else
    raise "not a socket"
  end
end

exit 0