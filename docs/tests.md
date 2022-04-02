# Tests

## Handling Requests for Nonexistent Documents

- Requirements
  - Write a test that handles nonexistent document routes
  - TDD: Write test first, then write implementation
- Implementation (how)
  - Create a test with two assertions:
    1. The initial response is a redirect
    2. [After requesting to redirect] The next response should be a successful response w/ index page
