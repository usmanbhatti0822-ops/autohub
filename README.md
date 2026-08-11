# AutoHub

A full-stack car marketplace and rental platform for Pakistan — buy or sell cars, rent vehicles by the day, and manage bookings end-to-end. Built as a portfolio project with a NestJS backend and a Flutter (Web/Mobile) client.

This is a **demo/portfolio build**: authentication, listings, bookings, and payments all work end-to-end against a real backend and database, but external integrations that require paid third-party credentials (SMS gateway, JazzCash/Easypaisa, Firebase push) are mocked behind the same architecture that would carry the real integration. See [Demo Mode](#demo-mode) below.

## Features

**Authentication**
- Phone number + OTP login/signup (SMS is simulated — the code is returned directly in dev mode)
- Email + password login/signup, with forgot/reset password (reset code simulated the same way as OTP)
- JWT-based sessions, secure token storage on device

**Marketplace (buy/sell)**
- Browse, search, and filter cars by make, model, city, category, transmission, fuel type, and price
- Sort by newest or price
- Listing detail with photo gallery, specs, features, seller info and rating
- Post a car for sale (goes to "pending" until admin approval)
- Mock "Contact Seller" inquiry

**Rentals**
- Browse and filter rental vehicles the same way as the marketplace
- Date-range availability picker with real overlap/conflict prevention on the backend
- Full booking flow: summary → payment method → confirmation, with a success animation
- Mock payment (Cash on Pickup or a simulated card payment — no real payment gateway is called)
- My Bookings with Upcoming / Active / Completed / Cancelled tabs, cancellation, and post-rental reviews
- List your own car for rent

**Profile & trust**
- Editable profile (name, email, city, avatar)
- Wallet balance (owner payouts ledger)
- Ratings & reviews between renters/buyers and owners/sellers

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile/Web client | Flutter, Riverpod (state), go_router (navigation incl. bottom-nav shell), Dio (HTTP) |
| Backend | NestJS, TypeORM, PostgreSQL, Passport + JWT, class-validator |
| Auth | bcrypt password hashing, JWT access tokens |

## Architecture

- **Backend** — modular NestJS app (`auth`, `users`, `listings`, `rentals`, `bookings`, `payments`, `wallet`, `reviews`, `notifications`), each with its own controller/service/entities/DTOs. Repository pattern via TypeORM. See [`project/backend/src`](project/backend/src).
- **Mobile** — feature-first Clean Architecture (`data` / `domain` / `presentation` per feature) under [`project/mobile/lib/features`](project/mobile/lib/features), with shared design tokens, widgets, and utilities in [`project/mobile/lib/core`](project/mobile/lib/core).
- Mock-only concerns (SMS, payment gateways, push notifications) are isolated behind the same service/DTO boundaries a real integration would use — see the inline "NOTE" comments in `auth.service.ts`, `payments.service.ts`, and `notifications.service.ts` for exactly what to replace and how.

## Setup Instructions

### Prerequisites
- Node.js 18+ and npm
- PostgreSQL running locally (or update `project/backend/.env` to point elsewhere)
- Flutter SDK (3.x) with web support enabled, and Chrome for local testing

### 1. Backend

```bash
cd project/backend
cp .env.example .env        # defaults work for a local Postgres with user/pass "postgres"
npm install
npm run seed                # wipes and repopulates demo data (users, listings, rentals, bookings, reviews)
npm run start:dev           # runs on http://localhost:3000/api
```

### 2. Mobile / Web client

```bash
cd project/mobile
flutter pub get
flutter run -d chrome
# or target a device/emulator: flutter run
```

By default the app points at `http://localhost:3000/api`. To point at a different backend:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=https://your-backend.example.com/api
```

## Demo Mode

No real SMS, payment, or push credentials are required to use every feature of the app.

**Demo account** (seeded by `npm run seed`), works with either login method:
- Phone: `03000000000` (or `+923000000000`), OTP code: **`1234`** (fixed for this number so you don't have to hunt for it)
- Email: `demo@autohub.pk`, Password: `Demo1234`

From the Welcome screen, tapping **"Try the Demo Account"** logs you in as this account in one tap.

For any *other* phone number or new signup, OTP/reset codes aren't sent by SMS/email — the backend returns the code directly in the API response (`devCode`), and the app displays it on screen and pre-fills the input for you. This only happens outside `NODE_ENV=production`.

Payments: choose "Cash on Pickup" (stays pending, as it would in real life) or "Pay by Card (Demo)", which simulates an instant successful charge via the backend's dev-settlement endpoint — no card details are collected or sent anywhere.

## API Overview

All endpoints are prefixed with `/api`. Highlights:

| Area | Endpoints |
|---|---|
| Auth | `POST /auth/otp/request`, `POST /auth/otp/verify`, `POST /auth/register`, `POST /auth/login`, `POST /auth/forgot-password`, `POST /auth/reset-password` |
| Users | `GET /users/me`, `PATCH /users/me` |
| Listings | `GET /listings`, `GET /listings/:id`, `POST /listings`, `PATCH /listings/:id`, `DELETE /listings/:id`, `PATCH /listings/:id/approve\|reject` |
| Rentals | `GET /rentals`, `GET /rentals/:id`, `POST /rentals`, `GET /rentals/mine` |
| Bookings | `POST /bookings`, `GET /bookings/mine`, `GET /bookings/:id`, `PATCH /bookings/:id/confirm\|start\|complete\|cancel` |
| Payments | `POST /payments/initiate`, `POST /payments/:id/dev-settle` (dev only) |
| Reviews | `POST /reviews`, `GET /reviews/user/:userId` |
| Wallet | `GET /wallet/balance`, `GET /wallet/history` |

## Future Production Integration Notes

These are the pieces intentionally mocked for this demo, and where to plug in the real thing:

- **SMS OTP** — `AuthService.requestOtp()` in `project/backend/src/modules/auth/auth.service.ts`. Swap the `console.log` for a Pakistani SMS gateway call.
- **Password reset email** — same file, `forgotPassword()`. Needs an email provider (e.g. SES/SendGrid) instead of returning the code in the response.
- **Payments** — `project/backend/src/modules/payments/payments.service.ts` has a detailed header comment on wiring JazzCash/Easypaisa signed-redirect flows and replacing `dev-settle` with real webhook signature verification.
- **Push notifications** — `project/backend/src/modules/notifications/notifications.service.ts`, wire up `firebase-admin` with a real service account.
- **Photo uploads** — listings/rentals currently assign a placeholder photo on creation since no object storage is configured; wire `image_picker` output to an S3-compatible presigned upload and pass the resulting URL(s) through.
- **Chat, ID verification, admin panel, web (Next.js) app** — scoped out of this build; the backend's module boundaries (and the `docs/` folder) are structured so they can be added without touching what's already here.

## Project Structure

```
project/
  backend/    NestJS API (see src/modules/*)
  mobile/     Flutter client (see lib/features/*, lib/core/*)
  docs/       Original product/architecture planning docs
```
