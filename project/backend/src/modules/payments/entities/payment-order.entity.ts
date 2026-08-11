import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

export enum PaymentGateway {
  JAZZCASH = 'jazzcash',
  EASYPAISA = 'easypaisa',
  CARD = 'card',
  CASH_ON_PICKUP = 'cash_on_pickup',
}

export enum PaymentStatus {
  PENDING = 'pending',
  SUCCESS = 'success',
  FAILED = 'failed',
}

@Entity('payment_orders')
export class PaymentOrder {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  payer: User;

  @Column()
  payerId: string;

  @Column('decimal', { precision: 12, scale: 2 })
  amount: number;

  @Column({ type: 'enum', enum: PaymentGateway })
  gateway: PaymentGateway;

  @Column({ type: 'enum', enum: PaymentStatus, default: PaymentStatus.PENDING })
  status: PaymentStatus;

  // e.g. booking ID or sale-offer ID this payment is for
  @Column({ nullable: true })
  relatedBookingId: string;

  // ID returned by the gateway, for reconciliation
  @Column({ type: 'varchar', nullable: true })
  gatewayReference: string | null;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
