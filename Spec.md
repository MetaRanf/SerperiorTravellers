# Build Prompt: "Serperior Travellers" — an Airbnb-style Vacation Planning App (iOS, iPhone-only)

## Overview

Build a native **iOS iPhone-only** app for planning and managing vacations, inspired by Airbnb. The app helps users discover destinations, build wishlists, book travel (hotels, flights, car rentals), plan itineraries, and collaborate with family and friends on shared trips.

Please build with **Swift and SwiftUI**, targeting modern iOS. Prioritize a clean, polished, Airbnb-like visual style.

## ⚠️ Scope of This First Ask: Build the Foundation

**This first task is to establish the foundation and scaffolding of the app — not to fully implement every feature.**

The codebase will later be **distributed across multiple engineers working in parallel**, so the priority is a solid, well-organized base that a team can build on top of without stepping on each other. Concretely, this first pass should deliver:

- A clean **project structure and architecture** (clear separation of concerns, e.g. features / models / services / views) that scales to many contributors.
- **Navigation skeleton** wiring together the main screens (home, search, wishlists, trips, map, etc.), even if screens are stubs or placeholders.
- **Core data models** and a **storage layer** interface for users, preferences, wishlists, and trips.
- **Service/API layer stubs** (booking, maps, AI, alerts) with clear boundaries and mock implementations, so real integrations can be dropped in later.
- Shared **design system primitives** (colors, typography, reusable card/list components) for visual consistency.
- Clear **module boundaries and conventions** so features listed below can be assigned to different engineers and developed independently.

Treat the feature list below as the **product roadmap** the foundation must support — not as work to complete in this first pass.

---

## Core Features

### 1. Discovery & Inspiration
- **Vacation carousel** — a scrollable, swipeable carousel of vacation options on the home screen.
- **"Hot" properties & attractions** — highlight popular places and activities with an emoji or badge (e.g. 🔥 trending).
- **Activity recommendations** — when a user enters a destination, suggest things to do there.
- **Surprise Me** — the user provides a time period, location, and budget, and the app proposes the best-matching vacation.

### 2. Search
- **Basic text search** for locations (simple, text-based — no advanced filters required for v1).

### 3. Wishlists
- Let users save destinations and ideas to wishlists, organized by:
  - **Location**
  - **Vacation type** (e.g. family-friendly, pet-friendly)
- **Add / edit wishlist flow** so users can create, update, and remove wishlist items.

### 4. Booking & Travel APIs
- Integrate travel APIs for **hotels, flights, and car rentals** (search + booking).
- **Price tracker** — a generic tracker that monitors flight/hotel prices for selected dates.
- **Booking notifications** — notify the user of booking confirmations, check-in times, and departure times once a route is decided.

### 5. Maps & Routing
- **Location map** showing the user's location and their destinations.
- Selected activities appear as pins on the map, with a **suggested route** connecting them.

### 6. Trip Management
- **My Trips page** — shows the user's active vacation plans.
- **Calendar / itinerary view** — visualize the vacation schedule and track activities day by day.

### 7. Collaboration & Sharing
- **Invite family or friends** to a shared trip plan.
- **Share a vacation plan** with others.

### 8. AI Assistant
- An **AI agent integration** that fetches richer details on a given flight, booking, or activity on demand.

### 9. Alerts
- **Weather and news alerts** for the vacation location.

### 10. Data & Storage
- A **storage system** to persist user information, preferences, and wishes.

---

## Notes & Priorities
- Platform: **iPhone only** (no iPad or other targets required for v1).
- Feel free to use realistic mock data or sandbox/test API keys where live travel APIs aren't available.
- Aim for a cohesive, Airbnb-inspired design language: large imagery, rounded cards, generous spacing.
