import asynchttpserver, asyncdispatch

var server = newAsyncHttpServer()
proc cb(req: Request) {.async.} =
  await req.respond(Http200, "Hello World!", newHttpHeaders([("Content-Type", "text/plain")]))

waitFor server.serve(Port(8080), cb)
