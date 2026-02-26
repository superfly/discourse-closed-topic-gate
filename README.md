# discourse-closed-topic-gate

Discourse plugin that requires login to view closed topics. Anonymous users (including search crawlers) see a login prompt instead of topic content.

## Why

Closed topics often contain stale information - outdated instructions, deprecated features, old troubleshooting steps. By gating them behind login:

- Search engines stop indexing outdated content
- Anonymous visitors are guided toward current resources
- Existing users retain full access to historical discussions

Works with Discourse's auto-close feature (e.g., close topics after 7 days of inactivity) to automatically gate aging content.

## Installation

SSH into your Discourse instance and install the plugin:

```bash
cd /var/www/discourse/plugins
git clone https://github.com/superfly/discourse-closed-topic-gate

cd /var/www/discourse
RAILS_ENV=production bundle exec rake plugin:install_all_gems
RAILS_ENV=production bundle exec rake assets:precompile
sv restart unicorn
```

## Settings

Two settings in Admin → Settings → Plugins:

| Setting | Default | Description |
|---------|---------|-------------|
| `closed_topic_gate_enabled` | true | Master switch for the plugin |
| `closed_topic_gate_demo_mode` | true | When on, only staff see the gate (for testing) |

## Demo Mode

The plugin installs with demo mode enabled. This lets you verify the gate works without affecting real users:

| User Type | Sees Gate? |
|-----------|------------|
| Staff | Yes (for testing) |
| Logged-in non-staff | No |
| Anonymous | No |

**To test:**

1. Log in as staff
2. Visit any closed topic
3. You should see Discourse's login prompt instead of the topic content
4. Open the same URL in incognito - should see normal topic content

## Production Mode

Once you've verified the gate works:

1. Go to Admin → Settings → Plugins
2. Set `closed_topic_gate_demo_mode` to **false**

Now the behavior flips:

| User Type | Sees Gate? |
|-----------|------------|
| Staff | No |
| Logged-in | No |
| Anonymous | Yes |

## Disabling

**Temporarily:** Set `closed_topic_gate_enabled` to false in Admin → Settings. Takes effect immediately, no restart needed.

**Permanently:** Remove the plugin:

```bash
rm -rf /var/www/discourse/plugins/discourse-closed-topic-gate
cd /var/www/discourse && sv restart unicorn
```

## How It Works

The plugin prepends to `Guardian#can_see_topic?`, the standard Discourse permission check for topic visibility. When a closed topic is requested by an anonymous user (in production mode), it returns `false`, triggering Discourse's built-in login prompt.

This gates both the web view and the JSON API uniformly.
