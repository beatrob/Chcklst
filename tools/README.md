# App Store Connect analytics helper

`appstore_analytics.py` downloads the Analytics Reports API data and creates a small Markdown brief that you can attach or point Codex at for analysis. It deliberately uses no third-party Python packages.

## One-time setup

In App Store Connect, the Account Holder must first approve access to the App Store Connect API. Create a team API key under **Users and Access → Integrations → App Store Connect API** and download its `.p8` private key. Use a key with **Sales and Reports** access to download Analytics reports; an **Admin** must create the initial report request.

Store the `.p8` file somewhere outside this repository. Copy the repository's `appstore-analytics.ini.example` to `appstore-analytics.ini`, then fill in these properties:

```ini
[appstore]
key_id = your-key-id
issuer_id = your-issuer-uuid
private_key_path = ~/Secrets/AuthKey_your-key-id.p8
app_id = 1234567890
output_dir = appstore-analytics
```

`appstore-analytics.ini` is ignored by Git. The Apple private key itself is never copied into the project or written to the output directory. For CI, the same values can instead be supplied as `APPSTORE_KEY_ID`, `APPSTORE_ISSUER_ID`, `APPSTORE_PRIVATE_KEY_PATH`, and `APPSTORE_APP_ID`; environment variables take precedence over the configuration file.

## Retrieve data

Run all commands from the project root.

```zsh
# Find the App Store Connect resource ID (this is not necessarily the bundle ID).
python3 tools/appstore_analytics.py apps

# Create an ongoing request once per app. Apple normally needs 24–48 hours
# before the first reports are ready. Uses app_id from the config.
# Use --snapshot for historical data.
python3 tools/appstore_analytics.py request

# Download every available Analytics report segment, then produce a brief.
python3 tools/appstore_analytics.py download
python3 tools/appstore_analytics.py summarize
```

Pass `--config /path/to/another.ini` before the command to use a config stored elsewhere, for example `python3 tools/appstore_analytics.py --config ~/.config/my-appstore.ini download`.

By default, files are placed in `appstore-analytics/` (ignored by Git):

- `raw/*.txt.gz` — Apple’s downloaded archives
- `raw/*.txt` — decompressed tab-delimited source data
- `manifest.json` — report name, granularity, and source-file mapping
- `summary.md` — compact, Codex-ready metrics and top rows

Then ask Codex something specific, for example: “Read `appstore-analytics/summary.md` and identify the biggest changes in user engagement, likely causes, and three experiments to run.” If a question needs deeper segmentation, Codex can use the raw `.txt` files alongside the summary.

The tool discovers the report types and granularities Apple has generated for the account; it does not assume a fixed schema. Apple applies privacy thresholds and may add noise to some Analytics data, so interpret low-volume values carefully.
