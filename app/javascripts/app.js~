// Import the page's CSS. Webpack will know what to do with it.
import "../stylesheets/app.css";

// Import libraries we need.
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'


import sharing_artifacts from '../../build/contracts/Sharing.json'

var Sharing = contract(sharing_artifacts);

let objects = {}

let totalObject = 0;

window.registerObject = function() {
  let des = $("#description").val();
  let pri = $("#price").val();
  let dep = $("#deposit").val();
  
  $("#description").val("");
  $("#price").val("");
  $("#deposit").val("");

  Sharing.deployed()
  .then(function(contractInstance) {
    contractInstance.registerObject(des,web3.toWei(pri,'ether'),web3.toWei(dep,'ether'), {gas: 140000, from: web3.eth.accounts[0]})
    .then(function() {
      totalObject++;
      objects[totalObject] = "object-" + totalObject;
      contractInstance.getObjInfo.call(totalObject)
      .then(function(v) {
        $("#object-rows").append("<tr><td>" + totalObject + "</td><td id='" + objects[totalObject] + "des" +"'>" + web3.toUtf8(v[0]) + "</td><td id='" + objects[totalObject] + "sta" +"'>" + v[1].toString() + "</td><td id='" + objects[totalObject] + "pri" +"'>" + web3.fromWei(v[2],"ether").toString() + "</td><td id='" + objects[totalObject] + "dep" +"'>" + web3.fromWei(v[3],"ether").toString() + "</td><td id='" + objects[totalObject] + "start" +"'>" + v[4].toString() + "</td><td id='" + objects[totalObject] + "end" +"'>" + v[5].toString() + "</td></tr>");
      });
    });
  });
}

window.reclaimObject = function() {
  let reclaimid = $("#objID").val();
  
  $("#objID").val("");

  Sharing.deployed()
  .then(function(contractInstance) {
    contractInstance.reclaimObject(reclaimid, {gas: 140000, from: web3.eth.accounts[0]})
    .then(function() {
      contractInstance.getObjInfo.call(reclaimid)
      .then(function(v) {
        $("#" + objects[reclaimid] + "sta").html(v[1].toString())
      });
    });
  });
}

window.rentObject = function() {
  let rentid = $("#objIDr").val();
  
  $("#objIDr").val("");

  Sharing.deployed()
  .then(function(contractInstance) {
    let deposit = $("#" + objects[rentid] + "dep").html();
    contractInstance.rentObject(rentid, {gas: 140000, value:web3.toWei(deposit,'ether'),from: web3.eth.accounts[5]})
    .then(function() {
      contractInstance.getObjInfo.call(rentid)
      .then(function(v) {
        $("#" + objects[rentid] + "sta").html(v[1].toString())
        $("#" + objects[rentid] + "start").html(v[4].toString())
      });
    });
  });
}

window.finishSharing = function() {
  let finishid = $("#objIDf").val();
  
  $("#objIDf").val("");

  Sharing.deployed()
  .then(function(contractInstance) {
    contractInstance.finishSharing(finishid, {gas: 140000, from: web3.eth.accounts[5]})
    .then(function() {
      contractInstance.getObjInfo.call(finishid)
      .then(function(v) {
        $("#" + objects[finishid] + "sta").html(v[1].toString())
        $("#" + objects[finishid] + "end").html(v[5].toString())
        $("#" + objects[finishid] + "start").html(v[4].toString())
      });
    });
  });
}

function populateObjects() {
  Sharing.deployed()
  .then(function(contractInstance) {
    contractInstance.getnumObjs.call()
    .then(function(numObjs) {
      totalObject = numObjs;
      for(let i=1; i <= numObjs; i++) {
        objects[i] = "object-" + i;
      }
      setupObjectRows();
      populate();
    });
  });
}

function setupObjectRows() {
  Object.keys(objects).forEach(function (object) { 
    $("#object-rows").append("<tr><td>" + object + "</td><td id='" + objects[object] + "des" +"'></td><td id='" + objects[object] + "sta" +"'></td><td id='" + objects[object] + "pri" +"'></td><td id='" + objects[object] + "dep" +"'></td><td id='" + objects[object] + "start" +"'></td><td id='" + objects[object] + "end" +"'></td></tr>");
  });
}

function populate() {
  let ids = Object.keys(objects);
  for (var i = 0; i < ids.length; i++) {
    let id = ids[i];
    Sharing.deployed()
    .then(function(contractInstance) {
      contractInstance.getObjInfo.call(id).then(function(v) {
        $("#" + objects[id] + "des").html(web3.toUtf8(v[0]));
        $("#" + objects[id] + "sta").html(v[1].toString());
        $("#" + objects[id] + "pri").html(web3.fromWei(v[2],"ether").toString());
        $("#" + objects[id] + "dep").html(web3.fromWei(v[3],"ether").toString());
        $("#" + objects[id] + "start").html(v[4].toString());
        $("#" + objects[id] + "end").html(v[5].toString());
      });
    });
  }
}

$( document ).ready(function() {
  if (typeof web3 !== 'undefined') {
    console.warn("Using web3 detected from external source like Metamask")
    // Use Mist/MetaMask's provider
    window.web3 = new Web3(web3.currentProvider);
  } else {
    console.warn("No web3 detected. Falling back to http://localhost:8545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  }

  Sharing.setProvider(web3.currentProvider);
  populateObjects();

});
