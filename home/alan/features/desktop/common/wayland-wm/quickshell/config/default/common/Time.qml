pragma Singleton
import Quickshell

import "root:/common"
import "root:/settings"

Singleton {
  function now(): date {
    return new Date()
  }

  function nowUnix(): int {
    return Math.floor(now() / 1000)
  }

  function nowDateString(): string {
    return dateString(now())
  }

  function nowTimeString(): string {
    return timeString(now())
  }

  function nowDateTimeString(): string {
    return dateTimeString(now())
  }

  function dateString(date: date): string {
    const year = date.getFullYear()
    const month = Util.zeroPad(date.getMonth() + 1, 2)
    const day = Util.zeroPad(date.getDate(), 2)
    return `${year}-${month}-${day}`
  }

  function timeString(date: date): string {
    const hour = Util.zeroPad(date.getHours(), 2)
    const minute = Util.zeroPad(date.getMinutes(), 2)
    const second = Util.zeroPad(date.getSeconds(), 2)
    return `${hour}:${minute}:${second}`
  }

  function dateTimeString(date: date): string {
    return `${dateString(date)} ${timeString(date)}`
  }

  function humanDuration(totalSeconds: var): string {
    if (typeof totalSeconds !== "number" || totalSeconds < 0)
      return "0s"
    totalSeconds = Math.floor(totalSeconds)
    const days = Math.floor(totalSeconds / 86400)
    const hours = Math.floor((totalSeconds % 86400) / 3600)
    const minutes = Math.floor((totalSeconds % 3600) / 60)
    const seconds = totalSeconds % 60
    const parts = []
    if (days)
      parts.push(`${days}d`)
    if (hours)
      parts.push(`${hours}h`)
    if (minutes)
      parts.push(`${minutes}m`)
    if (!hours && !minutes)
      parts.push(`${seconds}s`)
    return parts.join(" ")
  }

  function relativeHumanDuration(date: date): string {
    const diff = now - date.getTime()
    if (diff < 60000)
      return "now"
    if (diff < 120000)
      return "1 minute ago"
    if (diff < 3600000)
      return `${Math.floor(diff / 60000)} minutes ago`
    if (diff < 7200000)
      return "1 hour ago"
    if (diff < 86400000)
      return `${Math.floor(diff / 3600000)} hours ago`
    if (diff < 172800000)
      return "1 day ago"
    return `${Math.floor(diff / 86400000)} days ago`
  }
}
