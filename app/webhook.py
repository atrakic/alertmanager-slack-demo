from flask import Flask
from flask import request

app = Flask(__name__)

@app.route("/", methods=["GET"])
def index():
    return ("OK")

@app.route("/alert", methods=["POST"])
def handle_url():
    print(request.json)
    return {"result": "data updated"}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)
