#!/usr/bin/env python3
"""Download and summarize App Store Connect Analytics reports.

Uses only the Python standard library plus the macOS ``openssl`` command that
ships with Xcode/macOS. Credentials are supplied through environment variables
so the Apple private key never needs to be committed to this repository.
"""

from __future__ import annotations

import argparse
import base64
import configparser
import csv
import datetime as dt
import gzip
import json
import os
import re
import shutil
import subprocess
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from collections import Counter
from pathlib import Path
from typing import Any, Iterator


API_BASE = "https://api.appstoreconnect.apple.com/v1"
DEFAULT_OUTPUT = Path("appstore-analytics")
DEFAULT_CONFIG = Path("appstore-analytics.ini")
CONFIG: configparser.SectionProxy | None = None


def fail(message: str) -> "NoReturn":
    print(f"error: {message}", file=sys.stderr)
    raise SystemExit(2)


def b64url(value: bytes) -> str:
    return base64.urlsafe_b64encode(value).rstrip(b"=").decode("ascii")


def der_length(data: bytes, index: int) -> tuple[int, int]:
    if index >= len(data):
        raise ValueError("truncated DER signature")
    first = data[index]
    index += 1
    if first < 0x80:
        return first, index
    count = first & 0x7F
    if count == 0 or index + count > len(data):
        raise ValueError("invalid DER length")
    return int.from_bytes(data[index : index + count], "big"), index + count


def der_ecdsa_to_jose(signature: bytes) -> bytes:
    """Convert OpenSSL's ASN.1 DER ECDSA signature to JWT's 64-byte form."""
    if not signature or signature[0] != 0x30:
        raise ValueError("expected a DER ECDSA sequence")
    length, index = der_length(signature, 1)
    if index + length != len(signature):
        raise ValueError("invalid DER ECDSA sequence length")
    values: list[bytes] = []
    for _ in range(2):
        if index >= len(signature) or signature[index] != 0x02:
            raise ValueError("expected DER ECDSA integer")
        size, index = der_length(signature, index + 1)
        value = signature[index : index + size]
        index += size
        values.append(value.lstrip(b"\0").rjust(32, b"\0"))
    if index != len(signature) or any(len(value) != 32 for value in values):
        raise ValueError("invalid P-256 ECDSA signature")
    return b"".join(values)


def get_setting(environment_name: str, config_name: str) -> str:
    """Read a setting from the environment first, then [appstore] config."""
    value = os.environ.get(environment_name)
    if not value and CONFIG is not None:
        value = CONFIG.get(config_name, fallback="")
    if not value:
        fail(f"{config_name} is not configured; add it to {DEFAULT_CONFIG} or set {environment_name}")
    return value


def make_token() -> str:
    key_id = get_setting("APPSTORE_KEY_ID", "key_id")
    issuer_id = get_setting("APPSTORE_ISSUER_ID", "issuer_id")
    key_path = Path(get_setting("APPSTORE_PRIVATE_KEY_PATH", "private_key_path")).expanduser()
    if not key_path.is_file():
        fail(f"private key does not exist: {key_path}")
    if shutil.which("openssl") is None:
        fail("openssl is required to sign the App Store Connect JWT")

    now = int(time.time())
    header = b64url(json.dumps({"alg": "ES256", "kid": key_id, "typ": "JWT"}, separators=(",", ":")).encode())
    payload = b64url(json.dumps({"iss": issuer_id, "iat": now, "exp": now + 19 * 60, "aud": "appstoreconnect-v1"}, separators=(",", ":")).encode())
    signing_input = f"{header}.{payload}".encode("ascii")
    try:
        result = subprocess.run(
            ["openssl", "dgst", "-sha256", "-sign", str(key_path)],
            input=signing_input,
            capture_output=True,
            check=True,
        )
    except subprocess.CalledProcessError as exc:
        fail(f"could not sign JWT with {key_path}: {exc.stderr.decode(errors='replace').strip()}")
    return f"{header}.{payload}.{b64url(der_ecdsa_to_jose(result.stdout))}"


def request_json(method: str, url: str, body: dict[str, Any] | None = None, authenticate: bool = True) -> dict[str, Any]:
    headers = {"Accept": "application/json"}
    data = None
    if authenticate:
        headers["Authorization"] = f"Bearer {make_token()}"
    if body is not None:
        headers["Content-Type"] = "application/json"
        data = json.dumps(body).encode("utf-8")
    request = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            return json.load(response)
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        fail(f"Apple API returned HTTP {exc.code}: {detail}")
    except urllib.error.URLError as exc:
        fail(f"could not reach Apple API: {exc.reason}")


