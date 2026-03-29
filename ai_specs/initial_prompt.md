Create a srt generator that works as a Dart CLI tool.

Requirements:
- Takes an input path base filename with no extension
- Gets the corresponding filename.mp3 audio file 
- Gets the corresponding filename.md markdown file 
- outputs filename.srt file
- filename.srt is to be formatted as a SubRip Subtitle file. See `../examples/example.srt` for an example of an '.srt' file
- See `../examples/example.md` for an example of the input file format for filename.md
- Get the duration of the audio from filename.mp3 which is used as the final timestamp in filename.mp3
- Input lines from filename.md should be split into sentences, and each sentence should recalculate the timestamp based on either inter-word blanks, or character count.
- Sentences that cross multiple lines should be joined
 
## Implementation details
- Use dart-create skill to scaffold the Dart project in a `cli` subfolder
