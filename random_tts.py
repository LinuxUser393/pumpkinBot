from gtts import gTTS
import os
import random

random_speech = random.randint(0,2)
speech = ["Boo","Hello", "Test"]
play_speech= speech[random_speech]

language = 'en'  # English

# Create a gTTS object
tts_obj = gTTS(text=play_speech, lang=language, slow=False)

# Save the audio to an MP3 file
tts_obj.save("output.mp3")

# Play the audio (requires a local media player)
os.system("paplay output.mp3")