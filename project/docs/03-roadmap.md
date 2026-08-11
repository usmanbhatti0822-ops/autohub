# Development Roadmap (Phased)

## Phase 0 — Foundation (before feature work)
- Finalize open questions from PRD §8
- Finalize brand name, color palette, design system tokens
- Set up repos (mobile, backend, web), CI/CD, environments
- Database schema v1 + NestJS project skeleton (modules scaffolded)
- Flutter project skeleton (Clean Architecture folders, Riverpod + GoRouter wired, theme system)

## Phase 1 — Marketplace MVP
- Auth (OTP login/signup)
- Post/edit/delete car listing
- Browse, search, filters
- Listing detail page with image gallery
- In-app chat (buyer↔seller)
- Favorites/wishlist
- Basic admin: approve/reject listings, manage users

## Phase 2 — Rental & Booking Core
- Owner: list vehicle for rent, set availability & pricing
- Renter: search, view availability calendar, book
- Booking lifecycle (request → confirm → ongoing → complete)
- Pickup/return checklist with photo capture
- Cancellation rules

## Phase 3 — Payments & Trust
- JazzCash/Easypaisa integration
- Wallet / payout system for owners & sellers
- CNIC/ID verification flow + verified badges
- Ratings & reviews (both modules)
- Push notifications (FCM)

## Phase 4 — Polish & Growth
- Advanced UI animations pass (Rive/Lottie interactions, page transitions)
- Comparison tool, price-drop alerts, saved searches
- Web app launch (Next.js) with SEO optimization
- Admin analytics dashboard
- Dealer subscription tools

## Suggested Next Step
Once you confirm the open questions in `01-PRD.md §8`, we move to:
1. Final Figma-level UI/UX direction (or I generate high-fidelity design specs)
2. Database ER diagram
3. Flutter project scaffold + NestJS project scaffold (actual code, feature-first)
