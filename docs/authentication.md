# Authentication

## Requirements

- Only registered users should be allowed to CRUD files
- get '/'
  - Signed out user: sign in button
  - Signed in user:
    - [Bottom of page] Signed in as "user" + sign out button
    - Sign out button signs out + stores message: "You have been signed out."
- get '/users/signin'
  - Render sign in form
- post '/users/signin'
  - If admin credentials -> signin
    - Store a message: "Welcome!"
    - Redirect to '/'
  - Otherwise:
    - Store a message: "invalid Credentials"
    - Redisplay sign in form
      - _Note_: Username should be preserved (password shouldn't be)

## Implementation

- How to track auth status:
  - Store `username` in session (signed in)
  - Clear `username` from session (signed out)
- Invalid credentials:
  - Idea 1: Redisplay form, keep username set, remove password
  - Idea 2: Redirect to signin page w/ a prefilled username
    - Ensures error message will display
  - How can we create an "Invalid Credentials" error message?
- Idea: Use a before hook to redirect users to index if they aren't signed in
