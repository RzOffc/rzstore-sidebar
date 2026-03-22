#!/bin/bash

# ============================================================
#   Pterodactyl Sidebar Converter
#   Ubah topbar → sidebar kiri dengan logo RzStore
#   Support: Pterodactyl v1.12.x
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

PANEL_DIR="/var/www/pterodactyl"
THEME_DIR="$PANEL_DIR/public/themes/luxury"
VERSION="2.0.0"

info()    { echo -e "${CYAN}[INFO]${NC}  $1"; }
success() { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }
step()    { echo -e "\n${PURPLE}━━━ $1 ━━━${NC}"; }

check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "Jalankan sebagai root! sudo bash sidebar.sh"
        exit 1
    fi
}

print_banner() {
    clear
    echo -e "${PURPLE}"
    echo "  ██████╗ ███████╗███████╗████████╗ ██████╗ ██████╗ ███████╗"
    echo "  ██╔══██╗╚══███╔╝██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗██╔════╝"
    echo "  ██████╔╝  ███╔╝ ███████╗   ██║   ██║   ██║██████╔╝█████╗  "
    echo "  ██╔══██╗ ███╔╝  ╚════██║   ██║   ██║   ██║██╔══██╗██╔══╝  "
    echo "  ██║  ██║███████╗███████║   ██║   ╚██████╔╝██║  ██║███████╗"
    echo "  ╚═╝  ╚═╝╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝"
    echo -e "${NC}"
    echo -e "${CYAN}  ╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}  ║   ${BOLD}RzStore Sidebar Installer v$VERSION${NC}${CYAN}           ║${NC}"
    echo -e "${CYAN}  ║   Topbar → Sidebar Kiri + Logo RzStore           ║${NC}"
    echo -e "${CYAN}  ╚══════════════════════════════════════════════════╝${NC}"
    echo ""
}

generate_sidebar_css() {
    cat > "$THEME_DIR/sidebar.css" << 'CSSEOF'
@import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&family=Space+Grotesk:wght@400;500;600;700&display=swap');

:root {
  --sb-width: 68px;
  --sb-width-open: 240px;
  --sb-bg: #0a0a0f;
  --sb-border: #1e1e35;
  --sb-accent: #8b5cf6;
  --sb-accent2: #06b6d4;
  --sb-text: #f1f0ff;
  --sb-muted: #5a5880;
  --sb-hover: rgba(139,92,246,0.12);
  --sb-active: rgba(139,92,246,0.2);
  --sb-transition: all 0.3s cubic-bezier(0.4,0,0.2,1);
}

/* ── HIDE ORIGINAL TOPBAR ── */
nav.navigation-bar,
div[data-tw-merge][class*="NavigationBar"],
header[class*="navigation"],
.NavigationBar,
[data-testid="navigation-bar"] {
  display: none !important;
}

/* ── SIDEBAR WRAPPER ── */
#rzstore-sidebar {
  position: fixed;
  top: 0; left: 0;
  height: 100vh;
  width: var(--sb-width);
  background: linear-gradient(180deg, #0d0d1a 0%, #080810 100%);
  border-right: 1px solid var(--sb-border);
  z-index: 9999;
  display: flex;
  flex-direction: column;
  align-items: center;
  transition: var(--sb-transition);
  overflow: hidden;
  box-shadow: 4px 0 40px rgba(0,0,0,0.6);
}

#rzstore-sidebar.open {
  width: var(--sb-width-open);
  align-items: flex-start;
}

/* ── LOGO AREA ── */
#rzstore-logo {
  width: 100%;
  padding: 16px 0;
  display: flex;
  align-items: center;
  justify-content: center;
  border-bottom: 1px solid var(--sb-border);
  cursor: pointer;
  flex-shrink: 0;
  position: relative;
  min-height: 72px;
  background: linear-gradient(135deg, rgba(139,92,246,0.08), rgba(6,182,212,0.04));
}

