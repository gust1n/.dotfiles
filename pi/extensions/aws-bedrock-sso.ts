/**
 * AWS Bedrock SSO token expiry handler.
 *
 * Detects expired AWS SSO tokens and prompts you to refresh them.
 * Pi does not auto-open a browser like Claude Code does, so this
 * extension intercepts the error and offers to open the SSO portal
 * and run the login command for you.
 *
 * All account-specific values (profile, SSO URL) are read at runtime
 * from environment variables and ~/.aws/config — nothing is hardcoded.
 */

import { type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

const TOKEN_EXPIRED_PATTERNS = [
  /token is expired/i,
  /ExpiredTokenException/i,
  /security token.*expired/i,
  /sso.*session.*expired/i,
  /SSOTokenProvider/i,
];

/** Resolve the AWS profile to use: env var, then "default". */
function awsProfile(): string {
  return process.env.AWS_PROFILE ?? process.env.AWS_DEFAULT_PROFILE ?? "default";
}

/**
 * Parse ~/.aws/config to find the sso_start_url for a profile.
 * Returns undefined if the file is missing or the key is absent.
 */
function ssoStartUrl(profile: string): string | undefined {
  try {
    const raw = readFileSync(join(homedir(), ".aws", "config"), "utf8");
    // Section header is "[profile <name>]" for non-default profiles,
    // "[default]" for the default profile.
    const header =
      profile === "default" ? /^\[default\]/m : new RegExp(`^\\[profile ${profile}\\]`, "m");
    const headerMatch = raw.search(header);
    if (headerMatch === -1) return undefined;

    // Slice from the header to the next section header.
    const section = raw.slice(headerMatch).replace(/^\[[^\]]+\]\s*/, "");
    const nextSection = section.search(/^\[/m);
    const body = nextSection === -1 ? section : section.slice(0, nextSection);

    // Look for sso_start_url directly in this profile.
    const direct = body.match(/^\s*sso_start_url\s*=\s*(.+)$/m);
    if (direct) return direct[1].trim();

    // Alternatively follow an sso_session reference.
    const sessionName = body.match(/^\s*sso_session\s*=\s*(.+)$/m)?.[1].trim();
    if (!sessionName) return undefined;

    const sessionHeader = raw.search(new RegExp(`^\\[sso-session ${sessionName}\\]`, "m"));
    if (sessionHeader === -1) return undefined;

    const sessionSection = raw.slice(sessionHeader).replace(/^\[[^\]]+\]\s*/, "");
    const nextSession = sessionSection.search(/^\[/m);
    const sessionBody = nextSession === -1 ? sessionSection : sessionSection.slice(0, nextSession);

    return sessionBody.match(/^\s*sso_start_url\s*=\s*(.+)$/m)?.[1].trim();
  } catch {
    return undefined;
  }
}

export default function (pi: ExtensionAPI) {
  pi.on("message_end", async (event, ctx) => {
    const msg = event.message;
    if (msg.role !== "assistant") return;
    if (msg.stopReason !== "error") return;
    if (msg.provider !== "amazon-bedrock") return;

    const error = msg.errorMessage ?? "";
    const isExpired = TOKEN_EXPIRED_PATTERNS.some((re) => re.test(error));
    if (!isExpired) return;

    const profile = awsProfile();
    const loginCmd = `aws sso login --profile ${profile}`;
    const url = ssoStartUrl(profile);

    if (!ctx.hasUI) {
      process.stderr.write(`[aws-bedrock-sso] Token expired. Run: ${loginCmd}\n`);
      return;
    }

    const options = [
      ...(url ? [`Open browser (${url})`] : []),
      `Show command: ${loginCmd}`,
      "Dismiss",
    ];

    const choice = await ctx.ui.select("AWS SSO token expired — how do you want to refresh it?", options);

    if (url && choice === `Open browser (${url})`) {
      await pi.exec("open", [url]);
      ctx.ui.notify("Browser opened. After login, retry your last message.", "info");
    } else if (choice === `Show command: ${loginCmd}`) {
      ctx.ui.notify(loginCmd, "warning");
    }
  });
}
