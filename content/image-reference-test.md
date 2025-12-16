# Image Reference Test

This file tests:
1. Image path conversion from `resources/attachments` to `./attachments`
2. Valid links within public folder
3. Broken links to notes outside public folder

## Images with External Resource Path

Testing image with resources/attachments path (should be copied and path updated):

![[스크린샷 2025-12-15 20-10-09.png]]

## Valid Links (Within Public Folder)

These should work:
- [[index]] - Home page
- [[test-note-1]] - First test note
- [[learning-methods/spaced-repetition]] - Learning method

## External Reference (Should Be Broken Link)

This references a note OUTSIDE public folder:
- external-note - Outside public folder (external reference removed)

## Test Summary

Expected behavior:
- ✓ Image path should convert to `./attachments/스크린샷 2025-12-15 20-10-09.png`
- ✓ Image should be copied from resources/attachments to public/attachments
- ✓ [[index]] and [[test-note-1]] should be valid