# Baby Buddy (gxlabs) add-on

A Home Assistant add-on that runs the [gxlabs Baby Buddy fork][fork], which
extends the upstream Baby Buddy REST API so a photo can be attached to any
event (feeding, diaper change, sleep, pump, tummy time).

Otherwise identical to the standard Baby Buddy add-on:
- Web UI on the HA sidebar via ingress
- REST API exposed on host port **8001**
- SQLite database and uploaded media stored under `/data` (persisted)

## Options

| Option                  | Purpose                                       | Default |
| ----------------------- | --------------------------------------------- | ------- |
| `allowed_hosts`         | Django `ALLOWED_HOSTS` (comma-separated)     | `*`     |
| `csrf_trusted_origins`  | Extra `CSRF_TRUSTED_ORIGINS` values           | *(empty)* |
| `debug`                 | Django debug mode                              | `false` |

## Data path

Persistent state lives at `/data/data/db.sqlite3` and `/data/media/`. A random
`SECRET_KEY` is generated on first start and cached to `/data/.secretkey` so it
survives add-on updates.

## Ingress vs. host port

- **Sidebar / ingress**: automatically handled by HA
- **Direct**: host `:8001` for the REST API (used by the Zoey Baby iOS app and
  any other Baby Buddy client)

[fork]: https://github.com/gxlabs/babybuddy
