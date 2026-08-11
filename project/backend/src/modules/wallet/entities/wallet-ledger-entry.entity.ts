import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

export enum LedgerEntryType {
  CREDIT = 'credit', // earnings from a sale/rental
  DEBIT = 'debit', // payout withdrawn
  COMMISSION = 'commission', // platform fee deducted
}

@Entity('wallet_ledger_entries')
export class WalletLedgerEntry {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  user: User;

  @Column()
  userId: string;

  @Column({ type: 'enum', enum: LedgerEntryType })
  type: LedgerEntryType;

  @Column('decimal', { precision: 12, scale: 2 })
  amount: number;

  @Column('text', { nullable: true })
  note: string;

  @Column({ nullable: true })
  relatedBookingId: string;

  @CreateDateColumn()
  createdAt: Date;
}
