import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
for sub in ("software/shared/python", "software/pi-controller", "software/hp-agent"):
    p = str(ROOT / sub)
    if p not in sys.path:
        sys.path.insert(0, p)
