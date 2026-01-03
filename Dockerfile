FROM node:20-bullseye-slim

RUN apt-get update && apt-get install -y \
    ffmpeg \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /bot

COPY . .

RUN npm install

CMD ["node", "entry.js"]





{
  "name": "whatsapp-bot",
  "version": "1.0.0",
  "main": "entry.js",
  "type": "module",
  "dependencies": {
    "@whiskeysockets/baileys": "^6.5.0",
    "pino": "^8.0.0"
  }
}






js
import makeWASocket, { useMultiFileAuthState } from "@whiskeysockets/baileys"
import P from "pino"

async function startBot() {
  const { state, saveCreds } = await useMultiFileAuthState("auth")

  const sock = makeWASocket({
    logger: P({ level: "silent" }),
    printQRInTerminal: true,
    auth: state
  })

  sock.ev.on("creds.update", saveCreds)

  sock.ev.on("messages.upsert", async ({ messages }) => {
    const m = messages[0]
    if (!m.message || m.key.fromMe) return

    const msg = m.message.conversation || m.message.extendedTextMessage?.text || ""

    if (msg.toLowerCase() === "!test") {
      await sock.sendMessage(m.key.remoteJid, { text: "✅ Commande reçue avec succès !" })
    }
  })
}

startBot()
