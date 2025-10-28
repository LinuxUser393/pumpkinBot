from gtts import gTTS
import os

print("Running the gTTS maker!")
print("Generating mp3 files...")

# "phrase": "filename"
phrases = {
    "Testing": "testing"  # .mp3
}

sound_dir = 'sounds'
language = 'en'  # English

if not os.path.exists(sound_dir):
    os.mkdir(sound_dir)

for phrase, file_name in phrases.items():
    # Create a gTTS object
    tts_obj = gTTS(text=phrase, lang=language, slow=False)

    file = os.path.join(sound_dir, file_name + ".mp3")
    # Save the audio to an MP3 file
    tts_obj.save(file)

    # Play the audio (requires a local media player)
    os.system("paplay " + file)

    print("File has been saved as " + file)
