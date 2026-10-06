import argparse
import base64
import hashlib
import json
import os
import subprocess
from datetime import datetime, timezone
from pathlib import Path


APK_PATH = Path("build/app/outputs/flutter-apk/app-release.apk")


def required_env(name):
    value = os.environ.get(name)
    if not value:
        raise SystemExit(f"Missing environment variable: {name}")
    return value


def temporary_path(filename):
    return Path(required_env("RUNNER_TEMP")) / filename


def property_value(value):
    """Encode values safely for Java Properties."""
    data = value.encode("utf-16-be")
    return "".join(
        f"\\u{int.from_bytes(data[index:index + 2], 'big'):04x}"
        for index in range(0, len(data), 2)
    )


def write_signing_properties(keystore, store_password, key_password, alias):
    properties = {
        "storeFile": str(keystore),
        "storePassword": store_password,
        "keyPassword": key_password,
        "keyAlias": alias,
    }

    Path("android/key.properties").write_text(
        "".join(
            f"{key}={property_value(value)}\n"
            for key, value in properties.items()
        ),
        encoding="ascii",
    )


def prepare_pr_signing():
    """Generate a disposable key used only to validate PR builds."""
    os.umask(0o077)

    keystore = temporary_path("employee-book-ci.jks")
    password = "ci-validation"
    alias = "pr-validation"

    subprocess.run(
        [
            "keytool",
            "-genkeypair",
            "-noprompt",
            "-keystore", str(keystore),
            "-storetype", "JKS",
            "-storepass", password,
            "-keypass", password,
            "-alias", alias,
            "-keyalg", "RSA",
            "-keysize", "2048",
            "-validity", "2",
            "-dname", "CN=PR Validation",
        ],
        check=True,
    )

    write_signing_properties(
        keystore=keystore,
        store_password=password,
        key_password=password,
        alias=alias,
    )


def prepare_release_signing():
    """Restore the real release key from GitHub secrets."""
    encoded = required_env("ANDROID_KEYSTORE_BASE64")
    store_password = required_env("ANDROID_KEYSTORE_PASSWORD")
    key_password = required_env("ANDROID_KEY_PASSWORD")
    alias = required_env("ANDROID_KEY_ALIAS")

    os.umask(0o077)

    keystore = temporary_path("employee-book-ci.jks")
    encoded = "".join(encoded.split())
    keystore.write_bytes(base64.b64decode(encoded, validate=True))

    write_signing_properties(
        keystore=keystore,
        store_password=store_password,
        key_password=key_password,
        alias=alias,
    )


def slack_escape(value):
    return (
        value.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
    )


def notification_context():
    repository = required_env("GITHUB_REPOSITORY")
    server = required_env("GITHUB_SERVER_URL")
    sha = required_env("GITHUB_SHA")
    run_id = required_env("GITHUB_RUN_ID")

    return {
        "repository": repository,
        "sha": sha,
        "build": required_env("GITHUB_RUN_NUMBER"),
        "attempt": required_env("GITHUB_RUN_ATTEMPT"),
        "run_url": f"{server}/{repository}/actions/runs/{run_id}",
        "commit_url": f"{server}/{repository}/commit/{sha}",
    }


def common_message_lines(context):
    trigger = (
        "Manual workflow run"
        if required_env("GITHUB_EVENT_NAME") == "workflow_dispatch"
        else "Push to main (merge or direct push)"
    )

    return [
        f"*Repository:* {slack_escape(context['repository'])}",
        f"*Branch:* {slack_escape(required_env('GITHUB_REF_NAME'))}",
        f"*Trigger:* {trigger}",
        f"*Triggered by:* {slack_escape(required_env('GITHUB_ACTOR'))}",
        (
            "*Run requested by:* "
            f"{slack_escape(required_env('GITHUB_TRIGGERING_ACTOR'))}"
        ),
        f"*Commit:* <{context['commit_url']}|{context['sha'][:7]}>",
        f"*Build:* {context['build']} · Attempt {context['attempt']}",
    ]


def write_payload(filename, payload):
    temporary_path(filename).write_text(
        json.dumps(payload),
        encoding="utf-8",
    )


def prepare_success_notification():
    channel = required_env("SLACK_CHANNEL_ID")

    if not APK_PATH.is_file():
        raise SystemExit("Release APK was not found")

    context = notification_context()

    subject = subprocess.check_output(
        ["git", "log", "-1", "--format=%s"],
        text=True,
    ).strip()

    size_mib = APK_PATH.stat().st_size / (1024 * 1024)
    checksum = hashlib.sha256(APK_PATH.read_bytes()).hexdigest()
    timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")

    message = "\n".join([
        "✅ *Employee Book — Android build ready*",
        "",
        *common_message_lines(context),
        f"*Change:* {slack_escape(subject[:300])}",
        "*Checks:* Formatting, analysis, and tests passed",
        "*APK:* Release signed",
        f"*Size:* {size_mib:.1f} MiB",
        f"*Prepared at:* {timestamp}",
        f"*SHA-256:* `{checksum}`",
        "",
        f"<{context['run_url']}|View workflow run and GitHub artifact>",
        "Download the attached APK to install on Android.",
    ])

    write_payload(
        "slack-success.json",
        {
            "channel_id": channel,
            "initial_comment": message,
            "file": str(APK_PATH),
            "filename": (
                f"employee-book-{context['build']}-"
                f"{context['attempt']}.apk"
            ),
            "title": f"Employee Book — Build {context['build']}",
        },
    )


def prepare_failure_notification():
    channel = required_env("SLACK_CHANNEL_ID")
    checks = required_env("CHECKS_RESULT")
    apk = required_env("APK_RESULT")
    context = notification_context()

    summary = (
        "Analysis/test job failed. APK job was skipped."
        if checks == "failure"
        else (
            "APK build/delivery job failed. "
            "Check the logs for the exact failing step."
        )
    )

    message = "\n".join([
        "❌ *Employee Book — Pipeline failed*",
        "",
        summary,
        "",
        *common_message_lines(context),
        "",
        f"*Analyze & test:* {checks}",
        f"*APK build/delivery:* {apk}",
        "",
        f"<{context['run_url']}|Open workflow and inspect failed step>",
    ])

    write_payload(
        "slack-failure.json",
        {
            "channel": channel,
            "text": message,
            "unfurl_links": False,
            "unfurl_media": False,
        },
    )


def main():
    commands = {
        "signing-pr": prepare_pr_signing,
        "signing-release": prepare_release_signing,
        "slack-success": prepare_success_notification,
        "slack-failure": prepare_failure_notification,
    }

    parser = argparse.ArgumentParser(description="Android CI helpers")
    parser.add_argument("command", choices=commands)
    arguments = parser.parse_args()

    commands[arguments.command]()


if __name__ == "__main__":
    main()