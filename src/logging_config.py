"""
logging: provides structured logging.

Example usage:
from logging_config import setup_logging
logger = setup_logging()
logger.info("Pipeline started", extra={"component": "data_loader"})
"""
import logging
import sys
import json
import os
from datetime import datetime


class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_record = {
            'timestamp': datetime.utcnow().isoformat(),
            'level': record.levelname,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line': record.lineno
        }
        if hasattr(record, 'extra'):
            log_record.update(record.extra)
        if record.exc_info:
            log_record['exception'] = self.formatException(record.exc_info)
        return json.dumps(log_record)

def setup_logging(log_level=logging.INFO):
    """Configure logging with JSON format for container environments"""
    log_level_name = os.environ.get('LOG_LEVEL', 'INFO').upper()
    log_level = getattr(logging, log_level_name, logging.INFO)

    root_logger = logging.getLogger()
    root_logger.setLevel(log_level)

    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(JSONFormatter())
    root_logger.addHandler(handler)

    # Silence noisy loggers
    logging.getLogger("urllib3").setLevel(logging.WARNING)

    return root_logger
