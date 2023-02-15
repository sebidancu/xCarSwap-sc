#![no_std]

elrond_wasm::imports!();
elrond_wasm::derive_imports!();

mod nft_status;
use nft_status::NftInfo;

mod lottery_status;
use lottery_status::LotteryStatus;

#[elrond_wasm::derive::contract]
pub trait xcarswap {
    #[init]
    fn init(
        &self,
        maxticketsperwallet: u64,
        ticketprice: BigUint,
        maxticketsperlottery: u64,
        token_id: EgldOrEsdtTokenIdentifier,
    ) {
        self.max_tickets_per_address()
            .set_if_empty(&maxticketsperwallet);
        self.ticket_price().set_if_empty(&ticketprice);
        self.max_tickets_per_lottery()
            .set_if_empty(&maxticketsperlottery);
        self.token_identifier().set_if_empty(&token_id);
    }

    #[only_owner]
    #[payable("*")]
    #[endpoint]
    fn fund(&self) {}

    #[only_owner]
    #[endpoint]
    fn start_lottery(&self, deadline: u64, winners: u64) {
        let current_time = self.blockchain().get_block_timestamp();

        require!(deadline > current_time, "The deadline is in the past");

        self.deadline().set(&deadline);

        let lottery_counter = self.lottery_counter().get();
        self.lottery_counter().set(lottery_counter + 1);
        self.ticket_counter().clear();
        self.ticket_holder().clear();

        require!(
            self.lottery_status().get() == LotteryStatus::Closed,
            "Winner function was not called"
        );

        self.lottery_status().set(LotteryStatus::Opened);
        self.winners_number().set(winners);
    }

    /// Pay ticket
    #[payable("*")]
    #[endpoint]
    fn buy_tickets(&self, tickets: u64, _opt_ref: OptionalValue<ManagedBuffer>) {
        let timestamp = self.blockchain().get_block_timestamp();
        let deadline = self.deadline().get();
        let caller = self.blockchain().get_caller();
        let lottery_counter = self.lottery_counter().get();
        let lottery_status = self.lottery_status().get();
        let max_tickets = self.max_tickets_per_lottery().get();
        let ticket_counter = self.ticket_counter().get();
        let payments = self.call_value().all_esdt_transfers();
        let identifier_esdt = self.token_identifier().get();

        for payment in payments.into_iter() {
            require!(
                payment.token_identifier == identifier_esdt,
                "Incorrect Token"
            );

            require!(
                payment.amount == (self.ticket_price().get() * tickets),
                "Incorrect payment"
            );

            self.total_volume()
                .update(|total_volume| *total_volume += payment.amount);
        }

        require!(
            deadline > timestamp, 
            "Lottery is closed"
        );
        require!(
            lottery_status == LotteryStatus::Opened, 
            "Lottery is closed"
        );

        require!(
            max_tickets >= ticket_counter + tickets, 
            "Max tickets reached"
        );
        require!(
            self.tickets_per_address(&caller, lottery_counter).get()
                <= self.max_tickets_per_address().get(), 
            "Max tickets per wallet reached"
        );

        require!(
            BigUint::from(tickets) <= self.max_tickets_per_address().get(),
            "Too many tickets"
        );

        require!(
            self.tickets_per_address(&caller, lottery_counter).get() + tickets
                <= self.max_tickets_per_address().get(),
            "You are trying to buy too many tickets"
        );

        if self
            .tickets_per_address(&caller, lottery_counter)
            .is_empty()
        {
            self.tickets_per_address(&caller, lottery_counter)
                .set(tickets);
        } else {
            self.tickets_per_address(&caller, lottery_counter)
                .set(self.tickets_per_address(&caller, lottery_counter).get() + tickets);
        }

        for _ in 0..tickets {
            self.ticket_holder().push(&caller);
        }

        self.ticket_counter().update(|counter| *counter += tickets);
    }

