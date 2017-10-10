import Player from "./player"


const Video = {
  init(socket, element) {
    if (!element) return

    const playerId = element.getAttribute("data-player-id")
    const videoId = element.getAttribute("data-id")

    socket.connect()

    Player.init(element.id, playerId, () => {
      this.onReady(videoId, socket)
    })
  },

  onReady(videoId, socket) {
    const msgContainer = document.getElementById("msg-container")
    const msgInput = document.getElementById("msg-input")
    const postButton = document.getElementById("msg-submit")
    const vidChannel = socket.channel("videos:" + videoId)

    postButton.addEventListener("click", e => {
      const payload = {body: msgInput.value, at: Player.getCurrentTime()}
      vidChannel
        .push("new_annotation", payload)
        .receive("error", e => console.log(e))
      msgInput.value = ""
    })

    msgContainer.addEventListener("click", e => {
      e.preventDefault()
      const seconds =
        e.target.getAttribute("data-seek")
        || e.target.parentNode.getAttribute("data-seek")

      if (seconds) {
        Player.seekTo(seconds)
      }
    })

    vidChannel.on("new_annotation", res => {
      vidChannel.params.last_seen_id = res.id
      this.renderAnnotation(msgContainer, res)
    })

    vidChannel.join()
      .receive("ok", res => {
        const ids = res.annotations.map(x => x.id)
        if (ids.length > 0) {
          vidChannel.params.last_seen_id = Math.max(...ids)
        }
        this.scheduleMessages(msgContainer, res.annotations)
      })
      .receive("error", error => console.log("join failed", reason))
  },

  renderAnnotation(msgContainer, {user, body, at}) {
    const template = document.createElement("div")
    template.innerHTML = `
    <a href="#" data-seek="${this.esc(at)}">
      [${this.formatTime(at)}]
      <b>${this.esc(user.username)}</b>: ${this.esc(body)}
    </a>
    `
    msgContainer.appendChild(template)
    msgContainer.scrollTop = msgContainer.scrollHeight
  },

  scheduleMessages(msgContainer, annotations) {
    window.setTimeout(() => {
      const ctime = Player.getCurrentTime()
      const remaining = this.renderAtTime(annotations, ctime, msgContainer)
      this.scheduleMessages(msgContainer, remaining)
    }, 1000)
  },

  renderAtTime(annotations, seconds, msgContainer) {
    const {due, remaining} = annotations.reduce(({remaining, due}, ann) => {
      if (ann.at > seconds) {
        return {remaining: [...remaining, ann], due}
      } else {
        return {remaining, due: [...due, ann]}
      }
    }, {remaining: [], due: []})

    due.forEach(ann => {
      this.renderAnnotation(msgContainer, ann)
    })

    return remaining
  },

  formatTime(at) {
    const date = new Date(null)
    date.setSeconds(at / 1000)
    return date.toISOString().substr(14, 5)
  },

  esc(str) {
    const div = document.createElement("div")
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  },
}


export default Video
