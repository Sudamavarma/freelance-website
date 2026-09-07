# CUTFRAME | High-Performance Short-Form & UGC Video Editing Portfolio

![CUTFRAME Banner](https://img.shields.io/badge/Status-Live%20Portfolio-c3f400?style=for-the-badge&logo=youtube&logoColor=black)
![Vercel Ready](https://img.shields.io/badge/Deploy-Vercel%20Ready-000000?style=for-the-badge&logo=vercel&logoColor=white)
![HTML5](https://img.shields.io/badge/Frontend-HTML5%20%2F%20TailwindCSS-38bdf8?style=for-the-badge&logo=tailwindcss&logoColor=white)

A high-converting, performance-focused freelance video editing portfolio engineered for DTC brands, creators, and direct-response marketing agencies.

---

## ⚡ Features

- **Obsidian Dark & Neon Aesthetics**: Tailored `#0e0e10` dark palette with electric lime `#c3f400` accents.
- **Hero Showreel**: Autoplaying, looping hero showreel with full player transport controls (play/pause, timeline scrubber, volume toggle, fullscreen).
- **9:16 High-Performance Showcase**: Interactive vertical video portfolio cards with live hover previews and auto-generated thumbnail frames.
- **Full Video Player Modal**: 9:16 vertical video player modal supporting native MP4 files, YouTube, and Vimeo embeds with direct WhatsApp conversion CTAs.
- **Interactive ROAS Lift Calculator**: Real-time revenue & profit estimator based on monthly ad spend and baseline ROAS.
- **Client Testimonials & FAQs**: High-impact social proof with animated star ratings and expandable accordion answers.
- **Direct WhatsApp & Email Booking**: Interactive inquiry form routing straight to WhatsApp with pre-filled project parameters.

---

## 🚀 Deploying to Vercel (One-Click)

This project is completely static, self-contained, and **Vercel-ready**:

1. Log into your [Vercel Dashboard](https://vercel.com).
2. Click **"Add New..."** → **"Project"**.
3. Import your GitHub repository: `Sudamavarma/freelance-website`.
4. Leave all build settings at their defaults (Framework Preset: *Other*, Root Directory: `./`).
5. Click **"Deploy"**.

Your website will be live globally on Vercel with automatic HTTPS, global CDN edge caching, and video byte-range streaming support!

---

## 💻 Running Locally

### Option 1: PowerShell Server (Includes Byte-Range Streaming)
```powershell
powershell -ExecutionPolicy Bypass -File server.ps1
```
Then visit [http://localhost:8080/](http://localhost:8080/).

### Option 2: Any Static Web Server
```bash
# Python 3
python -m http.server 8080

# Node.js (npx serve)
npx serve .
```

---

## 📂 Project Structure

```
├── index.html          # Main portfolio landing page
├── code.html           # Original reference markup
├── vercel.json         # Vercel deployment headers & caching rules
├── server.ps1          # Lightweight local HTTP server with range streaming
├── .gitignore          # Git ignore rules
├── README.md           # Project documentation
└── videos/             # Video creative media files
    ├── ugc/            # UGC Ads (ugc-1.mp4, ugc-2.mp4, ...)
    ├── brand/          # Brand Promos (brand-1.mp4, brand-2.mp4, ...)
    └── viral/          # Viral Reels (viral-1.mp4, viral-2.mp4, ...)
```

---

## 📬 Contact & Inquiries

- **WhatsApp**: [+91 8978178134](https://wa.me/918978178134)
- **Email**: [chintalapatisudamavarma@gmail.com](mailto:chintalapatisudamavarma@gmail.com)
