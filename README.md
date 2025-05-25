# SysHealth - System Health Monitor

A lightweight bash script for monitoring system health metrics.

## Features

- CPU usage monitoring
- RAM usage display
- Disk space monitoring
- Network statistics
- Temperature monitoring (if available)
- Color-coded alerts
- Logging capabilities
- Clean, readable output

## Installation

Clone the repository:
```bash
git clone https://github.com/enchilada-composer/syshealth.git
```

Make the script executable:
```bash
chmod +x syshealth.sh
```

## Usage

Run the script:
```bash
./syshealth.sh
```

Optional arguments:
- `-l` or `--log`: Enable logging to file
- `-c` or `--color`: Enable color output
- `-t` or `--tail`: Show live log output
- `-h` or `--help`: Show help message

## Requirements

- Linux system
- Basic system utilities (top, free, df, etc.)
- bc (for calculations)

## License

MIT License
