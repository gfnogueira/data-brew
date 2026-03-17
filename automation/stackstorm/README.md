# StackStorm Implementation Study

This directory contains a progressive implementation study of StackStorm, an event-driven automation platform.

## StackStorm Overview
StackStorm is an open-source automation platform that connects services and tools into event-driven workflows. It enables automation of remediation, security responses, troubleshooting, and deployments.

## Current Implementation Status
This study focuses on building StackStorm components incrementally:

### Phase 1: Actions (Completed)
- Custom action for system health monitoring
- Alert notification system with multiple channels

### Phase 2: Rules and Sensors (Current)
- Automated rules connecting triggers to response actions
- File system sensor for real-time event detection
- Incident response workflow with conditional logic

## Implementation Details

### Actions
- `system_health_check` - Monitors CPU, memory, and disk usage with configurable thresholds
- `send_alert` - Sends notifications via email, Slack, or webhook channels

### Rules
- `health_check_alert_rule` - Automatically sends alerts when health checks fail
- `file_change_alert_rule` - Triggers notifications when monitored files change

### Sensors
- `file_watch_sensor` - Monitors file system changes and triggers events

### Workflows
- `incident_response` - Orchestrates incident response with conditional logic and escalation

## Files Structure
- `actions/` - Custom actions for system monitoring and alerting
- `sensors/` - File system monitoring sensors
- `rules/` - Automated response rules
- `workflows/` - Incident response workflows
- `packs/` - Pack metadata and configuration
- `docker-compose.yml` - Container deployment configuration

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
# Credentials: st2admin/123456@
```

## Testing Implementation
```bash
# Test actions
st2 run monitoring_pack.system_health_check
st2 run monitoring_pack.send_alert message="Test alert" severity="medium" channel="email"

# Test sensor (trigger file change)
echo "content" > /tmp/monitored_file.txt

# Test workflow
st2 run monitoring_pack.incident_response incident_type="test" severity="medium"

# View executions
st2 execution list

# View rules
st2 rule list --pack monitoring_pack
```

## References
- [StackStorm Documentation](https://docs.stackstorm.com/)
- [StackStorm Exchange](https://exchange.stackstorm.org/)
- [StackStorm GitHub](https://github.com/StackStorm/st2)
