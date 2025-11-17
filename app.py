from flask import Flask, render_template
import json
import requests

app = Flask(__name__)

def get_meme():
    url = "https://meme-api.com/gimme"
    response = json.loads(requests.get(url).text)
    meme_image = response['url']
    subreddit = response['subreddit']
    author = response['author']
    return meme_image, subreddit, author

@app.route("/")
def index():
    meme_image, subreddit, author = get_meme()
    return render_template("index.html", meme_image=meme_image, subreddit=subreddit, author=author)

app.run(host="0.0.0.0", port=5152, debug=True)