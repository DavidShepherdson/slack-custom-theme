# Slack Desktop Custom Theme

Based on [slack-dark-mode by LanikSJ](https://github.com/LanikSJ/slack-dark-mode), but modified to load a user-supplied custom CSS theme rather than a built-in dark theme.

Basic usage:

   1. Put your custom CSS into a file `custom-theme.css`.
   2. Run `slack-custom-theme.sh`.

You'll need to repeat this process any time you download a new version of the Slack client.

If you have changed your custom CSS, but not installed a new version of the Slack client, you can update the CSS by running `slack-custom-theme.sh --update`.

If you want to remove your custom CSS from the Slack client altogether, run `slack-custom-theme.sh --vanilla`.
