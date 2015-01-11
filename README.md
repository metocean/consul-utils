# Consul Utilities

A set of utilities to work with consul from Node.js. Not full featured or architected well enough to call an API but a good start.

[![BuildStatus](https://secure.travis-ci.org/metocean/consul-utils.png?branch=master)](http://travis-ci.org/metocean/consul-utils)
[![NPM version](https://badge.fury.io/js/consul-utils.svg)](http://badge.fury.io/js/consul-utils)

## Install

```sh
npm install consul-utils
```

Consul Utilities has no dependencies.

## Example

The service class can be used in [Redwire](https://github.com/metocean/redwire).

```js
var RedWire = require('redwire');
var consul = require('consul-utils');

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