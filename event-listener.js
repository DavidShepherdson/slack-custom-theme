
document.addEventListener('DOMContentLoaded', function() {
  const fs = require('fs');
  const filePath = "SLACK_CUSTOM_THEME_PATH";
  const IS_CUSTOM_THEME_KEY = "isCustomTheme";

  fs.readFile(filePath, {
    encoding: 'utf-8'
  }, function(err, css) {
    if (!err) {
      const styleEl = document.createElement("style");
      const head = document.querySelector("head");
      styleEl.innerHTML = css;

      if (localStorage.getItem(IS_CUSTOM_THEME_KEY) === null) {
        localStorage.setItem(IS_CUSTOM_THEME_KEY, true);
        window.location.reload(true);
      }

      if (JSON.parse(localStorage.getItem(IS_CUSTOM_THEME_KEY))) {
        head.append(styleEl);
      }

      document.addEventListener("keydown", (event) => {
        if (event.ctrlKey && event.keyCode === 76) {
          const isCustomTheme = JSON.parse(localStorage.getItem(IS_CUSTOM_THEME_KEY));
          isCustomTheme ? head.removeChild(styleEl) : head.append(styleEl);
          localStorage.setItem(IS_CUSTOM_THEME_KEY, !isCustomTheme);
        }
      });
    }
  });
});
