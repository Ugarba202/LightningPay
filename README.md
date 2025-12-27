⚡ LightningPay

LightningPay is a learning-focused Bitcoin & Lightning payment app built with Flutter.
The goal of this project is to understand how real-world fintech and Bitcoin systems are designed internally, not to process real money.

⚠️ IMPORTANT DISCLAIMER
All balances, transactions, deposits, withdrawals, and conversions in this app are 100% simulated (FAKE).
There is NO real Bitcoin, NO real bank integration, and NO real financial transactions involved.
This project is strictly for learning, experimentation, and portfolio demonstration.

🚀 Project Motivation

Cross-border payments are still difficult, especially when:

Users only have local bank money

Crypto wallets are complex and error-prone

Wallet addresses are hard to manage

Exchanges require prior crypto ownership

LightningPay was built to explore:

How local currency enters a system (on-ramp)

How Bitcoin can act as a settlement layer

How peer-to-peer payments can be simplified using usernames & QR codes

How funds exit back to local currency (off-ramp)

All of this is implemented using mock logic, mirroring real systems without financial risk.

🧠 Core Design Principles

BTC is the only transferable asset between users

Local currency is used only for Deposit and Withdraw

Deposit ≠ Convert ≠ Send ≠ Withdraw (clear separation of concerns)

Ledger-based system (balances update from transactions)

Human-friendly UX (no forced wallet addresses)

Built for learning by building

🧩 Features
🔐 Onboarding & Authentication

Splash screen & onboarding flow

Step-by-step authentication wizard

Profile creation (name, username, email, country, phone)

Login PIN setup

Editable user profile

🏠 Wallet Dashboard

BTC balance (primary)

Local currency equivalents (secondary)

Quick actions:

Send

Receive

Deposit

Withdraw

Convert

Recent transactions preview

📥 Receive (BTC Only)

Display username (@username)

BTC QR code

Copy & share options

No fiat, no conversion, no balance mutation

📤 Send (BTC Only)

Send BTC via:

Username

QR code

BTC amount input

Optional reason & note

Safe-send confirmation

Internal BTC ledger transfer

💰 Deposit (Local Currency → LightningPay)

Simulated local bank funding

Each user gets a LightningPay virtual account number

Format: LP-<COUNTRY>-<RANDOM>

Deposit purpose tagging

Local currency balance credited

No automatic conversion

🔁 Convert (Currency Bridge)

Dedicated conversion screen

Convert:

Local currency ↔ BTC

Mock exchange rates

“You will receive” preview

Ledger-based balance updates

🏧 Withdraw (LightningPay → Local Bank)

Users must withdraw in local currency

BTC must be converted before withdrawal

Mock bank account details

Balance validation & confirmation

🧾 Transactions & Receipts

Full transaction history

Supports:

Deposits

Conversions

Sends

Receives

Withdrawals

Detailed transaction receipts

PDF export

Shareable transaction summaries

🔁 Example Flow (Simulated)

Ali (Pakistan) → Usman (Nigeria)

Ali deposits PKR via LightningPay account number

Ali converts PKR → BTC

Ali sends BTC to @usman

Usman receives BTC

Usman converts BTC → NGN

Usman withdraws NGN to local bank

Bitcoin acts as the internal settlement layer, while users interact with familiar concepts.

🛠️ Tech Stack

Flutter

Firebase (Authentication & Firestore)

Ledger-based state management

Modular, clean architecture

🧪 Demo & Source Code

▶️ Live Demo: https://your-test-link-here

💻 Source Code: https://github.com/your-username/lightningpay

⚠️ Reminder:
This app uses mock data only.
No real money, no real Bitcoin, no real banking APIs.

📚 Learning Outcomes

This project helped me understand:

Ledger-based financial systems

Fiat on-ramp & off-ramp modeling

Currency conversion logic

P2P payment flows

Clean Flutter architecture

How Bitcoin & Lightning fit into real payment systems

🚧 Future Improvements (Learning-Only)

Replace mock services with testnet logic

Persist ledger data fully in Firestore

Add advanced security flows

Improve analytics & reporting

📄 License

This project is open-source and intended for educational purposes only.

If you want, next I can:

Shorten this README for recruiters

Create architecture diagrams

Write a case study version for your portfolio

Prepare interview talking points based on this project