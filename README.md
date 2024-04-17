```
let multMessage = initMessage("subject", "sender addr",  toMail.split(","), ccMail.split(","), @[("From", "MAIL")])
let html = "<h1>a</h1>"
multMessage.addHtml(html)
multMessage.addFiles(@["filepath1", "filepath2"])
let smtpConn = serverConnect("1.1.1.1", 25, false)
echo multMessage
smtpConn.messageSend(multMessage)
```
