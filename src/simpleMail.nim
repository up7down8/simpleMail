import smtp
import base64
import os
import strutils

type
  MessageContent = ref object
    headers: seq[tuple[name, value: string]]
    content: string

  MultMessage = ref object
    tag: string
    multBody: seq[MessageContent]
    to: seq[string]
    cc: seq[string]
    sender: string

proc `$` (messageContent: MessageContent): string =
  for h in messageContent.headers:
    result = "$1$2: $3\n" % [result, h.name, h.value]
  result = "$1\n$2\n" % [result, messageContent.content]

proc `$`* (multMessage: MultMessage): string = 
  result = $(multMessage.multBody[0])
  for m in multMessage.multBody[1 .. ^1]:
    result = "$1\n--$2\n$3" % [result, multMessage.tag, $m]
  result = "$1\n--$2--\n" % [result, multMessage.tag]

proc serverConnect*(ip: string, port: int, useSsl: bool, user: string = "", password: string = ""): Smtp =
  result = newSmtp(useSsl=useSsl)
  result.connect(ip, Port port)
  if user != "":
    result.auth("username", "password")


proc initMessage*(subject, sender: string, to, cc: seq[string], addHeader: seq[tuple[name, value:string]] = @[], tag: string = "8s2dF9gP4hT6jK1l3zX7cV5bN0mQ8wE2"): MultMessage =
  var headers = @[("Content-Type", "multipart/mixed; boundary=$1" % [tag]),("MIME-Version", "1.0")]
  for h in addHeader:
    headers.add(h)
  headers.add(("Subject", subject))
  headers.add(("To", join(to, ",")))
  headers.add(("Cc", join(cc, ",")))
  headers.add(("Sender", sender))
  let messageContent = MessageContent(headers: headers, content: "")
  result = MultMessage(tag: tag, multBody: @[messageContent], to: to, cc: cc, sender: sender)


proc addHtml*(multMessage: MultMessage, html: string) =
  let headers = @[("Content-Type", "text/html; charset=UTF-8")]
  let messageContent = MessageContent(headers: headers, content: html)
  multMessage.multBody.add(messageContent)


proc addFiles*(multMessage: MultMessage, files: openArray[string]) =
  for f in files:
    let filename = f.splitPath().tail
    let fHandle = open(f)
    defer: fHandle.close()
    let data = fHandle.readAll().encode()
    var headers: seq[tuple[name, value: string]]
    headers.add(("Content-Type", "application/pdf; name=$1" % [filename]))
    headers.add(("Content-Transfer-Encoding", "base64"))
    headers.add(("Content-Disposition", "attachment; filename=$1" % [filename]))
    let messageContent = MessageContent(headers: headers, content: data)
    multMessage.multBody.add(messageContent)

proc messageSend*(smtpConn: Smtp, multMessage:MultMessage) =
  smtpConn.sendmail(multMessage.sender, multMessage.to & multMessage.cc, $multMessage)

