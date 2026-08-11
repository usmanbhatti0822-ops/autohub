# AutoHub — Product Requirements Document (PRD)
*(Working name — replace with final brand name)*

## 1. Project Overview

A two-in-one automotive platform for the Pakistani market combining:
1. **Marketplace** — buy & sell new/used cars (peer-to-peer + dealer listings)
2. **Rental & Booking** — rent cars from individual owners or rental companies, with real-time availability and booking

Delivered as:
- **Mobile App** (Flutter — Android + iOS)
- **Web App** (responsive, same backend)
- **Admin Panel** (web, for platform management)

## 2. Target Market

- Primary: Pakistan (Lahore, Karachi, Islamabad as launch cities)
- Users: individual car buyers/sellers, car dealers, car owners wanting to rent out vehicles, renters (self-drive or with driver), rental companies

## 3. User Roles

| Role | Description |
|---|---|
| Buyer | Browses/searches listings, contacts sellers, saves favorites |
| Seller / Dealer | Posts car-for-sale listings, manages inquiries |
| Car Owner (Renter-out) | Lists a car for rent, sets pricing & availability |
| Renter | Books cars for a date range, with/without driver |
| Admin | Approves listings, manages users, disputes, payments, analytics |
| Support/Ops | Handles verification, complaints, KYC |

## 4. Core Modules

### 4.1 Marketplace (Sale/Purchase)
- Post a listing: photos (multi-upload), video optional, make/model/year/variant, mileage, condition, price, city, registration city, documents (optional upload for trust badge)
- Advanced search & filters: price range, make, model, year, city, fuel type, transmission, mileage, body type
- Saved searches + price-drop alerts
- In-app chat between buyer & seller
- "Verified Seller" / "Inspected Car" badge system
- Offer/negotiation flow (buyer can send offer, seller accept/reject/counter)
- Favorites / Wishlist
- Report listing / fraud flag
- Comparison tool (compare 2–3 cars side by side)

### 4.2 Rental & Booking
- Car owner lists vehicle: photos, specs, daily/weekly rate, security deposit, pickup location, availability calendar, self-drive or with-driver option
- Renter search: location, date range, price, transmission, car type
- Real-time availability calendar (no double-booking)
- Booking flow: select dates → price breakdown → payment → confirmation
- Booking states: requested → confirmed → ongoing → completed → cancelled
- Digital agreement / terms acceptance at booking
- Pickup/return checklist with photo capture (damage documentation)
- Ratings & reviews (renter ↔ owner, both directions)
- Cancellation & refund policy engine

### 4.3 Shared / Platform Features
- Authentication: phone number + OTP (primary, standard in Pakistan), optional email/Google/Apple sign-in
- User profile with verification levels (phone verified, CNIC/ID verified)
- Push notifications (booking updates, new messages, price drops, offers)
- In-app wallet / payment integration: JazzCash, Easypaisa, card (Stripe/PayFast), cash-on-pickup for rentals
- Ratings & reviews system
- Multi-language: Urdu + English toggle
- Location services: map view of listings (Google Maps)
- Admin panel: listing approval, user management, dispute resolution, commission/payout tracking, analytics dashboard

## 5. Non-Functional Requirements

- Advanced, animated, modern UI/UX (smooth transitions, micro-interactions, skeleton loaders — not default Material look)
- Fast search/filter performance even with large listing volume
- Secure payment handling (PCI-adjacent best practices via gateway, never store raw card data)
- Scalable backend (NestJS + PostgreSQL) to handle growth across cities
- Offline-friendly basics (cached last search results)
- Data privacy for CNIC/ID uploads (encrypted storage, restricted admin access)

## 6. Monetization (for later phase, flag for discussion)
- Listing boost / featured placement (marketplace)
- Commission per completed rental booking
- Subscription plan for dealers (bulk listings)
- Verification badge fee (optional)

## 7. Phased Roadmap (see 03-roadmap.md for detail)
- Phase 1: Marketplace core (MVP)
- Phase 2: Rental & Booking core
- Phase 3: Payments, wallet, admin panel maturity
- Phase 4: Advanced UI polish, animations, recommendations, dealer tools

## 8. Open Questions (need your input before dev starts)
- Exact platform cities for launch?
- Will "with driver" rentals be in scope for MVP or Phase 2?
- Payment gateway priority: JazzCash/Easypaisa first, or card gateway too?
- Is CNIC/ID verification mandatory before first listing, or only for high-value trust badge?
- Web app: separate framework (React/Next.js) or Flutter Web reusing mobile codebase?
