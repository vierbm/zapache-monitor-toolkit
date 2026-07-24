# ZApache Monitor Toolkit

A comprehensive Apache monitoring toolkit for Zabbix.

## Features

- Apache 2.2 / 2.4 support
- Event, Worker and Prefork MPM support
- Automatic log format detection
- Automatic HTTP client detection (curl/wget)
- Apache Scoreboard metrics
- HTTP 4xx/5xx error monitoring
- Zabbix UserParameter ready
- Health check utility
- Modular Bash library architecture
- Production tested

## Project Status

Current Version: v2.0.0-alpha

This project is under active development.

## Supported Platforms

- RHEL 7+
- CentOS 7+
- Rocky Linux
- AlmaLinux
- Oracle Linux
- Apache HTTP Server 2.4+

## Components

| Component | Description |
|-----------|-------------|
| zabbix_apache | Zabbix UserParameter script |
| test_zapache.sh | Apache and Zabbix health checker |
| lib/ | Shared libraries |
| conf/ | Configuration files |
| docs/ | Documentation |
| tests/ | Test suite |

## Roadmap

- [x] Apache metrics
- [x] HTTP error detection
- [x] Health checker
- [ ] Intelligent log parser
- [ ] JSON output
- [ ] HTML report
- [ ] Auto-discovery
- [ ] Plugin architecture

## License

MIT
