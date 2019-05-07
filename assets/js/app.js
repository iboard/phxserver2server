// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
import {socket,channel} from "./socket"

let connectButton = document.getElementById("connect-button")
if (connectButton != undefined ) {
  connectButton.onclick = function(){
    console.log("Button pressed")
    channel.push('connect_button', { "API_KEY": 123456 } )
      .receive('ok', resp => { console.log('Connecting Slave...', resp) })
    //socket
    false
  }
}
