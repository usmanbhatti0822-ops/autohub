import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { RentalVehicle } from '../../rentals/entities/rental-vehicle.entity';

export enum BookingStatus {
  REQUESTED = 'requested',
  CONFIRMED = 'confirmed',
  ONGOING = 'ongoing',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
}

@Entity('bookings')
export class Booking {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => RentalVehicle, (vehicle) => vehicle.bookings, { onDelete: 'CASCADE' })
  vehicle: RentalVehicle;

  @Column()
  vehicleId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  renter: User;

  @Column()
  renterId: string;

  @Column({ type: 'timestamptz' })
  startDate: Date;

  @Column({ type: 'timestamptz' })
  endDate: Date;

  @Column('decimal', { precision: 12, scale: 2 })
  totalPrice: number;

  @Column('decimal', { precision: 10, scale: 2, default: 0 })
  securityDeposit: number;

  @Column({ default: false })
  withDriver: boolean;

  @Column({ type: 'enum', enum: BookingStatus, default: BookingStatus.REQUESTED })
  status: BookingStatus;

  @Column('simple-array', { nullable: true })
  pickupPhotoUrls: string[];

  @Column('simple-array', { nullable: true })
  returnPhotoUrls: string[];

  @Column('text', { nullable: true })
  cancellationReason: string | null;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
