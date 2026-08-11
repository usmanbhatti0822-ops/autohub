# Technical Architecture & Tech Stack

## 1. High-Level Architecture

```
┌─────────────────┐     ┌─────────────────┐
│  Flutter Mobile  │     │   Web App        │
│  (Android/iOS)   │     │ (Next.js/React   │
│                  │     │  or Flutter Web) │
└────────┬─────────┘     └────────┬─────────┘
         │                        │
         └──────────┬─────────────┘
                     │  REST/GraphQL (HTTPS)
                     ▼
         ┌───────────────────────┐
         │   NestJS Backend API   │
         │  (modular: auth,       │
         │   listings, bookings,  │
         │   payments, chat,      │
         │   admin, notifications)│
         └──────────┬──────────────┘
                     │
      ┌──────────────┼───────────────┬─────────────┐
      ▼              ▼               ▼             ▼
 PostgreSQL     Redis (cache/     S3-compatible  Payment
 (primary DB)   queues/session)   storage        Gateways
                                  (images/docs)   (JazzCash/
                                                   Easypaisa/
                                                   Stripe)
```

Admin Panel = separate web frontend (React/Next.js) consuming the same NestJS API with role-gated endpoints.

## 2. Mobile App (Flutter)

- **State Management:** Riverpod
- **Routing:** GoRouter
- **Architecture:** Clean Architecture, feature-first structure
  ```
  lib/
    core/          → shared utils, theme, network client, error handling
    features/
      auth/
        data/  domain/  presentation/
      marketplace/
        data/  domain/  presentation/
      rentals/
        data/  domain/  presentation/
      bookings/
      chat/
      profile/
      admin/ (if admin also needs mobile, optional)
  ```
- **UI:** Material 3, custom design system (not default theme) — see 04-ui-ux-guidelines.md
- **Animation:** `flutter_animate`, `Rive` for complex interactive animations, `Lottie` for micro-animations, Hero animations for listing → detail transitions, implicit animations for state changes
- **Maps:** `google_maps_flutter`
- **Networking:** `dio` + Riverpod providers, repository pattern per feature
- **Local storage/cache:** `hive` or `shared_preferences` for lightweight cache, secure storage for tokens
- **Push notifications:** Firebase Cloud Messaging

## 3. Web App

- **Option A (recommended for speed + best web UX):** Next.js + React + Tailwind, shares API contracts with mobile
- **Option B (max code reuse):** Flutter Web — reuses Flutter codebase but generally weaker for SEO-heavy marketplace pages and animation smoothness on web
- Recommendation: **Next.js for the public marketplace/rental web app** (SEO matters for car listings), Flutter Web only if code-reuse speed outweighs SEO

## 4. Backend (NestJS + PostgreSQL)

- **Modules:** `auth`, `users`, `listings` (sale), `rentals`, `bookings`, `payments`, `chat`, `reviews`, `notifications`, `admin`
- **ORM:** Prisma or TypeORM
- **Auth:** JWT (access + refresh tokens), OTP via SMS gateway (Pakistani SMS provider)
- **Real-time:** WebSockets (Socket.IO/NestJS Gateway) for chat & live booking status
- **File storage:** S3-compatible bucket for images/documents (car photos, CNIC uploads)
- **Queue/Jobs:** BullMQ + Redis for notifications, price-drop alerts, booking reminders
- **Search:** PostgreSQL full-text search initially; consider Meilisearch/Elasticsearch if listing volume grows large
- **Payments:** JazzCash & Easypaisa API integration (local), Stripe/PayFast for card payments (optional phase 2)

## 5. Database — Key Entities (high level)

- `users` (role, verification_level, phone, cnic_status)
- `car_listings` (sale) — make, model, year, price, city, status, seller_id
- `rental_vehicles` — owner_id, daily_rate, availability rules
- `bookings` — vehicle_id, renter_id, dates, status, price_breakdown
- `offers` — listing_id, buyer_id, amount, status
- `payments` — booking_id/order_id, gateway, status, amount
- `reviews` — subject_id, author_id, rating, comment, type (buyer/seller/renter/owner)
- `chats` / `messages`
- `notifications`

(Full ER diagram to be built once scope questions in PRD §8 are answered.)

## 6. DevOps / Infra (baseline)

- Backend hosting: any Docker-friendly host (Railway/Render/DigitalOcean/AWS)
- CI/CD: GitHub Actions
- Environments: dev / staging / production
- Monitoring: Sentry (error tracking), basic uptime monitoring

## 7. Security Notes

- CNIC/ID documents encrypted at rest, access restricted to verification admins
- Rate limiting on OTP and search endpoints
- Input validation via NestJS DTOs + class-validator
- HTTPS everywhere, signed URLs for private file access
