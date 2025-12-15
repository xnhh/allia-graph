import { Transfer as TransferEvent } from "../generated/WBTC/WBTC";
import { Account, Transfer } from "../generated/schema";
import { BigInt, Bytes } from "@graphprotocol/graph-ts";

/**
 * 处理 WBTC Transfer 事件
 * 当发生转账时，更新发送方和接收方的余额
 * 
 * 注意：Starknet 使用 felt252 类型，需要转换为 Bytes
 */
export function handleTransfer(event: TransferEvent): void {
  // Starknet 使用 felt252，需要转换为十六进制字符串作为 ID
  let fromAddress = event.params.from.toHexString();
  let toAddress = event.params.to.toHexString();
  
  // 获取转账金额（可能是 value 或 amount，根据实际 ABI 调整）
  let amount = event.params.value;
  
  // 获取或创建发送方账户
  let fromAccount = Account.load(fromAddress);
  if (fromAccount == null) {
    fromAccount = new Account(fromAddress);
    // 将 felt252 转换为 Bytes
    fromAccount.address = Bytes.fromHexString(fromAddress);
    fromAccount.wbtcBalance = BigInt.fromI32(0);
    fromAccount.lastUpdated = event.block.timestamp;
  }
  
  // 更新发送方余额（减少）
  fromAccount.wbtcBalance = fromAccount.wbtcBalance.minus(amount);
  fromAccount.lastUpdated = event.block.timestamp;
  fromAccount.save();

  // 获取或创建接收方账户
  let toAccount = Account.load(toAddress);
  if (toAccount == null) {
    toAccount = new Account(toAddress);
    // 将 felt252 转换为 Bytes
    toAccount.address = Bytes.fromHexString(toAddress);
    toAccount.wbtcBalance = BigInt.fromI32(0);
    toAccount.lastUpdated = event.block.timestamp;
  }
  
  // 更新接收方余额（增加）
  toAccount.wbtcBalance = toAccount.wbtcBalance.plus(amount);
  toAccount.lastUpdated = event.block.timestamp;
  toAccount.save();

  // 创建转账记录
  let transferId = event.transaction.hash.toHexString() + "-" + event.logIndex.toString();
  let transfer = new Transfer(transferId);
  transfer.from = fromAccount.id;
  transfer.to = toAccount.id;
  transfer.amount = amount;
  transfer.timestamp = event.block.timestamp;
  transfer.blockNumber = event.block.number;
  transfer.transactionHash = event.transaction.hash;
  transfer.save();
}

