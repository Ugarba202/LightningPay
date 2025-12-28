⚡ LightningPay

LightningPay is a learning-focused Bitcoin & Lightning payment app built with Flutter, designed to demonstrate how modern fintech systems work internally — from deposits and conversions to peer-to-peer BTC transfers.

⚠️ Disclaimer
This project is for learning and portfolio purposes only.
All balances, transactions, deposits, withdrawals, and conversions are 100% simulated (FAKE).
There is no real Bitcoin, no real bank integration, and no real money involved.

🚀 Why This Project

I built LightningPay to deeply understand:

How local currency enters and exits a financial system

How Bitcoin (BTC) can act as an internal settlement layer

How P2P payments can be simplified using usernames and QR codes

How real fintech apps separate Deposit, Convert, Send, and Withdraw

This project focuses on system design, clean architecture, and realistic flows, not just UI.

✨ Key Features

Onboarding & Auth – step-by-step user setup and profile management

Wallet Dashboard – BTC balance with local currency equivalents

Send BTC – via username or QR code (BTC-only transfers)

Receive BTC – username & QR code (no fiat exposure)

Deposit (Mock) – local currency funding via virtual account number

Convert – local currency ↔ BTC (mock exchange rates)

Withdraw (Mock) – BTC → local currency → bank (simulated)

Transaction History – detailed receipts with PDF export

🔁 Example Flow (Simulated)
Local Bank
→ Deposit (Local Currency)
→ Convert (Local → BTC)
→ Send BTC (Username / QR)
→ Receive BTC
→ Convert (BTC → Local)
→ Withdraw to Bank


BTC is the only transferable asset between users.
Local currency is used only for entry and exit.

🧠 What This Demonstrates

Ledger-based financial modeling

Currency conversion logic

P2P payment system design

Clean Flutter architecture

How Bitcoin & Lightning fit into real payment systems

🛠️ Tech Stack

Flutter

Firebase (Auth & Firestore)

Mock services & ledger-based state management

📸 Screenshots

(Add screenshots here to make the repo stand out for recruiters)

![Onboarding](screenshots/onboarding.png)
![Dashboard](screenshots/dashboard.png)
![Send BTC](screenshots/send.png)
![Deposit](screenshots/deposit.png)
![Convert](screenshots/convert.png)
![Withdraw](screenshots/withdraw.png)


(Create a /screenshots folder and add 5–6 clean UI images.)

🔗 Demo & Source Code

▶️ Live Demo: https://your-test-link-here

💻 Source Code: https://github.com/your-username/lightningpay