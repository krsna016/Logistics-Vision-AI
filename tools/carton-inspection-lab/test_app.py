import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from app import reading_order


def test_reading_order_groups_rows_and_sorts_left_to_right():
    boxes = [[110, 100, 190, 160], [10, 102, 90, 162], [15, 205, 95, 265], [115, 200, 195, 260]]
    assert reading_order(boxes) == [1, 0, 2, 3]


def test_reading_order_empty():
    assert reading_order([]) == []
