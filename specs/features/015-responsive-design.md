# Feature 015: Responsive Design

## Status: draft

## User Story
Als Nutzer möchte ich die App auf jedem Gerät optimal nutzen können, egal ob Desktop, Tablet oder Smartphone.

## Akzeptanzkriterien
- [ ] Breakpoints: Mobile (<600px), Tablet (600-1024px), Desktop (>1024px)
- [ ] Mobile: Karte fullscreen, Filter als Bottom Sheet
- [ ] Tablet: Karte mit seitlichem Panel für Details
- [ ] Desktop: Split-View mit Liste links und Karte rechts
- [ ] Touch-optimierte Controls auf Mobile
- [ ] Hover-Effekte auf Desktop
- [ ] Widget-Tests für verschiedene Screen-Größen

## UI/UX
- Adaptive Layouts mit LayoutBuilder/MediaQuery
- Keine horizontalen Scrollbalken
- Mindestgröße: 320px Breite

## Technische Notizen
- Flutter LayoutBuilder für responsive Breakpoints
- Separate Widgets für Mobile/Desktop Layouts