#rzstore-sidebar.open #rzstore-logo {
  justify-content: flex-start;
  padding: 16px 18px;
  gap: 12px;
}

/* Logo icon — diamond shape */
.rz-logo-icon {
  width: 38px;
  height: 38px;
  flex-shrink: 0;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.rz-logo-icon svg {
  width: 38px;
  height: 38px;
  filter: drop-shadow(0 0 8px rgba(139,92,246,0.7));
  animation: logo-glow 3s ease-in-out infinite;
}

@keyframes logo-glow {
  0%,100% { filter: drop-shadow(0 0 8px rgba(139,92,246,0.7)); }
  50%      { filter: drop-shadow(0 0 16px rgba(6,182,212,0.9)); }
}

/* Logo text */
.rz-logo-text {
  opacity: 0;
  transform: translateX(-10px);
  transition: var(--sb-transition);
  white-space: nowrap;
  pointer-events: none;
}

#rzstore-sidebar.open .rz-logo-text {
  opacity: 1;
  transform: translateX(0);
}

.rz-logo-text .rz-name {
  font-family: 'Space Grotesk', sans-serif;
  font-size: 18px;
  font-weight: 700;
  background: linear-gradient(135deg, #8b5cf6, #06b6d4);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  line-height: 1.1;
  letter-spacing: 0.02em;
}

.rz-logo-text .rz-sub {
  font-size: 10px;
  color: var(--sb-muted);
  letter-spacing: 0.12em;
  text-transform: uppercase;
  font-family: 'Outfit', sans-serif;
}

/* ── TOGGLE BUTTON ── */
#rzstore-toggle {
  position: absolute;
  top: 50%;
  right: -12px;
  transform: translateY(-50%);
  width: 24px;
  height: 24px;
  background: linear-gradient(135deg, var(--sb-accent), var(--sb-accent2));
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  z-index: 10;
  box-shadow: 0 0 12px rgba(139,92,246,0.5);
  transition: var(--sb-transition);
  opacity: 0;
}

#rzstore-logo:hover #rzstore-toggle { opacity: 1; }

#rzstore-toggle svg {
  width: 12px; height: 12px;
  fill: white;
  transition: transform 0.3s ease;
}

#rzstore-sidebar.open #rzstore-toggle svg {
  transform: rotate(180deg);
}

/* ── NAV ITEMS ── */
#rzstore-nav {
  flex: 1;
  width: 100%;
  padding: 10px 0;
  overflow-y: auto;
  overflow-x: hidden;
  scrollbar-width: none;
}
#rzstore-nav::-webkit-scrollbar { display: none; }

.rz-nav-item {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  padding: 12px 0;
  cursor: pointer;
  position: relative;
  transition: var(--sb-transition);
  text-decoration: none !important;
  color: var(--sb-muted) !important;
  gap: 0;
  overflow: hidden;
}

#rzstore-sidebar.open .rz-nav-item {
  justify-content: flex-start;
  padding: 11px 18px;
  gap: 14px;
}

.rz-nav-item::before {
  content: '';
  position: absolute;
  left: 0; top: 15%; bottom: 15%;
  width: 3px;
  background: linear-gradient(180deg, var(--sb-accent), var(--sb-accent2));
  border-radius: 0 3px 3px 0;
  opacity: 0;
  transition: var(--sb-transition);
}

.rz-nav-item:hover {
  background: var(--sb-hover) !important;
  color: var(--sb-text) !important;
}
.rz-nav-item:hover::before { opacity: 1; }

.rz-nav-item.active {
  background: var(--sb-active) !important;
  color: var(--sb-text) !important;
}
.rz-nav-item.active::before { opacity: 1; }

/* Nav icon */
.rz-nav-icon {
  width: 38px;
  height: 38px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  background: transparent;
  transition: var(--sb-transition);
}

.rz-nav-item:hover .rz-nav-icon,
.rz-nav-item.active .rz-nav-icon {
  background: rgba(139,92,246,0.15);
}

