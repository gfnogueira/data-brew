# StackStorm Implementation Study

This directory contains a progressive implementation study of StackStorm, an event-driven automation platform.

## StackStorm Overview
StackStorm is an open-source automation platform that connects services and tools into event-driven workflows. It enables automation of remediation, security responses, troubleshooting, and deployments.

## Current Implementation Status
This study focuses on building StackStorm components incrementally:

### Phase 1: Actions (Current)
- Custom action for system health monitoring
- Alert notification system with multiple channels

## Implementation Details

### Actions
- `system_health_check` - Monitors CPU, memory, and disk usage with configurable thresholds
- `send_alert` - Sends notifications via email, Slack, or webhook channels

## Installation
1. Install StackStorm (see official documentation)
2. Copy pack contents to `/opt/stackstorm/packs/monitoring_pack/`
3. Install pack dependencies: `st2 pack install file:///opt/stackstorm/packs/monitoring_pack`
4. Reload StackStorm: `st2ctl reload --register-all`

## Container Deployment
```bash
# Start StackStorm with Docker Compose
docker-compose up -d

# Access StackStorm UI at http://localhost
# Credentials: st2admin/Ch@ngeMe
```

## Testing Actions
```bash
# Test system health check
st2 run monitoring_pack.system_health_check

# Test alert system
st2 run monitoring_pack.send_alert message="System alert test" severity="medium" channel="email"

# View executions
st2 execution list
```

## References
- [StackStorm Documentation](https://docs.stackstorm.com/)
- [StackStorm Exchange](https://exchange.stackstorm.org/)
- [StackStorm GitHub](https://github.com/StackStorm/st2)
