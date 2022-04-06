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

# Restricting Actions to Authenticated Users

## Requirements

- We can still allow unauthenticated users to view the files; just not modify them
- For the following actions:
  1. Verify user is authenticated
  2. If not --> redirect to index + add session message
  3. If they are --> proceed as normal
  - Visit the edit page
  - Submit changes
  - Visit new doc page
  - Submit new doc
  - Delete doc

## Implementation

- Modify tests for restricted to require authenticated state (`admin_session`)
- Add tests for all restricted actions for unauthenticated users
- For all routes w/ a certain metadata:
  - Check if session includes admin user
  - If so -> render as normal
  - Otherwise -> return 401 error, change session message, redirect to index

# Storing User Accounts

## Requirements

- Admin should be able to modify list of users who may sign into application

## Implementation

- Create a configuration file (`users.yaml`)
  - Store credentials as a hash (keys = users, values = passwords)
- Update signin logic
  - Compare input w/ all user/password combos (not just admin/secret)
- _Note_: No need to update `authenticate`: as long as a user exists in the session, we're authenticated

# Hashing Passwords

## Requirements

- Use the `bcrypt` algorithm to hash passwords

## Implementation

- [Admin] Create encoded version of passwords w/ irb
  - Store encoded passwords in `users.yml`
- Upon sign-in: Compare _hashed_ version of password input
