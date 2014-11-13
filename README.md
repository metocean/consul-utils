# Consul integration for RedWire

Consul integration for RedWire - a dyanmic, high performance, load balancing reverse proxy.

Consul provides a gossip-based, decentralised, dynamic list of servers that implement a service. This list is watched using long polling and used to keep an internal list of servers up to date. This means as your services come up or go down in consul RedWire will start and stop load balancing to them.

[![BuildStatus](https://secure.travis-ci.org/metocean/redwire.png?branch=master)](http://travis-ci.org/metocean/redwire)
[![NPM version](https://badge.fury.io/js/redwire.svg)](http://badge.fury.io/js/redwire)

## Install

```sh
npm install redwire redwire-consul
```

Consul integration for RedWire has no dependencies and can be used independently from RedWire, however it works best as a load-balancer handler in RedWire.

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

This code will monitor the service named 'web' from the consul server `localhost:8500` and round-robin load balance to all current services, making sure to stop if they leave the cluster and start as they join.

The optional callback can be used for logging changes to the server pool.

## TODO

- Health Checks
- Custom page when there are no servers