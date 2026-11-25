# Disable Chrome “Ask Google” and website install buttons

Chrome can show extra page-action buttons in the address bar, including:

- **Ask Google** / AI Mode / Lens entry points
- the **install website** / PWA install icon

Feature flags are not reliable for fully disabling these. Use local Chrome enterprise policies instead.

## Linux / Google Chrome policy file

Create a managed policy file:

```bash
sudo install -d -m 755 /etc/opt/chrome/policies/managed

sudo tee /etc/opt/chrome/policies/managed/disable-chrome-junk.json >/dev/null <<'JSON'
{
  "GenAiDefaultSettings": 2,
  "AIModeSettings": 1,
  "SearchContentSharingSettings": 1,
  "LensOverlaySettings": 1,
  "GoogleSearchSidePanelEnabled": false,
  "WebAppInstallByUserEnabled": false
}
JSON
```

Fully restart Chrome:

```bash
pkill chrome
google-chrome &
```

Or open:

```text
chrome://restart
```

## Verify

Open:

```text
chrome://policy
```

Click **Reload policies** and confirm the policies appear.

## What the policies do

- `GenAiDefaultSettings: 2` disables Chrome’s covered generative-AI features by default.
- `AIModeSettings: 1` disables Google AI Mode integrations in the address bar and New Tab page search box.
- `SearchContentSharingSettings: 1` disables sharing page/file content with Google AI Mode / Lens through Chrome side panels or tabs.
- `LensOverlaySettings: 1` disables Lens Overlay where still supported.
- `GoogleSearchSidePanelEnabled: false` disables Google Search side panel entry points.
- `WebAppInstallByUserEnabled: false` disables user web-app/PWA installation through the browser, which removes the website install icon.

## Caveat

Chrome will show **“Managed by your organization”** because local policies use Chrome’s enterprise policy mechanism. This is expected.
