import time
import unittest


class V3ProbeSlowFail(unittest.TestCase):
    """V3 probe: keeps the required `test` check pending ~4 min, then fails on purpose."""

    def test_slow_then_fail(self):
        time.sleep(240)
        self.fail("V3 probe: intentional CI failure")