    #[only_owner]
    #[endpoint]
    fn draw_winner(&self) {
        let lottery_counter = self.lottery_counter().get();
        let timestamp = self.blockchain().get_block_timestamp();
        let deadline = self.deadline().get();
        let ticket_len = self.ticket_holder().len();
        let identifier_esdt = self.token_identifier().get();
        let ticket_goal = self.max_tickets_per_lottery().get() as usize;


        require!(deadline <= timestamp || ticket_goal != ticket_len, "Deadline was not reached");


        require!(
            self.lottery_status().get() == LotteryStatus::Opened,
            "Winner already drawn"
        );

        if ticket_len == ticket_goal && self.lottery_status().get() == LotteryStatus::Opened {
            let numberofwinner = self.winners_number().get();
            //select winner
            for winner in 1..=numberofwinner {
                let wallets = self.ticket_holder();
                let wallets_nr = wallets.len(); //vad cate adrese s-au strans
                let mut rand_source = RandomnessSource::<Self::Api>::new();
                let index = rand_source.next_usize_in_range(1, wallets_nr + 1);
                let choosen_wallet = wallets.get(index);

                //TX winner

                if winner == 1u64 {
                    // 1st winner - send only nft
                    self.send().direct_esdt(
                        &choosen_wallet,
                        &self.nft_storage(winner).get().token_identifier,
                        self.nft_storage(winner).get().nft_nonce,
                        &BigUint::from(1u64),
                    );
                } else {
                    //place 2-10 nft + usdc
                    //send nft
                    self.send().direct_esdt(
                        &choosen_wallet,
                        &self.nft_storage(winner).get().token_identifier,
                        self.nft_storage(winner).get().nft_nonce,
                        &BigUint::from(1u64),
                    );
                    //send usdc
                    self.send().direct(
                        &choosen_wallet,
                        &identifier_esdt,
                        0u64,
                        &self.esdt_storage(winner).get(),
                    );
                }

                self.last_winner(lottery_counter)
                    .push(&choosen_wallet.clone());

                self.ticket_holder().swap_remove(index); //swap_remove wallet 
            }

            let balance = self.blockchain().get_sc_balance(&identifier_esdt, 0u64);
            // send money to xcarswap
            let owner_wallet = self.blockchain().get_owner_address();
            self.send()
                .direct(&owner_wallet, &identifier_esdt, 0, &balance);

        }
        else if ticket_len != ticket_goal && self.lottery_status().get() == LotteryStatus::Opened{
            //if the ticket goal is not reached, return 95% of the value 
            let wallets = self.ticket_holder();
            let wallets_nr = wallets.len();
            let ticket_price = self.ticket_price().get() * BigUint::from(95 as u64)/BigUint::from(100 as u64);
            
            for wallet in wallets.iter() {
                self.send().direct(&wallet, &identifier_esdt, 0, &ticket_price);
            }
        }
        self.lottery_status().set(LotteryStatus::Closed);
    }

    #[only_owner]
    #[endpoint]
    fn withdraw_esdt(&self) {
        let deadline = self.deadline().get();
        let current_time = self.blockchain().get_block_timestamp();

        require!(deadline < current_time, "Lottery is running");

        let identifier_esdt = self.token_identifier().get();

        let owner_wallet = self.owner_wallet().get();

        let balance = self.blockchain().get_sc_balance(&identifier_esdt, 0);

        self.send()
            .direct(&owner_wallet, &identifier_esdt, 0, &balance);
    }

    #[only_owner]
    #[payable("*")]
    #[endpoint]
    fn fund_nft(&self, tier: u64) {
        let payments = self.call_value().all_esdt_transfers();

        for payment in payments.into_iter() {
            require!(
                payment.amount == BigUint::from(1u32),
                "NFT amount is not valid"
            );
            let info = NftInfo {
                token_identifier: payment.token_identifier,
                nft_nonce: payment.token_nonce,
            };
            self.nft_storage(tier).set(&info);
        }
    }

    //index 1 is the big winner, index 2 is 2nd winner...
    #[only_owner]
    #[endpoint]
    fn set_esdt_storage(&self, index:u64, value:BigUint){
        self.esdt_storage(index).set(value);
    }

    #[only_owner]
    #[endpoint]
    fn change_token_id(&self, token_id: EgldOrEsdtTokenIdentifier) {
        self.token_identifier().set(token_id);
    }

    #[only_owner]
    #[endpoint]
    fn change_deadline(&self, newdeadline: u64) {
        self.deadline().set(newdeadline);
    }

    //<--- STORAGE ARE --->
    #[view(getbalancesc)]
    #[storage_mapper("balancesc")]
    fn balance_sc(&self) -> SingleValueMapper<BigUint>;

    #[view(getNoncesLkmex)]
    #[storage_mapper("nonceslkmex")]
    fn nonces_vec(&self) -> VecMapper<u64>;