.rz-nav-icon svg {
  width: 18px; height: 18px;
  fill: currentColor;
  transition: var(--sb-transition);
}

/* Nav label */
.rz-nav-label {
  font-family: 'Outfit', sans-serif;
  font-size: 13.5px;
  font-weight: 500;
  white-space: nowrap;
  opacity: 0;
  transform: translateX(-8px);
  transition: var(--sb-transition);
  pointer-events: none;
}

#rzstore-sidebar.open .rz-nav-label {
  opacity: 1;
  transform: translateX(0);
}

/* Tooltip (collapsed) */
.rz-nav-item .rz-tooltip {
  position: absolute;
  left: calc(var(--sb-width) + 8px);
  top: 50%;
  transform: translateY(-50%);
  background: rgba(15,15,26,0.98);
  color: var(--sb-text);
  font-family: 'Outfit', sans-serif;
  font-size: 12px;
  font-weight: 500;
  padding: 6px 12px;
  border-radius: 8px;
  white-space: nowrap;
  pointer-events: none;
  opacity: 0;
  transition: opacity 0.15s ease;
  border: 1px solid var(--sb-border);
  z-index: 99999;
}

#rzstore-sidebar:not(.open) .rz-nav-item:hover .rz-tooltip {
  opacity: 1;
}

/* ── DIVIDER ── */
.rz-divider {
  width: calc(100% - 24px);
  height: 1px;
  background: var(--sb-border);
  margin: 6px 12px;
  flex-shrink: 0;
}

/* ── SECTION LABEL ── */
.rz-section-label {
  font-family: 'Outfit', sans-serif;
  font-size: 9px;
  font-weight: 600;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: var(--sb-muted);
  padding: 8px 18px 4px;
  opacity: 0;
  transition: var(--sb-transition);
  white-space: nowrap;
}
#rzstore-sidebar.open .rz-section-label { opacity: 1; }

/* ── BOTTOM USER AREA ── */
#rzstore-bottom {
  width: 100%;
  padding: 10px 0;
  border-top: 1px solid var(--sb-border);
  flex-shrink: 0;
}

/* ── MAIN CONTENT SHIFT ── */
body {
  padding-left: var(--sb-width) !important;
  transition: padding-left 0.3s cubic-bezier(0.4,0,0.2,1) !important;
}

body.sidebar-open {
  padding-left: var(--sb-width-open) !important;
}

/* ── PAGE BG ── */
body {
  background: #0a0a0f !important;
}

/* Cards & content */
.card, .box, [class*="ContentBox"],
div[class*="bg-white"], div[class*="bg-neutral"] {
  background: #13131f !important;
  border: 1px solid #1e1e35 !important;
  border-radius: 14px !important;
}

/* Gradient line at top of page */
body::after {
  content: '';
  position: fixed;
  top: 0;
  left: var(--sb-width);
  right: 0;
  height: 2px;
  background: linear-gradient(90deg, var(--sb-accent), var(--sb-accent2), var(--sb-accent));
  background-size: 200% 100%;
  animation: gradient-slide 3s linear infinite;
  z-index: 9998;
  transition: left 0.3s ease;
}

body.sidebar-open::after {
  left: var(--sb-width-open);
}

@keyframes gradient-slide {
  0%   { background-position: 0% 0; }
  100% { background-position: 200% 0; }
}

/* Particles canvas */
#rz-particles {
  position: fixed;
  inset: 0;
  pointer-events: none;
  z-index: -1;
  opacity: 0.2;
}
CSSEOF
    success "sidebar.css dibuat!"
}

