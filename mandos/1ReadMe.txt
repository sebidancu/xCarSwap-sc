
How it works:

------
Perfect Scenario:

1. Init lottery -> lottery-Init.scen.json
2. Set Wallets -> set-wallets.scen.json
3. Fund the SC with egld and set prize pool -> fund-prizepoll.scen.json
4. Start the lottery -> start_lottery.scen.json
5. Buy Tickets with 3 different account -> buy-ticket.scen.json
6. Pick winner -> winner.scen.json

----

Other Scenario:

6. Acc3 Buys more tickets. Limit is 3 tickets and he has already 3 tickets (fail) -> You are trying to buy too many tickets
7. Acc3 Buys 3 more tickets. Limit is 3 and he has already 2 tickets (fail) -> You are trying to buy too many tickets
8. Winner Before deadline (fail) -> Deadline was not reached
9. Claim Funds while lottery is active (fail) -> Lottery is running
10. Draw Winner Again (fail) -> Winner already drawn



