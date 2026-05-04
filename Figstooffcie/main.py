from pathlib import Path
import sys

from PySide6.QtWidgets import QApplication

from app.main_window import MainWindow
from core.config import APP_AUTHOR, APP_NAME, build_app_paths


def main() -> int:
    app = QApplication(sys.argv)
    app.setApplicationName(APP_NAME)
    app.setOrganizationName(APP_AUTHOR)

    project_root = Path(__file__).resolve().parent
    paths = build_app_paths(project_root)

    window = MainWindow(paths)
    window.show()
    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
