import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { LedgerEntryType, WalletLedgerEntry } from './entities/wallet-ledger-entry.entity';

@Injectable()
export class WalletService {
  constructor(
    @InjectRepository(WalletLedgerEntry) private repo: Repository<WalletLedgerEntry>,
  ) {}

  async credit(userId: string, amount: number, note: string, relatedBookingId?: string) {
    const entry = this.repo.create({
      userId,
      type: LedgerEntryType.CREDIT,
      amount,
      note,
      relatedBookingId,
    });
    return this.repo.save(entry);
  }

  async recordCommission(userId: string, amount: number, relatedBookingId?: string) {
    const entry = this.repo.create({
      userId,
      type: LedgerEntryType.COMMISSION,
      amount,
      note: 'Platform commission',
      relatedBookingId,
    });
    return this.repo.save(entry);
  }

  async balance(userId: string): Promise<number> {
    const entries = await this.repo.find({ where: { userId } });
    return entries.reduce((sum, e) => {
      if (e.type === LedgerEntryType.DEBIT || e.type === LedgerEntryType.COMMISSION) {
        return sum - Number(e.amount);
      }
      return sum + Number(e.amount);
    }, 0);
  }

  async history(userId: string): Promise<WalletLedgerEntry[]> {
    return this.repo.find({ where: { userId }, order: { createdAt: 'DESC' } });
  }
}
