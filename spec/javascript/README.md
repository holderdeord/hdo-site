Javascript testing with busterjs: http://busterjs.org/

To run the tests you need to have buster.js installed.
Buster.JS on the command-line requires Node 0.6.3 or newer and NPM.
Node 0.6.3 and newer comes with NPM bundled on most platforms.
Install buster with: npm install -g buster

Run tests from project root with: buster test
Remember to capture browser first.
From the command-line: buster server
Open your favourite browser and go to localhost:1111 and capture browser.

To add more tests, update config in /spec/buster.js
