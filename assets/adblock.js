// Enhanced ad & tracker blocker
var selectors = ["iframe", "svg", "[class*='ad']", "[src*='tracker']", "[id*='ad']"];
selectors.forEach(sel => document.querySelectorAll(sel).forEach(el => el.remove()));
