from hello.cli import main


def test_main_prints_greeting_and_platform_info(capsys):
    main()
    out = capsys.readouterr().out
    assert "Hello from inside the container!" in out
    assert "Python :" in out
    assert "Machine:" in out
    assert "System :" in out
