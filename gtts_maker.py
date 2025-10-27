from gtts import gTTS
import os

print("Welcome to GTTS Maker")
print("")

speech = input("What do you want your speech to be? ")
file_name = input("What do you want the file name to be (the .mp3 will be added automatically at the end)? ")
language = 'en'  # English

# Create a gTTS object
tts_obj = gTTS(text=speech, lang=language, slow=False)

file = file_name + ".mp3"
# Save the audio to an MP3 file
tts_obj.save(file)

# Play the audio (requires a local media player)
os.system("paplay " + file)

print("File has been saved as " + file)