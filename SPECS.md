# 🧠 Adx402 — Technical Requirements

## 1. Agentic Automation (n8n-based)

### Overview

Handles all backend logic and orchestration:

- Ad publication and validation
- Content moderation (AI filter)
- Matching ads with publishers
- Reward calculation and payment scheduling

### Core Requirements

#### 🔧 Infrastructure

- **Runtime:** n8n self-hosted (Docker)
- **DB:** Supabase (PostgreSQL)
- **ORM:** Drizzle for schema and migrations
- **Storage:** Supabase Storage for ad assets
- **Blockchain:** Solana + x402 endpoints for payments and wallet verification
- **Hosting:** Vercel Edge Function or Railway for API gateway

#### 🧩 Workflows

1. **POST /publish-ad**
   - Validate `wallet` via x402
   - Check `brand:wallet` mapping (create if new, charge account creation fee)
   - Run content filter (AI moderation)
   - Store ad metadata in Supabase (`id`, `url`, `aspect_ratio`, `tags`, `wallet`)
   - Return `402` if payment required, else confirmation payload

2. **GET /ad/<creator>**
   - Retrieve publisher profile (wallet, tags, site metrics)
   - Match ads using LLM or scoring algorithm
   - Return ad metadata (image URL, target link, expiry)

3. **Ad Click Tracker**
   - Endpoint `/track-click` updates `creator:ad:click-count`
   - Includes simple anti-abuse heuristics (unique IP, time window)

4. **Weekly Settlement Job**
   - Aggregate verified impressions and clicks
   - Compute proportional rewards
   - Execute x402 transfer to publisher wallets

#### 🤖 AI Integrations

- **Content filter:** Third-party model (e.g., OpenAI moderation, Hive AI, or custom CLIP-based)
- **Ad-matching:** Lightweight LLM or embedding similarity search (tags, vibe)
- **Fraud detection:** Heuristic agent detecting click farms / fake traffic

#### ⚖️ Incentive Rules

- Brand registration = small one-time fee
- Ad lifespan = 7 days (configurable)
- Publisher reward = f(impressions, clicks, slot count)
  - Logarithmic reward drop after 3–5 slots
- Brand:wallet uniqueness enforced

---

## 2. Frontend SDK (Framework-Agnostic)

### Overview

A lightweight client library that allows any website or app to display dynamic, rewarded ads — no wallet setup required for the user.

### Core Requirements

#### ⚙️ Runtime

- **Language:** TypeScript → compiled to ESM + UMD
- **Build Tool:** Vite or tsup
- **Size Target:** < 30 KB gzipped
- **Dependencies:** None (vanilla JS compatible)

#### 🧱 API Design

```js
// Initialize global instance
adx402.init({
  wallet: "creator_wallet_address",
  tags: ["tech", "gaming", "education"], // optional
});

// Render an ad slot
adx402.render("#slot-id", {
  aspectRatio: "16x9", // or "1x1", "5x6", auto-detect
  fallback: "/img/placeholder.png",
});
```

### 🪶 Behavior

- Each `adx402.render()` creates an iframe or shadow DOM for isolation.
- Auto-resizes based on container width.
- Sends request to `/ad/<creator>` with wallet, tags, and aspectRatio.
- Tracks impressions + clicks (debounced, anti-spam).
- Receives and displays the matched ad from Supabase CDN.
- Optionally caches ads locally for 1 hour to minimize API load.

### 🧰 Optional Enhancements

- Lazy-load ads (IntersectionObserver)
- Support for `dark/light` mode ad variants
- WebComponent wrapper: `<adx-slot tags="tech,gaming" aspect="16x9"></adx-slot>`
- Analytics hook `(adx402.on('click', handler))`
