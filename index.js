#!/usr/bin/env node

var coffee = require('coffee-script').register();
var App = require('./app');

var app = new App();
app.start();
