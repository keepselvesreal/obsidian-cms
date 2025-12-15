# Image Reference Test

This file tests:
1. Obsidian format image conversion to markdown
2. Image path conversion from resources/attachments to ./attachments
3. Valid links within public folder only

## Images with Obsidian Format

Testing Obsidian format image (should be converted to markdown and path updated):

![[스크린샷 2025-12-15 20-10-09.png]]

## Valid Links (Within Public Folder Only)

These should work:
- [[index]] - Home page
- [[test-note-1]] - First test note
- [[learning-methods/spaced-repetition]] - Learning method

## Test Summary

Expected behavior:
- ✓ Obsidian image format converted to markdown: `![...](./attachments/...)`
- ✓ Image copied from resources/attachments to public/attachments
- ✓ All links are within public folder (no external references)
- ✓ Sync should complete successfully