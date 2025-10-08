#!/usr/bin/env python3

import os
import time
from datetime import datetime
from st2reactor.sensor.base import Sensor


class FileWatchSensor(Sensor):
    def __init__(self, sensor_service, config=None):
        super(FileWatchSensor, self).__init__(sensor_service=sensor_service, config=config)
        self._logger = self._sensor_service.get_logger(__name__)
        self._watch_file = "/tmp/monitored_file.txt"
        self._last_modified = None
        
    def setup(self):
        """Setup the sensor"""
        self._logger.info("FileWatchSensor: Setting up file monitoring")
        if os.path.exists(self._watch_file):
            self._last_modified = os.path.getmtime(self._watch_file)
    
    def run(self):
        """Main sensor loop"""
        self._logger.info(f"FileWatchSensor: Starting to monitor {self._watch_file}")
        
        while True:
            try:
                if os.path.exists(self._watch_file):
                    current_modified = os.path.getmtime(self._watch_file)
                    
                    if self._last_modified is None:
                        self._last_modified = current_modified
                    elif current_modified != self._last_modified:
                        # File has been modified
                        self._trigger_file_changed("modified")
                        self._last_modified = current_modified
                else:
                    if self._last_modified is not None:
                        # File was deleted
                        self._trigger_file_changed("deleted")
                        self._last_modified = None
                
                time.sleep(5)  # Check every 5 seconds
                
            except Exception as e:
                self._logger.error(f"FileWatchSensor error: {str(e)}")
                time.sleep(10)
    
    def cleanup(self):
        """Cleanup the sensor"""
        self._logger.info("FileWatchSensor: Cleaning up")
    
    def add_trigger(self, trigger):
        """Add trigger"""
        pass
    
    def update_trigger(self, trigger):
        """Update trigger"""
        pass
    
    def remove_trigger(self, trigger):
        """Remove trigger"""
        pass
    
    def _trigger_file_changed(self, event_type):
        """Trigger file changed event"""
        payload = {
            'file_path': self._watch_file,
            'event_type': event_type,
            'timestamp': datetime.now().isoformat()
        }
        
        self._logger.info(f"FileWatchSensor: File {event_type} - {self._watch_file}")
        self._sensor_service.dispatch(trigger="monitoring_pack.file_changed", payload=payload)
