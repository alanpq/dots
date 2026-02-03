
pragma Singleton
import Quickshell

Singleton {
  function pad(val: var, length: int): string {
    return String(val).padStart(length, " ")
  }

  function zeroPad(val: var, length: int): string {
    return String(val).padStart(length, "0")
  }

  function flattenString(val: string): string {
    return val.trim().replace("\r\n", " ").replace("\n", " ")
  }

  function truncate(val: string, maxLength: int): string {
    return val.length <= maxLength ? val : `${val.slice(0, maxLength - 1)}…`
  }

  function capitalize(val: string): string {
      return val.charAt(0).toUpperCase() + val.slice(1);
  }

  function httpRequest(url: string, method: string, body: var, contentType: var, cb: var) {
    let req = new XMLHttpRequest()
    req.onreadystatechange = function () {
      if (req.readyState === XMLHttpRequest.DONE) {
        cb({
          status: req.status,
          statusText: req.statusText,
          headers: req.getAllResponseHeaders(),
          contentType: req.responseType,
          text: req.responseText,
          xml: req.responseXML,
          json: () => JSON.parse(req.response)
        })
      }
    }
    if (contentType)
      req.setRequestHeader("Content-Type", contentType)
    req.open(method, url)
    req.send(body)
  }

  function httpGet(url: string, cb: var) {
    httpRequest(url, "GET", null, null, cb)
  }

  function httpPost(url: string, body: var, contentType: string, cb: var) {
    httpRequest(url, "POST", body, contentType, cb)
  }
}
