var web3 = new Web3(Web3.givenProvider);
var contractInstance;
var head_ivan = false;
var tail_filip = false;
var address;


$(document).ready(function() {
    window.ethereum.enable().then(function(accounts){
      contractInstance = new web3.eth.Contract(abi, "0x33b1848b5ebb6E94b5212562E748b55C5145939D", {from: accounts[0]});
      address=accounts[0];

      window.onload = displayJackpot();
      window.onload = displayUserBalance();

contractInstance.events.Player_Win()
.on('data', (event) => {
  displayJackpot();
  displayUserBalance();
  winner();
  $("#spinner").removeClass();
  $("#play").html("<span>Play</span>").addClass("btn btn-primary btn-lg").removeClass("disabled");
})
.on('error', console.error);


$('#play').click(function() {
  $('#play').html('<span class="spinner-grow spinner-grow-lg" id="spinner" role="status" aria-hidden="true"></span>').addClass("disabled");
});



$("#sendfund").click(donateFund);

    $("#play").click(bettingGame);
$("#spinner_button").click(withdrawUFu);
    $("#ivan").click(displayJackpot);
    $("#ivan").click(clickIvan);
    $("#filip").click(clickFilip);


});
});

function clickIvan(){
           $("#ivan").css('opacity', '0.5');
           $("#filip").css('opacity', '1');
           head_ivan = true;
           tail_filip= false;
           console.log(head_ivan);
           console.log(tail_filip);
}
function clickFilip(){
        $("#filip").css('opacity', '0.5');
        $("#ivan").css('opacity', '1');;
        tail_filip= true;
        head_ivan = false;
        console.log(head_ivan);
        console.log(tail_filip);
}

function refreshPage(){
  var bet_val = $("#AmountToBet").val();
$("#amount_to_win").text(bet_val*1.9 + " ETH");
displayJackpot();
displayUserBalance();
}

function withdrawUFu(){
  contractInstance.methods.withdrawUserFunds().send({from: address})
  displayJackpot();
  displayUserBalance();
}

function donateFund(){
  contractInstance.methods.sendFund().send({from: address, value: web3.utils.toWei("1", "ether")})
  displayJackpot();
  displayUserBalance();
}


function bettingGame(){
  var old_balance
  var am = $("#AmountToBet").val().toString();
  var config = {
    from: address,
    value: web3.utils.toWei(am, "ether"),

  }
  contractInstance.methods.FlipTheCoin(head_ivan, tail_filip).send(config)

}

function you_win() {
$("#text_win").text("You win");
}

function you_lose() {
$("#text_win").text("You lose");
}

function winner (){
  contractInstance.methods.who_wins().call().then(async function (res){
    if(res == true){
      you_win();
    }
    else {
      you_lose();
    }
  });
}

function displayUserBalance(){
var user_bal =  contractInstance.methods.getUserBalance().call().then(async function (res){
  $("#user_balance").text("Amount to withdraw " + res/1000000000000000000 + " ETH");
});


}

function displayJackpot(){
  contractInstance.methods.getSmartContractBalance().call().then(async function (res){
//  web3.eth.getBalance("0x0cbFb2e256c14CADaf48cC269CA9F3ed69829897").then(function (res){
    $("#jackpot").text(res/1000000000000000000 + " ETH");
  })
}
