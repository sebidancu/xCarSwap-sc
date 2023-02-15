from multiversx_sdk_core import Address

address = Address.from_bech32("erd1a8jaysc9aadaa57nm26nyz4euj994fsmmrkjpp2zg53gn3alj0wqls7f96")

from multiversx_sdk_core import Address, TokenPayment, Transaction
from multiversx_sdk_core.transaction_builders import ESDTTransferBuilder

payment = TokenPayment.fungible_from_amount("COUNTER-8b028f", "100.00", 2)

builder = ESDTTransferBuilder(
    config=config,
    sender=alice,
    receiver=bob,
    payment=payment
)

tx = builder.build()
print("Transaction:", tx.to_dictionary())
print("Transaction data:", tx.data)

