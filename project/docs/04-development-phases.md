# Detailed Development Phases

## Phase 0 — Foundation & Setup

**Backend (NestJS)**
- [ ] Repo setup, project scaffold, module structure (`auth`, `users`, `listings`, `rentals`, `bookings`, `payments`, `chat`, `reviews`, `notifications`, `admin`)
- [ ] PostgreSQL setup + Prisma/TypeORM config
- [ ] Base DTOs, error handling, response interceptor
- [ ] Environment configs (dev/staging/prod)

**Mobile (Flutter)**
- [ ] Project scaffold — Clean Architecture folders per feature
- [ ] Riverpod providers setup, GoRouter route structure
- [ ] Theme system (colors, typography, spacing tokens) — Material 3 custom theme
- [ ] Reusable widget library: buttons, cards, inputs, loaders/skeletons
- [ ] Network layer (`dio` client, interceptors, token refresh)

**Web**
- [ ] Next.js project scaffold, Tailwind setup, shared design tokens with mobile

**Design**
- [ ] Finalize brand name, color palette, logo
- [ ] Core screen wireframes: home, listing detail, search/filter, booking flow

**Deliverable:** Empty-but-wired skeleton apps (mobile + web + backend) that can talk to each other with a health-check endpoint.

---

## Phase 1 — Marketplace MVP (Sale/Purchase)

**Backend**
- [ ] Auth module: OTP send/verify, JWT issue/refresh
- [ ] Users module: profile CRUD, verification status field
- [ ] Listings module: create/edit/delete/list/search/filter endpoints
- [ ] Image upload to S3-compatible storage
- [ ] Chat module: basic message send/receive (WebSocket gateway)
- [ ] Admin: listing approve/reject endpoint

**Mobile**
- [ ] OTP login/signup screens
- [ ] Home feed with listings
- [ ] Search + filter UI
- [ ] Listing detail screen (image gallery, seller info, contact button)
- [ ] Post-a-listing flow (multi-step form, image picker/upload)
- [ ] In-app chat screen
- [ ] Favorites/wishlist screen

**Web**
- [ ] Public listing browse/search pages (SEO-friendly)
- [ ] Listing detail page
- [ ] Basic auth (OTP) for posting

**Admin Panel**
- [ ] Login
- [ ] Listings table: approve/reject/flag
- [ ] User management (basic view/suspend)

**Deliverable:** Users can sign up, post a car for sale, browse/search/filter, and chat with a seller — end to end.

---

## Phase 2 — Rental & Booking Core

**Backend**
- [ ] Rentals module: vehicle listing CRUD, availability calendar logic
- [ ] Bookings module: create booking, state machine (requested→confirmed→ongoing→completed→cancelled)
- [ ] Conflict prevention (no double-booking on overlapping dates)
- [ ] Pickup/return checklist endpoint (photo capture metadata)

**Mobile**
- [ ] "List your car for rent" flow (owner side)
- [ ] Availability calendar UI (owner sets, renter views)
- [ ] Rental search + booking flow (date picker → price breakdown → confirm)
- [ ] Booking status tracker screen
- [ ] Pickup/return checklist with camera capture

**Web**
- [ ] Rental browse/search page
- [ ] Booking flow (can defer full flow to mobile-first if timeline tight, keep browse-only on web for this phase)

**Admin Panel**
- [ ] Bookings overview + dispute flag view

**Deliverable:** Owners can list a car for rent; renters can search, book, and complete a full rental cycle.

---

## Phase 3 — Payments & Trust

**Backend**
- [ ] JazzCash/Easypaisa API integration
- [ ] Payment status webhook handling
- [ ] Wallet/payout ledger for owners & sellers
- [ ] CNIC/ID verification workflow (upload → admin review → badge)
- [ ] Reviews module (ratings both directions)
- [ ] FCM push notification service

**Mobile**
- [ ] Payment screen (gateway integration)
- [ ] Wallet/earnings screen (for owners/sellers)
- [ ] ID verification upload flow
- [ ] Ratings & review UI after booking/sale
- [ ] Push notifications wired (booking updates, messages, offers)

**Admin Panel**
- [ ] Verification review queue
- [ ] Payment/payout tracking dashboard

**Deliverable:** Real money moves through the platform safely; trust signals (verified badge, reviews) are live.

---

## Phase 4 — Polish, Animation & Growth

**Mobile/Web**
- [ ] Full animation pass: Hero transitions, Rive/Lottie micro-interactions, skeleton loaders everywhere, page transition polish
- [ ] Comparison tool (compare 2–3 listings)
- [ ] Saved searches + price-drop alerts
- [ ] Recommendation/related-listings logic

**Web**
- [ ] Full booking flow on web (parity with mobile)
- [ ] SEO optimization (meta tags, sitemaps, structured data for listings)

**Admin**
- [ ] Analytics dashboard (listings, bookings, revenue trends)
- [ ] Dealer subscription/bulk-listing tools

**Deliverable:** Production-polish level app ready for wider marketing push.

---

## Notes
- Each phase assumes the previous phase's backend + mobile are stable before moving on — but backend work for the next phase can start in parallel once its module boundaries are clear.
- Timeline/estimates not included here — let me know your team size (solo/small team) and I can add realistic week estimates per phase.
