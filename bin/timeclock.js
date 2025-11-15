#!/usr/bin/env node
const fs = require('fs')
const path = require('path')
const os = require('os')

const LOG_FILE = path.resolve(os.homedir(), 'timeclock-log.json')

const loadLog = () => {
  if (!fs.existsSync(LOG_FILE)) {
    fs.writeFileSync(LOG_FILE, JSON.stringify({ sessions: [] }, null, 2))
  }
  return JSON.parse(fs.readFileSync(LOG_FILE, 'utf8'))
}

const saveLog = (log) => {
  fs.writeFileSync(LOG_FILE, JSON.stringify(log, null, 2))
}

const command = process.argv[2]

const startSession = () => {
  const log = loadLog()

  const active = log.sessions.find((s) => !s.end)
  if (active) {
    console.log('Already clocked in at:', active.start)
    return
  }

  const newSession = { start: new Date().toISOString(), end: null }
  log.sessions.push(newSession)
  saveLog(log)
  console.log('Clocked IN at', newSession.start)
}

const endSession = () => {
  const log = loadLog()

  const session = log.sessions.find((s) => !s.end)
  if (!session) {
    console.log("You're not currently clocked in.")
    return
  }

  session.end = new Date().toISOString()
  saveLog(log)
  console.log('Clocked OUT at', session.end)
}

const viewSessions = () => {
  const log = loadLog()

  const totals = {}

  for (const s of log.sessions) {
    // skip incomplete sessions
    if (!s.end) continue
    const start = new Date(s.start)
    const end = new Date(s.end)
    const hours = (end - start) / (1000 * 60 * 60)

    const key = `${start.getFullYear()}-${String(start.getMonth() + 1).padStart(2, '0')}`

    totals[key] = (totals[key] || 0) + hours
  }

  console.log('\nHours Worked Per Month\n')

  if (Object.keys(totals).length === 0) {
    console.log('No completed sessions yet.')
    return
  }

  for (const [month, hours] of Object.entries(totals)) {
    console.log(`${month}: ${hours.toFixed(2)} hours`)
  }
}

const main = () => {
  switch (command) {
    case 'in':
      startSession()
      break
    case 'out':
      endSession()
      break
    case 'view':
      viewSessions()
      break
    default:
      console.log('Usage:')
      console.log('  node script.js in     # start work')
      console.log('  node script.js out    # stop work')
      console.log('  node script.js view   # view monthly hours')
  }
}

main()
