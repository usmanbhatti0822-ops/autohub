# AutoHub — Car Marketplace + Rental App

```
/backend   → NestJS + PostgreSQL API
/mobile    → Flutter app source (Clean Architecture, Riverpod, GoRouter)
/docs      → PRD, tech architecture, roadmap, phase breakdown
```

## What's included in this delivery

**Backend — fully coded, builds clean (`npx nest build` verified)**
- Auth: OTP (phone + code) issuing JWTs. Dev mode prints the OTP to the
  server console and returns it as `devCode` in the API response, so you
  can test without a real SMS gateway.
- Users: profile get/update
- Listings (marketplace): CRUD, search/filter, admin approve/reject
- Rentals: vehicle listing CRUD, search with date-range availability filtering
- Bookings: full lifecycle state machine (requested → confirmed → ongoing →
  completed / cancelled), pickup/return photo checklist endpoints
- Reviews: rating + comment, both directions (buyer/seller, renter/owner)
- Wallet: ledger for owner/seller earnings and platform commission
- Payments: order structure ready for JazzCash/Easypaisa/card — **the actual
  gateway calls are stubbed** (see the header comment in
  `payments.service.ts`) because that requires merchant credentials only you
  can obtain. Once you have them, tell me and I'll wire the real signed
  request/webhook flow.
- Notifications: push-notification service structured for Firebase Cloud
  Messaging — **also stubbed** (needs your Firebase service-account JSON).
  Currently logs to the server console in dev mode.

**Mobile — full source, written by hand (Flutter CLI isn't available in the
sandbox this was built in, so compiling could not be verified here — run it
locally and send me any errors to patch)**
- Phone entry + OTP screens (animated)
- Home feed: search, animated staggered grid, shimmer loading
- Listing detail: **crossfade image carousel with dot indicators + parallax
  hero scroll** (added after you shared the reference video — matches its
  smooth hero-image-transition feel)
- Post-a-listing form
- Rental browse, rental detail + date-range booking flow, "list your car for
  rent" form, my-bookings status tracker
- **App-wide smooth fade + slide-up page transitions** (also added to match
  the reference video's "reveal" feel instead of the default platform slide)
- GoRouter with auth-based redirect

## Not yet included
- In-app chat (button exists on listing detail, not wired)
- Image upload wiring (forms have a TODO for S3 presigned upload)
- Real payment gateway calls, real push notifications (need your credentials)
- CNIC/ID verification review UI, dealer subscription tools
- Web app (Next.js) — separate codebase, not started yet
- Admin dashboard UI (backend endpoints exist; no frontend yet)
- Further animation polish: comparison tool, saved-search alerts,
  recommendation logic (rest of Phase 4 per `docs/04-development-phases.md`)

## Backend — Getting Started

Requires Node.js 18+ and PostgreSQL.

```bash
cd backend
npm install
cp .env.example .env
# edit .env with your PostgreSQL credentials
npm run start:dev
```

API runs at `http://localhost:3000/api`. `synchronize: true` is on for dev
(TypeORM auto-creates tables) — switch off and use migrations before
production.

### Quick test flow
```bash
curl -X POST http://localhost:3000/api/auth/otp/request \
  -H "Content-Type: application/json" -d '{"phone": "+923001234567"}'
# copy "devCode" from the response

curl -X POST http://localhost:3000/api/auth/otp/verify \
  -H "Content-Type: application/json" \
  -d '{"phone": "+923001234567", "code": "<devCode>"}'
# copy "accessToken" and use as Bearer token for authenticated routes
```

## Mobile — Getting Started

Requires Flutter SDK 3.3+.

```bash
cd mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://<your-backend-host>:3000/api
```

- Android emulator + backend on same machine → `http://10.0.2.2:3000/api`
- Physical device → your computer's LAN IP

## Next Step

Run `flutter pub get` and send me any compile errors to patch. Say
"continue" to keep going on what's not yet included above (web app, chat,
image upload, real payment/notification wiring, admin dashboard).
