import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { CarListing } from '../../listings/entities/listing.entity';

export enum UserRole {
  BUYER_SELLER = 'buyer_seller',
  CAR_OWNER = 'car_owner',
  ADMIN = 'admin',
}

export enum VerificationLevel {
  UNVERIFIED = 'unverified',
  PHONE_VERIFIED = 'phone_verified',
  ID_VERIFIED = 'id_verified',
}

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  phone: string;

  @Column({ nullable: true })
  fullName: string;

  @Column({ nullable: true, unique: true })
  email: string;

  // select: false — never included in a normal find()/relation load, so it
  // can't leak through e.g. GET /listings' `seller` relation. Login must
  // explicitly re-select it (see AuthService.login).
  @Column({ type: 'varchar', nullable: true, select: false })
  passwordHash: string | null;

  @Column({ default: false })
  phoneVerified: boolean;

  @Column({
    type: 'enum',
    enum: VerificationLevel,
    default: VerificationLevel.UNVERIFIED,
  })
  verificationLevel: VerificationLevel;

  @Column({
    type: 'enum',
    enum: UserRole,
    default: UserRole.BUYER_SELLER,
  })
  role: UserRole;

  @Column({ nullable: true })
  city: string;

  @Column({ nullable: true })
  avatarUrl: string;

  @OneToMany(() => CarListing, (listing) => listing.seller)
  listings: CarListing[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