    #[only_owner] //wallet for nft holders 5%
    #[endpoint]
    fn setowner(&self, address: &ManagedAddress) {
        self.owner_wallet().set(address);
    }

    #[only_owner]
    #[endpoint]
    fn set_maxtickets_per_wallet(&self, maxtickets: u64) {
        self.max_tickets_per_address().set(maxtickets);
    }

    #[only_owner]
    #[endpoint]
    fn set_price(&self, price: BigUint) {
        self.ticket_price().set(price);
    }

    #[only_owner]
    #[endpoint]
    fn set_maxtickets_per_lottery(&self, tickets: u64) {
        self.max_tickets_per_lottery().set(tickets);
    }

    //---STORAGE
    #[view(getWinnersNb)]
    #[storage_mapper("winnersnb")]
    fn winners_number(&self) -> SingleValueMapper<u64>;

    #[view(getTokenId)]
    #[storage_mapper("tokenid")]
    fn token_identifier(&self) -> SingleValueMapper<EgldOrEsdtTokenIdentifier>;

    #[view(getWinner)]
    #[storage_mapper("lastwinner")]
    fn last_winner(&self, lottery: u64) -> VecMapper<ManagedAddress>;

    #[view(getNftStorage)]
    #[storage_mapper("nftstorage")]
    fn nft_storage(&self, index:u64) -> SingleValueMapper<NftInfo<Self::Api>>;

    #[view(getWinnersEsdt)]
    #[storage_mapper("winnersesdt")]
    fn esdt_storage(&self, index:u64) -> SingleValueMapper<BigUint>;

    #[view(getPrizePool)]
    #[storage_mapper("prizepool")]
    fn prizepool(&self) -> VecMapper<BigUint>;

    #[view(getStatus)]
    #[storage_mapper("lotterystatus")]
    fn lottery_status(&self) -> SingleValueMapper<LotteryStatus>;

    #[view(getTicketHolder)]
    #[storage_mapper("ticketHolder")]
    fn ticket_holder(&self) -> VecMapper<ManagedAddress>;

    #[view(getDeadline)]
    #[storage_mapper("deadline")]
    fn deadline(&self) -> SingleValueMapper<u64>;

    #[view(getPrize)]
    #[storage_mapper("totalprize")]
    fn totalprize(&self) -> SingleValueMapper<BigUint>;

    #[view(getVolume)]
    #[storage_mapper("totalvolume")]
    fn total_volume(&self) -> SingleValueMapper<BigUint>;

    #[view(getCounterTickets)]
    #[storage_mapper("ticketcounter")]
    fn ticket_counter(&self) -> SingleValueMapper<u64>;

    #[view(getCounterLottery)]
    #[storage_mapper("lotterycounter")]
    fn lottery_counter(&self) -> SingleValueMapper<u64>;

    //----Wallets
    #[storage_mapper("teamwallet")]
    fn team_wallet(&self) -> SingleValueMapper<ManagedAddress>;

    #[storage_mapper("ElrondBunnyHolders")]
    fn elrond_bunny_holders(&self) -> SingleValueMapper<ManagedAddress>;

    #[storage_mapper("marketingwallet")]
    fn marketing_wallet(&self) -> SingleValueMapper<ManagedAddress>;

    #[storage_mapper("ecfholderswallet")]
    fn ecf_holders_wallet(&self) -> SingleValueMapper<ManagedAddress>;

    #[storage_mapper("ownerwallet")]
    fn owner_wallet(&self) -> SingleValueMapper<ManagedAddress>;

    //-----

    #[view(getTicketsPerAddress)]
    #[storage_mapper("ticketsPerAddress")]
    fn tickets_per_address(&self, address: &ManagedAddress, lottery: u64)
        -> SingleValueMapper<u64>;

    #[view(getMaxTicketsPerAddress)]
    #[storage_mapper("maxTicketsPerAddress")]
    fn max_tickets_per_address(&self) -> SingleValueMapper<u64>;

    #[view(getTicketPrice)]
    #[storage_mapper("TicketPrice")]
    fn ticket_price(&self) -> SingleValueMapper<BigUint>;

    #[view(getMaxTickersPerLottery)]
    #[storage_mapper("MaxTickersPerLottery")]
    fn max_tickets_per_lottery(&self) -> SingleValueMapper<u64>;
}
