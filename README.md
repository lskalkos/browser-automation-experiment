
----
## Getting Started
### Requirements

- Java v 1.8 or 1.7. You can check your java version with `java --version`.
- make sure you have your JAVA_HOME variable set in your bash profile 

Example:

```
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
```

You may have to run `source ~/.bash_profile` in your shell. Try this if you get a BrowserMob::Proxy::Server::ServerDiedError:.

---
## Architecture

The main model in this application is EdgeTest. EdgeTest is responsible for starting and stopping the proxy server, setting up the Capybara web drivers, and encapsulating all pertinent requests and responses at the instance level. It does this using the browsermob-proxy-rb gem, which is a wrapper for the BrowserMob proxy server (written in Java) that captures requests and responses and provides a REST API to interact with it. 

Specs are then written as pretty run of the mill Rspec tests.

### Links
* browsermob-proxy-rb gem repo: https://github.com/jarib/browsermob-proxy-rb
Browser
* BrowserMob proxy repo/docs: https://github.com/lightbody/browsermob-proxy

----
## Running QA

You can manually run a QA test using Rake tasks. 

For a standard implementation:
`rake qa:standard['http://example.com']`

For an ecommerce implementation:
`rake qa:ecomm['http://example.com']`
