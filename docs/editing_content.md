# Editing Content

## Requirements

- "Edit" link next to each document name
- An edit page for a document
  - Textarea
  - Document content in textarea
  - Form submission =>
    - File is updated
    - Redirection to index page w/ message: $FILENAME has been updated

## Tests

- get "/:file/edit": Textarea has document rendered in it
- post "/:file/edit": Simulate submission (idea: use JQuery?)
  - Verify document has changed
  - Verify redirection => index + message is shown

## Implementation

get "/:file/edit":

- Load document into textarea (innerHTML of textarea)
  - JQuery?

post "/:file/edit":

- Use `File::write` to update the given `file`
  - Note: Closes file for us
- Store new message in `session[:message]`: "`file` has been updated"
- Redirection to "/" after writing
