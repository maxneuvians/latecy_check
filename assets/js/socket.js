// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/web/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket")

socket.connect()

function addNode(data) {
  let ip = data[0];
  let country = data[1];
  let htmlString = `
    <tr id="${ip.replace(/\./g, "-")}">
      <td>
        <img src="https://cdnjs.cloudflare.com/ajax/libs/flag-icon-css/3.1.0/flags/1x1/${country.toLowerCase()}.svg" width="24"/>
        ${country}
      </td>
      <td>${ip}</td>
      <td class="result"></td>
    </tr>
  `;
  $("#node-table tbody").append(htmlString);
}

function generateUUID() {
  var d = new Date().getTime();
  var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    var r = (d + Math.random()*16)%16 | 0;
    d = Math.floor(d/16);
    return (c=='x' ? r : (r&0x3|0x8)).toString(16);
  });
  return uuid;
};

function removeNode(node) {
  let parts = node.split("@");
  $("#node-table tbody #" + parts[1].replace(/\./g, "-")).remove();
}

let lobby = socket.channel("room:lobby", {})

lobby.join()
  .receive("ok", resp => { 
    Object.values(resp.nodes).forEach(node => { addNode(node) });
  })
  .receive("error", resp => { console.log("Unable to join", resp) })

lobby.on("new_node", payload => { addNode(payload.node);});
lobby.on("node_down", payload => { removeNode(payload.id); });

let uuid = generateUUID();
let channel = socket.channel("room:" + uuid, {})
let searchField = $("#url");

$("#url").on("keypress", event => {
  let val = searchField.val();
  if (event.keyCode == 13 && val.trim() !== "") {
    $(".result").html("<i class='fa fa-spinner fa-spin'></i>");
    channel.push("start_query", {url: searchField.val()});
  }
});

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel.on("node_result", payload => { 
  let parts = payload.node.split("@");
  let id = parts[1].replace(/\./g, "-");
  $("#" + id + " .result").html(payload.time);
})

export default socket

