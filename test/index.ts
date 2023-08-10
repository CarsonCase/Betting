import { expect } from "chai";
import { Signer } from "ethers";
import { ethers } from "hardhat";
import { Book, Bet } from "../typechain";

const winner = 1;
let book: Book;
let bookie: Signer;
let user1: Signer;

// OLD GAS COSTS [no opimization]
// New Book - 154,236
// FundBet - 364,611
// placeBet - 151,252
// deployment - 3,805,327


function getTime(){
  return Date.now() * 1000;
}
function tokens(strNum:string){
  return ethers.utils.parseEther(strNum);
}
describe("Old Betting", function () {
  before( async function () {
    [bookie, user1] =  await ethers.getSigners();
    const Book = await ethers.getContractFactory("Book");
    book = await Book.connect(bookie).deploy(2, getTime() + 1000, 500, [tokens("50"),tokens("50")], {value: tokens("100")});
    await book.deployed();    
  });

  it("place a bet", async function () {
    const betAm = tokens("1");
    const odds = await book.getOdds(winner,betAm);
    console.log(odds);
    await book.connect(user1).placeBet(winner,odds,{value:betAm});
  });

  it("call bet", async function(){
    await book.connect(bookie).settleBet(winner);
  });

  it("collect", async function(){
    const betAddress = await book.connect(user1).betsByIndex(winner);
    const bet = await ethers.getContractAt("Bet", betAddress.toString());

    const bal = await bet.connect(user1).balanceOf(await user1.getAddress());
    await bet.connect(user1).exchange(bal);
  });
});











// describe("Old Betting", function () {
//   before( async function () {
//     [bookie, user1] =  await ethers.getSigners();
//     const Betting = await ethers.getContractFactory("Test");
//     betting = await Betting.deploy();
//     await betting.deployed();    
//   });

//   it("newBook",async function () {
//     const tx = await betting.newBook();
//     const receipt = await tx.wait();
//     book = receipt.logs[0].topics[2];
//   });

//   it("Add liquidity to book", async function () {
//     await betting.fundBet(book,{value: ethers.utils.parseEther('1')});
//   });

//   it("place a bet",async function(){
//     await betting.connect(user1).placeBet(book,0,{value: ethers.utils.parseEther('0.0001')});
//   });

//   it('call bet', async function(){
//     console.log(await betting.books(book))
//     await betting.callBet(book,0);
//   });

//   it("settle bet", async function(){
//     await betting.connect(user1).settleBet(0);
//   });
// });
