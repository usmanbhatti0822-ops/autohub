import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

export enum ListingStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
  SOLD = 'sold',
}

export enum TransmissionType {
  MANUAL = 'manual',
  AUTOMATIC = 'automatic',
}

export enum FuelType {
  PETROL = 'petrol',
  DIESEL = 'diesel',
  HYBRID = 'hybrid',
  ELECTRIC = 'electric',
  CNG = 'cng',
}

export enum VehicleCategory {
  ECONOMY = 'economy',
  HATCHBACK = 'hatchback',
  SEDAN = 'sedan',
  SUV = 'suv',
  LUXURY = 'luxury',
}

@Entity('car_listings')
export class CarListing {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User, (user) => user.listings, { onDelete: 'CASCADE' })
  seller: User;

  @Column()
  sellerId: string;

  @Column()
  make: string;

  @Column()
  model: string;

  @Column()
  year: number;

  @Column({ nullable: true })
  variant: string;

  @Column('int')
  mileageKm: number;

  @Column('decimal', { precision: 12, scale: 2 })
  price: number;

  @Column()
  city: string;

  @Column({ type: 'enum', enum: TransmissionType })
  transmission: TransmissionType;

  @Column({ type: 'enum', enum: FuelType })
  fuelType: FuelType;

  @Column({ type: 'enum', enum: VehicleCategory, default: VehicleCategory.SEDAN })
  category: VehicleCategory;

  @Column('int', { default: 5 })
  seats: number;

  @Column('int', { default: 4 })
  doors: number;

  @Column('simple-array', { nullable: true })
  features: string[];

  @Column('simple-array', { nullable: true })
  photoUrls: string[];

  @Column('text', { nullable: true })
  description: string;

  @Column({ type: 'enum', enum: ListingStatus, default: ListingStatus.PENDING })
  status: ListingStatus;

  @Column({ default: false })
  isVerified: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
