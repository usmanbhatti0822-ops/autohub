import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Booking } from '../../bookings/entities/booking.entity';
import { TransmissionType, FuelType, VehicleCategory } from '../../listings/entities/listing.entity';

export enum RentalVehicleStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
  PAUSED = 'paused', // owner temporarily disabled bookings
}

@Entity('rental_vehicles')
export class RentalVehicle {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  owner: User;

  @Column()
  ownerId: string;

  @Column()
  make: string;

  @Column()
  model: string;

  @Column()
  year: number;

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

  @Column()
  city: string;

  @Column('text')
  pickupLocation: string;

  @Column('decimal', { precision: 10, scale: 2 })
  dailyRate: number;

  @Column('decimal', { precision: 10, scale: 2, default: 0 })
  securityDeposit: number;

  @Column({ default: false })
  driverAvailable: boolean;

  @Column('simple-array', { nullable: true })
  photoUrls: string[];

  @Column('text', { nullable: true })
  description: string;

  @Column({ type: 'enum', enum: RentalVehicleStatus, default: RentalVehicleStatus.PENDING })
  status: RentalVehicleStatus;

  @OneToMany(() => Booking, (booking) => booking.vehicle)
  bookings: Booking[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
