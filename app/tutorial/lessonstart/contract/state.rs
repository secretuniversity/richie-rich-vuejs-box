use cosmwasm_std::{Addr, Storage, StdResult, Uint128};
use cosmwasm_storage::{
    ReadonlySingleton, singleton, Singleton,
    singleton_read,
};
use secret_toolkit::storage::{Item};

use schemars::JsonSchema;
use serde::{Deserialize, Serialize};

const STATE_KEY: &[u8] = b"state";
pub const PREFIX_BALANCES: &[u8] = b"balances";


#[derive(Serialize, Deserialize, Clone, Debug, JsonSchema)]
#[cfg_attr(test, derive(Eq, PartialEq))]
pub struct Outcome {
    pub richest: Millionaire,
}

impl Outcome {
    pub fn init() -> Self {
        Self {
            richest: Millionaire { 
                addr: Addr::unchecked(""), 
                networth: Uint128::zero(), 
            },
        }
    }

    pub fn update_richest(&mut self, addr: Addr, networth: Uint128) {
        self.richest = Millionaire {
            addr,
            networth,
        }
    } 
}

pub fn state(storage: &mut dyn Storage) -> Singleton<Outcome> {
    singleton(storage, STATE_KEY)
}

pub fn state_read(storage: &dyn Storage) -> ReadonlySingleton<Outcome> {
    singleton_read(storage, STATE_KEY)
}   


#[derive(Serialize, Deserialize, Clone, Debug, JsonSchema)]
#[cfg_attr(test, derive(Eq, PartialEq))]
pub struct Millionaire {
    pub addr: Addr,
    pub networth: Uint128,
}

pub static NETWORTHS: Item<Uint128> = Item::new(PREFIX_BALANCES);
pub struct NetWorthStore {}
impl NetWorthStore {
    pub fn may_load(store: &dyn Storage, account: &Addr) -> Option<Uint128> {
        //
        // complete code here
        //
        Some(Uint128::from(0_u128))  // change this line of code
    }

    pub fn save(store: &mut dyn Storage, account: &Addr, amount: Uint128) -> StdResult<()> {
        //
        // complete code here
        //
        Ok(()) // change this line of code
    }
}
