import os

import hy
import pytest


def pytest_collect_file(parent, path):
    if (path.ext == ".hy"
        and "tests" in path.dirname + os.sep
        and path.basename != "__init__.hy"):

        if hasattr(pytest.Module, "from_parent"):
            pytest_mod = pytest.Module.from_parent(parent, fspath=path)
        else:
            pytest_mod = pytest.Module(path, parent)
        return pytest_mod
