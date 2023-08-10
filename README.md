# Betting Contract

A nice simple betting contract. Made up of 2 components:

- Book
- Bet

## Book
The Book is an individual "thing" to bet on. For example: Will Elon or Zuc win the fight?

The manager of a book is a "bookie" who gets a fee of the book using a "reserve rate" that impacts odds to balance books as best as possible while leaving that room for him. It's a clever way to collect fees in a rather invisible way that reall bookies use.

The bookie on Nov 12th will announce the winnner of the bet. It is a matter of trust with the bookie, unless it is a smart contract.

Also note that an expiration date and default expiration option is mandatory in case the fight is called off or the bookie disappears

If expiration date passes, anyone can claim the winner as the expiration option (but only that option)

## Bet
The Bet is an ERC20 to do the accounting and tokenization of individual bets. Really it's better to think of these as "coupons" as they are named w?iETH (i being the index in their parent book). This, as it seems, means these are conditionally Wrapped ETH tokens, meaning they act as a wrapper for ETH but only in the condition of that bet being a winner.

### Old Contracts
These are upgrades of my old betting contracts (very gross). Which are still included for nostalgia. They are noted in the NATSPEC header as Old