def all_pages(url: str) -> Iterator[dict[str, Any]]:
    while url:
        page = request_json("GET", url)
        yield page
        url = page.get("links", {}).get("next", "")


def all_data(url: str) -> Iterator[dict[str, Any]]:
    for page in all_pages(url):
        yield from page.get("data", [])


def write_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def command_apps(args: argparse.Namespace) -> None:
    fields = urllib.parse.urlencode({"fields[apps]": "name,bundleId,sku"})
    apps = list(all_data(f"{API_BASE}/apps?{fields}"))
    if not apps:
        print("No apps are visible to this API key.")
        return
    print("id\tname\tbundle ID\tsku")
    for app in apps:
        attributes = app.get("attributes", {})
        print(f"{app['id']}\t{attributes.get('name', '')}\t{attributes.get('bundleId', '')}\t{attributes.get('sku', '')}")


def configured_app_id(value: str | None) -> str:
    if value:
        return value
    return get_setting("APPSTORE_APP_ID", "app_id")


def configured_output(value: str | None) -> Path:
    if value:
        return Path(value)
    if CONFIG is not None:
        configured = CONFIG.get("output_dir", fallback="")
        if configured:
            return Path(configured)
    return DEFAULT_OUTPUT


def command_request(args: argparse.Namespace) -> None:
    app_id = configured_app_id(args.app_id)
    body = {
        "data": {
            "type": "analyticsReportRequests",
            "attributes": {"accessType": "ONE_TIME_SNAPSHOT" if args.snapshot else "ONGOING"},
            "relationships": {"app": {"data": {"type": "apps", "id": app_id}}},
        }
    }
    response = request_json("POST", f"{API_BASE}/analyticsReportRequests", body)
    request = response["data"]
    print(f"Created {request['attributes']['accessType']} report request: {request['id']}")
    if not args.snapshot:
        print("Apple usually makes the first ongoing reports available in 24–48 hours.")


