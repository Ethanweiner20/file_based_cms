# New Documents

## Requirements

- Create new document link in index
- Render new document form at get "/new"
  - Inline: Inputs should be on same lien
- Upon new doc form submission:
  - If given a name (without whitespace), create doc + redirect
    - Set a success mesage: $FILENAME was created.
  - Else, set an error message and rerender

## Questions

- Should whitespace be considered a name? Assume no

## Implementation

- Order routes such that routes for files are at the end (other routes prioritized)
- Strip whitespace from input before submission
- Creating document: `File.new("path", "w+)`
