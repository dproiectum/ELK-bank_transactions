# Phase 0 - Project Structure

## Status

Done.

## Goal

Create a clean, autonomous project repository that can be pushed to GitHub and run without depending on the original course folder.

## Done

- Project folder is named `ELK-bank_transactions`.
- The repository contains its own `generator/generate.py`.
- Generated logs are written under `logs/`.
- `logs/.gitignore` keeps generated `.log` and `.csv` files out of Git.
- Core folders exist:

```text
elasticsearch/
generator/
kibana/
logs/
logstash/
project-status/
scripts/
```

- Cleaning scripts are separated by intent:

```text
scripts/clean-logs.sh
scripts/clean-indices.sh
scripts/stream.sh
```

`stream.sh` wraps the original continuous generator and reports progress every 100 new log lines without modifying `generator/generate.py`.

- `.env` sets a Docker Compose project name compatible with Docker naming rules:

```text
COMPOSE_PROJECT_NAME=elk-bank_transactions
```

## Remaining Work

None for this phase.

## Related Files

- [`docker-compose.yml`](../docker-compose.yml)
- [`generator/generate.py`](../generator/generate.py)
- [`logs/.gitignore`](../logs/.gitignore)
- [`scripts/seed.sh`](../scripts/seed.sh)
- [`scripts/clean-logs.sh`](../scripts/clean-logs.sh)
- [`scripts/clean-indices.sh`](../scripts/clean-indices.sh)
- [`scripts/stream.sh`](../scripts/stream.sh)
