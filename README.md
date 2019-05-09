# Server2server

## Reverse connection dependencies

##Scenario

We have a Master running behind a restrictive firewall. Nobody can reach this 
server from outside. But the master can connect via https/wss to the Slave 
which is running on the public internet.

Once this websocket is established, the slave can push messages to the master 
while the firewall still sees an HTTP-connection from master to slave and no 
incoming request.

## Try it!

### Install

```bash
    git clone https://github.com/iboard/phxserver2server.git
    cd phxserver2server
    mix deps.get
```

### Start it

Start the first app as MASTER. The master has to know where the slave lives 
and on which port it is reachable.

```bash
    SYNC_MODE=master \
    SYNC_SLAVE=http://localhost \
    SYNC_PORT=5000 \
    PORT=4000 mix phx.server
```

Start another instance as SLAVE. The slave needs to know nothing except that it 
is a slave.

```bash
    SYNC_MODE=slave \
    PORT=5000 mix phx.server
```

Open a browser for Master at http://localhost:4000 and another browser for 
Slave at http://localhost:5000

The slave should show a disabled button “Waiting for master”. When you press 
the connect button in the master-window, you will see the button on slave enabled.

When you press the button on slave now, it sends a message to the slave-
backend which then forwards the message via Websockex to the master backend.


