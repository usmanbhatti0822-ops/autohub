import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

export enum ReviewType {
  BUYER_TO_SELLER = 'buyer_to_seller',
  SELLER_TO_BUYER = 'seller_to_buyer',
  RENTER_TO_OWNER = 'renter_to_owner',
  OWNER_TO_RENTER = 'owner_to_renter',
}

@Entity('reviews')
export class Review {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  author: User;

  @Column()
  authorId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  subject: User; // the user being reviewed

  @Column()
  subjectId: string;

  @Column({ type: 'enum', enum: ReviewType })
  type: ReviewType;

  @Column('int')
  rating: number; // 1-5

  @Column('text', { nullable: true })
  comment: string;

  // Links the review back to a booking or listing for traceability.
  @Column({ nullable: true })
  relatedBookingId: string;

  @Column({ nullable: true })
  relatedListingId: string;

  @CreateDateColumn()
  createdAt: Date;
}
