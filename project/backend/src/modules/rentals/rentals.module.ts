import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { RentalVehicle } from './entities/rental-vehicle.entity';
import { Booking } from '../bookings/entities/booking.entity';
import { RentalsService } from './rentals.service';
import { RentalsController } from './rentals.controller';

@Module({
  imports: [TypeOrmModule.forFeature([RentalVehicle, Booking])],
  controllers: [RentalsController],
  providers: [RentalsService],
  exports: [RentalsService],
})
export class RentalsModule {}
