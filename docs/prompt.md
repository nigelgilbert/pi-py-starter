Help design the perfect Raspberry Pi CPython Docker coding environment.

Eventually, this hello world will be forked, then used as a development harness for an MQTT server.  

This project will consist of 2 things: a Pi-hosted MQTT server (which controls external hardware) and a simple Python CLI script (which publishes an event to trigger the hardware by way of the MQTT server).  

Don't focus on the MQTT stuff.  I am more concerned with making a perfect docker environment.   I want to make the perfect boilerplate for CPython Pi work without dirtying my local environment with Python toolchain... I want to encapsulate all that tooling within the docker image!  I want to run the CLI script from _within the docker_ via tunneling from my CLI into the docker image.

Make it fun and easy to use!  KISS when reasonable.  I have some more notes in `cpython-memo.md`.  Please let me know if I can answer any questions.