import hashlib
import json

MODE = 'localSimulation'
MAX_UNITS = 9_000_000_000_000_000


class SandboxError(ValueError):
    pass


def identifier(value):
    if not isinstance(value, str) or not value or len(value) > 256:
        raise SandboxError('invalid identifier')
    return value


def units(value):
    if type(value) is not int or not 0 < value <= MAX_UNITS:
        raise SandboxError('amount must be positive integer minor units')
    return value


def timestamp(value):
    if type(value) is not int or value < 0:
        raise SandboxError('invalid timestamp')
    return value


def stable_id(kind, actor, key):
    return kind + '_' + hashlib.sha256(json.dumps([actor, key]).encode()).hexdigest()


