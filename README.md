# discourse-require-event

Discourse plugin that requires every new topic in selected categories to contain an
event from the built-in Discourse Events plugin (`[event ...][/event]` in the first post).

- New topics without an event are rejected with an error message.
- An existing event cannot be removed from a topic in those categories.
- Older topics without an event can still be edited.
- The `system` user is exempt (scripts, migrations).

## Settings

- `require_event_enabled` – turns the check on/off
- `require_event_categories` – categories where an event is mandatory

Error texts can be changed in Admin → Customize → Text (`require_event.`).

## Install

In `containers/app.yml`:

```yml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/adopilot/discourse-require-event.git
```

then `./launcher rebuild app`. To disable, comment out the line and rebuild,
or switch off `require_event_enabled`.
