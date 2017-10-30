User-Script "Effects"
=====================

This script adds an mode with RGB LED effects (and optionally sound).

Usage:

- Right/Blue Button: "SELECT"
  - Short press (50-300ms): Select next effect
  - Longer press (300-1000ms): Change color
  - Long press (1000-3000ms): Toggle sound output


Web API:

- `curl -H "ESPAUTH: $(ESPAUTH)" -s "http://$(ESPCONN)/effect?n=3&color=f00&color2=00f&fade=2&ms=20&duration=74&sound=1"`
