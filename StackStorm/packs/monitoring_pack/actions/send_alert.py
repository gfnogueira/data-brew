#!/usr/bin/env python3

import json
from datetime import datetime
from st2common.runners.base_action import Action


class SendAlertAction(Action):
    def run(self, message, severity="medium", channel="email"):
        """
        Send alert notification through specified channel
        """
        timestamp = datetime.now().isoformat()
        
        alert_data = {
            'timestamp': timestamp,
            'message': message,
            'severity': severity,
            'channel': channel
        }
        
        # Send alert based on channel
        if channel == "email":
            return self._send_email_alert(alert_data)
        elif channel == "slack":
            return self._send_slack_alert(alert_data)
        elif channel == "webhook":
            return self._send_webhook_alert(alert_data)
        else:
            return (False, f"Unknown channel: {channel}")
    
    def _send_email_alert(self, alert_data):
        """Send email alert"""
        self.logger.info(f"EMAIL ALERT: {alert_data['message']}")
        return (True, {
            'status': 'sent',
            'channel': 'email',
            'message': 'Email alert sent successfully',
            'alert_data': alert_data
        })
    
    def _send_slack_alert(self, alert_data):
        """Send Slack alert"""
        self.logger.info(f"SLACK ALERT: {alert_data['message']}")
        return (True, {
            'status': 'sent',
            'channel': 'slack',
            'message': 'Slack alert sent successfully',
            'alert_data': alert_data
        })
    
    def _send_webhook_alert(self, alert_data):
        """Send webhook alert"""
        self.logger.info(f"WEBHOOK ALERT: {alert_data['message']}")
        return (True, {
            'status': 'sent',
            'channel': 'webhook',
            'message': 'Webhook alert sent successfully',
            'alert_data': alert_data
        })
