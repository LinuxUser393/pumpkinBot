from gtts import gTTS
import os
import random
import time

times_played=0
go=1
speech = ["Boo","Do you like spiders","I see you","Identity confirmed, scanning database","User has been added to the database"]

language = 'en'  # English

while go==1:
    random_speech = random.randint(0,4)
    play_speech= speech[random_speech]
    times_played=times_played+1

    # Create a gTTS object
    tts_obj = gTTS(text=play_speech, lang=language, slow=True, tld='ie')

    # Save the audio to an MP3 file
    tts_obj.save("output.mp3")

    # Play the audio (requires a local media player)
    os.system("paplay output.mp3")
    print(f"Sound played {times_played}")
    time.sleep(5)