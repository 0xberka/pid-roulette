
# PID Roulette

A Bash roulette game that randomly selects a running process and sends it `SIGHUP`.

> **Warning:** Running this with `sudo` can affect system processes. Use only on a test system.

## How It Works

Processes are collected with `ps`, then one is randomly selected.
The selected PID receives `SIGHUP`:

```bash
kill -1 "$selected_pid"
```

## Usage

```bash
sudo ./roulette.sh
````

Auto mode:

```bash
sudo ./roulette.sh --auto
```

## Before You Spin

Probability is just organized chaos.