def download_url(url: str, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    request = urllib.request.Request(url, headers={"Authorization": f"Bearer {make_token()}"})
    try:
        with urllib.request.urlopen(request, timeout=120) as response, destination.open("wb") as target:
            shutil.copyfileobj(response, target)
    except urllib.error.HTTPError as exc:
        fail(f"download failed with HTTP {exc.code}: {exc.read().decode(errors='replace')}")


def safe_name(value: str) -> str:
    return re.sub(r"[^A-Za-z0-9._-]+", "_", value).strip("_") or "report"


def command_download(args: argparse.Namespace) -> None:
    app_id = configured_app_id(args.app_id)
    output = configured_output(args.output)
    request_url = f"{API_BASE}/apps/{app_id}/analyticsReportRequests"
    requests = list(all_data(request_url))
    if args.request_id:
        requests = [request for request in requests if request["id"] == args.request_id]
    if not requests:
        fail("no analytics report request found; run request first, then retry when Apple has generated reports")

    manifest: list[dict[str, str]] = []
    for report_request in requests:
        report_url = f"{API_BASE}/analyticsReportRequests/{report_request['id']}/reports"
        for report in all_data(report_url):
            name = report.get("attributes", {}).get("name", report["id"])
            for instance in all_data(f"{API_BASE}/analyticsReports/{report['id']}/instances"):
                granularity = instance.get("attributes", {}).get("granularity", "UNKNOWN")
                for segment in all_data(f"{API_BASE}/analyticsReportInstances/{instance['id']}/segments"):
                    attributes = segment.get("attributes", {})
                    source_url = attributes.get("url")
                    if not source_url:
                        continue
                    filename = safe_name(f"{name}_{granularity}_{segment['id']}") + ".txt.gz"
                    gzip_path = output / "raw" / filename
                    if not gzip_path.exists() or args.force:
                        print(f"Downloading {name} ({granularity})")
                        download_url(source_url, gzip_path)
                    tsv_path = gzip_path.with_suffix("")
                    if not tsv_path.exists() or args.force:
                        with gzip.open(gzip_path, "rb") as source, tsv_path.open("wb") as target:
                            shutil.copyfileobj(source, target)
                    manifest.append({"request_id": report_request["id"], "report": name, "granularity": granularity, "file": str(tsv_path)})
    write_json(output / "manifest.json", manifest)
    print(f"Saved {len(manifest)} segment(s) under {output}/raw and wrote {output}/manifest.json")


def numeric(value: str) -> float | None:
    try:
        return float(value.replace(",", ""))
    except (AttributeError, ValueError):
        return None


def summarize_file(path: Path, max_rows: int) -> tuple[list[str], list[str]]:
    with path.open(newline="", encoding="utf-8-sig", errors="replace") as source:
        rows = list(csv.DictReader(source, delimiter="\t"))
    if not rows:
        return [f"## {path.name}", "", "No rows."], []
    fields = list(rows[0])
    number_fields = [field for field in fields if sum(numeric(row.get(field, "")) is not None for row in rows) >= max(1, len(rows) * 0.8)]
    dimensions = [field for field in fields if field not in number_fields]
    lines = [f"## {path.name}", "", f"Rows: {len(rows):,}", ""]
    if number_fields:
        lines += ["| Metric | Total |", "| --- | ---: |"]
        for field in number_fields:
            total = sum(numeric(row.get(field, "")) or 0 for row in rows)
            lines.append(f"| {field} | {total:,.2f} |")
        lines.append("")
    preview_fields = dimensions[:3] + number_fields[:3]
    if preview_fields:
        sort_metric = number_fields[0] if number_fields else None
        sorted_rows = sorted(rows, key=lambda row: numeric(row.get(sort_metric, "")) or 0, reverse=True) if sort_metric else rows
        lines += ["Top rows:", "", "| " + " | ".join(preview_fields) + " |", "| " + " | ".join("---" for _ in preview_fields) + " |"]
        for row in sorted_rows[:max_rows]:
            lines.append("| " + " | ".join((row.get(field, "") or "").replace("|", "\\|") for field in preview_fields) + " |")
        lines.append("")
    return lines, fields


def command_summarize(args: argparse.Namespace) -> None:
    output_dir = configured_output(None)
    source = Path(args.input) if args.input else output_dir / "raw"
    files = [source] if source.is_file() else sorted(source.rglob("*.txt"))
    if not files:
        fail(f"no decompressed .txt reports found under {source}")
    report = ["# App Store Connect analytics summary", "", f"Generated: {dt.datetime.now().astimezone().isoformat(timespec='seconds')}", ""]
    for file in files:
        section, _ = summarize_file(file, args.max_rows)
        report.extend(section)
    output = Path(args.output) if args.output else output_dir / "summary.md"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("\n".join(report), encoding="utf-8")
    print(f"Wrote {output}. Share this Markdown file with Codex for trend analysis.")


def make_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Download App Store Connect Analytics report segments and create a Codex-ready summary.",
        epilog="Configuration: use --config appstore-analytics.ini (default), or APPSTORE_KEY_ID, APPSTORE_ISSUER_ID, APPSTORE_PRIVATE_KEY_PATH, and APPSTORE_APP_ID environment variables. Create a Sales and Reports API key in App Store Connect; an Admin role is required to create the first report request.",
    )
    parser.add_argument("--config", default=str(DEFAULT_CONFIG), help="INI config path (default: appstore-analytics.ini)")
    commands = parser.add_subparsers(dest="command", required=True)
    apps = commands.add_parser("apps", help="list apps visible to the API key")
    apps.set_defaults(func=command_apps)
    request = commands.add_parser("request", help="create an Analytics report request for an app")
    request.add_argument("--app-id", help="App Store Connect app resource ID (default: app_id in config)")
    request.add_argument("--snapshot", action="store_true", help="request a one-time historical snapshot instead of ongoing reports")
    request.set_defaults(func=command_request)
    download = commands.add_parser("download", help="download available report segments")
    download.add_argument("--app-id", help="App Store Connect app resource ID (default: app_id in config)")
    download.add_argument("--request-id", help="download only this report request")
    download.add_argument("--output", help="output directory (default: output_dir in config or appstore-analytics)")
    download.add_argument("--force", action="store_true", help="re-download and re-expand existing files")
    download.set_defaults(func=command_download)
    summary = commands.add_parser("summarize", help="convert downloaded TSV reports to a compact Markdown brief")
    summary.add_argument("--input", help="a report .txt file or directory (default: configured output_dir/raw)")
    summary.add_argument("--output", help="Markdown output path (default: configured output_dir/summary.md)")
    summary.add_argument("--max-rows", type=int, default=10, help="top rows to show per report")
    summary.set_defaults(func=command_summarize)
    return parser


def main() -> None:
    args = make_parser().parse_args()
    global CONFIG
    config_path = Path(args.config).expanduser()
    parser = configparser.ConfigParser()
    if config_path.exists():
        try:
            with config_path.open(encoding="utf-8") as source:
                parser.read_file(source)
        except (OSError, configparser.Error) as exc:
            fail(f"could not read config {config_path}: {exc}")
    CONFIG = parser["appstore"] if parser.has_section("appstore") else None
    args.func(args)


if __name__ == "__main__":
    main()
