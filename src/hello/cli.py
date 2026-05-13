import platform


def main() -> None:
    print("Hello from inside the container!")
    print(f"  Python : {platform.python_version()}")
    print(f"  Machine: {platform.machine()}")
    print(f"  System : {platform.system()} {platform.release()}")