generate_sidebar_js() {
    cat > "$THEME_DIR/sidebar.js" << 'JSEOF'
(function() {
  'use strict';

  const SIDEBAR_OPEN_KEY = 'rzstore_sidebar_open';

  // Nav items config
  const NAV_ITEMS = [
    {
      label: 'Dashboard',
      href: '/',
      icon: '<svg viewBox="0 0 24 24"><path d="M3 13h8V3H3v10zm0 8h8v-6H3v6zm10 0h8V11h-8v10zm0-18v6h8V3h-8z"/></svg>',
      match: (p) => p === '/' || p === ''
    },
    {
      label: 'Servers',
      href: '/',
      icon: '<svg viewBox="0 0 24 24"><path d="M20 3H4v10c0 2.21 1.79 4 4 4h6c2.21 0 4-1.79 4-4v-3h2c1.11 0 2-.89 2-2V5c0-1.11-.89-2-2-2zm0 5h-2V5h2v3zM4 19h16v2H4z"/></svg>',
      match: (p) => p.startsWith('/server')
    },
    {
      label: 'Account',
      href: '/account',
      icon: '<svg viewBox="0 0 24 24"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>',
      match: (p) => p.startsWith('/account')
    },
    {
      label: 'API Keys',
      href: '/account/api',
      icon: '<svg viewBox="0 0 24 24"><path d="M12.65 10C11.83 7.67 9.61 6 7 6c-3.31 0-6 2.69-6 6s2.69 6 6 6c2.61 0 4.83-1.67 5.65-4H17v4h4v-4h2v-4H12.65zM7 14c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2z"/></svg>',
      match: (p) => p.startsWith('/account/api')
    },
    {
      type: 'divider'
    },
    {
      label: 'SSH Keys',
      href: '/account/ssh',
      icon: '<svg viewBox="0 0 24 24"><path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z"/></svg>',
      match: (p) => p.startsWith('/account/ssh')
    },
    {
      label: 'Activity',
      href: '/account/activity',
      icon: '<svg viewBox="0 0 24 24"><path d="M13.5 5.5c1.09 0 2-.9 2-2s-.91-2-2-2c-1.1 0-2 .9-2 2s.9 2 2 2zM9.8 8.9L7 23h2.1l1.8-8 2.1 2v6h2v-7.5l-2.1-2 .6-3C14.8 12 16.8 13 19 13v-2c-1.9 0-3.5-1-4.3-2.4l-1-1.6c-.4-.6-1-1-1.7-1-.3 0-.5.1-.8.1L6 8.3V13h2V9.6l1.8-.7"/></svg>',
      match: (p) => p.startsWith('/account/activity')
    },
  ];

  function buildSidebar() {
    if (document.getElementById('rzstore-sidebar')) return;

    const isOpen = localStorage.getItem(SIDEBAR_OPEN_KEY) === 'true';
    const path = window.location.pathname;

    const sidebar = document.createElement('div');
    sidebar.id = 'rzstore-sidebar';
    if (isOpen) {
      sidebar.classList.add('open');
      document.body.classList.add('sidebar-open');
    }

    // ── LOGO ──
    const logo = document.createElement('div');
    logo.id = 'rzstore-logo';
    logo.title = 'Toggle Sidebar';
    logo.innerHTML = `
      <div class="rz-logo-icon">
        <svg viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="rz-g1" x1="0" y1="0" x2="40" y2="40" gradientUnits="userSpaceOnUse">
              <stop offset="0%" stop-color="#8b5cf6"/>
              <stop offset="100%" stop-color="#06b6d4"/>
            </linearGradient>
            <linearGradient id="rz-g2" x1="0" y1="0" x2="40" y2="40" gradientUnits="userSpaceOnUse">
              <stop offset="0%" stop-color="#06b6d4"/>
              <stop offset="100%" stop-color="#ec4899"/>
            </linearGradient>
          </defs>
          <!-- Outer diamond -->
          <polygon points="20,2 38,20 20,38 2,20" fill="none" stroke="url(#rz-g1)" stroke-width="1.5" opacity="0.6"/>
          <!-- Inner diamond -->
          <polygon points="20,8 32,20 20,32 8,20" fill="url(#rz-g1)" opacity="0.15"/>
          <!-- RZ letters -->
          <text x="20" y="25" text-anchor="middle" font-family="Space Grotesk, sans-serif"
            font-size="13" font-weight="700" fill="url(#rz-g2)" letter-spacing="-0.5">RZ</text>
          <!-- Corner dots -->
          <circle cx="20" cy="3.5" r="1.5" fill="url(#rz-g1)"/>
          <circle cx="36.5" cy="20" r="1.5" fill="url(#rz-g1)"/>
          <circle cx="20" cy="36.5" r="1.5" fill="url(#rz-g1)"/>
          <circle cx="3.5" cy="20" r="1.5" fill="url(#rz-g1)"/>
        </svg>
      </div>
      <div class="rz-logo-text">
        <div class="rz-name">RzStore</div>
        <div class="rz-sub">Game Panel</div>
      </div>
      <div id="rzstore-toggle">
        <svg viewBox="0 0 24 24"><path d="M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6z"/></svg>
      </div>
    `;

    logo.addEventListener('click', toggleSidebar);
    sidebar.appendChild(logo);

    // ── NAV ──
    const nav = document.createElement('div');
    nav.id = 'rzstore-nav';

    NAV_ITEMS.forEach(item => {
      if (item.type === 'divider') {
        const div = document.createElement('div');
        div.className = 'rz-divider';
        nav.appendChild(div);
        return;
      }

      const a = document.createElement('a');
      a.href = item.href;
      a.className = 'rz-nav-item';
      if (item.match(path)) a.classList.add('active');

      a.innerHTML = `
        <div class="rz-nav-icon">${item.icon}</div>
        <span class="rz-nav-label">${item.label}</span>
        <span class="rz-tooltip">${item.label}</span>
      `;
      nav.appendChild(a);
    });

    sidebar.appendChild(nav);

    // ── BOTTOM ──
    const bottom = document.createElement('div');
    bottom.id = 'rzstore-bottom';

    // Logout button
    const logoutBtn = document.createElement('a');
    logoutBtn.href = '/auth/logout';
    logoutBtn.className = 'rz-nav-item';
    logoutBtn.style.color = 'rgba(239,68,68,0.7)';
    logoutBtn.innerHTML = `
      <div class="rz-nav-icon">
        <svg viewBox="0 0 24 24" fill="currentColor">
          <path d="M17 7l-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5zM4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4V5z"/>
        </svg>
      </div>
      <span class="rz-nav-label">Logout</span>
      <span class="rz-tooltip">Logout</span>
    `;
    bottom.appendChild(logoutBtn);
    sidebar.appendChild(bottom);

    document.body.prepend(sidebar);
    initParticles();
  }

  function toggleSidebar() {
    const sidebar = document.getElementById('rzstore-sidebar');
    if (!sidebar) return;
    const isOpen = sidebar.classList.toggle('open');
    document.body.classList.toggle('sidebar-open', isOpen);
    localStorage.setItem(SIDEBAR_OPEN_KEY, isOpen);
  }

  function initParticles() {
    const canvas = document.createElement('canvas');
    canvas.id = 'rz-particles';
    document.body.appendChild(canvas);
    const ctx = canvas.getContext('2d');
    let W = canvas.width = window.innerWidth;
    let H = canvas.height = window.innerHeight;
    const COLORS = ['#8b5cf6','#06b6d4','#ec4899'];
    const pts = Array.from({length:40},()=>({
      x:Math.random()*W, y:Math.random()*H,
      vx:(Math.random()-.5)*.25, vy:(Math.random()-.5)*.25,
      r:Math.random()*1.2+.3,
      c:COLORS[Math.floor(Math.random()*3)],
      a:Math.random()*.35+.1
    }));
    function draw(){
      ctx.clearRect(0,0,W,H);
      pts.forEach(p=>{
        p.x+=p.vx; p.y+=p.vy;
        if(p.x<0)p.x=W; if(p.x>W)p.x=0;
        if(p.y<0)p.y=H; if(p.y>H)p.y=0;
        ctx.beginPath(); ctx.arc(p.x,p.y,p.r,0,Math.PI*2);
        ctx.fillStyle=p.c; ctx.globalAlpha=p.a; ctx.fill();
      });
      for(let i=0;i<pts.length;i++) for(let j=i+1;j<pts.length;j++){
        const dx=pts[i].x-pts[j].x,dy=pts[i].y-pts[j].y,d=Math.sqrt(dx*dx+dy*dy);
        if(d<80){
          ctx.beginPath();ctx.moveTo(pts[i].x,pts[i].y);ctx.lineTo(pts[j].x,pts[j].y);
          ctx.strokeStyle='#8b5cf6';ctx.globalAlpha=(1-d/80)*.07;ctx.lineWidth=.4;ctx.stroke();
        }
      }
      ctx.globalAlpha=1; requestAnimationFrame(draw);
    }
    draw();
    window.addEventListener('resize',()=>{W=canvas.width=window.innerWidth;H=canvas.height=window.innerHeight;});
  }

  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded', buildSidebar);
  else buildSidebar();
})();
JSEOF
    success "sidebar.js dibuat!"
}

