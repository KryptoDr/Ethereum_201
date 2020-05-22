import "./provableAPI_0.5.sol";
pragma solidity 0.5.12;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
  }

contract CoinFlip is usingProvable{
  uint256 constant NUM_RANDOM_BYTES_REQUESTED = 1;

  event Player_Win(bool plawin);

  using SafeMath for uint256;
  address payable owner;
  uint public balance;
  uint public result_random;
  uint private worst_case_balance;

  struct Player_data {
      bytes32 queryId;
      uint256 amountToWithdraw;
      uint256 bet_player;
      bool current_play;
      bool head_or_tail;
      uint256 player_random_Number;
      bool player_win;
      uint256 status;
    }

  mapping (address => Player_data) public player_info;
  mapping (bytes32 => address) public player_id_address;

  constructor () public payable{
    require(msg.value >= 0.5 ether);
    owner = msg.sender;
    balance+=msg.value;
    worst_case_balance+=msg.value;
  }

  modifier costs(uint cost){
      require(msg.value >= cost);
      _;
  }

function sendFund() public payable costs(1 ether){
  require(msg.value >= 1 ether);
  balance += msg.value;
  worst_case_balance+=msg.value;
}

function __callback(bytes32 _queryId, string memory _result) public {
  require(msg.sender == provable_cbAddress());
  uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) % 2;
  player_info[player_id_address[_queryId]].player_random_Number = randomNumber;
  result_random=randomNumber;
  player_info[player_id_address[_queryId]].status=0;
  player_info[player_id_address[_queryId]].player_win=false;
  uint win =0;

  if ( player_info[player_id_address[_queryId]].player_random_Number == 1 &&  player_info[player_id_address[_queryId]].head_or_tail == true){
    player_info[player_id_address[_queryId]].player_win=true;
    player_info[player_id_address[_queryId]].status=1;
  }
  else if (player_info[player_id_address[_queryId]].player_random_Number == 0 && player_info[player_id_address[_queryId]].head_or_tail == false){
    player_info[player_id_address[_queryId]].player_win=true;
    player_info[player_id_address[_queryId]].status=2;
  }
  else {
    player_info[player_id_address[_queryId]].player_win=false;
    player_info[player_id_address[_queryId]].status=3;
  }

  if(player_info[player_id_address[_queryId]].player_win==true){
    win =SafeMath.mul(player_info[player_id_address[_queryId]].bet_player,190)/100;
    balance -=win;
    player_info[player_id_address[_queryId]].amountToWithdraw+=win;
    player_info[player_id_address[_queryId]].status=4;
    player_info[player_id_address[_queryId]].current_play=false;
    emit Player_Win(player_info[player_id_address[_queryId]].player_win);
  }

  else{
    win =SafeMath.mul(player_info[player_id_address[_queryId]].bet_player,200)/100;
    worst_case_balance+=win;
    player_info[player_id_address[_queryId]].current_play=false;
    emit Player_Win(player_info[player_id_address[_queryId]].player_win);
  }

}

function update() payable public{
  uint256 QUERY_EXECUTION_DELAY = 0;
  uint256 GAS_FOR_CALLBACK = 200000;
  player_info[msg.sender].queryId = provable_newRandomDSQuery(
    QUERY_EXECUTION_DELAY,
    NUM_RANDOM_BYTES_REQUESTED,
    GAS_FOR_CALLBACK
    );
    player_id_address[player_info[msg.sender].queryId]=msg.sender;
}

function withdrawAll() private {
  require(msg.sender == owner);
  uint toTransfer = balance;
  balance = 0;
  msg.sender.transfer(toTransfer);
}

function withdrawUserFunds() public{
    uint toTransfer = player_info[msg.sender].amountToWithdraw;
  player_info[msg.sender].amountToWithdraw = 0;
    msg.sender.transfer(toTransfer);
}

function getUserBalance() public view returns (uint256){
    uint256 user_bal = player_info[msg.sender].amountToWithdraw;
    return user_bal;
}

function getSmartContractBalance() public view returns (uint256){
    return balance;
}

function who_wins() public view returns (bool){
    if (player_info[msg.sender].player_win==true){
      return true;
    }
    else {
      return false;
    }    
}

function FlipTheCoin(bool head_player, bool tail_player) public payable costs(0.1 ether){
  require(msg.value > 0);
  require ((head_player == true && tail_player==false)|| (head_player == false && tail_player==true));
  worst_case_balance-=msg.value;
  require ((balance-msg.value)>0);
  require(balance>worst_case_balance);
  require(player_info[msg.sender].current_play==false);

  player_info[msg.sender].current_play=true;
  if (head_player){
    player_info[msg.sender].head_or_tail= true;
  }
  else {
    player_info[msg.sender].head_or_tail=false;
  }

  player_info[msg.sender].bet_player = msg.value;
  balance += msg.value;
  update();
}

}
