#!/usr/bin/env python3

import psutil
from st2common.runners.base_action import Action


class SystemHealthCheckAction(Action):
    def run(self, threshold_cpu=80, threshold_memory=85, threshold_disk=90):
        """
        Check system health metrics and return status
        """
        result = {
            'healthy': True,
            'alerts': [],
            'metrics': {}
        }
        
        # Check CPU usage
        cpu_percent = psutil.cpu_percent(interval=1)
        result['metrics']['cpu_usage'] = cpu_percent
        
        if cpu_percent > threshold_cpu:
            result['healthy'] = False
            result['alerts'].append(f"High CPU usage: {cpu_percent}%")
        
        # Check Memory usage
        memory = psutil.virtual_memory()
        memory_percent = memory.percent
        result['metrics']['memory_usage'] = memory_percent
        
        if memory_percent > threshold_memory:
            result['healthy'] = False
            result['alerts'].append(f"High Memory usage: {memory_percent}%")
        
        # Check Disk usage
        disk = psutil.disk_usage('/')
        disk_percent = (disk.used / disk.total) * 100
        result['metrics']['disk_usage'] = disk_percent
        
        if disk_percent > threshold_disk:
            result['healthy'] = False
            result['alerts'].append(f"High Disk usage: {disk_percent:.1f}%")
        
        # Overall status
        result['status'] = 'HEALTHY' if result['healthy'] else 'UNHEALTHY'
        
        return (result['healthy'], result)
