# Consul integration for RedWire

Consul integration for RedWire - a dyanmic, high performance, load balancing reverse proxy.

[![BuildStatus](https://secure.travis-ci.org/metocean/redwire.png?branch=master)](http://travis-ci.org/metocean/redwire)
[![NPM version](https://badge.fury.io/js/redwire.svg)](http://badge.fury.io/js/redwire)

## Install

```sh
npm install redwire redwire-consul
```

## Example

```js
var RedWire = require('redwire');
var consul = require('redwire-consul');

var redwire = new RedWire({ http: { port: 80 } });
var services = new consul.Service('localhost:8500', 'web', function(added, removed) {
  console.log(added.length + " added");
  console.log(removed.length + " removed");
});

redwire.http('example.com')
  .use(services.distribute())
  .use(redwire.proxy());
```

This code will monitor the service named 'web' from the consul server `localhost:8500` and round-robin load balance to all servers registered.

The optional callback can be used for logging changes to the server pool.