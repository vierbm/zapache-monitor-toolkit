# ZApache Monitor Toolkit

A comprehensive Apache monitoring toolkit for Zabbix.

## Features

- Apache mod_status monitoring
- HTTP 4xx and 5xx error detection
- Intelligent Apache log parsing
- Apache health checks
- Zabbix Agent validation
- Event, Worker and Prefork MPM support
- Scoreboard analysis
- Diagnostic toolkit
- Bash-based with no external dependencies beyond standard system tools

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
