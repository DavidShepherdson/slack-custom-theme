#!/usr/bin/env bash
# Usage: ./slack-custom_theme.sh (see README.md for other commands)
# Homebaked Slack Custom Theme Applier. After executing this script restart Slack for changes to take effect.
# Adopted from https://gist.github.com/a7madgamal/c2ce04dde8520f426005e5ed28da8608

SLACK_DIRECT_LOCAL_SETTINGS="Library/Application\ Support/Slack/local-settings.json"
SLACK_STORE_LOCAL_SETTINGS="Library/Containers/com.tinyspeck.slackmacgap/Data/Library/Application\ Support/Slack/local-settings.json"
OSX_SLACK_RESOURCES_DIR="/Applications/Slack.app/Contents/Resources"
OSX_USER_SLACK_RESOURCES_DIR="$HOME/Applications/Slack.app/Contents/Resources"
LINUX_SLACK_RESOURCES_DIR="/usr/lib/slack/resources"
UPDATE_ONLY="false"
CUSTOM_CSS_SOURCE_PATH=custom-theme.css

for arg in "$@"; do
    shift
    case "$arg" in
        -[uU]|--[uU]pdate) UPDATE_ONLY="true" ;;
        -[lL]|--[vV]anilla) VANILLA_MODE="true" ;;
        *) echo "Option doesn't exist"; exit 1 ;;
    esac
done

# If we Have a Custom File, Append to the End
if [[ ! -f $CUSTOM_CSS_SOURCE_PATH ]]; then
    echo "Custom theme CSS file not found ($CUSTOM_CSS_SOURCE_PATH)"
    exit 1
fi


if [[ ! -d $OSX_SLACK_RESOURCES_DIR ]] && [[ ! -d $OSX_USER_SLACK_RESOURCES_DIR ]] && [[ ! -d $LINUX_SLACK_RESOURCES_DIR ]]; then echo "Please make sure Slack is installed /Applications or ~/Applications (macOS) or /usr/local/slack (Linux)" && exit 1; fi

echo && echo "This script requires sudo privileges." && echo "You'll need to provide your password."

NPX_PATH=$(type -P npx)
if [[ "$?" != "0" ]]; then echo "Please install NodeJS for your OS." && echo "macOS users will also need to install Homebrew from https://brew.sh" && exit 1; fi

if [[ -d $OSX_SLACK_RESOURCES_DIR ]]; then
    SLACK_RESOURCES_DIR=$OSX_SLACK_RESOURCES_DIR
fi

if [[ -d $OSX_USER_SLACK_RESOURCES_DIR ]] ; then
    SLACK_RESOURCES_DIR=$OSX_USER_SLACK_RESOURCES_DIR
fi

if [[ -d $LINUX_SLACK_RESOURCES_DIR ]]; then SLACK_RESOURCES_DIR=$LINUX_SLACK_RESOURCES_DIR; fi

if [[ "$1" == "-u" ]]; then UPDATE_ONLY="true"; fi

SLACK_EVENT_LISTENER="event-listener.js"
SLACK_FILEPATH="$SLACK_RESOURCES_DIR/app.asar.unpacked/dist/ssb-interop.bundle.js"
THEME_FILEPATH="$SLACK_RESOURCES_DIR/custom-theme.css"

if [[ "$UPDATE_ONLY" == "true" ]]; then echo && echo "Updating Custom Theme Code for Slack... "; fi

if [[ "$UPDATE_ONLY" == "false" ]]; then
    echo && echo "Adding Custom Theme Code to Slack... "
fi

if [[ -z $HOME ]]; then HOME=$(ls -d ~); fi

if [[ "$VANILLA_MODE" == "true" ]]; then
    echo "Removing Custom Theme... " && echo "Please refresh/restart Slack (ctrl/cmd + R) for changes to take affect." && sudo rm -f $THEME_FILEPATH
    exit
fi

# Copy CSS to Slack Folder
sudo cp -af "$CUSTOM_CSS_SOURCE_PATH" "$THEME_FILEPATH"

if [[ "$UPDATE_ONLY" == "false" ]]; then
    # Modify Local Settings
    if [[ -f "$HOME/$SLACK_DIRECT_LOCAL_SETTINGS" ]]; then sed -i 's/"bootSonic":"[^"]*"/"bootSonic":"never"/g' "$HOME/$SLACK_DIRECT_LOCAL_SETTINGS"; fi

    if [[ -f "$HOME/$SLACK_STORE_LOCAL_SETTINGS" ]]; then sudo sed -i 's/"bootSonic":"[^"]*"/"bootSonic":"never"/g' "$HOME/$SLACK_STORE_LOCAL_SETTINGS"; fi

    # Unpack Asar Archive for Slack
    sudo "PATH=$PATH" $NPX_PATH asar extract $SLACK_RESOURCES_DIR/app.asar $SLACK_RESOURCES_DIR/app.asar.unpacked

    # Add JS Code to Slack
    sudo tee -a "$SLACK_FILEPATH" > /dev/null < $SLACK_EVENT_LISTENER

    # Insert the CSS File Location in JS
    sudo sed -i -e s@SLACK_CUSTOM_THEME_PATH@$THEME_FILEPATH@g $SLACK_FILEPATH

    # Pack the Asar Archive for Slack
    sudo "PATH=$PATH" $NPX_PATH asar pack $SLACK_RESOURCES_DIR/app.asar.unpacked $SLACK_RESOURCES_DIR/app.asar
fi

echo && echo "Done! After executing this script restart Slack for changes to take effect."