inject_files() {
    step "Menginjeksi ke Blade Templates"

    local CSS_TAG='<link rel="stylesheet" href="/themes/luxury/sidebar.css?v=2.0.0">'
    local JS_TAG='<script defer src="/themes/luxury/sidebar.js?v=2.0.0"></script>'

    local FILES=(
        "$PANEL_DIR/resources/views/templates/base/core.blade.php"
        "$PANEL_DIR/resources/views/templates/wrapper.blade.php"
        "$PANEL_DIR/resources/views/layouts/admin.blade.php"
        "$PANEL_DIR/resources/views/layouts/scripts.blade.php"
    )

    for f in "${FILES[@]}"; do
        if [ -f "$f" ]; then
            grep -q "sidebar.css" "$f" || sed -i "s|</head>|$CSS_TAG\n</head>|" "$f"
            grep -q "sidebar.js" "$f"  || sed -i "s|</body>|$JS_TAG\n</body>|" "$f"
            success "Injeksi: $(basename $f)"
        fi
    done
}

restart_panel() {
    step "Restart Panel"
    cd "$PANEL_DIR"
    php artisan view:clear 2>/dev/null && success "Cache cleared!"
    systemctl restart php8.3-fpm 2>/dev/null || \
    systemctl restart php8.2-fpm 2>/dev/null || \
    systemctl restart php8.1-fpm 2>/dev/null || true
    systemctl restart nginx 2>/dev/null && success "Nginx restarted!"
}

# ── MAIN ──
check_root
print_banner
step "Install RzStore Sidebar"

if [ ! -d "$THEME_DIR" ]; then
    mkdir -p "$THEME_DIR"
    info "Membuat direktori tema..."
fi

generate_sidebar_css
generate_sidebar_js
inject_files
restart_panel

echo ""
echo -e "${PURPLE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✦  RzStore Sidebar berhasil diinstall!  ✦      ║${NC}"
echo -e "${PURPLE}║                                                  ║${NC}"
echo -e "${PURPLE}║   ▸ Sidebar kiri dengan logo RzStore             ║${NC}"
echo -e "${PURPLE}║   ▸ Klik logo untuk buka/tutup sidebar           ║${NC}"
echo -e "${PURPLE}║   ▸ Hover icon untuk lihat label (collapsed)     ║${NC}"
echo -e "${PURPLE}║   ▸ Posisi tersimpan otomatis                    ║${NC}"
echo -e "${PURPLE}║                                                  ║${NC}"
echo -e "${YELLOW}║   Refresh browser Ctrl+Shift+R !                 ║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════╝${NC}"
