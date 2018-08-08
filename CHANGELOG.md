# Change Log

All notable changes to this project will be documented in this file.

<a name="0.1"></a>
# 0.1.0 (2018-08-08)

Initial Implementation.

Supporting:

- Requests with JSON responses using `JSONDecoder`
- Endpoints with hardcoded URLs or URITemplate + variables
- Endpoints derived from a relationship to either a request or sessionConfiguration + variables
- URITemplate variables on a sessionConfiguration are available to all requests within that session
- Headers derived from a keypath to either a request or sessionConfiguration
- Configuration of JSONDecoder per session
- Customisation of dispatch queues for request encoding, response decoding, and callbacks
- Request and SessionConfiguration types can be strongly associated.
- Explicit handling of network errors distinct from server generated domain errors
